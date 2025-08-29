# Place 데이터베이스 설계 청사진

## 📋 개요
Place(플레이스)는 Member(스타)와 매칭되는 사업장 엔티티입니다. Member와 대칭적인 구조를 가지며, 추가로 사업자 인증, 유료 모델, 소셜 기능(하트, 즐겨찾기) 등의 확장 기능을 포함합니다.

## 🏗️ 핵심 설계 원칙

1. **Member와의 대칭성**: Member 테이블 구조와 일대일 매칭되는 구조
2. **매칭 호환성**: Member와 Place 간 양방향 매칭이 가능한 구조
3. **확장 가능성**: 홍보 게시판, 유료 기능, 소셜 기능 추가 가능
4. **데이터 재사용성**: 기존 attributes, area_groups 등 마스터 테이블 재사용

## 📊 테이블 설계

### 1. place_profiles (플레이스 기본 정보)
```sql
CREATE TABLE place_profiles (
    -- 기본 정보
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    
    -- 플레이스 정보 (place_info_page.dart)
    place_name TEXT NOT NULL,                    -- 업체명
    business_type TEXT,                          -- 업종 (attributes 참조 가능)
    contact_phone TEXT,                          -- 연락처
    contact_email TEXT,                          -- 이메일
    
    -- 주소 정보
    address TEXT,                                -- 기본 주소
    address_detail TEXT,                         -- 상세 주소
    postal_code TEXT,                            -- 우편번호
    latitude DECIMAL(10,8),                      -- 위도
    longitude DECIMAL(11,8),                     -- 경도
    
    -- 운영 정보
    operating_hours JSONB,                       -- 운영 시간 {"mon": {"open": "18:00", "close": "02:00"}}
    established_date DATE,                       -- 설립일
    employee_count INTEGER,                      -- 직원 수
    
    -- 프로필 정보
    profile_image_urls TEXT[],                   -- 대표 이미지들
    interior_image_urls TEXT[],                  -- 인테리어 이미지들
    menu_image_urls TEXT[],                      -- 메뉴/서비스 이미지들
    description TEXT,                            -- 소개글
    promotion_text TEXT,                         -- 홍보 문구
    
    -- 매칭 조건 (place_matching_preferences_page.dart)
    desired_experience_level experience_level_enum,  -- 원하는 경력 수준
    desired_pay_type pay_type_enum,             -- 급여 지급 방식
    desired_pay_amount INTEGER,                 -- 급여 금액
    desired_working_days TEXT[],                -- 근무 요일
    
    -- 혜택 및 특징은 place_attributes_link 테이블에 저장
    -- WELFARE 타입 attributes는 place_attributes_link에
    -- PLACE_FEATURE 타입 attributes는 place_attributes_link에
    
    -- 레벨 시스템 (유료 모델 연동)
    level INTEGER NOT NULL DEFAULT 1,
    experience_points BIGINT NOT NULL DEFAULT 0,
    subscription_tier TEXT DEFAULT 'FREE',       -- FREE, BASIC, PREMIUM, ENTERPRISE
    
    -- 소셜 기능
    hearts_count INTEGER DEFAULT 0,              -- 받은 하트 수
    favorites_count INTEGER DEFAULT 0,           -- 즐겨찾기된 횟수
    view_count BIGINT DEFAULT 0,                 -- 조회수
    
    -- 상태 관리
    is_verified BOOLEAN DEFAULT FALSE,           -- 사업자 인증 여부
    is_active BOOLEAN DEFAULT TRUE,              -- 활성 상태
    is_hiring BOOLEAN DEFAULT TRUE,              -- 채용중 여부
    
    -- 타임스탬프
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_place_profiles_location ON place_profiles(latitude, longitude);
CREATE INDEX idx_place_profiles_subscription ON place_profiles(subscription_tier);
CREATE INDEX idx_place_profiles_hiring ON place_profiles(is_hiring, is_active);
```

