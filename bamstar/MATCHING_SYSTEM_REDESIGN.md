# 🎯 BamStar 매칭 시스템 재설계

## 📋 문제점 분석

### 기존 접근법의 문제
1. **matching_conditions JSONB + LLM 처리**
   - 10만+ 레코드를 LLM이 실시간 처리 불가능
   - API 호출 비용 폭발적 증가 (레코드당 $0.01 × 100,000 = $1,000/요청)
   - 응답 시간 비현실적 (레코드당 1초 × 100,000 = 27시간)
   - JSONB 인덱싱 제한으로 쿼리 성능 저하

## 🏗️ 새로운 매칭 아키텍처

### 핵심 설계 원칙
1. **데이터베이스 네이티브 매칭**: SQL JOIN과 인덱스 활용
2. **점수 사전 계산**: 실시간 계산 대신 배치 처리
3. **다단계 필터링**: 하드 필터 → 소프트 필터 → 점수 정렬
4. **캐싱 전략**: 자주 매칭되는 프로필 메모리 캐싱

## 📊 테이블 설계

### 1. 매칭 점수 테이블 (핵심)
```sql
-- 기존 matching_conditions JSONB 필드 제거
ALTER TABLE member_profiles DROP COLUMN IF EXISTS matching_conditions;
ALTER TABLE place_profiles DROP COLUMN IF EXISTS matching_conditions;

-- 매칭 점수 사전 계산 테이블
CREATE TABLE matching_scores (
    id BIGSERIAL PRIMARY KEY,
    member_user_id UUID NOT NULL REFERENCES member_profiles(user_id) ON DELETE CASCADE,
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id) ON DELETE CASCADE,
    
    -- 매칭 점수 (0-100)
    total_score DECIMAL(5,2) NOT NULL DEFAULT 0,
    
    -- 세부 점수
    attribute_match_score DECIMAL(5,2) DEFAULT 0,  -- 속성 일치도
    preference_match_score DECIMAL(5,2) DEFAULT 0,  -- 선호도 일치도
    location_match_score DECIMAL(5,2) DEFAULT 0,    -- 위치 근접도
    pay_match_score DECIMAL(5,2) DEFAULT 0,         -- 급여 조건 일치도
    schedule_match_score DECIMAL(5,2) DEFAULT 0,    -- 근무일정 일치도
    
    -- 매칭 방향성
    member_to_place_score DECIMAL(5,2) DEFAULT 0,   -- 멤버→플레이스 점수
    place_to_member_score DECIMAL(5,2) DEFAULT 0,   -- 플레이스→멤버 점수
    
    -- 매칭 상태
    is_mutual_match BOOLEAN DEFAULT FALSE,          -- 양방향 매칭 여부
    match_rank INTEGER,                             -- 매칭 순위
    
    -- 메타데이터
    calculated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '7 days',
    
    -- 유니크 제약
    CONSTRAINT unique_matching_pair UNIQUE(member_user_id, place_user_id)
);

-- 인덱스 (성능 최적화)
CREATE INDEX idx_matching_scores_member ON matching_scores(member_user_id, total_score DESC);
CREATE INDEX idx_matching_scores_place ON matching_scores(place_user_id, total_score DESC);
CREATE INDEX idx_matching_scores_mutual ON matching_scores(is_mutual_match, total_score DESC) 
    WHERE is_mutual_match = true;
CREATE INDEX idx_matching_scores_fresh ON matching_scores(expires_at) 
    WHERE expires_at > NOW();
```

### 2. 매칭 가중치 설정
```sql
-- 매칭 요소별 가중치 (관리자가 조정 가능)
CREATE TABLE matching_weights (
    id SERIAL PRIMARY KEY,
    factor_name TEXT NOT NULL UNIQUE,
    weight DECIMAL(3,2) NOT NULL DEFAULT 1.0,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 기본 가중치 설정
INSERT INTO matching_weights (factor_name, weight, description) VALUES
    ('pay_type', 2.0, '급여 지급 방식'),
    ('pay_amount', 1.8, '급여 금액'),
    ('experience_level', 1.5, '경력 수준'),
    ('location', 1.5, '위치/지역'),
    ('working_days', 1.3, '근무 요일'),
    ('industry', 1.2, '업종'),
    ('job_role', 1.2, '직무'),
    ('style', 0.8, '스타일/성격'),
    ('welfare', 0.7, '복지/혜택'),
    ('place_feature', 0.6, '가게 특징');
```

