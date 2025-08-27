import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface UpdateMatchingConditionsRequest {
  bio?: string;
  desired_pay_type?: string;
  desired_pay_amount?: number;
  desired_working_days?: string[];
  experience_level?: string;
  selected_style_attribute_ids?: number[];
  selected_preference_attribute_ids?: number[];
  selected_area_group_ids?: number[];
}

interface MatchingConditions {
  MUST_HAVE: string[];
  ENVIRONMENT: {
    workplace_features: string[];
    location_preferences: string[];
  };
  PEOPLE: {
    team_dynamics: string[];
    communication_style: string[];
  };
  AVOID: string[];
}

interface ApiResponse {
  success: boolean;
  message?: string;
  error?: string;
}

Deno.serve(async (req: Request): Promise<Response> => {
  try {
    // 1. Authentication and Authorization
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ success: false, error: '인증 토큰이 필요합니다.' }),
        { 
          status: 401, 
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    const token = authHeader.replace('Bearer ', '');
    
    // Initialize Supabase client with service role
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
      global: {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    });

    // Verify JWT token and get user
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ success: false, error: '유효하지 않은 인증 토큰입니다.' }),
        { 
          status: 401, 
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Check if user role is MEMBER
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single();

    if (userError || userData?.role !== 'MEMBER') {
      return new Response(
        JSON.stringify({ success: false, error: '멤버 권한이 필요합니다.' }),
        { 
          status: 403, 
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Parse request body
    const requestBody: UpdateMatchingConditionsRequest = await req.json();

    // 2. Start Transaction and Update Database
    const { data, error } = await supabase.rpc('update_member_profile_and_conditions', {
      p_user_id: user.id,
      p_bio: requestBody.bio || null,
      p_desired_pay_type: requestBody.desired_pay_type || null,
      p_desired_pay_amount: requestBody.desired_pay_amount || null,
      p_desired_working_days: requestBody.desired_working_days || null,
      p_experience_level: requestBody.experience_level || null,
      p_style_attribute_ids: requestBody.selected_style_attribute_ids || [],
      p_preference_attribute_ids: requestBody.selected_preference_attribute_ids || [],
      p_area_group_ids: requestBody.selected_area_group_ids || []
    });

    if (error) {
      console.error('Database update error:', error);
      return new Response(
        JSON.stringify({ success: false, error: '데이터 업데이트 중 오류가 발생했습니다.' }),
        { 
          status: 500, 
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // 3. Load updated data for matching conditions generation
    const { data: profileData, error: profileError } = await supabase
      .from('member_profiles')
      .select(`
        bio,
        desired_pay_type,
        desired_pay_amount,
        desired_working_days,
        experience_level
      `)
      .eq('user_id', user.id)
      .single();

    if (profileError) {
      console.error('Profile fetch error:', profileError);
      return new Response(
        JSON.stringify({ success: false, error: '프로필 조회 중 오류가 발생했습니다.' }),
        { 
          status: 500, 
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Load attributes with details
    const { data: attributesData, error: attributesError } = await supabase
      .from('member_attributes_link')
      .select(`
        attributes!inner(
          name,
          category,
          type
        )
      `)
      .eq('member_user_id', user.id);

    if (attributesError) {
      console.error('Attributes fetch error:', attributesError);
      return new Response(
        JSON.stringify({ success: false, error: '속성 조회 중 오류가 발생했습니다.' }),
        { 
          status: 500, 
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Load preferences with details
    const { data: preferencesData, error: preferencesError } = await supabase
      .from('member_preferences_link')
      .select(`
        attributes!inner(
          name,
          category,
          type
        )
      `)
      .eq('member_user_id', user.id);

    if (preferencesError) {
      console.error('Preferences fetch error:', preferencesError);
      return new Response(
        JSON.stringify({ success: false, error: '선호도 조회 중 오류가 발생했습니다.' }),
        { 
          status: 500, 
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Load area groups
    const { data: areasData, error: areasError } = await supabase
      .from('member_preferred_area_groups')
      .select(`
        area_groups!inner(
          name,
          region
        )
      `)
      .eq('member_user_id', user.id);

    if (areasError) {
      console.error('Areas fetch error:', areasError);
    }

    // 4. Generate matching conditions JSON
    const matchingConditions = generateMatchingConditions(
      profileData,
      attributesData || [],
      preferencesData || [],
      areasData || []
    );

    // 5. Save matching conditions back to database
    const { error: updateError } = await supabase
      .from('member_profiles')
      .update({ matching_conditions: matchingConditions })
      .eq('user_id', user.id);

    if (updateError) {
      console.error('Matching conditions update error:', updateError);
      return new Response(
        JSON.stringify({ success: false, error: '매칭 조건 저장 중 오류가 발생했습니다.' }),
        { 
          status: 500, 
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Return success response
    const response: ApiResponse = {
      success: true,
      message: '매칭 조건이 성공적으로 업데이트되었습니다.'
    };

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({ success: false, error: '예상치 못한 오류가 발생했습니다.' }),
      { 
        status: 500, 
        headers: { 'Content-Type': 'application/json' }
      }
    );
  }
});

function generateMatchingConditions(
  profile: any,
  attributes: any[],
  preferences: any[],
  areas: any[]
): MatchingConditions {
  const conditions: MatchingConditions = {
    MUST_HAVE: [],
    ENVIRONMENT: {
      workplace_features: [],
      location_preferences: []
    },
    PEOPLE: {
      team_dynamics: [],
      communication_style: []
    },
    AVOID: []
  };

  // Add pay type and amount to MUST_HAVE
  if (profile.desired_pay_type && profile.desired_pay_amount) {
    const payTypeText = getPayTypeText(profile.desired_pay_type);
    conditions.MUST_HAVE.push(`페이: ${payTypeText} ${profile.desired_pay_amount.toLocaleString()}원`);
  } else if (profile.desired_pay_type) {
    const payTypeText = getPayTypeText(profile.desired_pay_type);
    conditions.MUST_HAVE.push(`페이: ${payTypeText}`);
  }

  // Add working days to MUST_HAVE
  if (profile.desired_working_days && profile.desired_working_days.length > 0) {
    conditions.MUST_HAVE.push(`근무일: ${profile.desired_working_days.join(', ')}`);
  }

  // Add experience level to MUST_HAVE
  if (profile.experience_level) {
    const experienceText = getExperienceLevelText(profile.experience_level);
    conditions.MUST_HAVE.push(`경력: ${experienceText}`);
  }

  // Process attributes
  for (const attr of attributes) {
    const attribute = attr.attributes;
    
    switch (attribute.category) {
      case 'AVOID':
        conditions.AVOID.push(attribute.name);
        break;
      case 'ENVIRONMENT':
        conditions.ENVIRONMENT.workplace_features.push(attribute.name);
        break;
      case 'PEOPLE':
        if (attribute.type === 'TEAM_DYNAMICS') {
          conditions.PEOPLE.team_dynamics.push(attribute.name);
        } else {
          conditions.PEOPLE.communication_style.push(attribute.name);
        }
        break;
      default:
        // Style attributes go to PEOPLE.communication_style
        conditions.PEOPLE.communication_style.push(attribute.name);
        break;
    }
  }

  // Process preferences
  for (const pref of preferences) {
    const preference = pref.attributes;
    
    switch (preference.type) {
      case 'INDUSTRY':
      case 'JOB_ROLE':
        conditions.MUST_HAVE.push(preference.name);
        break;
      case 'PLACE_FEATURE':
        conditions.ENVIRONMENT.workplace_features.push(preference.name);
        break;
      case 'WELFARE':
        conditions.ENVIRONMENT.workplace_features.push(preference.name);
        break;
    }
  }

  // Process area groups
  for (const area of areas) {
    const areaGroup = area.area_groups;
    conditions.ENVIRONMENT.location_preferences.push(`${areaGroup.region} ${areaGroup.name}`);
  }

  return conditions;
}

function getPayTypeText(payType: string): string {
  switch (payType) {
    case 'TC':
      return 'TC';
    case 'DAILY':
      return '일급';
    case 'MONTHLY':
      return '월급';
    case 'NEGOTIABLE':
      return '협의';
    default:
      return payType;
  }
}

function getExperienceLevelText(level: string): string {
  switch (level) {
    case 'NEWBIE':
      return '신입';
    case 'JUNIOR':
      return '주니어';
    case 'SENIOR':
      return '시니어';
    case 'EXPERT':
      return '전문가';
    default:
      return level;
  }
}