### 2. place_business_verification (사업자 인증)
```sql
CREATE TABLE place_business_verification (
    id BIGSERIAL PRIMARY KEY,
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id) ON DELETE CASCADE,
    
    -- 사업자 정보 (business_verification_page.dart)
    business_number TEXT NOT NULL,               -- 사업자등록번호
    business_name TEXT NOT NULL,                 -- 사업자명
    representative_name TEXT NOT NULL,           -- 대표자명
    business_type TEXT,                          -- 업태
    business_category TEXT,                      -- 종목
    
    -- 인증 문서
    business_registration_url TEXT,              -- 사업자등록증 이미지
    business_permit_url TEXT,                    -- 영업허가증 이미지
    additional_documents JSONB,                  -- 추가 서류
    
    -- AI 검증 결과
    ai_verification_status TEXT DEFAULT 'PENDING',  -- PENDING, APPROVED, REJECTED, MANUAL_REVIEW
    ai_verification_result JSONB,                -- AI 분석 결과
    ai_confidence_score DECIMAL(3,2),            -- 신뢰도 점수 (0.00 ~ 1.00)
    
    -- 수동 검증
    manual_review_status TEXT,                   -- PENDING, APPROVED, REJECTED
    manual_review_notes TEXT,                    -- 검토 노트
    reviewed_by UUID REFERENCES users(id),       -- 검토자
    reviewed_at TIMESTAMPTZ,
    
    -- 상태 관리
    is_verified BOOLEAN DEFAULT FALSE,
    verification_expires_at DATE,                -- 인증 만료일
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 유니크 제약
ALTER TABLE place_business_verification 
ADD CONSTRAINT unique_business_number UNIQUE(business_number);
```

### 3. place_preferences_link (원하는 스타 조건)
```sql
CREATE TABLE place_preferences_link (
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id) ON DELETE CASCADE,
    attribute_id INTEGER NOT NULL REFERENCES attributes(id) ON DELETE CASCADE,
    PRIMARY KEY (place_user_id, attribute_id)
);

-- 이 테이블은 Place가 원하는 스타의 조건을 저장
-- attributes 테이블의 타입:
-- - JOB_ROLE: 필요한 직무
-- - MEMBER_STYLE: 원하는 스타일/성격
-- - 기타 매칭에 필요한 속성들
```

### 4. place_attributes_link (플레이스 자체 속성)
```sql
CREATE TABLE place_attributes_link (
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id) ON DELETE CASCADE,
    attribute_id INTEGER NOT NULL REFERENCES attributes(id) ON DELETE CASCADE,
    PRIMARY KEY (place_user_id, attribute_id)
);

-- 이 테이블은 Place 자신의 속성을 저장
-- attributes 테이블의 타입:
-- - INDUSTRY: 업종
-- - PLACE_FEATURE: 가게 특징
-- - WELFARE: 제공하는 복지/혜택
```

### 5. place_preferred_area_groups (플레이스 위치/활동 지역)
```sql
CREATE TABLE place_preferred_area_groups (
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id) ON DELETE CASCADE,
    group_id INTEGER NOT NULL REFERENCES area_groups(group_id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,            -- 주요 활동 지역 여부
    PRIMARY KEY (place_user_id, group_id)
);
```

### 6. place_subscription_plans (유료 구독 플랜)
```sql
CREATE TABLE place_subscription_plans (
    id BIGSERIAL PRIMARY KEY,
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id) ON DELETE CASCADE,
    
    -- 플랜 정보
    plan_type TEXT NOT NULL,                     -- BASIC, PREMIUM, ENTERPRISE
    price_monthly INTEGER NOT NULL,              -- 월 구독료
    price_yearly INTEGER,                        -- 연 구독료
    
    -- 구독 상태
    status TEXT DEFAULT 'ACTIVE',                -- ACTIVE, PAUSED, CANCELLED, EXPIRED
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    cancelled_at TIMESTAMPTZ,
    
    -- 혜택
    features JSONB,                              -- 플랜별 기능 {"priority_matching": true, "unlimited_posts": true}
    boost_level INTEGER DEFAULT 0,               -- 노출 부스트 레벨
    
    -- 결제 정보
    payment_method TEXT,                         -- CARD, BANK_TRANSFER, etc
    last_payment_at TIMESTAMPTZ,
    next_billing_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_place_subscription_status ON place_subscription_plans(status, expires_at);
```