### 3. 매칭 필터 (하드 조건)
```sql
-- 필수 매칭 조건 (반드시 만족해야 하는 조건)
CREATE TABLE matching_filters (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_type TEXT NOT NULL CHECK (user_type IN ('MEMBER', 'PLACE')),
    
    -- 하드 필터 (필수 조건)
    min_pay_amount INTEGER,
    max_pay_amount INTEGER,
    required_experience_levels experience_level_enum[],
    required_pay_types pay_type_enum[],
    max_distance_km INTEGER,                        -- 최대 거리
    
    -- 제외 조건
    excluded_user_ids UUID[],                       -- 차단/제외할 사용자
    excluded_industries INTEGER[],                  -- 제외할 업종 (attribute_id)
    
    -- 필터 활성화
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- 유니크 제약
    CONSTRAINT unique_user_filter UNIQUE(user_id)
);
```

### 4. 매칭 히스토리 (학습 데이터)
```sql
-- 매칭 시도 및 결과 기록
CREATE TABLE matching_history (
    id BIGSERIAL PRIMARY KEY,
    member_user_id UUID NOT NULL REFERENCES member_profiles(user_id),
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id),
    
    -- 매칭 이벤트
    event_type TEXT NOT NULL CHECK (event_type IN (
        'VIEW', 'LIKE', 'CONTACT', 'INTERVIEW', 'HIRE', 'REJECT', 'CANCEL'
    )),
    
    -- 매칭 점수 스냅샷
    score_at_event DECIMAL(5,2),
    
    -- 피드백
    feedback_rating INTEGER CHECK (feedback_rating BETWEEN 1 AND 5),
    feedback_text TEXT,
    
    -- 메타데이터
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- 인덱스
CREATE INDEX idx_matching_history_member ON matching_history(member_user_id, created_at DESC);
CREATE INDEX idx_matching_history_place ON matching_history(place_user_id, created_at DESC);
CREATE INDEX idx_matching_history_event ON matching_history(event_type, created_at DESC);
```

### 5. 매칭 큐 (실시간 처리)
```sql
-- 매칭 계산 대기열
CREATE TABLE matching_queue (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    user_type TEXT NOT NULL CHECK (user_type IN ('MEMBER', 'PLACE')),
    action TEXT NOT NULL CHECK (action IN ('FULL_RECALC', 'PARTIAL_UPDATE', 'NEW_USER')),
    priority INTEGER DEFAULT 5,
    
    -- 처리 상태
    status TEXT DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')),
    processed_at TIMESTAMPTZ,
    error_message TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_matching_queue_pending ON matching_queue(priority DESC, created_at) 
    WHERE status = 'PENDING';
```

## 🎯 매칭 알고리즘

