-- Fix place_profiles RLS policies
-- Users can only access their own place profile data

-- Enable RLS (already enabled, but ensure it's on)
ALTER TABLE place_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can select their own place profile
CREATE POLICY "Users can view their own place profile" ON place_profiles
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own place profile  
CREATE POLICY "Users can insert their own place profile" ON place_profiles
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own place profile
CREATE POLICY "Users can update their own place profile" ON place_profiles
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own place profile
CREATE POLICY "Users can delete their own place profile" ON place_profiles
  FOR DELETE
  USING (auth.uid() = user_id);