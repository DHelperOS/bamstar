# BamStar Supabase Database 완전한 참조 문서

**프로젝트**: BamStar  
**프로젝트 ID**: tflvicpgyycvhttctcek  
**지역**: Northeast Asia (Seoul)  
**최종 업데이트**: 2025년 8월 29일 (새로운 테이블 및 함수 추가)

---

## 📊 데이터베이스 구조 개요

### 전체 테이블 목록 (37개)

#### 👤 사용자 관련 (3개)
1. **users** - 사용자 기본 정보
2. **roles** - 역할 관리 (Member/Place)
3. **devices** - 디바이스 관리

#### 🌟 Member(스타) 관련 (4개)
4. **member_profiles** - 멤버 프로필 정보
5. **member_attributes_link** - 멤버 속성 연결
6. **member_preferences_link** - 멤버 선호도 연결
7. **member_preferred_area_groups** - 멤버 선호 지역

#### 🏢 Place(플레이스) 관련 (4개) ✨NEW
8. **place_profiles** - 플레이스 프로필 정보
9. **place_attributes_link** - 플레이스 속성 연결
10. **place_preferences_link** - 플레이스 선호도 연결
11. **place_industries** - 플레이스 업종 정보

#### ❤️ 상호작용 관련 (5개) ✨NEW
12. **member_hearts** - 멤버가 보낸 좋아요
13. **place_hearts** - 플레이스가 보낸 좋아요
14. **member_favorites** - 멤버 즐겨찾기
15. **place_favorites** - 플레이스 즐겨찾기
16. **mutual_matches** (VIEW) - 상호 매칭 뷰

#### 🎯 매칭 시스템 (5개) ✨NEW
17. **matching_scores** - 매칭 점수 캐시
18. **matching_weights** - 사용자별 가중치 설정
19. **matching_filters** - 매칭 필터 설정
20. **matching_queue** - 매칭 처리 큐
21. **matching_history** - 매칭 히스토리

#### 📍 지역 관련 (3개)
22. **area_groups** - 지역 그룹 관리
23. **area_keywords** - 지역 키워드 매핑
24. **main_categories** - 주요 카테고리

#### 🎨 속성 관련 (1개)
25. **attributes** - 속성 마스터 (업종, 직무, 스타일 등)

#### 📱 커뮤니티 관련 (8개)
26. **community_posts** - 커뮤니티 게시물
27. **community_comments** - 댓글
28. **community_likes** - 좋아요
29. **community_hashtags** - 해시태그 마스터
30. **post_hashtags** - 게시물-해시태그 연결
31. **community_subscriptions** - 해시태그 구독
32. **community_reports** - 신고 시스템
33. **user_blocks** - 사용자 차단

#### 📊 통계 관련 (2개)
34. **daily_hashtag_curation** - 일일 해시태그 큐레이션
35. **trending_hashtags_cache** - 인기 해시태그 캐시

#### 📋 기타 (2개)
36. **push_tokens** - 푸시 알림 토큰
37. **terms** - 약관 관리
38. **user_term_agreements** - 약관 동의

---

## 🏢 Place 관련 테이블 (신규)

