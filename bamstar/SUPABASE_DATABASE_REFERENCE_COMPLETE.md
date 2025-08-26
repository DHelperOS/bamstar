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
    description TEXT
);
```

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