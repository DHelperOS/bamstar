-- Create RLS policies for place_industries table to fix INSERT operations

-- Allow viewing all place industries (for compatibility)
CREATE POLICY "view_all_place_industries"
ON place_industries FOR SELECT
USING (true);

-- Allow places to insert their own industry records
CREATE POLICY "insert_own_place_industries"
ON place_industries FOR INSERT
WITH CHECK (auth.uid() = place_user_id);

-- Allow places to update their own industry records
CREATE POLICY "update_own_place_industries"
ON place_industries FOR UPDATE
USING (auth.uid() = place_user_id);

-- Allow places to delete their own industry records
CREATE POLICY "delete_own_place_industries"
ON place_industries FOR DELETE
USING (auth.uid() = place_user_id);

-- Also add missing policies for related tables if they don't exist

-- place_attributes_link policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'place_attributes_link' AND policyname = 'view_all_place_attributes') THEN
        CREATE POLICY "view_all_place_attributes"
        ON place_attributes_link FOR SELECT
        USING (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'place_attributes_link' AND policyname = 'insert_own_place_attributes') THEN
        CREATE POLICY "insert_own_place_attributes"
        ON place_attributes_link FOR INSERT
        WITH CHECK (auth.uid() = place_user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'place_attributes_link' AND policyname = 'update_own_place_attributes') THEN
        CREATE POLICY "update_own_place_attributes"
        ON place_attributes_link FOR UPDATE
        USING (auth.uid() = place_user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'place_attributes_link' AND policyname = 'delete_own_place_attributes') THEN
        CREATE POLICY "delete_own_place_attributes"
        ON place_attributes_link FOR DELETE
        USING (auth.uid() = place_user_id);
    END IF;
END $$;

-- place_preferences_link policies  
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'place_preferences_link' AND policyname = 'view_all_place_preferences') THEN
        CREATE POLICY "view_all_place_preferences"
        ON place_preferences_link FOR SELECT
        USING (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'place_preferences_link' AND policyname = 'insert_own_place_preferences') THEN
        CREATE POLICY "insert_own_place_preferences"
        ON place_preferences_link FOR INSERT
        WITH CHECK (auth.uid() = place_user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'place_preferences_link' AND policyname = 'update_own_place_preferences') THEN
        CREATE POLICY "update_own_place_preferences"
        ON place_preferences_link FOR UPDATE
        USING (auth.uid() = place_user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'place_preferences_link' AND policyname = 'delete_own_place_preferences') THEN
        CREATE POLICY "delete_own_place_preferences"
        ON place_preferences_link FOR DELETE
        USING (auth.uid() = place_user_id);
    END IF;
END $$;