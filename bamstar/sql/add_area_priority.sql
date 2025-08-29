-- member_preferred_area_groups 테이블에 priority 필드 추가

ALTER TABLE member_preferred_area_groups 
ADD COLUMN priority INTEGER DEFAULT 1;

-- 기존 데이터에 우선순위 설정 (created_at 순서로)
WITH ranked_areas AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (PARTITION BY member_user_id ORDER BY created_at) as rn
    FROM member_preferred_area_groups
)
UPDATE member_preferred_area_groups 
SET priority = ranked_areas.rn
FROM ranked_areas 
WHERE member_preferred_area_groups.id = ranked_areas.id;

-- 인덱스 추가
CREATE INDEX idx_member_preferred_areas_priority ON member_preferred_area_groups(member_user_id, priority);

-- 코멘트 추가
COMMENT ON COLUMN member_preferred_area_groups.priority IS '지역 선호 우선순위 (1=최우선, 5=최하위)';