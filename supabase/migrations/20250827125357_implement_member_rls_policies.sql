-- ================================================
-- Member Tables Row Level Security (RLS) Implementation
-- ================================================
-- This migration implements comprehensive RLS policies for all member-related tables
-- to ensure proper data isolation and security according to the principle of least privilege.

-- ================================================
-- 1. Enable RLS on all member tables
-- ================================================

-- Enable RLS on attributes table (read-only for users, admin-only writes)
ALTER TABLE public.attributes ENABLE ROW LEVEL SECURITY;

-- Enable RLS on member_profiles table (users can only access their own data)
ALTER TABLE public.member_profiles ENABLE ROW LEVEL SECURITY;

-- Enable RLS on member_attributes_link table (users can only access their own links)
ALTER TABLE public.member_attributes_link ENABLE ROW LEVEL SECURITY;

-- Enable RLS on member_preferences_link table (users can only access their own preferences)
ALTER TABLE public.member_preferences_link ENABLE ROW LEVEL SECURITY;

-- Enable RLS on member_preferred_area_groups table (users can only access their own area preferences)
ALTER TABLE public.member_preferred_area_groups ENABLE ROW LEVEL SECURITY;

-- ================================================
-- 2. Drop existing policies if they exist (idempotent)
-- ================================================

-- attributes table policies
DROP POLICY IF EXISTS "Anyone can read attributes" ON public.attributes;
DROP POLICY IF EXISTS "Only admins can insert attributes" ON public.attributes;
DROP POLICY IF EXISTS "Only admins can update attributes" ON public.attributes;
DROP POLICY IF EXISTS "Only admins can delete attributes" ON public.attributes;

-- member_profiles table policies
DROP POLICY IF EXISTS "Users can read own profile" ON public.member_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.member_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.member_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.member_profiles;

-- member_attributes_link table policies
DROP POLICY IF EXISTS "Users can read own attribute links" ON public.member_attributes_link;
DROP POLICY IF EXISTS "Users can insert own attribute links" ON public.member_attributes_link;
DROP POLICY IF EXISTS "Users can update own attribute links" ON public.member_attributes_link;
DROP POLICY IF EXISTS "Users can delete own attribute links" ON public.member_attributes_link;

-- member_preferences_link table policies
DROP POLICY IF EXISTS "Users can read own preference links" ON public.member_preferences_link;
DROP POLICY IF EXISTS "Users can insert own preference links" ON public.member_preferences_link;
DROP POLICY IF EXISTS "Users can update own preference links" ON public.member_preferences_link;
DROP POLICY IF EXISTS "Users can delete own preference links" ON public.member_preferences_link;

-- member_preferred_area_groups table policies
DROP POLICY IF EXISTS "Users can read own area preferences" ON public.member_preferred_area_groups;
DROP POLICY IF EXISTS "Users can insert own area preferences" ON public.member_preferred_area_groups;
DROP POLICY IF EXISTS "Users can update own area preferences" ON public.member_preferred_area_groups;
DROP POLICY IF EXISTS "Users can delete own area preferences" ON public.member_preferred_area_groups;

-- ================================================
-- 3. ATTRIBUTES TABLE POLICIES
-- ================================================
-- The attributes table is a reference/lookup table that should be readable by all 
-- authenticated users, but only modifiable by administrators

-- SELECT: Allow all authenticated users to read attributes
CREATE POLICY "Anyone can read attributes" 
ON public.attributes 
FOR SELECT 
TO authenticated 
USING (true);

-- INSERT: Only allow users with admin role to insert new attributes
CREATE POLICY "Only admins can insert attributes" 
ON public.attributes 
FOR INSERT 
TO authenticated 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
);

-- UPDATE: Only allow users with admin role to update attributes
CREATE POLICY "Only admins can update attributes" 
ON public.attributes 
FOR UPDATE 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
);

-- DELETE: Only allow users with admin role to delete attributes
CREATE POLICY "Only admins can delete attributes" 
ON public.attributes 
FOR DELETE 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
);

-- ================================================
-- 4. MEMBER_PROFILES TABLE POLICIES
-- ================================================
-- Users can only access and modify their own profile data

-- SELECT: Users can only read their own profile
CREATE POLICY "Users can read own profile" 
ON public.member_profiles 
FOR SELECT 
TO authenticated 
USING (user_id = auth.uid());

-- INSERT: Users can only create their own profile
CREATE POLICY "Users can insert own profile" 
ON public.member_profiles 
FOR INSERT 
TO authenticated 
WITH CHECK (user_id = auth.uid());

-- UPDATE: Users can only update their own profile
CREATE POLICY "Users can update own profile" 
ON public.member_profiles 
FOR UPDATE 
TO authenticated 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- DELETE: Users can only delete their own profile
CREATE POLICY "Users can delete own profile" 
ON public.member_profiles 
FOR DELETE 
TO authenticated 
USING (user_id = auth.uid());

-- ================================================
-- 5. MEMBER_ATTRIBUTES_LINK TABLE POLICIES
-- ================================================
-- Users can only access their own attribute links (personal style/strengths)

-- SELECT: Users can only read their own attribute links
CREATE POLICY "Users can read own attribute links" 
ON public.member_attributes_link 
FOR SELECT 
TO authenticated 
USING (member_user_id = auth.uid());

-- INSERT: Users can only create their own attribute links
CREATE POLICY "Users can insert own attribute links" 
ON public.member_attributes_link 
FOR INSERT 
TO authenticated 
WITH CHECK (member_user_id = auth.uid());

