-- ===================================================================
-- 기존 테이블 구조에 맞춘 해시태그 자동화 RPC 함수들
-- ===================================================================

-- 1. 배치 해시태그 통계 업데이트 함수 (기존 구조에 맞춤)
CREATE OR REPLACE FUNCTION batch_upsert_hashtag_stats(
  hashtag_names text[],
  updated_at timestamptz DEFAULT now()
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  tag_name text;
BEGIN
  -- 각 해시태그에 대해 UPSERT 실행
  FOREACH tag_name IN ARRAY hashtag_names
  LOOP
    INSERT INTO community_hashtags (name, post_count, subscriber_count, last_used_at, created_at)
    VALUES (lower(tag_name), 1, 0, updated_at, updated_at)
    ON CONFLICT (name) 
    DO UPDATE SET 
      post_count = community_hashtags.post_count + 1,
      last_used_at = updated_at;
  END LOOP;
END;
$$;

-- 2. 해시태그 트렌드 분석 함수 (기존 구조 사용)
CREATE OR REPLACE FUNCTION analyze_hashtag_trends(
  days_back integer DEFAULT 7,
  min_usage_count integer DEFAULT 2
)
RETURNS TABLE(
  hashtag_name text,
  usage_count bigint,
  trend_score numeric,
  category text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH hashtag_stats AS (
    SELECT 
      h.name,
      h.post_count::bigint as usage_count,
      h.last_used_at,
      CASE 
        WHEN h.last_used_at > (now() - interval '1 day') THEN 3.0
        WHEN h.last_used_at > (now() - interval '3 days') THEN 2.0
        WHEN h.last_used_at > (now() - interval '7 days') THEN 1.5
        ELSE 1.0
      END as recency_multiplier,
      COALESCE(h.category, 'general') as auto_category
    FROM community_hashtags h
    WHERE h.post_count >= min_usage_count
      AND (h.last_used_at IS NULL OR h.last_used_at > (now() - interval concat(days_back, ' days')::text))
  )
  SELECT 
    s.name::text,
    s.usage_count,
    (s.usage_count * s.recency_multiplier)::numeric as trend_score,
    s.auto_category::text
  FROM hashtag_stats s
  ORDER BY trend_score DESC, s.usage_count DESC;
END;
$$;

-- 3. 해시태그 추천 함수 (간단한 버전)
CREATE OR REPLACE FUNCTION recommend_hashtags_for_content(
  content_text text,
  max_recommendations integer DEFAULT 5
)
RETURNS TABLE(
  hashtag_name text,
  relevance_score numeric,
  usage_count bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  content_keywords text[];
BEGIN
  -- 간단한 키워드 추출
  content_keywords := string_to_array(lower(regexp_replace(content_text, '[^가-힣a-zA-Z0-9\s]', ' ', 'g')), ' ');
  
  RETURN QUERY
  WITH hashtag_matches AS (
    SELECT DISTINCT
      h.name,
      h.post_count::bigint,
      CASE 
        WHEN h.name = ANY(content_keywords) THEN 10.0
        WHEN EXISTS(
          SELECT 1 FROM unnest(content_keywords) as k 
          WHERE h.name ILIKE '%' || k || '%' OR k ILIKE '%' || h.name || '%'
        ) THEN 5.0
        ELSE 1.0
      END as base_score
    FROM community_hashtags h
    WHERE h.post_count > 0
      AND (
        h.name = ANY(content_keywords)
        OR EXISTS(
          SELECT 1 FROM unnest(content_keywords) as k 
          WHERE h.name ILIKE '%' || k || '%' OR k ILIKE '%' || h.name || '%'
        )
      )
  )
  SELECT 
    m.name::text,
    (m.base_score * log(m.post_count + 1))::numeric as relevance_score,
    m.post_count
  FROM hashtag_matches m
  ORDER BY relevance_score DESC, m.post_count DESC
  LIMIT max_recommendations;
END;
$$;

-- 4. 해시태그 검색 함수
CREATE OR REPLACE FUNCTION search_hashtags(
  search_term text,
  limit_count integer DEFAULT 10
)
RETURNS TABLE(
  hashtag_name text,
  usage_count bigint,
  last_used timestamptz,
  match_type text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    h.name::text,
    h.post_count::bigint,
    h.last_used_at,
    CASE 
      WHEN h.name = lower(search_term) THEN 'exact'
      WHEN h.name LIKE lower(search_term) || '%' THEN 'prefix'
      WHEN h.name LIKE '%' || lower(search_term) || '%' THEN 'contains'
      ELSE 'fuzzy'
    END::text as match_type
  FROM community_hashtags h
  WHERE h.name ILIKE '%' || lower(search_term) || '%'
  ORDER BY 
    CASE 
      WHEN h.name = lower(search_term) THEN 1
      WHEN h.name LIKE lower(search_term) || '%' THEN 2
      WHEN h.name LIKE '%' || lower(search_term) || '%' THEN 3
      ELSE 4
    END,
    h.post_count DESC,
    h.last_used_at DESC NULLS LAST
  LIMIT limit_count;
END;
$$;

-- 5. 인기 해시태그 조회 함수
CREATE OR REPLACE FUNCTION get_trending_hashtags(
  limit_count integer DEFAULT 10,
  days_back integer DEFAULT 7
)
RETURNS TABLE(
  hashtag_name text,
  post_count integer,
  last_used_at timestamptz,
  category text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    h.name::text,
    h.post_count,
    h.last_used_at,
    COALESCE(h.category, 'general')::text
  FROM community_hashtags h
  WHERE h.post_count > 0
    AND (h.last_used_at IS NULL OR h.last_used_at > (now() - interval concat(days_back, ' days')::text))
  ORDER BY h.post_count DESC, h.last_used_at DESC NULLS LAST
  LIMIT limit_count;
END;
$$;

-- 권한 설정
GRANT EXECUTE ON FUNCTION batch_upsert_hashtag_stats TO authenticated, anon;
GRANT EXECUTE ON FUNCTION analyze_hashtag_trends TO authenticated, anon;
GRANT EXECUTE ON FUNCTION recommend_hashtags_for_content TO authenticated, anon;
GRANT EXECUTE ON FUNCTION search_hashtags TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_trending_hashtags TO authenticated, anon;