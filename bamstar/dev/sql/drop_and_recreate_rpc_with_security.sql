-- Drop existing conflicting functions and recreate them with SECURITY DEFINER
-- WARNING: Run on staging first. This will DROP and replace functions; backup if needed.

BEGIN;

-- Drop previous versions to allow changing return types
DROP FUNCTION IF EXISTS public.get_post_commenter_avatars_batch(bigint[], int);
DROP FUNCTION IF EXISTS public.get_post_commenter_avatars(bigint, int);
DROP FUNCTION IF EXISTS public.get_post_recent_interactors_batch(bigint[], int);
DROP FUNCTION IF EXISTS public.get_post_recent_interactors(bigint, int);

-- Recreate get_post_commenter_avatars_batch
CREATE OR REPLACE FUNCTION public.get_post_commenter_avatars_batch(post_ids_in bigint[], limit_in int)
RETURNS TABLE(post_id bigint, profile_img text)
LANGUAGE sql STABLE
SECURITY DEFINER
AS $$
  WITH recent AS (
    SELECT post_id, author_id, MAX(created_at) AS last_comment_at
    FROM public.community_comments
    WHERE post_id = ANY(post_ids_in)
      AND (is_anonymous IS DISTINCT FROM true)
      AND author_id IS NOT NULL
    GROUP BY post_id, author_id
  ), ranked AS (
    SELECT r.post_id, r.author_id, r.last_comment_at,
      ROW_NUMBER() OVER (PARTITION BY r.post_id ORDER BY r.last_comment_at DESC) AS rn
    FROM recent r
  )
  SELECT r.post_id::bigint, u.profile_img
  FROM ranked r
  JOIN public.users u ON u.id = r.author_id
  WHERE r.rn <= GREATEST(1, COALESCE(limit_in, 3))
    AND u.profile_img IS NOT NULL
  ORDER BY r.post_id, r.rn;
$$;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars_batch(bigint[], int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars_batch(bigint[], int) TO authenticated;

-- Recreate get_post_commenter_avatars (single)
CREATE OR REPLACE FUNCTION public.get_post_commenter_avatars(post_id_in bigint, limit_in int)
RETURNS TABLE(profile_img text)
LANGUAGE sql STABLE
SECURITY DEFINER
AS $$
  WITH recent AS (
    SELECT author_id, MAX(created_at) AS last_comment_at
    FROM public.community_comments
    WHERE post_id = post_id_in
      AND (is_anonymous IS DISTINCT FROM true)
      AND author_id IS NOT NULL
    GROUP BY author_id
  )
  SELECT u.profile_img
  FROM recent r
  JOIN public.users u ON u.id = r.author_id
  WHERE u.profile_img IS NOT NULL
  ORDER BY r.last_comment_at DESC
  LIMIT GREATEST(1, COALESCE(limit_in, 3));
$$;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars(bigint, int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars(bigint, int) TO authenticated;

-- Recreate get_post_recent_interactors_batch (likers + commenters merged)
CREATE OR REPLACE FUNCTION public.get_post_recent_interactors_batch(post_ids_in bigint[], limit_in int DEFAULT 3)
RETURNS TABLE(post_id bigint, profile_img text)
LANGUAGE sql STABLE
SECURITY DEFINER
AS $$
WITH
comments_agg AS (
  SELECT post_id, author_id::uuid AS user_id, MAX(created_at) AS last_interaction_at
  FROM public.community_comments
  WHERE post_id = ANY(post_ids_in)
    AND (is_anonymous IS DISTINCT FROM true)
    AND author_id IS NOT NULL
  GROUP BY post_id, author_id
),
likes_agg AS (
  SELECT post_id, user_id::uuid AS user_id, MAX(created_at) AS last_interaction_at
  FROM public.community_likes
  WHERE post_id = ANY(post_ids_in)
    AND user_id IS NOT NULL
  GROUP BY post_id, user_id
),
all_interactions AS (
  SELECT post_id, user_id, last_interaction_at FROM comments_agg
  UNION ALL
  SELECT post_id, user_id, last_interaction_at FROM likes_agg
),
collapsed AS (
  SELECT post_id, user_id, MAX(last_interaction_at) AS last_interaction_at
  FROM all_interactions
  GROUP BY post_id, user_id
),
ranked AS (
  SELECT c.post_id, c.user_id, c.last_interaction_at,
    ROW_NUMBER() OVER (PARTITION BY c.post_id ORDER BY c.last_interaction_at DESC) AS rn
  FROM collapsed c
)
SELECT r.post_id::bigint, u.profile_img
FROM ranked r
JOIN public.users u ON u.id = r.user_id
WHERE r.rn <= GREATEST(1, COALESCE(limit_in, 3))
  AND u.profile_img IS NOT NULL
ORDER BY r.post_id, r.rn;
$$;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors_batch(bigint[], int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors_batch(bigint[], int) TO authenticated;

-- Recreate get_post_recent_interactors (single)
CREATE OR REPLACE FUNCTION public.get_post_recent_interactors(post_id_in bigint, limit_in int DEFAULT 3)
RETURNS TABLE(profile_img text)
LANGUAGE sql STABLE
SECURITY DEFINER
AS $$
  SELECT profile_img FROM public.get_post_recent_interactors_batch(ARRAY[post_id_in]::bigint[], limit_in);
$$;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors(bigint, int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors(bigint, int) TO authenticated;

COMMIT;

-- NOTES:
-- 1) This script DROPs the old functions first to avoid the "cannot change return type" error.
-- 2) If you want to change function ownership, execute ALTER FUNCTION ... OWNER TO <role> as a separate step (after confirming <role> exists and is trusted).
-- 3) Test with:
--    SELECT * FROM public.get_post_commenter_avatars(123, 3);
--    SELECT * FROM public.get_post_commenter_avatars_batch(ARRAY[1,2,3]::bigint[], 3);
--    SELECT * FROM public.get_post_recent_interactors(123, 3);
--    SELECT * FROM public.get_post_recent_interactors_batch(ARRAY[1,2,3]::bigint[], 3);
