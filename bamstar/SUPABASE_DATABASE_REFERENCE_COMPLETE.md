# BamStar Supabase Database 완전한 참조 문서

**프로젝트**: BamStar  
**프로젝트 ID**: tflvicpgyycvhttctcek  
**지역**: Northeast Asia (Seoul)  
**생성일**: 2025년 8월 14일  
**최종 조회**: 2025년 8월 26일 (CLI 직접 조회)

---

## 📊 데이터베이스 구조 개요 (실제 조회 결과)

### 전체 테이블 목록 (16개)
✅ **CLI로 직접 조회한 정확한 테이블 목록**

1. **area_groups** - 지역 그룹 관리
2. **area_keywords** - 지역 키워드 매핑
3. **community_comments** - 커뮤니티 댓글
4. **community_hashtags** - 해시태그 마스터
5. **community_likes** - 좋아요 시스템
6. **community_posts** - 커뮤니티 게시물
7. **community_reports** - 신고 시스템 ✅
8. **community_subscriptions** - 해시태그 구독
9. **daily_hashtag_curation** - 일일 해시태그 큐레이션
10. **devices** - 디바이스 관리
11. **main_categories** - 주요 카테고리
12. **post_hashtags** - 게시물-해시태그 연결 테이블
13. **roles** - 역할 관리
14. **trending_hashtags_cache** - 인기 해시태그 캐시
15. **user_blocks** - 사용자 차단 시스템 ✅
16. **users** - 사용자 정보

---

## 📋 테이블 상세 스키마 (실제 조회)

### 1. area_groups
**목적**: 지역 그룹 분류 관리
```sql
CREATE TABLE area_groups (
    group_id INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES main_categories(category_id),
    name VARCHAR(100) NOT NULL
);
```

### 2. area_keywords  
**목적**: 지역별 키워드 매핑
```sql
CREATE TABLE area_keywords (
    keyword_id INTEGER PRIMARY KEY,
    keyword VARCHAR(50) UNIQUE NOT NULL,
    group_id INTEGER NOT NULL REFERENCES area_groups(group_id)
);
```
**인덱스**: `idx_area_keywords_keyword`

