import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface HeartsRequest {
  action: 'send' | 'accept' | 'reject' | 'check_mutual'
  fromUserId: string
  toUserId: string
  userType: 'member' | 'place'
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { action, fromUserId, toUserId, userType }: HeartsRequest = await req.json()
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    switch (action) {
      case 'send': {
        const table = userType === 'member' ? 'member_hearts' : 'place_hearts'
        const fromColumn = userType === 'member' ? 'member_user_id' : 'place_user_id'
        const toColumn = userType === 'member' ? 'place_user_id' : 'member_user_id'
        
        // Check if already sent
        const { data: existing } = await supabase
          .from(table)
          .select('*')
          .eq(fromColumn, fromUserId)
          .eq(toColumn, toUserId)
          .single()
        
        if (existing) {
          return new Response(
            JSON.stringify({ message: 'Already sent', heart: existing }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          )
        }
        
        // Insert new heart
        const { data: heart, error } = await supabase
          .from(table)
          .insert({
            [fromColumn]: fromUserId,
            [toColumn]: toUserId,
            status: 'pending'
          })
          .select()
          .single()
        
        if (error) throw error
        
        // Check for mutual match
        const oppositeTable = userType === 'member' ? 'place_hearts' : 'member_hearts'
        const { data: oppositeHeart } = await supabase
          .from(oppositeTable)
          .select('*')
          .eq(userType === 'member' ? 'place_user_id' : 'member_user_id', toUserId)
          .eq(userType === 'member' ? 'member_user_id' : 'place_user_id', fromUserId)
          .single()
        
        if (oppositeHeart) {
          // Auto-accept both for mutual match
          await Promise.all([
            supabase.from(table).update({ status: 'accepted' }).eq('id', heart.id),
            supabase.from(oppositeTable).update({ status: 'accepted' }).eq('id', oppositeHeart.id)
          ])
          
          return new Response(
            JSON.stringify({ 
              success: true,
              mutual: true,
              message: '상호 매칭 성립! 채팅이 활성화되었습니다.',
              heart
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          )
        }
        
        return new Response(
          JSON.stringify({ 
            success: true,
            mutual: false,
            message: '좋아요를 보냈습니다.',
            heart
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      case 'accept': {
        const table = userType === 'member' ? 'place_hearts' : 'member_hearts'
        const fromColumn = userType === 'member' ? 'place_user_id' : 'member_user_id'
        const toColumn = userType === 'member' ? 'member_user_id' : 'place_user_id'
        
        const { data: heart, error } = await supabase
          .from(table)
          .update({ status: 'accepted' })
          .eq(fromColumn, toUserId)
          .eq(toColumn, fromUserId)
          .select()
          .single()
        
        if (error) throw error
        
        // Auto send heart back for mutual match
        const myTable = userType === 'member' ? 'member_hearts' : 'place_hearts'
        const myFromColumn = userType === 'member' ? 'member_user_id' : 'place_user_id'
        const myToColumn = userType === 'member' ? 'place_user_id' : 'member_user_id'
        
        await supabase
          .from(myTable)
          .upsert({
            [myFromColumn]: fromUserId,
            [myToColumn]: toUserId,
            status: 'accepted'
          })
        
        return new Response(
          JSON.stringify({ 
            success: true,
            message: '좋아요를 수락했습니다. 매칭이 성립되었습니다!',
            heart
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      case 'reject': {
        const table = userType === 'member' ? 'place_hearts' : 'member_hearts'
        const fromColumn = userType === 'member' ? 'place_user_id' : 'member_user_id'
        const toColumn = userType === 'member' ? 'member_user_id' : 'place_user_id'
        
        const { data: heart, error } = await supabase
          .from(table)
          .update({ status: 'rejected' })
          .eq(fromColumn, toUserId)
          .eq(toColumn, fromUserId)
          .select()
          .single()
        
        if (error) throw error
        
        return new Response(
          JSON.stringify({ 
            success: true,
            message: '좋아요를 거절했습니다.',
            heart
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      case 'check_mutual': {
        const { data: mutual } = await supabase
          .from('mutual_matches')
          .select('*')
          .or(`member_user_id.eq.${fromUserId},member_user_id.eq.${toUserId}`)
          .or(`place_user_id.eq.${fromUserId},place_user_id.eq.${toUserId}`)
          .single()
        
        return new Response(
          JSON.stringify({ 
            isMutualMatch: !!mutual,
            matchDetails: mutual
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      default:
        throw new Error('Invalid action')
    }
    
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