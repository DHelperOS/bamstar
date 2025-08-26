# BamStar Supabase 관리 지침

**목적**: 모든 데이터베이스 변경사항을 체계적으로 관리하고 문서화

---

## 📋 DB 변경 관리 원칙

### 1. 모든 변경은 마이그레이션으로
- ✅ **DO**: SQL 마이그레이션 파일 생성
- ❌ **DON'T**: Supabase 대시보드에서 직접 수정
- ❌ **DON'T**: SQL 에디터에서 직접 실행

### 2. 마이그레이션 파일 명명 규칙
```
YYYYMMDDHHMMSS_descriptive_name.sql

예시:
20250826143000_add_user_preferences_table.sql
20250826143100_create_notification_system.sql
20250826143200_update_community_posts_add_pinned.sql
```

### 3. 변경사항 분류
- **CREATE**: 새 테이블/함수/인덱스 생성
- **ALTER**: 기존 구조 수정
- **DROP**: 테이블/컬럼/함수 삭제
- **DATA**: 데이터 수정/초기화
- **INDEX**: 인덱스 관련 변경
- **RLS**: 보안 정책 변경

---

## 🔧 실습 가이드

### Step 1: 마이그레이션 파일 생성

#### 방법 1: 수동 생성 (권장)
```bash
# 파일 생성
touch supabase/migrations/$(date +%Y%m%d%H%M%S)_your_change_description.sql

# 예시
touch supabase/migrations/20250826143000_add_user_preferences.sql
```

#### 방법 2: Supabase CLI 사용
```bash
# 현재 스키마 상태 기록
supabase db diff --schema public --file new_migration

# 또는 빈 마이그레이션 생성
supabase migration new your_change_description
```

### Step 2: 마이그레이션 작성

```sql
-- 20250826143000_add_user_preferences.sql
-- 목적: 사용자 환경설정 테이블 추가

-- 1. 테이블 생성
CREATE TABLE IF NOT EXISTS user_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    notification_enabled BOOLEAN DEFAULT TRUE,
    theme TEXT DEFAULT 'auto' CHECK (theme IN ('light', 'dark', 'auto')),
    language TEXT DEFAULT 'ko' CHECK (language IN ('ko', 'en', 'ja')),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_user_preferences UNIQUE(user_id)
);

-- 2. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id 
ON user_preferences(user_id);

-- 3. RLS 활성화
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- 4. RLS 정책 생성
CREATE POLICY "Users can manage their own preferences" ON user_preferences
FOR ALL USING (user_id = auth.uid());

-- 5. 권한 부여
GRANT SELECT, INSERT, UPDATE, DELETE ON user_preferences TO authenticated;
GRANT USAGE ON SEQUENCE user_preferences_id_seq TO authenticated;

-- 6. 기본 데이터 삽입 (필요시)
-- INSERT INTO user_preferences (user_id) 
-- SELECT id FROM auth.users WHERE id NOT IN (SELECT user_id FROM user_preferences);
```

### Step 3: 마이그레이션 테스트 (로컬)

```bash
# Docker 컨테이너 시작 (필요시)
supabase start

# 마이그레이션 적용 테스트
supabase db reset

# 특정 마이그레이션만 테스트
supabase migration up --target 20250826143000
```

### Step 4: 프로덕션 배포

```bash
# ⚠️ 주의: 프로덕션 배포 전 반드시 백업

# 연결된 프로젝트에 배포
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b \
supabase db push --linked

# 또는 프로젝트 지정
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b \
supabase db push --project-ref tflvicpgyycvhttctcek
```

### Step 5: 문서 업데이트

```bash
# 1. SUPABASE_DATABASE_REFERENCE.md 업데이트
# - 새 테이블 스키마 추가
# - 새 함수 문서화  
# - 인덱스 정보 업데이트

# 2. 변경사항 커밋
git add supabase/migrations/ SUPABASE_DATABASE_REFERENCE.md
git commit -m "feat: add user preferences system

- Add user_preferences table with theme/language settings
- Add RLS policies for user data protection  
- Add indexes for performance optimization

Migration: 20250826143000_add_user_preferences.sql"
```

---

## 📁 파일 구조 관리

