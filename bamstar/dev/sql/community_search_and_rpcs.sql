-- SQL helpers for community search and RPCs
-- Add to Supabase SQL editor / pgAdmin and run in public schema

-- 1) Add view_count column if not present
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='community_posts' AND column_name='view_count'
    ) THEN
        ALTER TABLE public.community_posts ADD COLUMN view_count bigint DEFAULT 0;
    END IF;
END$$;

-- 2) Full-text search index using to_tsvector on content (Korean recommended config: 'simple' or 'ko' if an extension is installed)
-- Use pg_trgm for fuzzy LIKE acceleration
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create trigram index for ilike fast substring search
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes WHERE tablename = 'community_posts' AND indexname = 'idx_community_posts_content_trgm'
    ) THEN
        CREATE INDEX idx_community_posts_content_trgm ON public.community_posts USING gin (content gin_trgm_ops);
    END IF;
END$$;

-- 3) RPC: get_post_counts(post_ids_in bigint[])
CREATE OR REPLACE FUNCTION public.get_post_counts(post_ids_in bigint[])
RETURNS TABLE(post_id bigint, likes_count bigint, comments_count bigint)
LANGUAGE sql STABLE
AS $$
    SELECT p.post_id::bigint,
           COALESCE(l.likes_count, 0)::bigint,
           COALESCE(c.comments_count, 0)::bigint
    FROM (
      SELECT unnest(post_ids_in) AS post_id
    ) p
    LEFT JOIN (
      SELECT post_id, COUNT(*) AS likes_count
      FROM public.community_likes
      WHERE post_id = ANY(post_ids_in)
      GROUP BY post_id
    ) l ON l.post_id = p.post_id
    LEFT JOIN (
      SELECT post_id, COUNT(*) AS comments_count
      FROM public.community_comments
      WHERE post_id = ANY(post_ids_in)
      GROUP BY post_id
    ) c ON c.post_id = p.post_id;
$$;

-- 4) RPC: get_user_liked_posts(post_ids_in bigint[]) -> rows of post_id
CREATE OR REPLACE FUNCTION public.get_user_liked_posts(post_ids_in bigint[])
RETURNS TABLE(post_id bigint)
LANGUAGE plpgsql STABLE SECURITY DEFINER
AS $$
DECLARE
  uid uuid := current_setting('jwt.claims.user_id', true)::uuid;
BEGIN
  IF uid IS NULL THEN
    RETURN;
  END IF;
  RETURN QUERY
  SELECT post_id::bigint FROM public.community_likes
  WHERE user_id = uid AND post_id = ANY(post_ids_in);
END$$;

-- 5) RPC: increment_post_view(post_id_in bigint) -> new_count bigint
CREATE OR REPLACE FUNCTION public.increment_post_view(post_id_in bigint)
RETURNS TABLE(new_count bigint)
LANGUAGE sql VOLATILE
AS $$
  UPDATE public.community_posts
  SET view_count = COALESCE(view_count,0) + 1
  WHERE id = post_id_in
  RETURNING view_count AS new_count;
$$;

-- 6) RPC: get_post_commenter_avatars_batch(post_ids_in bigint[], limit_in int)
CREATE OR REPLACE FUNCTION public.get_post_commenter_avatars_batch(post_ids_in bigint[], limit_in int)
RETURNS TABLE(post_id bigint, profile_img text)
LANGUAGE sql STABLE
AS $$
  SELECT c.post_id::bigint, u.profile_img
  FROM (
    SELECT DISTINCT ON (post_id, author_id) post_id, author_id
    FROM public.community_comments
    WHERE post_id = ANY(post_ids_in) AND (is_anonymous IS DISTINCT FROM true)
    ORDER BY post_id, created_at DESC
  ) c
  JOIN public.users u ON u.id = c.author_id
  WHERE u.profile_img IS NOT NULL
  ORDER BY c.post_id, u.id
  LIMIT GREATEST(1, COALESCE(limit_in, 3));
$$;

