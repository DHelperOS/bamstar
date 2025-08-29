-- 매칭 시스템 핵심 테이블

-- 1. 매칭 점수 캐시
CREATE TABLE IF NOT EXISTS matching_scores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    member_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 총점과 카테고리별 점수
    total_score DECIMAL(5,2) NOT NULL DEFAULT 0,
    job_role_score DECIMAL(5,2) DEFAULT 0,      -- 40%
    industry_score DECIMAL(5,2) DEFAULT 0,       -- 20%
    style_score DECIMAL(5,2) DEFAULT 0,          -- 15%
    location_score DECIMAL(5,2) DEFAULT 0,       -- 15%
    pay_score DECIMAL(5,2) DEFAULT 0,            -- 10%
    welfare_bonus DECIMAL(5,2) DEFAULT 0,        -- Bonus
    
    -- 매칭 상태
    match_status TEXT DEFAULT 'potential' 
        CHECK (match_status IN ('potential', 'viewed', 'contacted', 'rejected', 'accepted')),
    
    -- 캐싱 정보
    calculated_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
    version INT DEFAULT 1,
    
    UNIQUE(member_user_id, place_user_id)
);

-- 2. 매칭 가중치 설정
CREATE TABLE IF NOT EXISTS matching_weights (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    user_type TEXT NOT NULL CHECK (user_type IN ('member', 'place')),
    
    job_role_weight DECIMAL(3,2) DEFAULT 0.40,
    industry_weight DECIMAL(3,2) DEFAULT 0.20,
    style_weight DECIMAL(3,2) DEFAULT 0.15,
    location_weight DECIMAL(3,2) DEFAULT 0.15,
    pay_weight DECIMAL(3,2) DEFAULT 0.10,
    
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id),
    CHECK (
        job_role_weight + industry_weight + style_weight + 
        location_weight + pay_weight = 1.0
    )
);

-- 3. 매칭 필터
CREATE TABLE IF NOT EXISTS matching_filters (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_type TEXT NOT NULL CHECK (user_type IN ('member', 'place')),
    
    min_score DECIMAL(5,2) DEFAULT 60,
    max_distance_km INT,
    excluded_user_ids UUID[] DEFAULT '{}',
    
    required_attributes INT[] DEFAULT '{}',
    excluded_attributes INT[] DEFAULT '{}',
    
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 4. 매칭 처리 큐
CREATE TABLE IF NOT EXISTS matching_queue (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    user_type TEXT NOT NULL CHECK (user_type IN ('member', 'place')),
    priority INT DEFAULT 5 CHECK (priority >= 1 AND priority <= 10),
    status TEXT DEFAULT 'pending' 
        CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    
    queued_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    error_message TEXT,
    retry_count INT DEFAULT 0
);

-- 5. 매칭 히스토리
CREATE TABLE IF NOT EXISTS matching_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    member_user_id UUID NOT NULL REFERENCES users(id),
    place_user_id UUID NOT NULL REFERENCES users(id),
    
    action_type TEXT NOT NULL CHECK (action_type IN (
        'viewed', 'liked', 'contacted', 'rejected', 
        'accepted', 'interview_scheduled', 'hired'
    )),
    
    action_by TEXT NOT NULL CHECK (action_by IN ('member', 'place')),
    action_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- 상호작용 데이터
    message TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_matching_member ON matching_scores(member_user_id, total_score DESC);
CREATE INDEX IF NOT EXISTS idx_matching_place ON matching_scores(place_user_id, total_score DESC);
CREATE INDEX IF NOT EXISTS idx_matching_expiry ON matching_scores(expires_at);
CREATE INDEX IF NOT EXISTS idx_queue_status ON matching_queue(status, priority DESC, queued_at);
CREATE INDEX IF NOT EXISTS idx_history_member ON matching_history(member_user_id, action_at DESC);
CREATE INDEX IF NOT EXISTS idx_history_place ON matching_history(place_user_id, action_at DESC);