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

-- End of script
