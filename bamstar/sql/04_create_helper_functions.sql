-- 매칭 점수 계산 헬퍼 함수들

-- 1. 지역 기반 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_location_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_place_area_id INT;
    v_member_area_ids INT[];
    v_score DECIMAL;
BEGIN
    -- Place의 area_group_id 가져오기
    SELECT area_group_id INTO v_place_area_id
    FROM place_profiles
    WHERE user_id = p_place_id;
    
    -- Member의 선호 지역들 가져오기
    SELECT ARRAY_AGG(group_id) INTO v_member_area_ids
    FROM member_preferred_area_groups
    WHERE member_user_id = p_member_id;
    
    -- 점수 계산
    IF v_place_area_id = ANY(v_member_area_ids) THEN
        RETURN 100; -- 정확히 일치
    ELSIF EXISTS (
        SELECT 1 FROM area_groups ag1
        JOIN area_groups ag2 ON ag1.category_id = ag2.category_id
        WHERE ag1.group_id = v_place_area_id
        AND ag2.group_id = ANY(v_member_area_ids)
    ) THEN
        RETURN 70; -- 같은 카테고리 내
    ELSE
        RETURN 30; -- 다른 지역
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 2. 급여 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_pay_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_member_pay INT;
    v_place_min INT;
    v_place_max INT;
BEGIN
    SELECT desired_pay_amount INTO v_member_pay
    FROM member_profiles
    WHERE user_id = p_member_id;
    
    SELECT offered_min_pay, offered_max_pay 
    INTO v_place_min, v_place_max
    FROM place_profiles
    WHERE user_id = p_place_id;
    
    IF v_member_pay IS NULL OR v_place_min IS NULL THEN
        RETURN 50; -- 정보 없으면 중간 점수
    ELSIF v_member_pay BETWEEN v_place_min AND v_place_max THEN
        RETURN 100; -- 범위 내
    ELSIF v_member_pay < v_place_min THEN
        -- 멤버가 원하는 것보다 더 많이 제공
        RETURN 100;
    ELSE
        -- 차이에 따라 점수 감소
        RETURN GREATEST(0, 100 - ((v_member_pay - v_place_max)::DECIMAL / v_member_pay * 100));
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3. 직무 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_job_role_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_member_jobs INT[];
    v_place_required_jobs INT[];
    v_match_count INT;
BEGIN
    -- Member의 JOB_ROLE attributes
    SELECT ARRAY_AGG(mal.attribute_id) INTO v_member_jobs
    FROM member_attributes_link mal
    JOIN attributes a ON mal.attribute_id = a.id
    WHERE mal.member_user_id = p_member_id
    AND a.type = 'JOB_ROLE';
    
    -- Place가 원하는 JOB_ROLE (required only)
    SELECT ARRAY_AGG(ppl.attribute_id) INTO v_place_required_jobs
    FROM place_preferences_link ppl
    JOIN attributes a ON ppl.attribute_id = a.id
    WHERE ppl.place_user_id = p_place_id
    AND a.type = 'JOB_ROLE'
    AND ppl.preference_level = 'required';
    
    IF v_place_required_jobs IS NULL OR array_length(v_place_required_jobs, 1) = 0 THEN
        RETURN 100; -- 필수 직무 없으면 만점
    END IF;
    
    -- 매칭 개수 계산
    SELECT COUNT(*) INTO v_match_count
    FROM unnest(v_member_jobs) AS member_job
    WHERE member_job = ANY(v_place_required_jobs);
    
    RETURN (v_match_count::DECIMAL / array_length(v_place_required_jobs, 1)) * 100;
END;
$$ LANGUAGE plpgsql;

-- 4. 업종 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_industry_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_member_industries INT[];
    v_place_industry INT;
BEGIN
    -- Member가 경험한 업종들
    SELECT ARRAY_AGG(mal.attribute_id) INTO v_member_industries
    FROM member_attributes_link mal
    JOIN attributes a ON mal.attribute_id = a.id
    WHERE mal.member_user_id = p_member_id
    AND a.type = 'INDUSTRY';
    
    -- Place의 주 업종
    SELECT pi.attribute_id INTO v_place_industry
    FROM place_industries pi
    WHERE pi.place_user_id = p_place_id
    AND pi.is_primary = true
    LIMIT 1;
    
    IF v_place_industry IS NULL THEN
        -- Place 업종이 없으면 중간 점수
        RETURN 50;
    ELSIF v_place_industry = ANY(v_member_industries) THEN
        -- 경험 있음
        RETURN 100;
    ELSE
        -- 경험 없음
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. 스타일 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_style_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_member_styles INT[];
    v_place_preferred_styles INT[];
    v_match_count INT;
BEGIN
    -- Member의 스타일
    SELECT ARRAY_AGG(mal.attribute_id) INTO v_member_styles
    FROM member_attributes_link mal
    JOIN attributes a ON mal.attribute_id = a.id
    WHERE mal.member_user_id = p_member_id
    AND a.type = 'MEMBER_STYLE';
    
    -- Place가 선호하는 스타일
    SELECT ARRAY_AGG(ppl.attribute_id) INTO v_place_preferred_styles
    FROM place_preferences_link ppl
    JOIN attributes a ON ppl.attribute_id = a.id
    WHERE ppl.place_user_id = p_place_id
    AND a.type = 'MEMBER_STYLE';
    
    IF v_place_preferred_styles IS NULL OR array_length(v_place_preferred_styles, 1) = 0 THEN
        RETURN 100; -- 선호 스타일 없으면 만점
    END IF;
    
    -- 매칭 개수 계산
    SELECT COUNT(*) INTO v_match_count
    FROM unnest(v_member_styles) AS member_style
    WHERE member_style = ANY(v_place_preferred_styles);
    
    RETURN LEAST(100, (v_match_count::DECIMAL / array_length(v_place_preferred_styles, 1)) * 100);
END;
$$ LANGUAGE plpgsql;

-- 6. 복지 보너스 점수 계산
CREATE OR REPLACE FUNCTION calculate_welfare_bonus_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_member_welfare_prefs INT[];
    v_place_welfares INT[];
    v_match_count INT;
BEGIN
    -- Member가 원하는 복지
    SELECT ARRAY_AGG(mpl.attribute_id) INTO v_member_welfare_prefs
    FROM member_preferences_link mpl
    JOIN attributes a ON mpl.attribute_id = a.id
    WHERE mpl.member_user_id = p_member_id
    AND a.type = 'WELFARE';
    
    -- Place가 제공하는 복지
    SELECT ARRAY_AGG(pal.attribute_id) INTO v_place_welfares
    FROM place_attributes_link pal
    JOIN attributes a ON pal.attribute_id = a.id
    WHERE pal.place_user_id = p_place_id
    AND a.type = 'WELFARE';
    
    IF v_member_welfare_prefs IS NULL OR array_length(v_member_welfare_prefs, 1) = 0 THEN
        RETURN 0; -- 원하는 복지 없으면 보너스 없음
    END IF;
    
    -- 매칭 개수 계산
    SELECT COUNT(*) INTO v_match_count
    FROM unnest(v_member_welfare_prefs) AS member_pref
    WHERE member_pref = ANY(v_place_welfares);
    
    -- 보너스 점수 (최대 20점)
    RETURN LEAST(20, v_match_count * 5);
END;
$$ LANGUAGE plpgsql;