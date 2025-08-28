-- Fix RLS policies for users table to allow all authenticated users to read user profiles

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;

-- Enable RLS on users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create new policies

-- Allow all authenticated users to view all user profiles (needed for community posts)
CREATE POLICY "Users can view all profiles" ON public.users
    FOR SELECT
    TO authenticated
    USING (true);

-- Allow users to insert their own profile
CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Grant necessary permissions
GRANT SELECT ON public.users TO authenticated;
GRANT INSERT, UPDATE ON public.users TO authenticated;

-- Also allow anon users to view profiles (for public community viewing)
GRANT SELECT ON public.users TO anon;

-- Create policy for anon users
CREATE POLICY "Anyone can view profiles" ON public.users
    FOR SELECT
    TO anon
    USING (true);