### 1. 점수 계산 함수
```sql
-- 메인 매칭 점수 계산 함수
CREATE OR REPLACE FUNCTION calculate_matching_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS TABLE (
    total_score DECIMAL,
    attribute_score DECIMAL,
    preference_score DECIMAL,
    location_score DECIMAL,
    pay_score DECIMAL,
    schedule_score DECIMAL
) AS $$
DECLARE
    v_attribute_score DECIMAL := 0;
    v_preference_score DECIMAL := 0;
    v_location_score DECIMAL := 0;
    v_pay_score DECIMAL := 0;
    v_schedule_score DECIMAL := 0;
    v_total_score DECIMAL := 0;
BEGIN
    -- 1. 속성 매칭 점수 (멤버 속성 ∩ 플레이스가 원하는 속성)
    SELECT COUNT(*)::DECIMAL / NULLIF(
        (SELECT COUNT(*) FROM place_preferences_link WHERE place_user_id = p_place_id), 0
    ) * 100
    INTO v_attribute_score
    FROM member_attributes_link mal
    INNER JOIN place_preferences_link ppl ON mal.attribute_id = ppl.attribute_id
    WHERE mal.member_user_id = p_member_id 
    AND ppl.place_user_id = p_place_id;
    
    -- 2. 선호도 매칭 점수 (플레이스 속성 ∩ 멤버가 원하는 속성)
    SELECT COUNT(*)::DECIMAL / NULLIF(
        (SELECT COUNT(*) FROM member_preferences_link WHERE member_user_id = p_member_id), 0
    ) * 100
    INTO v_preference_score
    FROM place_attributes_link pal
    INNER JOIN member_preferences_link mpl ON pal.attribute_id = mpl.attribute_id
    WHERE pal.place_user_id = p_place_id 
    AND mpl.member_user_id = p_member_id;
    
    -- 3. 위치 매칭 점수 (공통 선호 지역)
    SELECT COUNT(*)::DECIMAL / GREATEST(
        (SELECT COUNT(*) FROM member_preferred_area_groups WHERE member_user_id = p_member_id),
        (SELECT COUNT(*) FROM place_preferred_area_groups WHERE place_user_id = p_place_id),
        1
    ) * 100
    INTO v_location_score
    FROM member_preferred_area_groups mpag
    INNER JOIN place_preferred_area_groups ppag ON mpag.group_id = ppag.group_id
    WHERE mpag.member_user_id = p_member_id 
    AND ppag.place_user_id = p_place_id;
    
    -- 4. 급여 조건 매칭
    WITH pay_match AS (
        SELECT 
            CASE 
                WHEN mp.desired_pay_type = pp.desired_pay_type THEN 50
                WHEN mp.desired_pay_type = 'NEGOTIABLE' OR pp.desired_pay_type = 'NEGOTIABLE' THEN 30
                ELSE 0
            END +
            CASE 
                WHEN mp.desired_pay_amount BETWEEN pp.desired_pay_amount * 0.8 
                    AND pp.desired_pay_amount * 1.2 THEN 50
                WHEN mp.desired_pay_amount BETWEEN pp.desired_pay_amount * 0.6 
                    AND pp.desired_pay_amount * 1.4 THEN 25
                ELSE 0
            END AS score
        FROM member_profiles mp, place_profiles pp
        WHERE mp.user_id = p_member_id AND pp.user_id = p_place_id
    )
    SELECT score INTO v_pay_score FROM pay_match;
    
    -- 5. 근무일정 매칭
    WITH schedule_match AS (
        SELECT 
            array_length(
                ARRAY(
                    SELECT unnest(mp.desired_working_days) 
                    INTERSECT 
                    SELECT unnest(pp.desired_working_days)
                ), 1
            )::DECIMAL / 
            NULLIF(array_length(pp.desired_working_days, 1), 0) * 100 AS score
        FROM member_profiles mp, place_profiles pp
        WHERE mp.user_id = p_member_id AND pp.user_id = p_place_id
    )
    SELECT COALESCE(score, 0) INTO v_schedule_score FROM schedule_match;
    
    -- 가중치 적용하여 총점 계산
    SELECT 
        (v_attribute_score * w1.weight + 
         v_preference_score * w2.weight + 
         v_location_score * w3.weight + 
         v_pay_score * w4.weight + 
         v_schedule_score * w5.weight) / 
        (w1.weight + w2.weight + w3.weight + w4.weight + w5.weight)
    INTO v_total_score
    FROM 
        matching_weights w1,
        matching_weights w2,
        matching_weights w3,
        matching_weights w4,
        matching_weights w5
    WHERE 
        w1.factor_name = 'style' AND
        w2.factor_name = 'industry' AND
        w3.factor_name = 'location' AND
        w4.factor_name = 'pay_amount' AND
        w5.factor_name = 'working_days';
    
    RETURN QUERY SELECT 
        v_total_score,
        v_attribute_score,
        v_preference_score,
        v_location_score,
        v_pay_score,
        v_schedule_score;
END;
$$ LANGUAGE plpgsql;
```

