import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface CurationResult {
  trending_hashtags: Array<{
    name: string;
    usage_count: number;
    trend_score: number;
    category: string;
  }>;
  cleanup_stats: {
    deleted_count: number;
    cleanup_date: string;
  };
  ai_suggestions: string[];
  processed_at: string;
}

/**
 * 일일 해시태그 큐레이션 Edge Function
 * - 매일 실행되는 스케줄드 함수
 * - 트렌드 분석, 정리, AI 기반 추천 수행
 */
Deno.serve(async (req: Request) => {
  try {
    // CORS 헤더 설정
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    };

    // OPTIONS 요청 처리
    if (req.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }

    console.log('Daily hashtag curation started at:', new Date().toISOString());

    // Supabase 클라이언트 초기화
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 1. 현재 트렌드 분석
    console.log('Analyzing hashtag trends...');
    const { data: trendingHashtags, error: trendError } = await supabase.rpc(
      'analyze_hashtag_trends',
      {
        days_back: 7,
        min_usage_count: 2
      }
    );

    if (trendError) {
      console.error('Failed to analyze trends:', trendError);
      throw trendError;
    }

    console.log(`Found ${trendingHashtags?.length || 0} trending hashtags`);

    // 2. 미사용 해시태그 정리
    console.log('Cleaning up unused hashtags...');
    const { data: cleanupResult, error: cleanupError } = await supabase.rpc(
      'cleanup_unused_hashtags',
      {
        unused_days: 30,
        min_usage_threshold: 1
      }
    );

    if (cleanupError) {
      console.error('Failed to cleanup hashtags:', cleanupError);
      throw cleanupError;
    }

    const cleanupStats = cleanupResult?.[0] || { deleted_count: 0, cleanup_date: new Date().toISOString() };
    console.log(`Cleaned up ${cleanupStats.deleted_count} unused hashtags`);

    // 3. AI 기반 해시태그 추천 (Google Gemini 사용)
    console.log('Generating AI-based hashtag suggestions...');
    const aiSuggestions = await generateAISuggestions(trendingHashtags?.slice(0, 10) || []);

    // 4. 큐레이션 결과 구성
    const curationResult: CurationResult = {
      trending_hashtags: trendingHashtags?.slice(0, 20) || [],
      cleanup_stats: cleanupStats,
      ai_suggestions: aiSuggestions,
      processed_at: new Date().toISOString()
    };

    // 5. 큐레이션 결과를 데이터베이스에 저장
    const { error: saveError } = await supabase
      .from('daily_hashtag_curation')
      .insert({
        curation_date: new Date().toISOString().split('T')[0], // YYYY-MM-DD 형식
        trending_hashtags: curationResult.trending_hashtags,
        cleanup_stats: curationResult.cleanup_stats,
        ai_suggestions: curationResult.ai_suggestions,
        created_at: new Date().toISOString()
      });

    if (saveError && saveError.code !== '42P01') { // 테이블이 없을 수 있음
      console.warn('Failed to save curation result:', saveError);
    }

    // 6. 트렌딩 해시태그 캐시 업데이트 (Redis나 별도 테이블에 저장)
    await updateTrendingCache(supabase, curationResult.trending_hashtags.slice(0, 10));

    console.log('Daily hashtag curation completed successfully');

    // 응답 반환
    return new Response(
      JSON.stringify({
        success: true,
        result: curationResult
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );

  } catch (error) {
    console.error('Daily curation error:', error);
    
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
 * Google Gemini API를 사용한 AI 해시태그 추천
 */
async function generateAISuggestions(
  trendingHashtags: Array<{ hashtag_name: string; usage_count: number; category: string }>
): Promise<string[]> {
  try {
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
    
    if (!geminiApiKey) {
      console.warn('GEMINI_API_KEY not found, skipping AI suggestions');
      return [];
    }

    // 현재 트렌딩 해시태그를 분석하여 새로운 추천 생성
    const trendingList = trendingHashtags.map(h => `${h.hashtag_name} (${h.category})`).join(', ');
    
    const prompt = `
현재 한국의 소셜미디어에서 인기있는 해시태그들입니다:
${trendingList}

이 트렌드를 바탕으로 다음 조건에 맞는 새로운 해시태그 5개를 추천해주세요:
1. 한국어로 된 해시태그
2. 현재 트렌드와 연관성이 있으면서 새로운 키워드
3. 젊은 세대가 사용할 만한 트렌디한 표현
4. 2-4글자의 짧고 기억하기 쉬운 형태
5. 실제로 사용할 가능성이 높은 해시태그

답변은 해시태그만 쉼표로 구분해서 작성해주세요. (#은 제외)
`;

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${geminiApiKey}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: prompt
                }
              ]
            }
          ],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 200,
          }
        })
      }
    );

    if (!response.ok) {
      throw new Error(`Gemini API error: ${response.status}`);
    }

    const data = await response.json();
    const generatedText = data.candidates?.[0]?.content?.parts?.[0]?.text || "";
    
    // 응답에서 해시태그 추출
    const suggestions = generatedText
      .split(',')
      .map(tag => tag.trim().replace(/^#/, ''))
      .filter(tag => tag.length > 0 && tag.length <= 10)
      .slice(0, 5);

    console.log(`Generated ${suggestions.length} AI hashtag suggestions:`, suggestions);
    return suggestions;

  } catch (error) {
    console.error('Error generating AI suggestions:', error);
    return [];
  }
}

/**
 * 트렌딩 해시태그 캐시 업데이트
 */
async function updateTrendingCache(
  supabase: any,
  trendingHashtags: Array<{ hashtag_name: string; usage_count: number; trend_score: number }>
): Promise<void> {
  try {
    // 트렌딩 해시태그 캐시 테이블 업데이트
    const { error } = await supabase
      .from('trending_hashtags_cache')
      .upsert({
        cache_key: 'current_trending',
        hashtags: trendingHashtags,
        updated_at: new Date().toISOString(),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24시간 후 만료
      });

    if (error && error.code !== '42P01') {
      console.warn('Failed to update trending cache:', error);
    } else {
      console.log('Trending hashtags cache updated successfully');
    }
  } catch (error) {
    console.error('Error updating trending cache:', error);
  }
}