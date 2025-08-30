import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface SchedulerRequest {
  batchSize?: number
  priority?: number
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Cron job 또는 수동 트리거
    const { batchSize = 100, priority = null }: SchedulerRequest = await req.json().catch(() => ({}))
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    // 1. 대기열에서 처리할 항목 가져오기
    let query = supabase
      .from('matching_queue')
      .select('*')
      .eq('status', 'pending')
      .order('priority', { ascending: false })
      .order('queued_at')
      .limit(batchSize)
    
    if (priority !== null) {
      query = query.eq('priority', priority)
    }
    
    const { data: queueItems, error } = await query
    
    if (error) throw error
    if (!queueItems || queueItems.length === 0) {
      return new Response(JSON.stringify({ 
        message: 'No items to process',
        processed: 0,
        successful: 0,
        failed: 0
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    
    // 2. 항목들을 processing 상태로 변경
    const itemIds = queueItems.map(item => item.id)
    await supabase
      .from('matching_queue')
      .update({ 
        status: 'processing',
        started_at: new Date().toISOString()
      })
      .in('id', itemIds)
    
    // 3. 배치 처리
    const results = await Promise.allSettled(
      queueItems.map(item => processQueueItem(supabase, item))
    )
    
    // 4. 결과 업데이트
    const successful = results.filter(r => r.status === 'fulfilled').length
    const failed = results.filter(r => r.status === 'rejected').length
    
    // 성공한 항목 업데이트
    const successIds = queueItems
      .filter((_, i) => results[i].status === 'fulfilled')
      .map(item => item.id)
    
    if (successIds.length > 0) {
      await supabase
        .from('matching_queue')
        .update({ 
          status: 'completed',
          completed_at: new Date().toISOString()
        })
        .in('id', successIds)
    }
    
    // 실패한 항목 업데이트
    const failedItems = queueItems
      .filter((_, i) => results[i].status === 'rejected')
      .map((item, i) => ({
        id: item.id,
        error: (results.find((r, idx) => idx === i && r.status === 'rejected') as PromiseRejectedResult)?.reason?.message || 'Unknown error',
        retry_count: item.retry_count || 0
      }))
    
    for (const failedItem of failedItems) {
      await supabase
        .from('matching_queue')
        .update({ 
          status: 'failed',
          error_message: failedItem.error,
          retry_count: failedItem.retry_count + 1
        })
        .eq('id', failedItem.id)
    }
    
    return new Response(JSON.stringify({
      processed: queueItems.length,
      successful,
      failed,
      details: results.map((result, i) => ({
        itemId: queueItems[i].id,
        userId: queueItems[i].user_id,
        status: result.status,
        error: result.status === 'rejected' ? result.reason?.message : null
      }))
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
    
  } catch (error) {
    return new Response(JSON.stringify({ 
      error: error.message,
      processed: 0,
      successful: 0,
      failed: 1
    }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})

// 개별 큐 항목 처리
async function processQueueItem(supabase: any, item: any) {
  console.log(`Processing queue item: ${item.id} for user: ${item.user_id} (${item.user_type})`)
  
  // 사용자 타입에 따라 매칭 대상 결정
  const targetTable = item.user_type === 'member' ? 'place_profiles' : 'member_profiles'
  
  // 매칭 대상 조회 (이미 매칭된 것 제외)
  const { data: targets, error: targetsError } = await supabase
    .from(targetTable)
    .select('user_id')
    .limit(20)  // 각 사용자당 20개씩 계산
  
  if (targetsError) throw targetsError
  if (!targets || targets.length === 0) {
    return { userId: item.user_id, matched: 0, message: 'No targets found' }
  }
  
  // 이미 계산된 매칭 제외
  const existingColumn = item.user_type === 'member' ? 'member_user_id' : 'place_user_id'
  const targetColumn = item.user_type === 'member' ? 'place_user_id' : 'member_user_id'
  
  const { data: existing } = await supabase
    .from('matching_scores')
    .select(targetColumn)
    .eq(existingColumn, item.user_id)
  
  const existingIds = existing?.map(e => e[targetColumn]) || []
  const newTargets = targets.filter(t => !existingIds.includes(t.user_id))
  
  if (newTargets.length === 0) {
    return { userId: item.user_id, matched: 0, message: 'All targets already calculated' }
  }
  
  // 각 대상과의 매칭 점수 계산
  let successCount = 0
  const calculations = newTargets.map(async (target) => {
    try {
      const memberId = item.user_type === 'member' ? item.user_id : target.user_id
      const placeId = item.user_type === 'place' ? item.user_id : target.user_id
      
      const response = await fetch(`${Deno.env.get('SUPABASE_URL')}/functions/v1/match-calculator`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('SUPABASE_ANON_KEY')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ memberId, placeId })
      })
      
      if (response.ok) {
        successCount++
        return { success: true, memberId, placeId }
      } else {
        const errorText = await response.text()
        console.warn(`Match calculation failed for ${memberId}-${placeId}: ${errorText}`)
        return { success: false, memberId, placeId, error: errorText }
      }
    } catch (error) {
      console.error(`Match calculation error: ${error.message}`)
      return { success: false, error: error.message }
    }
  })
  
  await Promise.all(calculations)
  
  return { 
    userId: item.user_id, 
    matched: successCount,
    total: newTargets.length,
    message: `Generated ${successCount}/${newTargets.length} matching scores`
  }
}