### 2. 배치 매칭 업데이트
```sql
-- 배치로 매칭 점수 업데이트
CREATE OR REPLACE FUNCTION batch_update_matching_scores(
    p_limit INTEGER DEFAULT 1000
) RETURNS INTEGER AS $$
DECLARE
    v_updated_count INTEGER := 0;
BEGIN
    -- 만료된 점수 재계산
    WITH expired_matches AS (
        SELECT DISTINCT ON (member_user_id, place_user_id)
            member_user_id, 
            place_user_id
        FROM matching_scores
        WHERE expires_at < NOW()
        LIMIT p_limit
    ),
    calculated AS (
        SELECT 
            em.member_user_id,
            em.place_user_id,
            calc.*
        FROM expired_matches em
        CROSS JOIN LATERAL calculate_matching_score(em.member_user_id, em.place_user_id) calc
    )
    INSERT INTO matching_scores (
        member_user_id, 
        place_user_id,
        total_score,
        attribute_match_score,
        preference_match_score,
        location_match_score,
        pay_match_score,
        schedule_match_score,
        calculated_at,
        expires_at
    )
    SELECT 
        member_user_id,
        place_user_id,
        total_score,
        attribute_score,
        preference_score,
        location_score,
        pay_score,
        schedule_score,
        NOW(),
        NOW() + INTERVAL '7 days'
    FROM calculated
    ON CONFLICT (member_user_id, place_user_id) 
    DO UPDATE SET
        total_score = EXCLUDED.total_score,
        attribute_match_score = EXCLUDED.attribute_match_score,
        preference_match_score = EXCLUDED.preference_match_score,
        location_match_score = EXCLUDED.location_match_score,
        pay_match_score = EXCLUDED.pay_match_score,
        schedule_match_score = EXCLUDED.schedule_match_score,
        calculated_at = EXCLUDED.calculated_at,
        expires_at = EXCLUDED.expires_at;
    
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    RETURN v_updated_count;
END;
$$ LANGUAGE plpgsql;
```

### 3. 실시간 매칭 쿼리
```sql
-- Place가 최적의 Member 찾기
CREATE OR REPLACE FUNCTION find_best_members_for_place(
    p_place_id UUID,
    p_limit INTEGER DEFAULT 20
) RETURNS TABLE (
    member_id UUID,
    member_name TEXT,
    total_score DECIMAL,
    is_mutual_match BOOLEAN,
    match_details JSONB
) AS $$
BEGIN
    RETURN QUERY
    WITH filtered_members AS (
        -- 1단계: 하드 필터 적용
        SELECT DISTINCT mp.user_id
        FROM member_profiles mp
        INNER JOIN users u ON mp.user_id = u.id
        LEFT JOIN matching_filters mf ON u.id = mf.user_id
        WHERE 
            -- 활성 사용자만
            u.role_id = 6 -- MEMBER role
            AND NOT EXISTS (
                SELECT 1 FROM user_blocks ub 
                WHERE ub.blocked_user_id = mp.user_id 
                AND ub.blocker_id = p_place_id
            )
            -- 급여 조건 필터
            AND (
                mf.min_pay_amount IS NULL OR 
                (SELECT desired_pay_amount FROM place_profiles WHERE user_id = p_place_id) >= mf.min_pay_amount
            )
            AND (
                mf.max_pay_amount IS NULL OR 
                (SELECT desired_pay_amount FROM place_profiles WHERE user_id = p_place_id) <= mf.max_pay_amount
            )
    ),
    scored_members AS (
        -- 2단계: 점수 조회 또는 계산
        SELECT 
            fm.user_id,
            COALESCE(ms.total_score, 
                (SELECT total_score FROM calculate_matching_score(fm.user_id, p_place_id))
            ) AS score,
            ms.attribute_match_score,
            ms.preference_match_score,
            ms.location_match_score,
            ms.pay_match_score,
            ms.schedule_match_score,
            ms.is_mutual_match
        FROM filtered_members fm
        LEFT JOIN matching_scores ms ON 
            ms.member_user_id = fm.user_id 
            AND ms.place_user_id = p_place_id
            AND ms.expires_at > NOW()
    )
    SELECT 
        sm.user_id AS member_id,
        u.nickname AS member_name,
        sm.score AS total_score,
        sm.is_mutual_match,
        jsonb_build_object(
            'attribute_score', sm.attribute_match_score,
            'preference_score', sm.preference_match_score,
            'location_score', sm.location_match_score,
            'pay_score', sm.pay_match_score,
            'schedule_score', sm.schedule_match_score
        ) AS match_details
    FROM scored_members sm
    INNER JOIN users u ON sm.user_id = u.id
    ORDER BY 
        sm.is_mutual_match DESC,  -- 상호 매칭 우선
        sm.score DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Member가 최적의 Place 찾기 (대칭 함수)
CREATE OR REPLACE FUNCTION find_best_places_for_member(
    p_member_id UUID,
    p_limit INTEGER DEFAULT 20
) RETURNS TABLE (
    place_id UUID,
    place_name TEXT,
    total_score DECIMAL,
    is_mutual_match BOOLEAN,
    match_details JSONB
) AS $$
BEGIN
    -- Place 버전과 동일한 로직으로 구현
    -- (코드 중복 방지를 위해 생략, 실제로는 대칭적으로 구현)
END;
$$ LANGUAGE plpgsql;
```