### 7. place_hearts (하트/좋아요 기능)
```sql
CREATE TABLE place_hearts (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,        -- 하트를 준 사용자
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id) ON DELETE CASCADE,  -- 받은 플레이스
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- 유니크 제약 (한 사용자가 같은 플레이스에 하트는 하나만)
    CONSTRAINT unique_place_heart UNIQUE(user_id, place_user_id)
);

-- 인덱스
CREATE INDEX idx_place_hearts_place ON place_hearts(place_user_id);
CREATE INDEX idx_place_hearts_user ON place_hearts(user_id);
```

### 8. place_favorites (즐겨찾기)
```sql
CREATE TABLE place_favorites (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,        -- 즐겨찾기한 사용자
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id) ON DELETE CASCADE,  -- 즐겨찾기된 플레이스
    notes TEXT,                                                          -- 개인 메모
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- 유니크 제약
    CONSTRAINT unique_place_favorite UNIQUE(user_id, place_user_id)
);

-- 인덱스
CREATE INDEX idx_place_favorites_user ON place_favorites(user_id);
CREATE INDEX idx_place_favorites_place ON place_favorites(place_user_id);
```

### 9. place_promotion_boards (홍보 게시판 - 미래 확장)
```sql
-- 향후 홍보 게시판 기능을 위한 예약 테이블
CREATE TABLE place_promotion_boards (
    id BIGSERIAL PRIMARY KEY,
    place_user_id UUID NOT NULL REFERENCES place_profiles(user_id) ON DELETE CASCADE,
    
    -- 게시물 정보
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    image_urls TEXT[],
    video_urls TEXT[],
    
    -- 게시 옵션
    is_pinned BOOLEAN DEFAULT FALSE,             -- 상단 고정
    is_featured BOOLEAN DEFAULT FALSE,           -- 추천 게시물
    expires_at TIMESTAMPTZ,                      -- 만료일 (이벤트 등)
    
    -- 통계
    view_count BIGINT DEFAULT 0,
    click_count BIGINT DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    
    -- 상태
    status TEXT DEFAULT 'DRAFT',                 -- DRAFT, PUBLISHED, ARCHIVED
    published_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## 🔄 매칭 시스템 호환성

### Member ↔ Place 매칭 로직

```sql
-- 매칭 쿼리 예시
-- Place가 원하는 Member 찾기
SELECT m.* FROM member_profiles m
INNER JOIN member_attributes_link mal ON m.user_id = mal.member_user_id
WHERE mal.attribute_id IN (
    SELECT attribute_id FROM place_preferences_link 
    WHERE place_user_id = [PLACE_ID]
)
AND m.desired_pay_type = (SELECT desired_pay_type FROM place_profiles WHERE user_id = [PLACE_ID])
AND m.experience_level = (SELECT desired_experience_level FROM place_profiles WHERE user_id = [PLACE_ID]);

-- Member가 원하는 Place 찾기
SELECT p.* FROM place_profiles p
INNER JOIN place_attributes_link pal ON p.user_id = pal.place_user_id
WHERE pal.attribute_id IN (
    SELECT attribute_id FROM member_preferences_link 
    WHERE member_user_id = [MEMBER_ID]
)
AND p.desired_pay_type = (SELECT desired_pay_type FROM member_profiles WHERE user_id = [MEMBER_ID]);
```

## 🔑 RLS (Row Level Security) 정책

```sql
-- place_profiles RLS
ALTER TABLE place_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Places can read all active profiles" ON place_profiles
    FOR SELECT USING (is_active = true OR auth.uid() = user_id);

CREATE POLICY "Users can insert own place profile" ON place_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own place profile" ON place_profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own place profile" ON place_profiles
    FOR DELETE USING (auth.uid() = user_id);