### 3. community_comments
**목적**: 게시물 댓글 시스템
```sql
CREATE TABLE community_comments (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT REFERENCES community_posts(id) ON DELETE CASCADE,
    author_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4. community_hashtags
**목적**: 해시태그 마스터 테이블
```sql
CREATE TABLE community_hashtags (
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    subscriber_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 5. community_likes
**목적**: 게시물/댓글 좋아요 관리
```sql
CREATE TABLE community_likes (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id BIGINT REFERENCES community_posts(id) ON DELETE CASCADE,
    comment_id BIGINT REFERENCES community_comments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_post_like UNIQUE(user_id, post_id),
    CONSTRAINT unique_comment_like UNIQUE(user_id, comment_id)
);
```

### 6. community_posts
**목적**: 커뮤니티 게시물 저장
```sql
CREATE TABLE community_posts (
    id BIGSERIAL PRIMARY KEY,
    author_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT FALSE,
    image_urls TEXT[] DEFAULT '{}',
    view_count BIGINT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 7. community_reports ✅
**목적**: 게시물 신고 시스템
```sql
CREATE TABLE community_reports (
    id BIGSERIAL PRIMARY KEY,
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reported_post_id BIGINT NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    report_reason TEXT NOT NULL CHECK (
        report_reason IN ('inappropriate', 'spam', 'harassment', 'illegal', 'privacy', 'misinformation', 'other')
    ),
    report_details TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (
        status IN ('pending', 'resolved', 'dismissed')
    ),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

### 8. community_subscriptions
**목적**: 해시태그 구독 관리
```sql
CREATE TABLE community_subscriptions (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    target_hashtag_id INTEGER REFERENCES community_hashtags(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_subscription UNIQUE(user_id, target_hashtag_id)
);
```

### 9. daily_hashtag_curation
**목적**: 일일 해시태그 큐레이션 데이터
```sql
CREATE TABLE daily_hashtag_curation (
    id BIGSERIAL PRIMARY KEY,
    hashtag_id INTEGER REFERENCES community_hashtags(id),
    curation_date DATE NOT NULL,
    score NUMERIC,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 10. devices
**목적**: 사용자 디바이스 관리
```sql
CREATE TABLE devices (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    device_token TEXT,
    platform TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 11. main_categories
**목적**: 메인 카테고리 분류
```sql
CREATE TABLE main_categories (
    category_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
```

### 12. post_hashtags ⭐
**목적**: 게시물과 해시태그 연결 테이블 (Many-to-Many)
```sql
CREATE TABLE post_hashtags (
    post_id BIGINT NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    hashtag_id INTEGER NOT NULL REFERENCES community_hashtags(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, hashtag_id)
);
```

### 13. roles
**목적**: 사용자 역할 관리
```sql
CREATE TABLE roles (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    kor_name VARCHAR(100) NOT NULL,
    description TEXT
);
```

**실제 데이터 (2025-08-28 확인)**:
```json
[
  {"idx": 0, "id": 1, "name": "GUEST", "kor_name": "게스트"},
  {"idx": 1, "id": 2, "name": "STAR", "kor_name": "스타"},
  {"idx": 2, "id": 3, "name": "PLACE", "kor_name": "플레이스"},
  {"idx": 3, "id": 4, "name": "ADMIN", "kor_name": "관리자"},
  {"idx": 4, "id": 6, "name": "MEMBER", "kor_name": "멤버"}
]
```

**중요**: roles는 별도 테이블이며, users 테이블의 role_id가 이 테이블의 id를 참조합니다.

### 14. trending_hashtags_cache
**목적**: 인기 해시태그 캐시 테이블
```sql
CREATE TABLE trending_hashtags_cache (
    id BIGSERIAL PRIMARY KEY,
    hashtag_id INTEGER REFERENCES community_hashtags(id),
    trend_score NUMERIC,
    cached_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 15. user_blocks ✅
**목적**: 사용자 차단 관리
```sql
CREATE TABLE user_blocks (
    id BIGSERIAL PRIMARY KEY,
    blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blocked_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL DEFAULT 'user_report',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_block_relationship UNIQUE(blocker_id, blocked_user_id),
    CONSTRAINT no_self_block CHECK (blocker_id != blocked_user_id)
);
```

### 16. users
**목적**: 사용자 기본 정보
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    profile_img TEXT,
    nickname VARCHAR(100),
    email VARCHAR(255),
    role_id INTEGER REFERENCES roles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🔧 데이터베이스 함수 (실제 조회 - 48개)

### 커스텀 비즈니스 함수 (8개 핵심)

#### 1. `get_post_counts(post_ids_in bigint[])`
**목적**: 여러 게시물의 좋아요/댓글 수 일괄 조회

#### 2. `increment_post_view(post_id_in bigint)`
**목적**: 게시물 조회수 증가

#### 3. `get_top_posts_by_metric(window_days integer, metric text, limit_val integer, offset_val integer)`
**목적**: 인기 게시물 조회 (좋아요/댓글 기준)

#### 4. `get_post_commenter_avatars_batch(post_ids_in bigint[], limit_in int)`
**목적**: 여러 게시물의 최근 댓글 작성자 프로필 이미지

#### 5. `get_post_commenter_avatars(post_id_in bigint, limit_in int)`
**목적**: 특정 게시물의 최근 댓글 작성자 프로필 이미지

#### 6. `get_post_recent_interactors_batch(post_ids_in bigint[], limit_in int)`
**목적**: 여러 게시물의 최근 상호작용자 (댓글+좋아요)

#### 7. `get_post_recent_interactors(post_id_in bigint, limit_in int)`  
**목적**: 특정 게시물의 최근 상호작용자

#### 8. `get_user_liked_posts(...)`
**목적**: 사용자가 좋아요한 게시물 목록

### 트리거 함수들

#### 9. `auto_block_reported_user()`
**목적**: 신고 시 자동으로 신고 대상자 차단
- 트리거: community_reports AFTER INSERT

#### 10. `handle_post_hashtags()`
**목적**: 게시물 해시태그 처리
- 트리거: community_posts INSERT/UPDATE

#### 11. `update_hashtag_subscriber_count()`
**목적**: 해시태그 구독자 수 자동 업데이트

#### 12. `subscribe_default_channels_on_signup()`
**목적**: 회원가입 시 기본 채널 구독

#### 13. `set_default_guest_role()`
**목적**: 기본 게스트 역할 설정

#### 14. `update_updated_at_column()`
**목적**: updated_at 컬럼 자동 업데이트

#### 15. `handle_updated_at()`
**목적**: updated_at 처리

#### 16. `set_current_timestamp_updated_at()`
**목적**: 현재 타임스탬프를 updated_at에 설정

### PostgreSQL Extension 함수들 (pg_trgm - 32개)
전문 검색을 위한 trigram 확장 함수들:
- `similarity()`, `show_trgm()`, `set_limit()` 등
- GIN/GiST 인덱스 관련 함수들

---

## ☁️ Edge Functions (실제 조회)

### 1. hashtag-processor
**ID**: 528c2dad-43e7-4210-a168-c0f83235feea  
**상태**: ACTIVE (버전 2)  
**최종 배포**: 2025-08-26 06:55:05  

### 2. daily-hashtag-curation
**ID**: 1ee97ad0-b72f-4a6d-8675-22714cb71856  
**상태**: ACTIVE (버전 3)  
**최종 배포**: 2025-08-26 07:00:17  

### 3. image-safety-web
**ID**: 01a3f2bd-84c1-4abf-aa9d-84f65e3c1281  
**상태**: ACTIVE (버전 2)  
**최종 배포**: 2025-08-20 14:32:00  

### 4. cloudinary-signature
**ID**: ddd480e5-699a-465c-8ba6-2417465b8bc8  
**상태**: ACTIVE (버전 3)  
**최종 배포**: 2025-08-22 14:25:06  

---

## 🔗 테이블 관계도

```
main_categories (1) ←→ (N) area_groups (1) ←→ (N) area_keywords

auth.users (1) ←→ (N) users
           ↓
    community_posts (1) ←→ (N) community_comments
           ↓                        ↓
    community_likes          community_likes
           ↓
    post_hashtags (N) ←→ (N) community_hashtags
           ↓                        ↓
    community_subscriptions    daily_hashtag_curation
                                   ↓
                          trending_hashtags_cache

auth.users ←→ community_reports ←→ community_posts
     ↓              ↓
user_blocks    (auto-trigger)

auth.users ←→ devices
     ↓
   roles
```

---

## 🚀 성능 최적화 및 인덱스

### 확인된 인덱스들
1. **area_keywords**: `idx_area_keywords_keyword` (키워드 검색)
2. **post_hashtags**: 복합 기본키 (post_id, hashtag_id)
3. **community_posts**: trigram 인덱스 (전문 검색)
4. **기본 인덱스들**: 모든 기본키, 외래키, 유니크 제약

### pg_trgm 확장
- **전문 검색 지원**: similarity(), show_trgm() 등
- **GIN 인덱스**: 빠른 텍스트 검색
- **유사성 검색**: 오타 허용 검색 가능

---

## 🔐 보안 정책 (확인된 RLS)

### post_hashtags 테이블
```sql
POLICY "Allow read access to all users" FOR SELECT USING (true)
```

### 기타 테이블들
- community_reports: 신고자 기준 RLS
- user_blocks: 차단자 기준 RLS
- 대부분 테이블: 사용자별 데이터 접근 제한

---

## ⚡ 주요 비즈니스 로직

### 1. 해시태그 시스템
- **post_hashtags**: 게시물-해시태그 N:N 관계
- **community_subscriptions**: 사용자 구독 시스템
- **daily_hashtag_curation**: 일일 큐레이션
- **trending_hashtags_cache**: 인기 해시태그 캐싱

### 2. 지역 기반 분류
- **main_categories** → **area_groups** → **area_keywords**
- 3단계 계층 구조로 지역 정보 관리

### 3. 신고 및 차단 시스템 ✅
- **community_reports**: 신고 접수
- **user_blocks**: 자동/수동 차단
- **auto_block_reported_user()**: 신고 시 자동 차단

### 4. 상호작용 추적
- **community_likes**: 좋아요 시스템
- **community_comments**: 댓글 시스템
- **view_count**: 조회수 추적

### 5. 사용자 관리
- **users**: 프로필 정보
- **roles**: 역할 기반 권한
- **devices**: 푸시 알림용 디바이스 토큰

---

## 📊 데이터 흐름

### 게시물 작성 플로우
1. **community_posts** 생성
2. **handle_post_hashtags()** 트리거 → **post_hashtags** 자동 생성
3. **community_hashtags** 업데이트 (필요시 신규 생성)

### 신고 플로우  
1. **community_reports** 생성
2. **auto_block_reported_user()** 트리거 → **user_blocks** 자동 생성

### 해시태그 큐레이션 플로우
1. **daily-hashtag-curation** Edge Function 실행
2. **daily_hashtag_curation** 테이블 업데이트
3. **trending_hashtags_cache** 생성/업데이트

---

## 🔍 누락되었던 중요 테이블들

### post_hashtags ⭐⭐⭐
**가장 중요한 누락**: 게시물과 해시태그의 N:N 관계를 담당하는 핵심 테이블

### area_groups & area_keywords
**지역 기반 기능**: 지역별 콘텐츠 분류 시스템

### daily_hashtag_curation & trending_hashtags_cache
**AI 기반 큐레이션**: Edge Function과 연동되는 해시태그 추천 시스템

### devices
**푸시 알림**: 모바일 앱 알림 시스템

### roles & main_categories
**권한 및 분류**: 사용자 권한과 콘텐츠 분류 체계

---

## ✅ 결론

**총 16개 테이블이 정확하게 조회되었습니다!**

이전 문서에서는 Flutter 코드 분석만으로 8개 테이블만 파악했지만, 실제 CLI 조회 결과 **8개의 추가 테이블**이 발견되었습니다:

1. **area_groups** - 지역 그룹
2. **area_keywords** - 지역 키워드  
3. **post_hashtags** - 게시물-해시태그 연결 (핵심!)
4. **daily_hashtag_curation** - 일일 큐레이션
5. **devices** - 디바이스 관리
6. **main_categories** - 메인 카테고리
7. **roles** - 역할 관리  
8. **trending_hashtags_cache** - 인기 해시태그 캐시

**이제 완전하고 정확한 데이터베이스 참조 문서가 완성되었습니다!** 🎉

---

## 🎯 멤버 매칭 시스템 구현 (2025-08-27)

### 추가 테이블 확인 및 구현

#### 멤버 프로필 관련 테이블
**기존 문서에서 누락되었던 중요 테이블들이 추가로 확인되었습니다:**

### 17. **attributes**
**목적**: 통합 속성 사전 (업종, 직무, 스타일, 특징, 복지)
```sql
CREATE TABLE attributes (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL,
    type_kor TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT unique_type_name UNIQUE (type, name)
);
```

**데이터 현황**: 48개 속성 (실제 조회 확인)
- **INDUSTRY** (업종): 8개 - 모던 바, 토크 바, 캐주얼 펍, 가라오케, 카페, 테라피, 라이브 방송, 이벤트
- **JOB_ROLE** (구하는 직무): 7개 - 매니저, 실장, 바텐더, 스탭, 가드, 주방, DJ  
- **WELFARE** (복지 및 혜택): 15개 - 당일지급, 선불/마이킹, 인센티브, 4대보험 등
- **PLACE_FEATURE** (가게 특징): 10개 - 초보환영, 경력자우대, 가족같은, 파티분위기 등
- **MEMBER_STYLE** (나의 스타일/강점): 8개 - 긍정적, 활발함, 차분함, 성실함 등

### 18. **member_profiles**
**목적**: 멤버 상세 프로필
```sql
CREATE TABLE member_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    real_name TEXT,
    age INT,
    gender gender_enum,
    contact_phone TEXT,
    profile_image_urls TEXT[],
    social_links JSONB,
    bio TEXT,
    experience_level experience_level_enum,
    desired_pay_type pay_type_enum,
    desired_pay_amount INT,
    desired_working_days TEXT[],
    available_from DATE,
    can_relocate BOOLEAN DEFAULT false,
    level INT NOT NULL DEFAULT 1,
    experience_points BIGINT NOT NULL DEFAULT 0,
    title TEXT DEFAULT '새로운 스타',
    updated_at TIMESTAMPTZ
);
```

**⚠️ 스키마 변경 사항**:
- `nickname TEXT UNIQUE NOT NULL` → 삭제됨 (2025-08-27)
- `birthdate DATE` → 삭제됨, `age INT` → 추가됨 (2025-08-27)

### 19. **member_attributes_link** 
**목적**: 멤버와 스타일 속성 연결 (MEMBER_STYLE)
```sql
CREATE TABLE member_attributes_link (
    member_user_id UUID NOT NULL REFERENCES member_profiles(user_id) ON DELETE CASCADE,
    attribute_id INT NOT NULL REFERENCES attributes(id) ON DELETE CASCADE,
    PRIMARY KEY (member_user_id, attribute_id)
);
```

### 20. **member_preferences_link**
**목적**: 멤버와 선호도 연결 (INDUSTRY, JOB_ROLE, PLACE_FEATURE, WELFARE)
```sql
CREATE TABLE member_preferences_link (
    member_user_id UUID NOT NULL REFERENCES member_profiles(user_id) ON DELETE CASCADE,
    attribute_id INT NOT NULL REFERENCES attributes(id) ON DELETE CASCADE,
    PRIMARY KEY (member_user_id, attribute_id)
);
```

### 21. **member_preferred_area_groups**
**목적**: 멤버와 선호 지역 연결
```sql
CREATE TABLE member_preferred_area_groups (
    member_user_id UUID NOT NULL REFERENCES member_profiles(user_id) ON DELETE CASCADE,
    group_id INT NOT NULL REFERENCES area_groups(group_id) ON DELETE CASCADE,
    PRIMARY KEY (member_user_id, group_id)
);
```

---

## 🛠️ 매칭 시스템 서비스 구현

### AttributeService 
**파일**: `lib/services/attribute_service.dart`

**주요 기능**:
- 속성 타입별 데이터 조회 (캐싱 포함)
- UI 컴포넌트용 데이터 변환
- 배치 조회로 성능 최적화
- 공통 속성 프리로드

**핵심 메서드**:
```dart
Future<List<Attribute>> getAttributesByType(String type)
Future<Map<String, List<Attribute>>> getMultipleAttributeTypes(List<String> types)
Future<List<Map<String, dynamic>>> getAttributesForUI(String type)
```

### MemberPreferencesService
**파일**: `lib/services/member_preferences_service.dart`

**주요 기능**:
- 매칭 선호도 저장 (3개 테이블 동시 처리)
- 기존 선호도 불러오기
- 멤버 프로필 관리
- 페이 타입 변환 (UI ↔ DB enum)

**핵심 메서드**:
```dart
Future<bool> saveMatchingPreferences(MatchingPreferencesData data)
Future<MatchingPreferencesData?> loadMatchingPreferences()
Future<MemberProfile?> getMemberProfile()
```

### MatchingPreferencesPage 업데이트
**파일**: `lib/scenes/matching_preferences_page.dart`

**구현된 기능**:
- ✅ 하드코딩 데이터를 DB 연동으로 전환
- ✅ 로딩 상태 및 에러 처리 추가
- ✅ 기존 사용자 선호도 자동 로드
- ✅ 실시간 데이터 저장 (3개 테이블 트랜잭션)
- ✅ Flutter 테마 시스템 준수 유지

---

## 📊 데이터 플로우 - 매칭 시스템

### 매칭 선호도 저장 플로우
1. **UI 데이터 수집**: MatchingPreferencesPage에서 사용자 선택
2. **데이터 변환**: String ID → Integer ID, 페이 타입 enum 변환
3. **데이터베이스 저장** (트랜잭션):
   - `member_profiles`: 급여 조건, 근무 요일
   - `member_attributes_link`: 스타일/강점 (MEMBER_STYLE)
   - `member_preferences_link`: 업종, 직무, 특징, 복지

### 속성 데이터 로딩 플로우
1. **캐시 확인**: AttributeService에서 메모리 캐시 체크
2. **배치 조회**: 여러 타입 동시 조회로 성능 최적화
3. **UI 변환**: 아이콘 포함 Map 형태로 변환
4. **기존 데이터 로드**: 사용자 선호도 복원

---

## 🔗 업데이트된 테이블 관계도

```
            attributes (통합 속성 사전)
                 ↙          ↘
member_attributes_link   member_preferences_link
         ↓                        ↓
    member_profiles ←→ member_preferred_area_groups
         ↓                        ↓
       users                 area_groups
```

---

## 🎯 매칭 시스템 완료 상태

### ✅ 완료된 구현
1. **데이터베이스 스키마 확인**: 5개 추가 테이블 완전 구현
2. **속성 데이터 완비**: 48개 속성이 5개 타입으로 정확히 분류
3. **서비스 레이어**: AttributeService, MemberPreferencesService 완전 구현
4. **UI 통합**: MatchingPreferencesPage 완전 데이터베이스 연동
5. **로딩/에러 처리**: 사용자 경험 최적화
6. **Flutter 테마 준수**: CLAUDE.md 가이드라인 완벽 준수

### 🔄 AI 프롬프트 생성 시스템 준비
- **데이터 수집**: 모든 사용자 선택 데이터가 정규화되어 저장
- **4가지 바구니**: MUST_HAVE, ENVIRONMENT, PEOPLE, AVOID 분류 준비
- **프롬프트 템플릿**: member_profile.md 명세에 따른 한글 프롬프트 구조

**총 테이블 수**: 21개 (기존 16개 + 매칭 시스템 5개)**

---

## 📝 최근 스키마 변경 사항 (2025-08-27)

### member_profiles 테이블 수정
**변경 사항**: 
1. `nickname` 컬럼이 데이터베이스에서 삭제됨
2. `birthdate(DATE)` 컬럼이 삭제되고 `age(INT)` 컬럼이 추가됨

**영향받는 파일**:
- `lib/services/basic_info_service.dart` ✅ 업데이트 완료
  - `BasicInfo` 클래스에서 `nickname` 필드 제거 ✅ 완료
  - `fromMap()` 메소드: birthdate 계산 로직 제거, age 직접 조회 ✅ 완료
  - `toMap()` 메소드: birthdate 계산 로직 제거, age 직접 저장 ✅ 완료
  - 나이 계산 로직 완전 제거 (DB에서 직접 저장/조회) ✅ 완료

**데이터 매핑 변경**:
- **nickname 제거**: `nickname` ↔ `member_profiles.nickname` → 삭제됨
- **나이 처리 변경**: 
  - **이전**: `age(계산값)` ↔ `member_profiles.birthdate` (DATE)
  - **현재**: `age` ↔ `member_profiles.age` (INT)