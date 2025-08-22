-- Integrated RPC: return recent interactors (likers + commenters) per post
-- This returns each post's top-N unique interactors ordered by last interaction time (most recent first).
-- NOTE: If your DB uses RLS on `users` or other tables, consider adding SECURITY DEFINER and setting an appropriate owner.

CREATE OR REPLACE FUNCTION public.get_post_recent_interactors_batch(
  post_ids_in bigint[],
  limit_in int DEFAULT 3
)
RETURNS TABLE(post_id bigint, profile_img text)
LANGUAGE sql STABLE
AS $$
WITH
-- Aggregate latest interaction time per (post_id, user_id) from comments (non-anonymous) and likes
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
-- Collapse duplicates (same user may both like and comment) keeping the latest timestamp per (post_id,user_id)
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

-- Single-post convenience wrapper
CREATE OR REPLACE FUNCTION public.get_post_recent_interactors(
  post_id_in bigint,
  limit_in int DEFAULT 3
)
RETURNS TABLE(profile_img text)
LANGUAGE sql STABLE
AS $$
  SELECT profile_img FROM public.get_post_recent_interactors_batch(ARRAY[post_id_in]::bigint[], limit_in);
$$;

-- OPTIONAL: example grants (uncomment and adjust if you want anon role to execute directly)
-- GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors(bigint,int) TO anon;
-- GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors_batch(bigint[],int) TO anon;

-- SECURITY NOTE:
-- If your `users` table has RLS policies preventing direct reads of profile_img from the anon role,
-- consider creating SECURITY DEFINER versions of these functions and setting the function owner to a
-- trusted service role. Be careful with SECURITY DEFINER usage and ensure the function body only
-- exposes the minimal data required.
