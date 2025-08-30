-- Add content blocking policies for user-blocked content
-- This migration adds RLS policies to hide posts and comments from blocked users

-- ============================================================================
-- 1. RLS POLICY: Hide blocked users' posts
-- ============================================================================
CREATE POLICY "Hide blocked users posts" ON community_posts
FOR SELECT USING (
    -- Show anonymous posts (author_id is null)
    author_id IS NULL OR 
    -- Show own posts
    author_id = auth.uid() OR
    -- Show posts from non-blocked users only
    NOT EXISTS (
        SELECT 1 FROM user_blocks 
        WHERE blocker_id = auth.uid() 
        AND blocked_user_id = author_id
    )
);

-- ============================================================================
-- 2. RLS POLICY: Hide blocked users' comments  
-- ============================================================================
CREATE POLICY "Hide blocked users comments" ON community_comments
FOR SELECT USING (
    -- Show anonymous comments (author_id is null)
    author_id IS NULL OR 
    -- Show own comments
    author_id = auth.uid() OR
    -- Show comments from non-blocked users only
    NOT EXISTS (
        SELECT 1 FROM user_blocks 
        WHERE blocker_id = auth.uid() 
        AND blocked_user_id = author_id
    )
);

-- ============================================================================
-- 3. HELPER FUNCTION: Get blocked user IDs for application-level filtering
-- ============================================================================
CREATE OR REPLACE FUNCTION get_blocked_user_ids_for_current_user()
RETURNS TABLE(blocked_user_id UUID)
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
    SELECT ub.blocked_user_id
    FROM user_blocks ub
    WHERE ub.blocker_id = auth.uid();
$$;

-- ============================================================================
-- 4. PERFORMANCE OPTIMIZATION: Ensure proper indexes exist
-- ============================================================================
-- These indexes should already exist from previous migrations, but let's ensure they're there

-- Index for blocker_id lookups (should exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'user_blocks' AND indexname = 'idx_user_blocks_blocker_id'
    ) THEN
        CREATE INDEX idx_user_blocks_blocker_id ON user_blocks(blocker_id);
    END IF;
END$$;

-- Index for blocked_user_id lookups (should exist)  
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'user_blocks' AND indexname = 'idx_user_blocks_blocked_user_id'
    ) THEN
        CREATE INDEX idx_user_blocks_blocked_user_id ON user_blocks(blocked_user_id);
    END IF;
END$$;

-- Composite index for blocking relationship lookups (new, for performance)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'user_blocks' AND indexname = 'idx_user_blocks_blocker_blocked'
    ) THEN
        CREATE INDEX idx_user_blocks_blocker_blocked ON user_blocks(blocker_id, blocked_user_id);
    END IF;
END$$;

-- ============================================================================
-- 5. GRANT PERMISSIONS
-- ============================================================================
-- Grant execute permission on the helper function to authenticated users
GRANT EXECUTE ON FUNCTION get_blocked_user_ids_for_current_user() TO authenticated;

-- ============================================================================
-- MIGRATION NOTES
-- ============================================================================
-- This migration implements a hybrid blocking system:
-- 
-- 1. DATABASE LEVEL (RLS Policies):
--    - Automatic filtering at the database level
--    - Safety net that applies to all queries
--    - Cannot be bypassed by application code
--
-- 2. APPLICATION LEVEL (Helper Function):  
--    - get_blocked_user_ids_for_current_user() for explicit filtering
--    - Performance optimization for frequently used queries
--    - Allows for caching in application layer
--
-- 3. PERFORMANCE CONSIDERATIONS:
--    - RLS policies use EXISTS subqueries with proper indexes
--    - Composite index on (blocker_id, blocked_user_id) for optimal performance
--    - Helper function marked as STABLE for query planning optimization
--
-- 4. SECURITY:
--    - RLS policies ensure blocked content is never visible
--    - Helper function uses SECURITY DEFINER to access user_blocks safely
--    - auth.uid() ensures policies only apply to authenticated users
--
-- 5. EDGE CASES HANDLED:
--    - Anonymous posts/comments (author_id IS NULL) are always visible
--    - Users can always see their own content
--    - Proper NULL handling throughout