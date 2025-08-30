import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface MatchFinderRequest {
  userId: string
  userType: 'member' | 'place'
  limit?: number
  offset?: number
  minScore?: number
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { 
      userId, 
      userType,
      limit = 20,
      offset = 0,
      minScore = 60
    }: MatchFinderRequest = await req.json()
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    // Build query based on user type - simplified without deep joins
    let query = supabase
      .from('matching_scores')
      .select(`
        *,
        member:users!member_user_id(
          id, email,
          member_profile:member_profiles(*)
        ),
        place:users!place_user_id(
          id, email,
          place_profile:place_profiles(*)
        )
      `)
      .gte('expires_at', new Date().toISOString())
      .gte('total_score', minScore)
      .order('total_score', { ascending: false })
      .range(offset, offset + limit - 1)
    
    if (userType === 'member') {
      query = query.eq('member_user_id', userId)
    } else {
      query = query.eq('place_user_id', userId)
    }
    
    const { data: matches, error } = await query
    
    if (error) throw error
    
    // Get member attributes and preferences data separately
    const memberIds = matches.map(m => m.member_user_id)
    
    const { data: memberAttributes } = await supabase
      .from('member_attributes_link')
      .select(`
        member_user_id,
        attributes:attributes(
          name,
          type
        )
      `)
      .in('member_user_id', memberIds)
    
    const { data: memberPreferences } = await supabase
      .from('member_preferences_link')
      .select(`
        member_user_id,
        attributes:attributes(
          name,
          type
        )
      `)
      .in('member_user_id', memberIds)

    const { data: memberAreas } = await supabase
      .from('member_preferred_area_groups')
      .select(`
        member_user_id,
        priority,
        area_groups:area_groups(name)
      `)
      .in('member_user_id', memberIds)
    
    // Check for hearts and favorites status
    const targetIds = matches.map(m => 
      userType === 'member' ? m.place_user_id : m.member_user_id
    )
    
    // Get hearts status
    const heartsTable = userType === 'member' ? 'member_hearts' : 'place_hearts'
    const { data: hearts } = await supabase
      .from(heartsTable)
      .select('*')
      .eq(userType === 'member' ? 'member_user_id' : 'place_user_id', userId)
      .in(userType === 'member' ? 'place_user_id' : 'member_user_id', targetIds)
    
    // Get favorites status
    const favoritesTable = userType === 'member' ? 'member_favorites' : 'place_favorites'
    const { data: favorites } = await supabase
      .from(favoritesTable)
      .select('*')
      .eq(userType === 'member' ? 'member_user_id' : 'place_user_id', userId)
      .in(userType === 'member' ? 'place_user_id' : 'member_user_id', targetIds)
    
    // Enrich matches with interaction status and member data
    const enrichedMatches = matches.map(match => {
      const targetId = userType === 'member' ? match.place_user_id : match.member_user_id
      const heart = hearts?.find(h => 
        (userType === 'member' ? h.place_user_id : h.member_user_id) === targetId
      )
      const favorite = favorites?.find(f => 
        (userType === 'member' ? f.place_user_id : f.member_user_id) === targetId
      )
      
      // Add member attributes and preferences
      const memberAttrs = memberAttributes?.filter(attr => 
        attr.member_user_id === match.member_user_id
      )
      const memberPrefs = memberPreferences?.filter(pref => 
        pref.member_user_id === match.member_user_id
      )
      const memberAreasList = memberAreas?.filter(area => 
        area.member_user_id === match.member_user_id
      )
      
      return {
        ...match,
        member: {
          ...match.member,
          member_attributes: memberAttrs || [],
          member_preferences: memberPrefs || [],
          member_areas: memberAreasList || []
        },
        has_sent_heart: !!heart,
        heart_status: heart?.status,
        is_favorited: !!favorite,
        favorite_notes: favorite?.notes
      }
    })
    
    return new Response(
      JSON.stringify({
        matches: enrichedMatches,
        total: matches.length,
        hasMore: matches.length === limit
      }),
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