### 프로젝트 구조
```
bamstar/
├── supabase/
│   ├── migrations/
│   │   ├── 20250826000001_create_report_system.sql ✅
│   │   ├── 20250826143000_add_user_preferences.sql (예시)
│   │   └── ...
│   └── functions/ (Edge Functions - 별도 배포)
│       ├── hashtag-processor/
│       ├── daily-hashtag-curation/
│       └── ...
├── SUPABASE_DATABASE_REFERENCE.md ✅
├── SUPABASE_MANAGEMENT_GUIDE.md ✅
└── dev/
    └── sql/ (개발용 SQL 스크립트)
        ├── community_search_and_rpcs.sql ✅
        └── ...
```

### 마이그레이션 디렉토리 규칙
- **시간순 정렬**: 파일명으로 실행 순서 보장
- **설명적 이름**: 변경 내용을 명확히 표현
- **원자성**: 각 마이그레이션은 독립적으로 실행 가능
- **되돌리기**: 필요시 롤백 가능하도록 설계

---

## ⚠️ 주의사항

### 마이그레이션 작성 시 고려사항

#### 1. 안전성 확보
```sql
-- ✅ GOOD: IF NOT EXISTS 사용
CREATE TABLE IF NOT EXISTS new_table (...);
CREATE INDEX IF NOT EXISTS idx_name ON table_name(...);

-- ❌ BAD: 조건 없는 생성
CREATE TABLE new_table (...);  -- 실패 시 마이그레이션 중단
```

#### 2. 기본값 설정
```sql
-- ✅ GOOD: 기존 데이터 호환성 고려
ALTER TABLE users ADD COLUMN notification_enabled BOOLEAN DEFAULT TRUE;

-- ❌ BAD: NOT NULL without DEFAULT (기존 레코드 오류)
ALTER TABLE users ADD COLUMN notification_enabled BOOLEAN NOT NULL;
```

#### 3. 제약조건 처리
```sql
-- ✅ GOOD: 단계별 적용
ALTER TABLE users ADD COLUMN email TEXT;
UPDATE users SET email = 'temp@example.com' WHERE email IS NULL;
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- ❌ BAD: 즉시 NOT NULL (데이터 없으면 실패)
ALTER TABLE users ADD COLUMN email TEXT NOT NULL;
```

#### 4. 인덱스 동시성
```sql
-- ✅ GOOD: CONCURRENTLY 사용 (프로덕션)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_name ON table_name(column);

-- ❌ BAD: 테이블 락 발생
CREATE INDEX idx_name ON table_name(column);
```

### 롤백 전략

#### 1. 마이그레이션 롤백
```bash
# 특정 버전으로 되돌리기
supabase migration down --target 20250825000000

# 한 단계만 되돌리기  
supabase migration down
```

#### 2. 수동 롤백 SQL 준비
```sql
-- 각 마이그레이션 파일에 롤백 명령 주석으로 기록
-- ROLLBACK COMMANDS:
-- DROP TABLE IF EXISTS user_preferences;
-- DROP INDEX IF EXISTS idx_user_preferences_user_id;
```

---

## 🔍 모니터링 및 검증

### 마이그레이션 후 검증

#### 1. 테이블 구조 확인
```sql
-- 테이블 생성 확인
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'user_preferences';

-- 컬럼 정보 확인
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'user_preferences';
```

#### 2. 인덱스 확인
```sql
-- 인덱스 생성 확인
SELECT indexname, indexdef FROM pg_indexes 
WHERE tablename = 'user_preferences';
```

#### 3. RLS 정책 확인
```sql
-- RLS 활성화 상태 확인
SELECT schemaname, tablename, rowsecurity FROM pg_tables 
WHERE tablename = 'user_preferences';

-- 정책 목록 확인
SELECT policyname, roles, cmd, qual FROM pg_policies 
WHERE tablename = 'user_preferences';
```

#### 4. 함수 확인
```sql
-- 함수 존재 확인
SELECT routine_name, routine_type FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_name LIKE '%new_function%';
```

### 성능 모니터링

#### 1. 쿼리 성능 확인
```sql
-- 느린 쿼리 모니터링
SELECT query, mean_exec_time, calls, total_exec_time
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC LIMIT 10;
```

