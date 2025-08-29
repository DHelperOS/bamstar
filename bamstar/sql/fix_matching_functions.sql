-- 매칭 함수들 로직 개선

-- 1. 지역 매칭 - 우선순위 반영
CREATE OR REPLACE FUNCTION calculate_location_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_place_area_id INT;
    v_member_area_priorities INT[];
    v_priority_index INT;
BEGIN
    -- Place의 area_group_id 가져오기
    SELECT area_group_id INTO v_place_area_id
    FROM place_profiles
    WHERE user_id = p_place_id;
    
    -- Member의 선호 지역들을 우선순위 순으로 가져오기
    SELECT ARRAY_AGG(group_id ORDER BY created_at) INTO v_member_area_priorities
    FROM member_preferred_area_groups
    WHERE member_user_id = p_member_id;
    
    IF v_place_area_id IS NULL OR v_member_area_priorities IS NULL THEN
        RETURN 50;
    END IF;
    
    -- 우선순위별 점수 계산
    FOR v_priority_index IN 1..array_length(v_member_area_priorities, 1) LOOP
        IF v_member_area_priorities[v_priority_index] = v_place_area_id THEN
            -- 1순위: 100점, 2순위: 90점, 3순위: 80점...
            RETURN GREATEST(70, 110 - (v_priority_index * 10));
        END IF;
    END LOOP;
    
    -- 같은 카테고리 내 지역인지 확인
    IF EXISTS (
        SELECT 1 FROM area_groups ag1
        JOIN area_groups ag2 ON ag1.category_id = ag2.category_id
        WHERE ag1.group_id = v_place_area_id
        AND ag2.group_id = ANY(v_member_area_priorities)
    ) THEN
        RETURN 40; -- 같은 카테고리
    ELSE
        RETURN 10; -- 완전히 다른 지역
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 2. 직무 매칭 - 양방향 매칭
CREATE OR REPLACE FUNCTION calculate_job_role_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_member_jobs INT[];
    v_member_preferred_jobs INT[];
    v_place_required_jobs INT[];
    v_place_preferred_jobs INT[];
    v_required_match_count INT;
    v_preferred_match_count INT;
    v_total_required INT;
    v_score DECIMAL := 0;
BEGIN
    -- Member의 경험 직무
    SELECT ARRAY_AGG(mal.attribute_id) INTO v_member_jobs
    FROM member_attributes_link mal
    JOIN attributes a ON mal.attribute_id = a.id
    WHERE mal.member_user_id = p_member_id
    AND a.type = 'JOB_ROLE';
    
    -- Member가 선호하는 직무
    SELECT ARRAY_AGG(mpl.attribute_id) INTO v_member_preferred_jobs
    FROM member_preferences_link mpl
    JOIN attributes a ON mpl.attribute_id = a.id
    WHERE mpl.member_user_id = p_member_id
    AND a.type = 'JOB_ROLE';
    
    -- Place의 필수 직무
    SELECT ARRAY_AGG(ppl.attribute_id) INTO v_place_required_jobs
    FROM place_preferences_link ppl
    JOIN attributes a ON ppl.attribute_id = a.id
    WHERE ppl.place_user_id = p_place_id
    AND a.type = 'JOB_ROLE'
    AND ppl.preference_level = 'required';
    
    -- Place의 선호 직무
    SELECT ARRAY_AGG(ppl.attribute_id) INTO v_place_preferred_jobs
    FROM place_preferences_link ppl
    JOIN attributes a ON ppl.attribute_id = a.id
    WHERE ppl.place_user_id = p_place_id
    AND a.type = 'JOB_ROLE'
    AND ppl.preference_level = 'preferred';
    
    -- 1. Place 필수 조건 확인 (70% 가중치)
    IF v_place_required_jobs IS NOT NULL AND array_length(v_place_required_jobs, 1) > 0 THEN
        SELECT COUNT(*) INTO v_required_match_count
        FROM unnest(v_member_jobs) AS member_job
        WHERE member_job = ANY(v_place_required_jobs);
        
        v_total_required := array_length(v_place_required_jobs, 1);
        v_score := v_score + ((v_required_match_count::DECIMAL / v_total_required) * 70);
    ELSE
        v_score := v_score + 70; -- 필수 조건 없으면 70점
    END IF;
    
    -- 2. Member 선호도와 Place 제공 직무 매칭 (30% 가중치)
    IF v_member_preferred_jobs IS NOT NULL AND array_length(v_member_preferred_jobs, 1) > 0 THEN
        SELECT COUNT(*) INTO v_preferred_match_count
        FROM unnest(v_member_preferred_jobs) AS preferred_job
        WHERE preferred_job = ANY(v_place_required_jobs) OR preferred_job = ANY(v_place_preferred_jobs);
        
        v_score := v_score + ((v_preferred_match_count::DECIMAL / array_length(v_member_preferred_jobs, 1)) * 30);
    ELSE
        v_score := v_score + 15; -- 선호 없으면 절반 점수
    END IF;
    
    RETURN LEAST(100, v_score);
END;
$$ LANGUAGE plpgsql;

-- 3. 업종 매칭 - 경력별 차등 점수
CREATE OR REPLACE FUNCTION calculate_industry_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_member_industries INT[];
    v_member_experience_level VARCHAR(50);
    v_place_industry INT;
BEGIN
    -- Member 경험 업종들
    SELECT ARRAY_AGG(mal.attribute_id) INTO v_member_industries
    FROM member_attributes_link mal
    JOIN attributes a ON mal.attribute_id = a.id
    WHERE mal.member_user_id = p_member_id
    AND a.type = 'INDUSTRY';
    
    -- Member 경력 수준
    SELECT experience_level INTO v_member_experience_level
    FROM member_profiles
    WHERE user_id = p_member_id;
    
    -- Place 주 업종
    SELECT pi.attribute_id INTO v_place_industry
    FROM place_industries pi
    WHERE pi.place_user_id = p_place_id
    AND pi.is_primary = true
    LIMIT 1;
    
    IF v_place_industry IS NULL THEN
        RETURN 50; -- Place 업종 정보 없음
    END IF;
    
    -- 업종 경험 여부에 따른 점수
    IF v_place_industry = ANY(v_member_industries) THEN
        RETURN 100; -- 동일 업종 경험 있음
    ELSE
        -- 경력 수준에 따른 차등 점수
        CASE v_member_experience_level
            WHEN 'NEWBIE' THEN RETURN 80;      -- 신입: 80점 (도전 기회)
            WHEN 'JUNIOR' THEN RETURN 60;      -- 주니어: 60점
            WHEN 'SENIOR' THEN RETURN 40;      -- 시니어: 40점  
            WHEN 'PROFESSIONAL' THEN RETURN 20; -- 전문가: 20점
            ELSE RETURN 70; -- 정보 없으면 70점
        END CASE;
    END IF;
END;
$$ LANGUAGE plpgsql;