## 🚀 성능 최적화 전략

### 1. 파티셔닝
```sql
-- matching_scores 테이블을 월별로 파티셔닝
CREATE TABLE matching_scores_2025_08 PARTITION OF matching_scores
    FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

CREATE TABLE matching_scores_2025_09 PARTITION OF matching_scores
    FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');
```

### 2. materialized View (상위 매칭)
```sql
-- 인기 매칭 materialized view
CREATE MATERIALIZED VIEW top_matches AS
SELECT 
    member_user_id,
    place_user_id,
    total_score,
    ROW_NUMBER() OVER (PARTITION BY member_user_id ORDER BY total_score DESC) as member_rank,
    ROW_NUMBER() OVER (PARTITION BY place_user_id ORDER BY total_score DESC) as place_rank
FROM matching_scores
WHERE 
    expires_at > NOW()
    AND total_score > 70
WITH DATA;

-- 인덱스
CREATE INDEX idx_top_matches_member ON top_matches(member_user_id, member_rank);
CREATE INDEX idx_top_matches_place ON top_matches(place_user_id, place_rank);

-- 주기적 리프레시 (1시간마다)
CREATE OR REPLACE FUNCTION refresh_top_matches() RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY top_matches;
END;
$$ LANGUAGE plpgsql;
```

### 3. 트리거 기반 실시간 업데이트
```sql
-- 프로필 변경 시 매칭 큐에 추가
CREATE OR REPLACE FUNCTION queue_matching_update() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO matching_queue (user_id, user_type, action, priority)
    VALUES (
        NEW.user_id,
        CASE 
            WHEN TG_TABLE_NAME = 'member_profiles' THEN 'MEMBER'
            WHEN TG_TABLE_NAME = 'place_profiles' THEN 'PLACE'
        END,
        'PARTIAL_UPDATE',
        5
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_member_profile_matching_update
    AFTER UPDATE ON member_profiles
    FOR EACH ROW
    WHEN (
        OLD.desired_pay_type IS DISTINCT FROM NEW.desired_pay_type OR
        OLD.desired_pay_amount IS DISTINCT FROM NEW.desired_pay_amount OR
        OLD.desired_working_days IS DISTINCT FROM NEW.desired_working_days OR
        OLD.experience_level IS DISTINCT FROM NEW.experience_level
    )
    EXECUTE FUNCTION queue_matching_update();

CREATE TRIGGER trigger_place_profile_matching_update
    AFTER UPDATE ON place_profiles
    FOR EACH ROW
    WHEN (
        OLD.desired_pay_type IS DISTINCT FROM NEW.desired_pay_type OR
        OLD.desired_pay_amount IS DISTINCT FROM NEW.desired_pay_amount OR
        OLD.desired_working_days IS DISTINCT FROM NEW.desired_working_days OR
        OLD.desired_experience_level IS DISTINCT FROM NEW.desired_experience_level
    )
    EXECUTE FUNCTION queue_matching_update();
```

## 📊 예상 성능 지표

### Before (JSONB + LLM)
- 매칭 시간: 10만 레코드 × 1초 = 27시간
- API 비용: $1,000/요청
- 확장성: 불가능