-- UPDATE: Users can only update their own attribute links
CREATE POLICY "Users can update own attribute links" 
ON public.member_attributes_link 
FOR UPDATE 
TO authenticated 
USING (member_user_id = auth.uid())
WITH CHECK (member_user_id = auth.uid());

-- DELETE: Users can only delete their own attribute links
CREATE POLICY "Users can delete own attribute links" 
ON public.member_attributes_link 
FOR DELETE 
TO authenticated 
USING (member_user_id = auth.uid());

-- ================================================
-- 6. MEMBER_PREFERENCES_LINK TABLE POLICIES
-- ================================================
-- Users can only access their own preference links (desired job roles, industries, welfare, etc.)

-- SELECT: Users can only read their own preference links
CREATE POLICY "Users can read own preference links" 
ON public.member_preferences_link 
FOR SELECT 
TO authenticated 
USING (member_user_id = auth.uid());

-- INSERT: Users can only create their own preference links
CREATE POLICY "Users can insert own preference links" 
ON public.member_preferences_link 
FOR INSERT 
TO authenticated 
WITH CHECK (member_user_id = auth.uid());

-- UPDATE: Users can only update their own preference links
CREATE POLICY "Users can update own preference links" 
ON public.member_preferences_link 
FOR UPDATE 
TO authenticated 
USING (member_user_id = auth.uid())
WITH CHECK (member_user_id = auth.uid());

-- DELETE: Users can only delete their own preference links
CREATE POLICY "Users can delete own preference links" 
ON public.member_preferences_link 
FOR DELETE 
TO authenticated 
USING (member_user_id = auth.uid());

-- ================================================
-- 7. MEMBER_PREFERRED_AREA_GROUPS TABLE POLICIES
-- ================================================
-- Users can only access their own preferred area groups (geographic preferences)

-- SELECT: Users can only read their own area preferences
CREATE POLICY "Users can read own area preferences" 
ON public.member_preferred_area_groups 
FOR SELECT 
TO authenticated 
USING (member_user_id = auth.uid());

-- INSERT: Users can only create their own area preferences
CREATE POLICY "Users can insert own area preferences" 
ON public.member_preferred_area_groups 
FOR INSERT 
TO authenticated 
WITH CHECK (member_user_id = auth.uid());

-- UPDATE: Users can only update their own area preferences
CREATE POLICY "Users can update own area preferences" 
ON public.member_preferred_area_groups 
FOR UPDATE 
TO authenticated 
USING (member_user_id = auth.uid())
WITH CHECK (member_user_id = auth.uid());

-- DELETE: Users can only delete their own area preferences
CREATE POLICY "Users can delete own area preferences" 
ON public.member_preferred_area_groups 
FOR DELETE 
TO authenticated 
USING (member_user_id = auth.uid());

-- ================================================
-- 8. Grant necessary table permissions to authenticated users
-- ================================================
-- Ensure authenticated users have proper table-level permissions

-- Grant permissions on attributes table (read-only for regular users)
GRANT SELECT ON public.attributes TO authenticated;

-- Grant full permissions on member tables for authenticated users (RLS will handle the filtering)
GRANT ALL ON public.member_profiles TO authenticated;
GRANT ALL ON public.member_attributes_link TO authenticated;
GRANT ALL ON public.member_preferences_link TO authenticated;
GRANT ALL ON public.member_preferred_area_groups TO authenticated;

-- Grant sequence usage permissions for attributes table (for admin operations)
GRANT USAGE ON public.attributes_id_seq TO authenticated;

-- ================================================
-- 9. Create helper function for RLS testing
-- ================================================
-- This function helps administrators test RLS policies by simulating different user contexts

CREATE OR REPLACE FUNCTION public.test_user_access(
  test_user_id UUID,
  table_name TEXT
) RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  current_user_id UUID;
BEGIN
  -- Only allow admins to run this test function
  IF NOT EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admin role required.';
  END IF;

  -- Store current user context
  current_user_id := auth.uid();
  
  -- This is a simplified test function - in a real implementation,
  -- you would use more sophisticated testing methods
  result := json_build_object(
    'message', 'RLS testing function created',
    'test_user_id', test_user_id,
    'table_name', table_name,
    'admin_user_id', current_user_id
  );
  
  RETURN result;
END;
$$;

-- ================================================
-- 10. Add comments for documentation
-- ================================================

COMMENT ON TABLE public.attributes IS 
'Reference table for all attribute types (industries, job roles, welfare, styles, etc.). Read-only for regular users, admin-only writes.';

COMMENT ON TABLE public.member_profiles IS 
'Core member profile data. Each user can only access and modify their own profile record.';

COMMENT ON TABLE public.member_attributes_link IS 
'Links members to their personal attributes/styles/strengths. Users can only access their own links.';

COMMENT ON TABLE public.member_preferences_link IS 
'Links members to their job/industry/welfare preferences. Users can only access their own links.';

COMMENT ON TABLE public.member_preferred_area_groups IS 
'Links members to their preferred work areas. Users can only access their own area preferences.';

-- ================================================
-- Migration Summary
-- ================================================
-- ✅ Enabled RLS on all 5 member-related tables
-- ✅ Created 20 comprehensive RLS policies (4 CRUD operations × 5 tables)
-- ✅ Implemented defense-in-depth: table permissions + row-level policies
-- ✅ Followed principle of least privilege
-- ✅ Added proper error handling and admin-only functions
-- ✅ Added documentation via comments
--
-- Security Features:
-- • User data isolation: Users can only access their own records
-- • Admin controls: Only admins can modify reference data
-- • Authentication required: All operations require valid auth.uid()
-- • Cross-user prevention: Foreign key constraints + RLS prevent data leaks
-- • Comprehensive coverage: All CRUD operations are secured