### place_profiles
```sql
CREATE TABLE place_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id),
    business_name VARCHAR(255) NOT NULL,
    business_type VARCHAR(50) NOT NULL,
    business_number VARCHAR(20) NOT NULL,
    homepage VARCHAR(255),
    
    -- 위치 정보 (정확한 주소)
    address VARCHAR(500) NOT NULL,
    address_detail VARCHAR(255),
    area_group_id INT REFERENCES area_groups(group_id),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- 근무 조건
    offered_min_pay INT,
    offered_max_pay INT,
    work_days_per_week INT,
    work_hours_per_day INT,
    work_start_time TIME,
    work_end_time TIME,
    
    -- 매니저 정보
    manager_name VARCHAR(100),
    manager_phone VARCHAR(20),
    manager_email VARCHAR(255),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### place_attributes_link
```sql
CREATE TABLE place_attributes_link (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_user_id UUID NOT NULL REFERENCES users(id),
    attribute_id INT NOT NULL REFERENCES attributes(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### place_preferences_link
```sql
CREATE TABLE place_preferences_link (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_user_id UUID NOT NULL REFERENCES users(id),
    attribute_id INT NOT NULL REFERENCES attributes(id),
    preference_level VARCHAR(20) DEFAULT 'preferred',
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### place_industries
```sql
CREATE TABLE place_industries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_user_id UUID NOT NULL REFERENCES users(id),
    attribute_id INT NOT NULL REFERENCES attributes(id),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## ❤️ 상호작용 테이블 (신규)

### member_hearts
```sql
CREATE TABLE member_hearts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_user_id UUID NOT NULL REFERENCES users(id),
    place_user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending',
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    responded_at TIMESTAMPTZ,
    UNIQUE(member_user_id, place_user_id)
);
```

### place_hearts
```sql
CREATE TABLE place_hearts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_user_id UUID NOT NULL REFERENCES users(id),
    member_user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending',
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    responded_at TIMESTAMPTZ,
    UNIQUE(place_user_id, member_user_id)
);
```

### mutual_matches (VIEW)
```sql
CREATE VIEW mutual_matches AS
SELECT DISTINCT
    LEAST(mh.member_user_id, ph.place_user_id) as member_user_id,
    GREATEST(mh.member_user_id, ph.place_user_id) as place_user_id,
    GREATEST(mh.sent_at, ph.sent_at) as matched_at
FROM member_hearts mh
JOIN place_hearts ph ON 
    mh.member_user_id = ph.member_user_id AND 
    mh.place_user_id = ph.place_user_id
WHERE mh.status = 'accepted' AND ph.status = 'accepted';
```

---

## 🎯 매칭 시스템 테이블 (신규)

### matching_scores
```sql
CREATE TABLE matching_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_user_id UUID NOT NULL REFERENCES users(id),
    place_user_id UUID NOT NULL REFERENCES users(id),
    total_score DECIMAL(5,2) NOT NULL,
    job_role_score DECIMAL(5,2),
    industry_score DECIMAL(5,2),
    style_score DECIMAL(5,2),
    location_score DECIMAL(5,2),
    pay_score DECIMAL(5,2),
    welfare_bonus DECIMAL(5,2),
    calculated_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    UNIQUE(member_user_id, place_user_id)
);
```

### matching_weights
```sql
CREATE TABLE matching_weights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    job_role_weight DECIMAL(3,2) DEFAULT 0.40,
    industry_weight DECIMAL(3,2) DEFAULT 0.20,
    style_weight DECIMAL(3,2) DEFAULT 0.15,
    location_weight DECIMAL(3,2) DEFAULT 0.15,
    pay_weight DECIMAL(3,2) DEFAULT 0.10,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);
```

---

## 🔧 PostgreSQL 함수 (신규)

### 1. calculate_location_match_score
```sql
-- 지역 기반 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_location_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL;
```

### 2. calculate_pay_match_score
```sql
-- 급여 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_pay_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL;
```

### 3. calculate_job_role_match_score
```sql
-- 직무 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_job_role_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL;
```

### 4. calculate_industry_match_score
```sql
-- 업종 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_industry_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL;
```

### 5. calculate_style_match_score
```sql
-- 스타일 매칭 점수 계산
CREATE OR REPLACE FUNCTION calculate_style_match_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL;
```

### 6. calculate_welfare_bonus_score
```sql
-- 복지 보너스 점수 계산
CREATE OR REPLACE FUNCTION calculate_welfare_bonus_score(
    p_member_id UUID,
    p_place_id UUID
) RETURNS DECIMAL;
```

---

## 🚀 Edge Functions (신규)

### 1. match-calculator
- **용도**: 개별 매칭 점수 계산
- **엔드포인트**: `/match-calculator`
- **메서드**: POST
- **파라미터**: `memberId`, `placeId`, `forceRecalculate`

### 2. match-finder
- **용도**: 매칭 목록 조회
- **엔드포인트**: `/match-finder`
- **메서드**: POST
- **파라미터**: `userId`, `userType`, `limit`, `offset`, `minScore`

### 3. hearts-manager
- **용도**: 좋아요 관리
- **엔드포인트**: `/hearts-manager`
- **메서드**: POST
- **액션**: `send`, `accept`, `reject`, `check_mutual`

---

## 🔒 RLS (Row Level Security) 정책

### 핵심 정책
1. **Member는 모든 Place를 자유롭게 조회 가능**
2. **Place는 수락된 Member만 조회 가능**
3. **본인 데이터만 수정/삭제 가능**
4. **매칭 점수는 Service Role만 생성 가능**

### RLS 활성화 테이블
- ✅ place_profiles
- ✅ place_attributes_link
- ✅ place_preferences_link
- ✅ place_industries
- ✅ member_hearts
- ✅ place_hearts
- ✅ member_favorites
- ✅ place_favorites
- ✅ matching_scores
- ✅ matching_weights
- ✅ matching_filters
- ✅ matching_queue
- ✅ matching_history

---

## 📊 Enum 타입

### attribute_type_enum
```sql
CREATE TYPE attribute_type_enum AS ENUM (
    'INDUSTRY',      -- 업종
    'JOB_ROLE',      -- 직무
    'MEMBER_STYLE',  -- 멤버 스타일
    'PLACE_FEATURE', -- 플레이스 특징
    'WELFARE'        -- 복지
);
```

### preference_level_enum
```sql
CREATE TYPE preference_level_enum AS ENUM (
    'required',   -- 필수
    'preferred',  -- 선호
    'nice_to_have' -- 있으면 좋음
);
```

### heart_status_enum
```sql
CREATE TYPE heart_status_enum AS ENUM (
    'pending',   -- 대기중
    'accepted',  -- 수락됨
    'rejected'   -- 거절됨
);
```

---

## 📈 통계 정보

- **총 테이블 수**: 37개
- **신규 추가 테이블**: 13개 (Place 및 매칭 시스템)
- **PostgreSQL 함수**: 6개
- **Edge Functions**: 3개
- **RLS 정책 적용**: 13개 테이블

---

## 🔗 연결 정보

- **Project ID**: `tflvicpgyycvhttctcek`
- **Database URL**: `postgresql://postgres.tflvicpgyycvhttctcek:[PASSWORD]@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres`
- **API URL**: `https://tflvicpgyycvhttctcek.supabase.co`
- **Region**: Northeast Asia (Seoul)

---

**마지막 업데이트**: 2025년 8월 29일
**작성자**: Claude Code Assistant