#### 2. 인덱스 사용률
```sql  
-- 인덱스 사용률 확인
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes 
WHERE idx_scan = 0;  -- 사용되지 않는 인덱스
```

---

## 🚨 응급 상황 대처

### 마이그레이션 실패 시

#### 1. 즉시 조치
```bash
# 1. 마이그레이션 상태 확인
supabase migration list --linked

# 2. 실패한 마이그레이션 확인
# Supabase Dashboard > Database > Migrations에서 확인

# 3. 롤백 준비
supabase db reset  # 로컬 테스트 환경
```

#### 2. 프로덕션 복구
```sql
-- 1. 실패한 마이그레이션 수동 정리
-- (실패 지점부터 수동으로 SQL 실행)

-- 2. supabase_migrations 테이블에서 기록 제거
DELETE FROM supabase_migrations.schema_migrations 
WHERE version = '20250826143000';
```

#### 3. 데이터 복구
```bash
# 백업에서 복원 (사전 백업 필요)
# Supabase Dashboard > Settings > Database > Point-in-time recovery
```

---

## 📋 체크리스트

### 마이그레이션 전 체크리스트
- [ ] 백업 생성 확인
- [ ] 로컬 테스트 완료
- [ ] SQL 문법 검증
- [ ] RLS 정책 검토
- [ ] 성능 영향 분석
- [ ] 롤백 계획 수립

### 마이그레이션 후 체크리스트  
- [ ] 테이블/함수 생성 확인
- [ ] 인덱스 정상 생성
- [ ] RLS 정책 적용 확인
- [ ] 애플리케이션 테스트
- [ ] 성능 모니터링
- [ ] 문서 업데이트

---

## 🔗 참고 링크

- **Supabase CLI 문서**: https://supabase.com/docs/guides/cli
- **마이그레이션 가이드**: https://supabase.com/docs/guides/cli/local-development
- **프로젝트 대시보드**: https://supabase.com/dashboard/project/tflvicpgyycvhttctcek
- **PostgreSQL 문서**: https://www.postgresql.org/docs/

---

## ✅ 마이그레이션 예시 모음

### 1. 테이블 추가
```sql
-- 20250826143000_add_bookmarks_table.sql
CREATE TABLE IF NOT EXISTS user_bookmarks (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id BIGINT NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_bookmark UNIQUE(user_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_user_bookmarks_user_id ON user_bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_user_bookmarks_created_at ON user_bookmarks(created_at DESC);

ALTER TABLE user_bookmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their bookmarks" ON user_bookmarks
FOR ALL USING (user_id = auth.uid());

GRANT SELECT, INSERT, DELETE ON user_bookmarks TO authenticated;
GRANT USAGE ON SEQUENCE user_bookmarks_id_seq TO authenticated;
```

### 2. 컬럼 추가
```sql
-- 20250826143100_add_post_pinned_column.sql
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'community_posts' AND column_name = 'is_pinned'
    ) THEN
        ALTER TABLE community_posts ADD COLUMN is_pinned BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_community_posts_pinned 
ON community_posts(is_pinned, created_at DESC) WHERE is_pinned = true;
```

### 3. 함수 생성
```sql
-- 20250826143200_add_search_posts_function.sql
CREATE OR REPLACE FUNCTION search_posts(
    search_query TEXT,
    limit_val INTEGER DEFAULT 20,
    offset_val INTEGER DEFAULT 0
)
RETURNS TABLE(
    id BIGINT,
    content TEXT,
    author_id UUID,
    created_at TIMESTAMPTZ,
    similarity REAL
)
LANGUAGE sql STABLE
AS $$
    SELECT p.id, p.content, p.author_id, p.created_at,
           similarity(p.content, search_query) as similarity
    FROM community_posts p
    WHERE p.content % search_query
    ORDER BY similarity DESC, p.created_at DESC
    LIMIT COALESCE(limit_val, 20)
    OFFSET COALESCE(offset_val, 0);
$$;
```

---

**⚡ 중요**: 이 가이드에 따라 모든 DB 변경을 수행하여 일관성과 안정성을 유지하세요!