-- 1. 플레이스 기본 프로필
CREATE TABLE IF NOT EXISTS place_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    
    -- 사업장 기본 정보
    place_name TEXT NOT NULL,
    business_type TEXT,
    business_number TEXT,
    business_verified BOOLEAN DEFAULT false,
    
    -- 위치 정보
    address TEXT NOT NULL,
    detail_address TEXT,
    postcode TEXT,
    road_address TEXT,
    jibun_address TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    area_group_id INT REFERENCES area_groups(group_id),
    
    -- 관리자 정보
    manager_name TEXT,
    manager_phone TEXT,
    manager_gender TEXT CHECK (manager_gender IN ('남', '여')),
    
    -- SNS 정보
    sns_type TEXT CHECK (sns_type IN ('카카오톡', '인스타그램', '기타')),
    sns_handle TEXT,
    
    -- 소개
    intro TEXT,
    
    -- 이미지
    profile_image_urls TEXT[],
    representative_image_index INT DEFAULT 0,
    
    -- 운영 정보
    operating_hours JSONB,
    
    -- 제공 조건
    offered_pay_type TEXT CHECK (offered_pay_type IN ('TC', '일급', '월급', '협의')),
    offered_min_pay INT,
    offered_max_pay INT,
    
    -- 원하는 스타 조건
    desired_experience_level TEXT CHECK (desired_experience_level IN ('무관', '신입', '주니어', '시니어', '전문가')),
    desired_working_days TEXT[],
    
    -- 메타데이터
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_place_location ON place_profiles(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_place_area ON place_profiles(area_group_id);
CREATE INDEX IF NOT EXISTS idx_place_pay ON place_profiles(offered_min_pay, offered_max_pay);

-- 2. 플레이스가 제공하는 것 (복지, 가게특징)
CREATE TABLE IF NOT EXISTS place_attributes_link (
    place_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    attribute_id INT NOT NULL REFERENCES attributes(id),
    PRIMARY KEY (place_user_id, attribute_id)
);

-- 3. 플레이스가 원하는 것 (직무, 스타일)
CREATE TABLE IF NOT EXISTS place_preferences_link (
    place_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    attribute_id INT NOT NULL REFERENCES attributes(id),
    preference_level TEXT DEFAULT 'preferred' 
        CHECK (preference_level IN ('required', 'preferred', 'nice_to_have')),
    PRIMARY KEY (place_user_id, attribute_id)
);

-- 4. 플레이스 업종
CREATE TABLE IF NOT EXISTS place_industries (
    place_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    attribute_id INT NOT NULL REFERENCES attributes(id),
    is_primary BOOLEAN DEFAULT false,
    PRIMARY KEY (place_user_id, attribute_id)
);