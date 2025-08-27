-- ==========[ BamStar - Member Tables RLS Policies ]==========
-- Comprehensive Row Level Security implementation for member-related tables

-- 1. Enable RLS on all member tables
ALTER TABLE public.attributes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_attributes_link ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_preferences_link ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_preferred_area_groups ENABLE ROW LEVEL SECURITY;

-- ==========[ ATTRIBUTES TABLE POLICIES ]==========
-- Everyone can read attributes, only admins can modify

-- Allow all authenticated users to read attributes
CREATE POLICY "Anyone can read attributes" ON public.attributes
    FOR SELECT USING (auth.role() = 'authenticated');

-- Only users with admin role can insert/update/delete attributes
CREATE POLICY "Only admins can insert attributes" ON public.attributes
    FOR INSERT WITH CHECK (
        auth.role() = 'authenticated' AND 
        EXISTS (
            SELECT 1 FROM public.users u 
            JOIN public.roles r ON u.role_id = r.id 
            WHERE u.id = auth.uid() AND r.name = 'ADMIN'
        )
    );

CREATE POLICY "Only admins can update attributes" ON public.attributes
    FOR UPDATE USING (
        auth.role() = 'authenticated' AND 
        EXISTS (
            SELECT 1 FROM public.users u 
            JOIN public.roles r ON u.role_id = r.id 
            WHERE u.id = auth.uid() AND r.name = 'ADMIN'
        )
    );

CREATE POLICY "Only admins can delete attributes" ON public.attributes
    FOR DELETE USING (
        auth.role() = 'authenticated' AND 
        EXISTS (
            SELECT 1 FROM public.users u 
            JOIN public.roles r ON u.role_id = r.id 
            WHERE u.id = auth.uid() AND r.name = 'ADMIN'
        )
    );

-- ==========[ MEMBER_PROFILES TABLE POLICIES ]==========
-- Users can only access their own profile data

-- Users can read their own profile
CREATE POLICY "Users can read own profile" ON public.member_profiles
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile" ON public.member_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.member_profiles
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own profile
CREATE POLICY "Users can delete own profile" ON public.member_profiles
    FOR DELETE USING (auth.uid() = user_id);

-- ==========[ MEMBER_ATTRIBUTES_LINK TABLE POLICIES ]==========
-- Users can only access their own attribute links

-- Users can read their own attribute links
CREATE POLICY "Users can read own attributes" ON public.member_attributes_link
    FOR SELECT USING (auth.uid() = member_user_id);

-- Users can insert their own attribute links
CREATE POLICY "Users can insert own attributes" ON public.member_attributes_link
    FOR INSERT WITH CHECK (auth.uid() = member_user_id);

-- Users can update their own attribute links
CREATE POLICY "Users can update own attributes" ON public.member_attributes_link
    FOR UPDATE USING (auth.uid() = member_user_id);

-- Users can delete their own attribute links
CREATE POLICY "Users can delete own attributes" ON public.member_attributes_link
    FOR DELETE USING (auth.uid() = member_user_id);

-- ==========[ MEMBER_PREFERENCES_LINK TABLE POLICIES ]==========
-- Users can only access their own preference links

-- Users can read their own preference links
CREATE POLICY "Users can read own preferences" ON public.member_preferences_link
    FOR SELECT USING (auth.uid() = member_user_id);

-- Users can insert their own preference links
CREATE POLICY "Users can insert own preferences" ON public.member_preferences_link
    FOR INSERT WITH CHECK (auth.uid() = member_user_id);

-- Users can update their own preference links
CREATE POLICY "Users can update own preferences" ON public.member_preferences_link
    FOR UPDATE USING (auth.uid() = member_user_id);

-- Users can delete their own preference links
CREATE POLICY "Users can delete own preferences" ON public.member_preferences_link
    FOR DELETE USING (auth.uid() = member_user_id);

-- ==========[ MEMBER_PREFERRED_AREA_GROUPS TABLE POLICIES ]==========
-- Users can only access their own area preferences

-- Users can read their own area preferences
CREATE POLICY "Users can read own area preferences" ON public.member_preferred_area_groups
    FOR SELECT USING (auth.uid() = member_user_id);

-- Users can insert their own area preferences
CREATE POLICY "Users can insert own area preferences" ON public.member_preferred_area_groups
    FOR INSERT WITH CHECK (auth.uid() = member_user_id);

-- Users can update their own area preferences
CREATE POLICY "Users can update own area preferences" ON public.member_preferred_area_groups
    FOR UPDATE USING (auth.uid() = member_user_id);

-- Users can delete their own area preferences
CREATE POLICY "Users can delete own area preferences" ON public.member_preferred_area_groups
    FOR DELETE USING (auth.uid() = member_user_id);

-- ==========[ SECURITY VALIDATION ]==========
-- Additional security measures

-- Ensure member_profiles.user_id cannot be changed after creation
CREATE OR REPLACE FUNCTION prevent_user_id_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.user_id != NEW.user_id THEN
        RAISE EXCEPTION 'Cannot change user_id in member_profiles';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to prevent user_id changes
DROP TRIGGER IF EXISTS prevent_member_profile_user_id_change ON public.member_profiles;
CREATE TRIGGER prevent_member_profile_user_id_change
    BEFORE UPDATE ON public.member_profiles
    FOR EACH ROW
    EXECUTE FUNCTION prevent_user_id_change();

-- ==========[ GRANT PERMISSIONS ]==========
-- Ensure proper table permissions

-- Grant usage on sequences
GRANT USAGE ON SEQUENCE public.attributes_id_seq TO authenticated;

-- Grant table permissions
GRANT SELECT ON public.attributes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.member_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.member_attributes_link TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.member_preferences_link TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.member_preferred_area_groups TO authenticated;

-- ==========[ POLICY TESTING QUERIES ]==========
-- These queries can be used to test the RLS policies

/*
-- Test as authenticated user:
SELECT * FROM public.attributes; -- Should work for all users
SELECT * FROM public.member_profiles; -- Should only show current user's profile
SELECT * FROM public.member_attributes_link; -- Should only show current user's links
SELECT * FROM public.member_preferences_link; -- Should only show current user's preferences

-- Test insert (should only work for current user's data):
INSERT INTO public.member_profiles (user_id, nickname) 
VALUES (auth.uid(), 'Test User');

-- Test unauthorized access (should fail):
INSERT INTO public.member_profiles (user_id, nickname) 
VALUES ('00000000-0000-0000-0000-000000000000', 'Unauthorized');
*/