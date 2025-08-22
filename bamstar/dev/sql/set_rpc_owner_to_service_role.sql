-- Safely set OWNER of RPC functions to `service_role` if the role exists.
-- Run this as a superuser in staging first. It will ALTER FUNCTION OWNER only when the role exists.

BEGIN;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    RAISE NOTICE 'service_role exists, altering function owners...';
    EXECUTE 'ALTER FUNCTION public.get_post_commenter_avatars_batch(bigint[], int) OWNER TO service_role';
    EXECUTE 'ALTER FUNCTION public.get_post_commenter_avatars(bigint, int) OWNER TO service_role';
    EXECUTE 'ALTER FUNCTION public.get_post_recent_interactors_batch(bigint[], int) OWNER TO service_role';
    EXECUTE 'ALTER FUNCTION public.get_post_recent_interactors(bigint, int) OWNER TO service_role';
  ELSE
    RAISE NOTICE 'service_role does not exist, skipping OWNER changes';
  END IF;
END$$;

-- Re-grant execute to anon/authenticated just in case
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars_batch(bigint[], int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars_batch(bigint[], int) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars(bigint, int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_commenter_avatars(bigint, int) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors_batch(bigint[], int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors_batch(bigint[], int) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors(bigint, int) TO anon;
GRANT EXECUTE ON FUNCTION public.get_post_recent_interactors(bigint, int) TO authenticated;

COMMIT;

-- NOTES:
-- If you want to use a different role name, edit the script and replace 'service_role' accordingly before running.
-- This script assumes the functions already exist (created by previous scripts). If they do not, run the create script first.