-- 7) RPC: get_post_commenter_avatars(post_id_in bigint, limit_in int)
CREATE OR REPLACE FUNCTION public.get_post_commenter_avatars(post_id_in bigint, limit_in int)
RETURNS TABLE(profile_img text)
LANGUAGE sql STABLE
AS $$
  SELECT u.profile_img
  FROM (
    SELECT DISTINCT ON (author_id) author_id
    FROM public.community_comments
    WHERE post_id = post_id_in AND (is_anonymous IS DISTINCT FROM true)
    ORDER BY created_at DESC
    LIMIT COALESCE(limit_in, 3)
  ) c
  JOIN public.users u ON u.id = c.author_id
  WHERE u.profile_img IS NOT NULL;
$$;

-- 8) RPC: get_top_posts_by_metric(window_days integer, metric text, limit_val integer, offset_val integer)
-- Returns posts ordered by `metric` ("comments" or "likes") within the recent window (days).
-- Use this RPC from clients when showing "인기 순" / "좋아요 순" to get correct top-N pagination.
-- If a previous version of this function exists with a different
-- OUT/RETURN type, CREATE OR REPLACE cannot change the row type.
-- Drop the function first to allow recreation (safe if no dependent
-- objects rely on the exact row type). The line below makes the
-- SQL idempotent for redeploys.
DROP FUNCTION IF EXISTS public.get_top_posts_by_metric(integer, text, integer, integer);

CREATE OR REPLACE FUNCTION public.get_top_posts_by_metric(
  window_days integer DEFAULT 7,
  metric text DEFAULT 'comments',
  limit_val integer DEFAULT 20,
  offset_val integer DEFAULT 0
) RETURNS TABLE(
  id bigint,
  author_id uuid,
  content text,
  is_anonymous boolean,
  image_urls text[],
  view_count bigint,
  created_at timestamptz,
  likes_count bigint,
  comments_count bigint
) LANGUAGE sql STABLE
AS $$
WITH windowed_posts AS (
  SELECT p.*, p.id AS post_id
  FROM public.community_posts p
  WHERE (window_days IS NULL) OR (p.created_at >= now() - (window_days || ' days')::interval)
),
agg AS (
  Slower(metric) = 'comments' THEN a.comments_count
       ELSE a.comments_count END DESC,
  a.created_at DESC
LIMIT GREATEST(1, COALESCE(limit_val, 20))
OFFSET GREATEST(0, COALESCE(offset_val, 0));
$$;

-- Recommended indexes to accelerate metric/time-window queries
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'community_comments' AND indexname = 'idx_community_comments_post_created_at') THEN
    CREATE INDEX idx_community_comments_post_created_at ON public.community_comments (post_id, created_at);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'community_likes' AND indexname = 'idx_community_likes_post_created_at') THEN
    CREATE INDEX idx_community_likes_post_created_at ON public.community_likes (post_id, created_at);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'community_posts' AND indexname = 'idx_community_posts_created_at') THEN
    CREATE INDEX idx_community_posts_created_at ON public.community_posts (created_at);
  END IF;
END$$;
ELECT wp.id AS id,
         wp.author_id,
         wp.content,
         wp.is_anonymous,
         wp.image_urls,
         wp.view_count,
         wp.created_at,
         COALESCE(l.likes_count, 0)::bigint AS likes_count,
         COALESCE(c.comments_count, 0)::bigint AS comments_count
  FROM windowed_posts wp
  LEFT JOIN (
    SELECT post_id, COUNT(*)::bigint AS likes_count
    FROM public.community_likes
    WHERE post_id IS NOT NULL
    GROUP BY post_id
  ) l ON l.post_id = wp.id
  LEFT JOIN (
    SELECT post_id, COUNT(*)::bigint AS comments_count
    FROM public.community_comments
    WHERE post_id IS NOT NULL
    GROUP BY post_id
  ) c ON c.post_id = wp.id
)
SELECT a.id, a.author_id, a.content, a.is_anonymous, a.image_urls, a.view_count, a.created_at,
       a.likes_count, a.comments_count
FROM agg a
ORDER BY
  CASE WHEN lower(metric) = 'likes' THEN a.likes_count
       WHEN 
-- End of script
