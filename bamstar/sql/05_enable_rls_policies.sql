-- Row Level Security (RLS) 정책 설정
-- 모든 테이블에 RLS 활성화 및 정책 적용

-- ========================================
-- 1. Place 관련 테이블 RLS
-- ========================================

-- place_profiles 테이블
ALTER TABLE place_profiles ENABLE ROW LEVEL SECURITY;

-- 조회 정책은 아래 특별 정책 섹션에서 정의

CREATE POLICY "Users can update own place profile"
ON place_profiles FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own place profile"
ON place_profiles FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own place profile"
ON place_profiles FOR DELETE
USING (auth.uid() = user_id);

-- place_attributes_link 테이블
ALTER TABLE place_attributes_link ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all place attributes"
ON place_attributes_link FOR SELECT
USING (true);

CREATE POLICY "Users can manage own place attributes"
ON place_attributes_link FOR ALL
USING (auth.uid() = place_user_id);

-- place_preferences_link 테이블
ALTER TABLE place_preferences_link ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all place preferences"
ON place_preferences_link FOR SELECT
USING (true);

CREATE POLICY "Users can manage own place preferences"
ON place_preferences_link FOR ALL
USING (auth.uid() = place_user_id);

-- place_industries 테이블
ALTER TABLE place_industries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all place industries"
ON place_industries FOR SELECT
USING (true);

CREATE POLICY "Users can manage own place industries"
ON place_industries FOR ALL
USING (auth.uid() = place_user_id);

-- ========================================
-- 2. Hearts (좋아요) 테이블 RLS
-- ========================================

-- member_hearts 테이블
ALTER TABLE member_hearts ENABLE ROW LEVEL SECURITY;

-- 멤버는 자신이 보낸 좋아요만 관리 가능
CREATE POLICY "Members can send hearts"
ON member_hearts FOR INSERT
WITH CHECK (auth.uid() = member_user_id);

CREATE POLICY "Users can view hearts related to them"
ON member_hearts FOR SELECT
USING (
    auth.uid() = member_user_id OR 
    auth.uid() = place_user_id
);

CREATE POLICY "Members can update own hearts"
ON member_hearts FOR UPDATE
USING (auth.uid() = member_user_id);

CREATE POLICY "Members can delete own hearts"
ON member_hearts FOR DELETE
USING (auth.uid() = member_user_id);

-- place_hearts 테이블
ALTER TABLE place_hearts ENABLE ROW LEVEL SECURITY;

-- 플레이스는 자신이 보낸 좋아요만 관리 가능
CREATE POLICY "Places can send hearts"
ON place_hearts FOR INSERT
WITH CHECK (auth.uid() = place_user_id);

CREATE POLICY "Users can view hearts related to them"
ON place_hearts FOR SELECT
USING (
    auth.uid() = place_user_id OR 
    auth.uid() = member_user_id
);

CREATE POLICY "Places can update own hearts"
ON place_hearts FOR UPDATE
USING (auth.uid() = place_user_id);

CREATE POLICY "Places can delete own hearts"
ON place_hearts FOR DELETE
USING (auth.uid() = place_user_id);

-- ========================================
-- 3. Favorites (즐겨찾기) 테이블 RLS
-- ========================================

-- member_favorites 테이블
ALTER TABLE member_favorites ENABLE ROW LEVEL SECURITY;

-- 멤버는 자신의 즐겨찾기만 관리 가능
CREATE POLICY "Members can manage own favorites"
ON member_favorites FOR ALL
USING (auth.uid() = member_user_id);

-- place_favorites 테이블
ALTER TABLE place_favorites ENABLE ROW LEVEL SECURITY;

-- 플레이스는 자신의 즐겨찾기만 관리 가능
CREATE POLICY "Places can manage own favorites"
ON place_favorites FOR ALL
USING (auth.uid() = place_user_id);

-- ========================================
-- 4. Matching 관련 테이블 RLS
-- ========================================

-- matching_scores 테이블
ALTER TABLE matching_scores ENABLE ROW LEVEL SECURITY;

-- 자신과 관련된 매칭 점수만 조회 가능
CREATE POLICY "Users can view own matching scores"
ON matching_scores FOR SELECT
USING (
    auth.uid() = member_user_id OR 
    auth.uid() = place_user_id
);

