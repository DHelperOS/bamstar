import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface HashtagProcessorPayload {
  post_id: string;
  content: string;
  hashtags: string[];
  user_id: string;
}

interface HashtagAnalysis {
  extracted_hashtags: string[];
  recommended_hashtags: string[];
  trending_hashtags: string[];
  category_suggestions: string[];
}

/**
 * 해시태그 자동 처리 Edge Function
 * - 새 포스트 생성 시 자동으로 호출
 * - 해시태그 추출, 추천, 통계 업데이트 수행
 */
Deno.serve(async (req: Request) => {
  try {
    // CORS 헤더 설정
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
    };

    // OPTIONS 요청 처리
    if (req.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }

    // POST 요청만 허용
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        {
          status: 405,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 요청 본문 파싱
    const payload: HashtagProcessorPayload = await req.json();
    const { post_id, content, hashtags, user_id } = payload;

    if (!post_id || !content) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: post_id, content" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Supabase 클라이언트 초기화
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 해시태그 분석 시작
    console.log(`Processing hashtags for post ${post_id}`);
    
    // 1. 기존 해시태그 정규화 및 통계 업데이트
    const normalizedHashtags = hashtags.map(tag => tag.toLowerCase().trim()).filter(tag => tag.length > 0);
    
    if (normalizedHashtags.length > 0) {
      const { error: batchError } = await supabase.rpc('batch_upsert_hashtag_stats', {
        hashtag_names: normalizedHashtags,
        updated_at: new Date().toISOString()
      });
      
      if (batchError) {
        console.error('Failed to batch update hashtag stats:', batchError);
      } else {
        console.log(`Updated stats for ${normalizedHashtags.length} hashtags`);
      }
    }

    // 2. 콘텐츠 기반 해시태그 추천
    const { data: recommendedHashtags, error: recommendError } = await supabase.rpc(
      'recommend_hashtags_for_content',
      {
        content_text: content,
        max_recommendations: 5
      }
    );

    if (recommendError) {
      console.error('Failed to get hashtag recommendations:', recommendError);
    }

    // 3. 현재 트렌딩 해시태그 조회
    const { data: trendingHashtags, error: trendError } = await supabase.rpc(
      'analyze_hashtag_trends',
      {
        days_back: 7,
        min_usage_count: 3
      }
    );

    if (trendError) {
      console.error('Failed to get trending hashtags:', trendError);
    }

    // 4. 카테고리별 인기 해시태그 추천
    const categoryHashtags = await getCategoryRecommendations(supabase, content);

    // 5. 해시태그 분석 결과 구성
    const analysis: HashtagAnalysis = {
      extracted_hashtags: normalizedHashtags,
      recommended_hashtags: recommendedHashtags?.slice(0, 5).map(h => h.hashtag_name) || [],
      trending_hashtags: trendingHashtags?.slice(0, 5).map(h => h.hashtag_name) || [],
      category_suggestions: categoryHashtags
    };

    // 6. 분석 결과를 별도 테이블에 저장 (선택사항)
    const { error: saveError } = await supabase
      .from('hashtag_analysis_logs')
      .insert({
        post_id,
        user_id,
        analysis_data: analysis,
        processed_at: new Date().toISOString()
      });

    if (saveError && saveError.code !== '42P01') { // 테이블이 없을 수 있음
      console.warn('Failed to save analysis log:', saveError);
    }

    console.log(`Hashtag processing completed for post ${post_id}`);

    // 응답 반환
    return new Response(
      JSON.stringify({
        success: true,
        post_id,
        analysis,
        processed_at: new Date().toISOString()
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );

  } catch (error) {
    console.error('Hashtag processor error:', error);
    
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        message: error.message
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
});

/**
 * 콘텐츠 분석을 통한 카테고리별 해시태그 추천
 */
async function getCategoryRecommendations(
  supabase: any,
  content: string
): Promise<string[]> {
  try {
    // 간단한 키워드 기반 카테고리 분류
    const categories = {
      food: ['음식', '맛집', '요리', '레시피', '먹방', '디저트', '카페'],
      travel: ['여행', '관광', '휴가', '여행지', '호텔', '항공', '패키지'],
      health: ['운동', '헬스', '건강', '다이어트', '피트니스', '요가'],
      fashion: ['패션', '스타일', '옷', '코디', '뷰티', '화장품'],
      tech: ['기술', '개발', 'IT', '프로그래밍', '앱', '소프트웨어'],
      daily: ['일상', '생활', '소소한', '데일리', '오늘', '하루']
    };

    const detectedCategories: string[] = [];
    
    for (const [category, keywords] of Object.entries(categories)) {
      if (keywords.some(keyword => content.toLowerCase().includes(keyword))) {
        detectedCategories.push(category);
      }
    }

    if (detectedCategories.length === 0) {
      return [];
    }

    // 감지된 카테고리의 인기 해시태그 조회
    const { data: categoryHashtags, error } = await supabase
      .from('community_hashtags')
      .select('name, usage_count')
      .or(detectedCategories.map(cat => `name.like.%${cat}%`).join(','))
      .order('usage_count', { ascending: false })
      .limit(3);

    if (error) {
      console.error('Failed to get category recommendations:', error);
      return [];
    }

    return categoryHashtags?.map(h => h.name) || [];
  } catch (error) {
    console.error('Error in category recommendations:', error);
    return [];
  }
}