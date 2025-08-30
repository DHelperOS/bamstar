-- RLS Policies for place_industries table
-- This table manages the industries that Places operate in

-- ========================================
-- Place Industries Policies
-- ========================================

-- Allow Places to view all industries (for compatibility)
CREATE POLICY "view_all_place_industries"
ON place_industries FOR SELECT
USING (true);

-- Allow Places to manage their own industries
CREATE POLICY "manage_own_place_industries"
ON place_industries FOR INSERT
WITH CHECK (auth.uid() = place_user_id);

CREATE POLICY "update_own_place_industries"
ON place_industries FOR UPDATE
USING (auth.uid() = place_user_id);

CREATE POLICY "delete_own_place_industries"
ON place_industries FOR DELETE
USING (auth.uid() = place_user_id);

-- Also need to check other related tables that might be missing policies
-- Let's also add policies for place_attributes_link and place_preferences_link

-- ========================================
-- Place Attributes Link Policies (if missing)
-- ========================================

-- Check if policies already exist, if not create them
DO $$
BEGIN
  -- Only create if no policies exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'place_attributes_link' 
    AND schemaname = 'public'
  ) THEN
    EXECUTE 'CREATE POLICY "view_all_place_attributes" ON place_attributes_link FOR SELECT USING (true)';
    EXECUTE 'CREATE POLICY "manage_own_place_attributes" ON place_attributes_link FOR INSERT WITH CHECK (auth.uid() = place_user_id)';
    EXECUTE 'CREATE POLICY "update_own_place_attributes" ON place_attributes_link FOR UPDATE USING (auth.uid() = place_user_id)';
    EXECUTE 'CREATE POLICY "delete_own_place_attributes" ON place_attributes_link FOR DELETE USING (auth.uid() = place_user_id)';
  END IF;
END $$;

-- ========================================
-- Place Preferences Link Policies (if missing)
-- ========================================

DO $$
BEGIN
  -- Only create if no policies exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'place_preferences_link' 
    AND schemaname = 'public'
  ) THEN
    EXECUTE 'CREATE POLICY "view_all_place_preferences" ON place_preferences_link FOR SELECT USING (true)';
    EXECUTE 'CREATE POLICY "manage_own_place_preferences" ON place_preferences_link FOR INSERT WITH CHECK (auth.uid() = place_user_id)';
    EXECUTE 'CREATE POLICY "update_own_place_preferences" ON place_preferences_link FOR UPDATE USING (auth.uid() = place_user_id)';
    EXECUTE 'CREATE POLICY "delete_own_place_preferences" ON place_preferences_link FOR DELETE USING (auth.uid() = place_user_id)';
  END IF;
END $$;