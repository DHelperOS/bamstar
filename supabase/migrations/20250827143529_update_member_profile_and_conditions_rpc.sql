-- Function to update member profile and related conditions in a transaction
CREATE OR REPLACE FUNCTION update_member_profile_and_conditions(
  p_user_id UUID,
  p_bio TEXT DEFAULT NULL,
  p_desired_pay_type TEXT DEFAULT NULL,
  p_desired_pay_amount INTEGER DEFAULT NULL,
  p_desired_working_days TEXT[] DEFAULT NULL,
  p_experience_level TEXT DEFAULT NULL,
  p_style_attribute_ids INTEGER[] DEFAULT ARRAY[]::INTEGER[],
  p_preference_attribute_ids INTEGER[] DEFAULT ARRAY[]::INTEGER[],
  p_area_group_ids INTEGER[] DEFAULT ARRAY[]::INTEGER[]
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  attribute_id INTEGER;
  area_group_id INTEGER;
BEGIN
  -- Start transaction (implicit in function)
  
  -- 1. Update or insert member profile
  INSERT INTO member_profiles (
    user_id,
    bio,
    desired_pay_type,
    desired_pay_amount,
    desired_working_days,
    experience_level,
    updated_at
  )
  VALUES (
    p_user_id,
    p_bio,
    p_desired_pay_type,
    p_desired_pay_amount,
    p_desired_working_days,
    p_experience_level,
    NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET
    bio = COALESCE(EXCLUDED.bio, member_profiles.bio),
    desired_pay_type = COALESCE(EXCLUDED.desired_pay_type, member_profiles.desired_pay_type),
    desired_pay_amount = COALESCE(EXCLUDED.desired_pay_amount, member_profiles.desired_pay_amount),
    desired_working_days = COALESCE(EXCLUDED.desired_working_days, member_profiles.desired_working_days),
    experience_level = COALESCE(EXCLUDED.experience_level, member_profiles.experience_level),
    updated_at = NOW();

  -- 2. Update member attributes (styles/strengths)
  -- Delete existing member attributes
  DELETE FROM member_attributes_link
  WHERE member_user_id = p_user_id;

  -- Insert new member attributes
  FOREACH attribute_id IN ARRAY p_style_attribute_ids
  LOOP
    INSERT INTO member_attributes_link (member_user_id, attribute_id)
    VALUES (p_user_id, attribute_id);
  END LOOP;

  -- 3. Update member preferences (industries, jobs, place features, welfare)
  -- Delete existing member preferences
  DELETE FROM member_preferences_link
  WHERE member_user_id = p_user_id;

  -- Insert new member preferences
  FOREACH attribute_id IN ARRAY p_preference_attribute_ids
  LOOP
    INSERT INTO member_preferences_link (member_user_id, attribute_id)
    VALUES (p_user_id, attribute_id);
  END LOOP;

  -- 4. Update preferred area groups
  -- Delete existing area group preferences
  DELETE FROM member_preferred_area_groups
  WHERE member_user_id = p_user_id;

  -- Insert new area group preferences
  FOREACH area_group_id IN ARRAY p_area_group_ids
  LOOP
    INSERT INTO member_preferred_area_groups (member_user_id, area_group_id)
    VALUES (p_user_id, area_group_id);
  END LOOP;

  -- Return success
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    -- Log the error (in production, you might want to use a proper logging mechanism)
    RAISE LOG 'Error in update_member_profile_and_conditions: %', SQLERRM;
    -- Re-raise the exception to trigger rollback
    RAISE;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION update_member_profile_and_conditions(UUID, TEXT, TEXT, INTEGER, TEXT[], TEXT, INTEGER[], INTEGER[], INTEGER[]) TO authenticated;
GRANT EXECUTE ON FUNCTION update_member_profile_and_conditions(UUID, TEXT, TEXT, INTEGER, TEXT[], TEXT, INTEGER[], INTEGER[], INTEGER[]) TO service_role;

-- Add comment for documentation
COMMENT ON FUNCTION update_member_profile_and_conditions IS 'Updates member profile and all related conditions (attributes, preferences, area groups) in a single transaction';