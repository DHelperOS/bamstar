-- ALTER / SECURITY DEFINER / GRANT script for RPCs that read users.profile_img
-- Usage: Review and replace <SERVICE_ROLE> with your trusted DB role (e.g. postgres or service_role).
-- Run this in a superuser or owner context. Creating SECURITY DEFINER functions and changing owner
-- requires appropriate privileges.

-- IMPORTANT:
-- 1) Replace <SERVICE_ROLE> with the DB role you want to own these functions (e.g. "postgres" or "service_role").
-- 2) Review bodies to ensure they match your security expectations; SECURITY DEFINER runs with the function owner's privileges.
-- 3) After running, consider removing any broader grants if you prefer to expose execution only to specific roles.

BEGIN;

-- === get_post_commenter_avatars_batch (SECURITY DEFINER) ===
CREATE OR REPLACE FUNCTION public.get_post_commenter_avatars_batch(post_ids_in bigint[], limit_in int)
RETURNS TABLE(post_id bigint, profile_img text)
LANGUAGE sql STABLE
SECURITY DEFINER
AS $$
  WITH recent AS (
    -- get last comment time per (post_id, author_id)
    SELECT post_id, author_id, MAX(created_at) AS last_comment_at
    FROM public.community_comments
    WHERE post_id = ANY(post_ids_in)
      AND (is_anonymous IS DISTINCT FROM true)
      AND author_id IS NOT NULL
    GROUP BY post_id, author_id
  ), ranked AS (
    SELECT
      r.post_id,
      r.author_id,
      r.last_comment_at,
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
-- TODO: Optionally set function owner to a trusted role. Replace <SERVICE_ROLE> and run the ALTER manually
-- Example: ALTER FUNCTION public.get_post_commenter_avatars_batch(bigint[], int) OWNER TO service_role;
-- ALTER FUNCTION public.get_post_commenter_avatars_batch(bigint[], int) OWNER TO <SERVICE_ROLE>;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars_batch(bigint[], int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars_batch(bigint[], int) TO authenticated;

-- === get_post_commenter_avatars (single-post) (SECURITY DEFINER) ===
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
-- TODO: Optionally set function owner to a trusted role. Replace <SERVICE_ROLE> and run the ALTER manually
-- Example: ALTER FUNCTION public.get_post_commenter_avatars(bigint, int) OWNER TO service_role;
-- ALTER FUNCTION public.get_post_commenter_avatars(bigint, int) OWNER TO <SERVICE_ROLE>;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars(bigint, int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars(bigint, int) TO authenticated;

-- === get_post_recent_interactors_batch (likers + commenters) (SECURITY DEFINER) ===
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
  SELECT
    c.post_id,
    c.user_id,
    c.last_interaction_at,
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
-- TODO: Optionally set function owner to a trusted role. Replace <SERVICE_ROLE> and run the ALTER manually
-- Example: ALTER FUNCTION public.get_post_recent_interactors_batch(bigint[], int) OWNER TO service_role;
-- ALTER FUNCTION public.get_post_recent_interactors_batch(bigint[], int) OWNER TO <SERVICE_ROLE>;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors_batch(bigint[], int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors_batch(bigint[], int) TO authenticated;

-- === get_post_recent_interactors (single-post) (SECURITY DEFINER) ===
CREATE OR REPLACE FUNCTION public.get_post_recent_interactors(post_id_in bigint, limit_in int DEFAULT 3)
RETURNS TABLE(profile_img text)
LANGUAGE sql STABLE
SECURITY DEFINER
AS $$
  SELECT profile_img FROM public.get_post_recent_interactors_batch(ARRAY[post_id_in]::bigint[], limit_in);
$$;
-- TODO: Optionally set function owner to a trusted role. Replace <SERVICE_ROLE> and run the ALTER manually
-- Example: ALTER FUNCTION public.get_post_recent_interactors(bigint, int) OWNER TO service_role;
-- ALTER FUNCTION public.get_post_recent_interactors(bigint, int) OWNER TO <SERVICE_ROLE>;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors(bigint, int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors(bigint, int) TO authenticated;

COMMIT;

-- NOTES:
-- - Replace <SERVICE_ROLE> before executing.
-- - Running this will re-create the functions with SECURITY DEFINER. Ensure the function owner role is secure.
-- - If you prefer not to change owner, remove ALTER FUNCTION ... OWNER TO lines and run as a role that already owns the functions.