-- Service role만 insert/update 가능 (Edge Functions에서 처리)
CREATE POLICY "Service role can manage matching scores"
ON matching_scores FOR ALL
USING (auth.role() = 'service_role');

-- matching_weights 테이블
ALTER TABLE matching_weights ENABLE ROW LEVEL SECURITY;

-- 자신의 가중치만 관리 가능
CREATE POLICY "Users can manage own weights"
ON matching_weights FOR ALL
USING (auth.uid() = user_id);

-- matching_filters 테이블
ALTER TABLE matching_filters ENABLE ROW LEVEL SECURITY;

-- 자신의 필터만 관리 가능
CREATE POLICY "Users can manage own filters"
ON matching_filters FOR ALL
USING (auth.uid() = user_id);

-- matching_queue 테이블
ALTER TABLE matching_queue ENABLE ROW LEVEL SECURITY;

-- 자신의 큐 항목만 조회 가능
CREATE POLICY "Users can view own queue items"
ON matching_queue FOR SELECT
USING (auth.uid() = user_id);

-- Service role만 관리 가능
CREATE POLICY "Service role can manage queue"
ON matching_queue FOR ALL
USING (auth.role() = 'service_role');

-- matching_history 테이블
ALTER TABLE matching_history ENABLE ROW LEVEL SECURITY;

-- 자신과 관련된 히스토리만 조회 가능
CREATE POLICY "Users can view own history"
ON matching_history FOR SELECT
USING (
    auth.uid() = member_user_id OR 
    auth.uid() = place_user_id
);

-- 자신의 액션만 추가 가능
CREATE POLICY "Users can add own actions"
ON matching_history FOR INSERT
WITH CHECK (
    (action_by = 'member' AND auth.uid() = member_user_id) OR
    (action_by = 'place' AND auth.uid() = place_user_id)
);

-- ========================================
-- 5. 특별 정책: 조회 권한 차별화
-- ========================================

-- Member는 모든 Place 프로필을 자유롭게 조회 가능
-- Place는 자신의 프로필만 조회 가능
CREATE POLICY "Members can view all place profiles freely"
ON place_profiles FOR SELECT
USING (
    auth.uid() = user_id OR  -- 자신의 프로필
    EXISTS (  -- Member인 경우 모든 Place 조회 가능
        SELECT 1 FROM users
        WHERE id = auth.uid()
        AND role_id = 2  -- Member role
    )
);

-- Place는 수락된 Member만 조회 가능
CREATE POLICY "Places can only view accepted members"
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

-- ========================================
-- 6. 기존 member 테이블 RLS 확인 및 추가
-- ========================================

-- member_profiles가 RLS 활성화되어 있지 않다면
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE tablename = 'member_profiles' 
        AND rowsecurity = true
    ) THEN
        ALTER TABLE member_profiles ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- member_attributes_link RLS
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE tablename = 'member_attributes_link' 
        AND rowsecurity = true
    ) THEN
        ALTER TABLE member_attributes_link ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can view all member attributes"
        ON member_attributes_link FOR SELECT
        USING (true);
        
        CREATE POLICY "Users can manage own member attributes"
        ON member_attributes_link FOR ALL
        USING (auth.uid() = member_user_id);
    END IF;
END $$;

-- member_preferences_link RLS
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE tablename = 'member_preferences_link' 
        AND rowsecurity = true
    ) THEN
        ALTER TABLE member_preferences_link ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can view member preferences with matching"
        ON member_preferences_link FOR SELECT
        USING (
            auth.uid() = member_user_id OR
            EXISTS (
                SELECT 1 FROM matching_scores
                WHERE member_user_id = member_preferences_link.member_user_id
                AND place_user_id = auth.uid()
                AND total_score >= 60
            )
        );
        
        CREATE POLICY "Users can manage own member preferences"
        ON member_preferences_link FOR ALL
        USING (auth.uid() = member_user_id);
    END IF;
END $$;

-- member_preferred_area_groups RLS
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE tablename = 'member_preferred_area_groups' 
        AND rowsecurity = true
    ) THEN
        ALTER TABLE member_preferred_area_groups ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can view member preferred areas"
        ON member_preferred_area_groups FOR SELECT
        USING (true);  -- 지역 선호도는 공개
        
        CREATE POLICY "Users can manage own preferred areas"
        ON member_preferred_area_groups FOR ALL
        USING (auth.uid() = member_user_id);
    END IF;
END $$;