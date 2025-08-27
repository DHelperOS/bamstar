-- ================================================
-- RLS Policy Test & Validation Script
-- ================================================
-- This script helps validate that the RLS policies are working correctly
-- Run this after applying the RLS migration to verify security

-- ================================================
-- Test 1: Verify RLS is enabled on all tables
-- ================================================
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled,
  forcerowsecurity as force_rls
FROM pg_tables 
WHERE tablename IN (
  'attributes',
  'member_profiles', 
  'member_attributes_link',
  'member_preferences_link',
  'member_preferred_area_groups'
)
AND schemaname = 'public'
ORDER BY tablename;

-- ================================================
-- Test 2: List all RLS policies
-- ================================================
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename IN (
  'attributes',
  'member_profiles', 
  'member_attributes_link',
  'member_preferences_link',
  'member_preferred_area_groups'
)
AND schemaname = 'public'
ORDER BY tablename, cmd, policyname;

-- ================================================
-- Test 3: Verify table permissions
-- ================================================
SELECT 
  table_schema,
  table_name,
  grantee,
  privilege_type
FROM information_schema.table_privileges
WHERE table_name IN (
  'attributes',
  'member_profiles', 
  'member_attributes_link',
  'member_preferences_link',
  'member_preferred_area_groups'
)
AND table_schema = 'public'
AND grantee = 'authenticated'
ORDER BY table_name, privilege_type;

-- ================================================
-- Test 4: Mock data insertion for testing
-- ================================================
-- Note: This should be run by an authenticated user to test the policies

-- Insert test attributes (should work for admins only)
/*
INSERT INTO public.attributes (type, type_kor, name, description) VALUES 
('TEST_TYPE', 'テスト', 'test_attribute', 'RLS test attribute');
*/

-- Insert test member profile (should work for the authenticated user)
/*
INSERT INTO public.member_profiles (user_id, nickname, bio) 
VALUES (auth.uid(), 'test_user_' || auth.uid()::text, 'RLS test profile');
*/

-- Insert test attribute link (should work for the authenticated user)
/*
INSERT INTO public.member_attributes_link (member_user_id, attribute_id)
SELECT auth.uid(), id FROM public.attributes LIMIT 1;
*/

-- ================================================
-- Test 5: Cross-user access validation
-- ================================================
-- These queries should return empty results for non-admin users
-- when testing with a different user's data

-- Test: Try to access another user's profile (should return nothing)
/*
SELECT * FROM public.member_profiles 
WHERE user_id != auth.uid()
LIMIT 1;
*/

-- Test: Try to access another user's attributes (should return nothing)
/*
SELECT * FROM public.member_attributes_link 
WHERE member_user_id != auth.uid()
LIMIT 1;
*/

-- ================================================
-- Test 6: Admin privilege validation
-- ================================================
-- Check if current user has admin role
SELECT 
  id,
  email,
  role,
  CASE 
    WHEN role = 'admin' THEN 'Has admin privileges'
    ELSE 'Regular user - limited access'
  END as access_level
FROM public.users 
WHERE id = auth.uid();

-- ================================================
-- Test 7: Policy effectiveness summary
-- ================================================
-- Create a summary of what each policy should accomplish

SELECT 'RLS Policy Test Summary' as test_name,
       'The following should be true after RLS implementation:' as description
UNION ALL
SELECT 'attributes table', 'All authenticated users can READ, only admins can INSERT/UPDATE/DELETE'
UNION ALL
SELECT 'member_profiles table', 'Users can only CRUD their own profile (user_id = auth.uid())'
UNION ALL
SELECT 'member_attributes_link table', 'Users can only CRUD their own links (member_user_id = auth.uid())'
UNION ALL
SELECT 'member_preferences_link table', 'Users can only CRUD their own preferences (member_user_id = auth.uid())'
UNION ALL
SELECT 'member_preferred_area_groups table', 'Users can only CRUD their own area preferences (member_user_id = auth.uid())'
UNION ALL
SELECT 'Cross-user protection', 'Users cannot access data belonging to other users'
UNION ALL
SELECT 'Authentication requirement', 'All operations require valid auth.uid() - anonymous users blocked';

-- ================================================
-- Instructions for manual testing
-- ================================================

/*
MANUAL TESTING STEPS:

1. Apply the RLS migration first:
   supabase db push

2. Run this validation script:
   supabase db reset --local
   supabase migration up
   
3. Test as regular user:
   - Sign in as a non-admin user
   - Try to read from attributes table (should work)
   - Try to insert into attributes table (should fail)
   - Create own member profile (should work)
   - Try to access another user's profile (should return empty)

4. Test as admin user:
   - Sign in as admin user
   - Try all operations on attributes table (should work)
   - Verify you can still only see your own member data

5. Test authentication requirement:
   - Try operations without being signed in (should fail)
   - Verify all operations require valid auth.uid()

6. Verify policy names and structure:
   - Check that all 20 policies exist (4 CRUD × 5 tables)
   - Verify descriptive naming convention
   - Check that USING and WITH CHECK clauses match

EXPECTED RESULTS:
✅ All tables have RLS enabled
✅ 20 total policies created (4 per table × 5 tables)
✅ Users can only access their own data
✅ Attributes table is read-only for regular users
✅ Admin users can manage attributes table
✅ Anonymous users are blocked from all operations
✅ No cross-user data leakage possible
*/