-- 양방향 좋아요/즐겨찾기 시스템

-- 1. 멤버 → 플레이스 좋아요
CREATE TABLE IF NOT EXISTS member_hearts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    member_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    status TEXT DEFAULT 'pending' 
        CHECK (status IN ('pending', 'accepted', 'rejected')),
    UNIQUE(member_user_id, place_user_id)
);

-- 2. 플레이스 → 멤버 좋아요
CREATE TABLE IF NOT EXISTS place_hearts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    place_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    member_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    status TEXT DEFAULT 'pending' 
        CHECK (status IN ('pending', 'accepted', 'rejected')),
    UNIQUE(place_user_id, member_user_id)
);

-- 3. 멤버 즐겨찾기
CREATE TABLE IF NOT EXISTS member_favorites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    member_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    UNIQUE(member_user_id, place_user_id)
);

-- 4. 플레이스 즐겨찾기
CREATE TABLE IF NOT EXISTS place_favorites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    place_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    member_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    UNIQUE(place_user_id, member_user_id)
);

-- 5. 상호 매칭 뷰
CREATE OR REPLACE VIEW mutual_matches AS
SELECT 
    mh.member_user_id,
    mh.place_user_id,
    mh.sent_at as member_liked_at,
    ph.sent_at as place_liked_at,
    GREATEST(mh.sent_at, ph.sent_at) as matched_at
FROM member_hearts mh
INNER JOIN place_hearts ph 
    ON mh.member_user_id = ph.member_user_id 
    AND mh.place_user_id = ph.place_user_id
WHERE mh.status = 'accepted' 
    AND ph.status = 'accepted';

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_member_hearts_member ON member_hearts(member_user_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_member_hearts_place ON member_hearts(place_user_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_place_hearts_place ON place_hearts(place_user_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_place_hearts_member ON place_hearts(member_user_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_member_favorites ON member_favorites(member_user_id, added_at DESC);
CREATE INDEX IF NOT EXISTS idx_place_favorites ON place_favorites(place_user_id, added_at DESC);