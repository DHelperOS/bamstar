#!/bin/bash

# Database connection details
DB_HOST="aws-1-ap-northeast-2.pooler.supabase.com"
DB_PORT="6543"
DB_NAME="postgres"
DB_USER="postgres.tflvicpgyycvhttctcek"
DB_PASSWORD="!@Wnrsmsek1"

# Apply RLS policies
echo "Applying RLS policies..."

# Use psql with inline SQL
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" << 'EOF'

-- Enable RLS for Place tables
ALTER TABLE place_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE place_attributes_link ENABLE ROW LEVEL SECURITY;
ALTER TABLE place_preferences_link ENABLE ROW LEVEL SECURITY;
ALTER TABLE place_industries ENABLE ROW LEVEL SECURITY;

-- Enable RLS for Hearts tables
ALTER TABLE member_hearts ENABLE ROW LEVEL SECURITY;
ALTER TABLE place_hearts ENABLE ROW LEVEL SECURITY;

-- Enable RLS for Favorites tables
ALTER TABLE member_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE place_favorites ENABLE ROW LEVEL SECURITY;

-- Enable RLS for Matching tables
ALTER TABLE matching_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE matching_weights ENABLE ROW LEVEL SECURITY;
ALTER TABLE matching_filters ENABLE ROW LEVEL SECURITY;
ALTER TABLE matching_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE matching_history ENABLE ROW LEVEL SECURITY;

-- Create policies for place_profiles
CREATE POLICY IF NOT EXISTS "Users can view all place profiles"
ON place_profiles FOR SELECT
USING (true);

CREATE POLICY IF NOT EXISTS "Users can update own place profile"
ON place_profiles FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can insert own place profile"
ON place_profiles FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can delete own place profile"
ON place_profiles FOR DELETE
USING (auth.uid() = user_id);

-- Create policies for place_attributes_link
CREATE POLICY IF NOT EXISTS "Users can view all place attributes"
ON place_attributes_link FOR SELECT
USING (true);

CREATE POLICY IF NOT EXISTS "Users can manage own place attributes"
ON place_attributes_link FOR ALL
USING (auth.uid() = place_user_id);

-- Create policies for place_preferences_link
CREATE POLICY IF NOT EXISTS "Users can view all place preferences"
ON place_preferences_link FOR SELECT
USING (true);

CREATE POLICY IF NOT EXISTS "Users can manage own place preferences"
ON place_preferences_link FOR ALL
USING (auth.uid() = place_user_id);

-- Create policies for place_industries
CREATE POLICY IF NOT EXISTS "Users can view all place industries"
ON place_industries FOR SELECT
USING (true);

CREATE POLICY IF NOT EXISTS "Users can manage own place industries"
ON place_industries FOR ALL
USING (auth.uid() = place_user_id);

-- Create policies for member_hearts
CREATE POLICY IF NOT EXISTS "Members can send hearts"
ON member_hearts FOR INSERT
WITH CHECK (auth.uid() = member_user_id);

CREATE POLICY IF NOT EXISTS "Users can view hearts related to them"
ON member_hearts FOR SELECT
USING (auth.uid() = member_user_id OR auth.uid() = place_user_id);

CREATE POLICY IF NOT EXISTS "Members can update own hearts"
ON member_hearts FOR UPDATE
USING (auth.uid() = member_user_id);

CREATE POLICY IF NOT EXISTS "Members can delete own hearts"
ON member_hearts FOR DELETE
USING (auth.uid() = member_user_id);

-- Create policies for place_hearts
CREATE POLICY IF NOT EXISTS "Places can send hearts"
ON place_hearts FOR INSERT
WITH CHECK (auth.uid() = place_user_id);

CREATE POLICY IF NOT EXISTS "Users can view hearts related to them"
ON place_hearts FOR SELECT
USING (auth.uid() = place_user_id OR auth.uid() = member_user_id);

CREATE POLICY IF NOT EXISTS "Places can update own hearts"
ON place_hearts FOR UPDATE
USING (auth.uid() = place_user_id);

CREATE POLICY IF NOT EXISTS "Places can delete own hearts"
ON place_hearts FOR DELETE
USING (auth.uid() = place_user_id);

-- Create policies for member_favorites
CREATE POLICY IF NOT EXISTS "Members can manage own favorites"
ON member_favorites FOR ALL
USING (auth.uid() = member_user_id);

-- Create policies for place_favorites
CREATE POLICY IF NOT EXISTS "Places can manage own favorites"
ON place_favorites FOR ALL
USING (auth.uid() = place_user_id);

-- Create policies for matching_scores
CREATE POLICY IF NOT EXISTS "Users can view own matching scores"
ON matching_scores FOR SELECT
USING (auth.uid() = member_user_id OR auth.uid() = place_user_id);

CREATE POLICY IF NOT EXISTS "Service role can manage matching scores"
ON matching_scores FOR ALL
USING (auth.role() = 'service_role');

-- Create policies for matching_weights
CREATE POLICY IF NOT EXISTS "Users can manage own weights"
ON matching_weights FOR ALL
USING (auth.uid() = user_id);

-- Create policies for matching_filters
CREATE POLICY IF NOT EXISTS "Users can manage own filters"
ON matching_filters FOR ALL
USING (auth.uid() = user_id);

-- Create policies for matching_queue
CREATE POLICY IF NOT EXISTS "Users can view own queue items"
ON matching_queue FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Service role can manage queue"
ON matching_queue FOR ALL
USING (auth.role() = 'service_role');

-- Create policies for matching_history
CREATE POLICY IF NOT EXISTS "Users can view own history"
ON matching_history FOR SELECT
USING (auth.uid() = member_user_id OR auth.uid() = place_user_id);

CREATE POLICY IF NOT EXISTS "Users can add own actions"
ON matching_history FOR INSERT
WITH CHECK (
    (action_by = 'member' AND auth.uid() = member_user_id) OR
    (action_by = 'place' AND auth.uid() = place_user_id)
);

-- Check RLS status
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN (
    'place_profiles',
    'place_attributes_link',
    'place_preferences_link',
    'place_industries',
    'member_hearts',
    'place_hearts',
    'member_favorites',
    'place_favorites',
    'matching_scores',
    'matching_weights',
    'matching_filters',
    'matching_queue',
    'matching_history'
);

EOF

echo "RLS policies applied successfully!"