### After (SQL 기반)
- 매칭 시간: 50-200ms (인덱스 활용)
- 비용: 서버 비용만
- 확장성: 선형적 확장 가능
- 캐시 히트율: 80%+ (상위 매칭)

## 🔄 마이그레이션 계획

### Phase 1: 테이블 생성 (Week 1)
```sql
-- 1. 새 테이블 생성
CREATE TABLE matching_scores ...
CREATE TABLE matching_weights ...
CREATE TABLE matching_filters ...
CREATE TABLE matching_history ...
CREATE TABLE matching_queue ...

-- 2. 인덱스 생성
CREATE INDEX ...

-- 3. 함수 생성
CREATE FUNCTION calculate_matching_score ...
CREATE FUNCTION find_best_members_for_place ...
```

### Phase 2: 데이터 마이그레이션 (Week 2)
```sql
-- 1. matching_conditions JSONB 제거 준비
ALTER TABLE member_profiles 
    ALTER COLUMN matching_conditions SET DEFAULT NULL;

-- 2. 초기 매칭 점수 계산 (배치)
SELECT batch_update_matching_scores(10000);

-- 3. 트리거 활성화
CREATE TRIGGER ...
```

### Phase 3: 검증 및 최적화 (Week 3)
```sql
-- 1. 성능 테스트
EXPLAIN ANALYZE SELECT * FROM find_best_members_for_place(...);

-- 2. 인덱스 튜닝
CREATE INDEX CONCURRENTLY ...

-- 3. matching_conditions 컬럼 제거
ALTER TABLE member_profiles DROP COLUMN matching_conditions;
ALTER TABLE place_profiles DROP COLUMN matching_conditions;
```

## 🎯 Flutter 서비스 레이어 업데이트

### MatchingService 수정
```dart
class MatchingService {
  // 기존 LLM 기반 코드 제거
  // Future<List<Match>> findMatchesWithAI() { ... } // DEPRECATED
  
  // 새로운 SQL 기반 매칭
  Future<List<Match>> findBestMatches({
    required String userId,
    required UserType userType,
    int limit = 20,
  }) async {
    final result = await supabase.rpc(
      userType == UserType.member 
        ? 'find_best_places_for_member'
        : 'find_best_members_for_place',
      params: {
        'p_${userType.name}_id': userId,
        'p_limit': limit,
      },
    );
    
    return result.map((r) => Match.fromJson(r)).toList();
  }
  
  // 매칭 이벤트 기록
  Future<void> recordMatchingEvent({
    required String memberId,
    required String placeId,
    required MatchingEvent event,
  }) async {
    await supabase.from('matching_history').insert({
      'member_user_id': memberId,
      'place_user_id': placeId,
      'event_type': event.name,
    });
  }
}
```

## 📈 모니터링 및 분석

### 매칭 품질 메트릭
```sql
-- 매칭 성공률
CREATE VIEW matching_success_rate AS
SELECT 
    DATE_TRUNC('day', created_at) AS date,
    COUNT(*) FILTER (WHERE event_type = 'HIRE') AS successful_matches,
    COUNT(*) AS total_matches,
    COUNT(*) FILTER (WHERE event_type = 'HIRE')::DECIMAL / NULLIF(COUNT(*), 0) * 100 AS success_rate
FROM matching_history
GROUP BY DATE_TRUNC('day', created_at);

-- 평균 매칭 점수
CREATE VIEW avg_matching_scores AS
SELECT 
    AVG(total_score) AS avg_score,
    AVG(total_score) FILTER (WHERE is_mutual_match) AS avg_mutual_score,
    COUNT(*) FILTER (WHERE is_mutual_match) AS mutual_match_count
FROM matching_scores
WHERE expires_at > NOW();
```

## 🔑 핵심 개선사항

1. **확장성**: 10만+ 레코드도 실시간 처리 가능
2. **비용 효율성**: LLM API 비용 제거
3. **성능**: 밀리초 단위 응답 시간
4. **유지보수성**: SQL 기반으로 디버깅 용이
5. **학습 가능**: matching_history로 알고리즘 개선 가능