-- RLS Policies for BamStar Matching System

-- ========================================
-- 1. Place Profile Policies
-- ========================================
-- Member는 모든 Place를 자유롭게 조회 가능
CREATE POLICY "members_view_all_places"
ON place_profiles FOR SELECT
USING (
    auth.uid() = user_id OR  -- 자신의 프로필
    EXISTS (  -- Member인 경우 모든 Place 조회 가능
        SELECT 1 FROM users
        WHERE id = auth.uid()
        AND role_id = 2  -- Member role
    )
);

CREATE POLICY "update_own_place_profile"
ON place_profiles FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "insert_own_place_profile"
ON place_profiles FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "delete_own_place_profile"
ON place_profiles FOR DELETE
USING (auth.uid() = user_id);

-- ========================================
-- 2. Place Attributes Link Policies
-- ========================================
CREATE POLICY "view_all_place_attributes"
ON place_attributes_link FOR SELECT
USING (true);

CREATE POLICY "manage_own_place_attributes"
ON place_attributes_link FOR ALL
USING (auth.uid() = place_user_id);

-- ========================================
-- 3. Place Preferences Link Policies
-- ========================================
CREATE POLICY "view_all_place_preferences"
ON place_preferences_link FOR SELECT
USING (true);

CREATE POLICY "manage_own_place_preferences"
ON place_preferences_link FOR ALL
USING (auth.uid() = place_user_id);

-- ========================================
-- 4. Place Industries Policies
-- ========================================
CREATE POLICY "view_all_place_industries"
ON place_industries FOR SELECT
USING (true);

CREATE POLICY "manage_own_place_industries"
ON place_industries FOR ALL
USING (auth.uid() = place_user_id);

-- ========================================
-- 5. Member Hearts Policies
-- ========================================
CREATE POLICY "members_send_hearts"
ON member_hearts FOR INSERT
WITH CHECK (auth.uid() = member_user_id);

CREATE POLICY "view_related_member_hearts"
ON member_hearts FOR SELECT
USING (auth.uid() = member_user_id OR auth.uid() = place_user_id);

CREATE POLICY "members_update_own_hearts"
ON member_hearts FOR UPDATE
USING (auth.uid() = member_user_id);

CREATE POLICY "members_delete_own_hearts"
ON member_hearts FOR DELETE
USING (auth.uid() = member_user_id);

-- ========================================
-- 6. Place Hearts Policies
-- ========================================
CREATE POLICY "places_send_hearts"
ON place_hearts FOR INSERT
WITH CHECK (auth.uid() = place_user_id);

CREATE POLICY "view_related_place_hearts"
ON place_hearts FOR SELECT
USING (auth.uid() = place_user_id OR auth.uid() = member_user_id);

CREATE POLICY "places_update_own_hearts"
ON place_hearts FOR UPDATE
USING (auth.uid() = place_user_id);

CREATE POLICY "places_delete_own_hearts"
ON place_hearts FOR DELETE
USING (auth.uid() = place_user_id);

-- ========================================
-- 7. Member Favorites Policies
-- ========================================
CREATE POLICY "members_manage_favorites"
ON member_favorites FOR ALL
USING (auth.uid() = member_user_id);

-- ========================================
-- 8. Place Favorites Policies
-- ========================================
CREATE POLICY "places_manage_favorites"
ON place_favorites FOR ALL
USING (auth.uid() = place_user_id);

-- ========================================
-- 9. Matching Scores Policies
-- ========================================
CREATE POLICY "view_own_matching_scores"
ON matching_scores FOR SELECT
USING (auth.uid() = member_user_id OR auth.uid() = place_user_id);

CREATE POLICY "service_manage_matching_scores"
ON matching_scores FOR ALL
USING (auth.role() = 'service_role');

-- ========================================
-- 10. Matching Weights Policies
-- ========================================
CREATE POLICY "manage_own_weights"
ON matching_weights FOR ALL
USING (auth.uid() = user_id);

-- ========================================
-- 11. Matching Filters Policies
-- ========================================
CREATE POLICY "manage_own_filters"
ON matching_filters FOR ALL
USING (auth.uid() = user_id);

-- ========================================
-- 12. Matching Queue Policies
-- ========================================
CREATE POLICY "view_own_queue_items"
ON matching_queue FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "service_manage_queue"
ON matching_queue FOR ALL
USING (auth.role() = 'service_role');

-- ========================================
-- 13. Matching History Policies
-- ========================================
CREATE POLICY "view_own_history"
ON matching_history FOR SELECT
USING (auth.uid() = member_user_id OR auth.uid() = place_user_id);

CREATE POLICY "add_own_actions"
ON matching_history FOR INSERT
WITH CHECK (
    (action_by = 'member' AND auth.uid() = member_user_id) OR
    (action_by = 'place' AND auth.uid() = place_user_id)
);

-- ========================================
-- 14. Member Profile Special Policies
-- ========================================
-- Place는 수락된 Member만 조회 가능
CREATE POLICY "places_view_accepted_members_only"
ON member_profiles FOR SELECT
USING (
    auth.uid() = user_id OR  -- 자신의 프로필
    EXISTS (  -- Place가 보낸 좋아요를 Member가 수락한 경우
        SELECT 1 FROM place_hearts
        WHERE place_user_id = auth.uid()
        AND member_user_id = member_profiles.user_id
        AND status = 'accepted'
    ) OR
    EXISTS (  -- Member가 보낸 좋아요를 Place가 수락한 경우 (상호 매칭)
        SELECT 1 FROM member_hearts
        WHERE member_user_id = member_profiles.user_id
        AND place_user_id = auth.uid()
        AND status = 'accepted'
    ) OR
    EXISTS (  -- Member인 경우 다른 Member 프로필도 볼 수 있음
        SELECT 1 FROM users
        WHERE id = auth.uid()
        AND role_id = 2  -- Member role
    )
);

CREATE POLICY "update_own_member_profile"
ON member_profiles FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "insert_own_member_profile"
ON member_profiles FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "delete_own_member_profile"
ON member_profiles FOR DELETE
USING (auth.uid() = user_id);