-- place_business_verification RLS
ALTER TABLE place_business_verification ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own verification" ON place_business_verification
    FOR SELECT USING (
        auth.uid() = place_user_id OR 
        EXISTS (
            SELECT 1 FROM users u 
            JOIN roles r ON u.role_id = r.id 
            WHERE u.id = auth.uid() AND r.name = 'ADMIN'
        )
    );

-- 다른 테이블들도 동일한 패턴으로 RLS 적용
```

## 🎯 트리거 및 함수

```sql
-- updated_at 자동 업데이트 트리거
CREATE TRIGGER update_place_profiles_updated_at
    BEFORE UPDATE ON place_profiles
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 하트 수 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_place_hearts_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE place_profiles 
        SET hearts_count = hearts_count + 1 
        WHERE user_id = NEW.place_user_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE place_profiles 
        SET hearts_count = hearts_count - 1 
        WHERE user_id = OLD.place_user_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_place_hearts_count
    AFTER INSERT OR DELETE ON place_hearts
    FOR EACH ROW
    EXECUTE FUNCTION update_place_hearts_count();

-- 즐겨찾기 수 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_place_favorites_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE place_profiles 
        SET favorites_count = favorites_count + 1 
        WHERE user_id = NEW.place_user_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE place_profiles 
        SET favorites_count = favorites_count - 1 
        WHERE user_id = OLD.place_user_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_place_favorites_count
    AFTER INSERT OR DELETE ON place_favorites
    FOR EACH ROW
    EXECUTE FUNCTION update_place_favorites_count();

-- 사업자 인증 상태 동기화
CREATE OR REPLACE FUNCTION sync_place_verification_status()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE place_profiles 
    SET is_verified = NEW.is_verified 
    WHERE user_id = NEW.place_user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sync_place_verification
    AFTER UPDATE OF is_verified ON place_business_verification
    FOR EACH ROW
    EXECUTE FUNCTION sync_place_verification_status();
```

## 📈 성능 최적화 인덱스

```sql
-- 지역 기반 검색
CREATE INDEX idx_place_location_active ON place_profiles(latitude, longitude) 
    WHERE is_active = true AND is_hiring = true;

-- 매칭 검색 최적화
CREATE INDEX idx_place_matching ON place_profiles(desired_experience_level, desired_pay_type, is_active);

-- 구독 플랜별 검색
CREATE INDEX idx_place_subscription_tier ON place_profiles(subscription_tier) 
    WHERE is_active = true;

-- 인기순 정렬
CREATE INDEX idx_place_popularity ON place_profiles(hearts_count DESC, favorites_count DESC, view_count DESC);
```

## 🔄 마이그레이션 순서

1. **Phase 1: 기본 테이블 생성**
   - place_profiles
   - place_business_verification

2. **Phase 2: 매칭 관련 테이블**
   - place_preferences_link
   - place_attributes_link
   - place_preferred_area_groups

3. **Phase 3: 확장 기능**
   - place_subscription_plans
   - place_hearts
   - place_favorites

4. **Phase 4: 트리거 및 함수**
   - 모든 트리거 생성
   - 헬퍼 함수 생성

5. **Phase 5: RLS 정책**
   - 모든 테이블에 RLS 적용

## 📊 예상 데이터 볼륨

- place_profiles: ~10,000개 (초기), ~100,000개 (1년)
- place_hearts: ~1,000,000개 (1년)
- place_favorites: ~500,000개 (1년)
- place_business_verification: place_profiles와 1:1
- place_subscription_plans: ~3,000개 (유료 사용자 30%)

## 🎯 주요 쿼리 패턴

1. **지역 기반 Place 검색**
2. **매칭 조건에 맞는 Place 찾기**
3. **인기 Place 랭킹**
4. **구독 플랜별 Place 필터링**
5. **사업자 인증된 Place만 조회**

## 📝 참고사항

- 모든 테이블은 users 테이블의 role_id = 3 (PLACE)인 사용자와 연결
- attributes 테이블은 Member와 공유하여 일관성 유지
- area_groups도 기존 테이블 재사용
- 향후 홍보 게시판 기능을 위한 확장 가능한 구조
- 유료 모델과 소셜 기능을 위한 확장 가능한 구조