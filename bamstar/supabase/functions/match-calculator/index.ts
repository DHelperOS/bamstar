import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface MatchCalculationRequest {
  memberId: string
  placeId: string
  forceRecalculate?: boolean
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { memberId, placeId, forceRecalculate = false }: MatchCalculationRequest = await req.json()
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    // 1. 캐시 확인
    if (!forceRecalculate) {
      const { data: cached } = await supabase
        .from('matching_scores')
        .select('*')
        .eq('member_user_id', memberId)
        .eq('place_user_id', placeId)
        .gte('expires_at', new Date().toISOString())
        .single()
      
      if (cached) {
        return new Response(
          JSON.stringify({ cached: true, score: cached }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }
    
    // 2. 점수 계산 (SQL 함수 호출)
    const { data: jobScore } = await supabase.rpc('calculate_job_role_match_score', {
      p_member_id: memberId,
      p_place_id: placeId
    })
    
    const { data: industryScore } = await supabase.rpc('calculate_industry_match_score', {
      p_member_id: memberId,
      p_place_id: placeId
    })
    
    const { data: styleScore } = await supabase.rpc('calculate_style_match_score', {
      p_member_id: memberId,
      p_place_id: placeId
    })
    
    const { data: locationScore } = await supabase.rpc('calculate_location_match_score', {
      p_member_id: memberId,
      p_place_id: placeId
    })
    
    const { data: payScore } = await supabase.rpc('calculate_pay_match_score', {
      p_member_id: memberId,
      p_place_id: placeId
    })
    
    const { data: welfareBonus } = await supabase.rpc('calculate_welfare_bonus_score', {
      p_member_id: memberId,
      p_place_id: placeId
    })
    
    // 3. 사용자별 가중치 가져오기 (없으면 기본값)
    const { data: userWeights } = await supabase
      .from('matching_weights')
      .select('*')
      .eq('user_id', memberId)
      .single()
    
    const weights = {
      job_role: userWeights?.job_role_weight || 0.40,
      industry: userWeights?.industry_weight || 0.20,
      style: userWeights?.style_weight || 0.15,
      location: userWeights?.location_weight || 0.15,
      pay: userWeights?.pay_weight || 0.10
    }
    
    const totalScore = 
      (jobScore || 0) * weights.job_role +
      (industryScore || 0) * weights.industry +
      (styleScore || 0) * weights.style +
      (locationScore || 0) * weights.location +
      (payScore || 0) * weights.pay +
      (welfareBonus || 0)
    
    // 4. 결과 저장
    const scoreData = {
      member_user_id: memberId,
      place_user_id: placeId,
      total_score: Math.min(100, totalScore),
      job_role_score: jobScore || 0,
      industry_score: industryScore || 0,
      style_score: styleScore || 0,
      location_score: locationScore || 0,
      pay_score: payScore || 0,
      welfare_bonus: welfareBonus || 0,
      calculated_at: new Date().toISOString(),
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
    }
    
    const { data: saved, error } = await supabase
      .from('matching_scores')
      .upsert(scoreData)
      .select()
      .single()
    
    if (error) throw error
    
    return new Response(
      JSON.stringify({ cached: false, score: saved }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})