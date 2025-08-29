-- 급여 매칭 점수 계산 함수 수정
-- Member가 입력한 금액을 "최소 희망 급여"로 처리하도록 수정

CREATE OR REPLACE FUNCTION calculate_pay_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_member_min_pay INT;
    v_place_min INT;
    v_place_max INT;
BEGIN
    -- Member의 최소 희망 급여 (예: 12만원 = 12만원 이상 원함)
    SELECT desired_pay_amount INTO v_member_min_pay
    FROM member_profiles
    WHERE user_id = p_member_id;
    
    -- Place가 제공하는 급여 범위
    SELECT offered_min_pay, offered_max_pay 
    INTO v_place_min, v_place_max
    FROM place_profiles
    WHERE user_id = p_place_id;
    
    -- 정보가 없는 경우
    IF v_member_min_pay IS NULL OR v_place_max IS NULL THEN
        RETURN 50; -- 정보 없으면 중간 점수
    END IF;
    
    -- Place가 Member의 최소 요구 급여 이상 제공 가능한지 확인
    IF v_place_max >= v_member_min_pay THEN
        -- 조건 만족: Place가 충분히 제공 가능
        IF v_member_min_pay BETWEEN COALESCE(v_place_min, 0) AND v_place_max THEN
            RETURN 100; -- 완벽한 범위 내 매칭
        ELSE
            RETURN 90;  -- 최소 조건은 만족하지만 범위 밖
        END IF;
    ELSE
        -- 조건 불만족: Place 최대 제공액 < Member 최소 요구액
        RETURN 0;   -- 매칭 불가능
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 예시:
-- Member: 12만원 원함 (12만원 이상)
-- Place A: 10~15만원 → 15 >= 12 AND 12 BETWEEN 10 AND 15 → 100점 ✅
-- Place B: 15~20만원 → 20 >= 12 AND 12 < 15 → 90점 ✅  
-- Place C: 8~10만원  → 10 < 12 → 0점 ✅