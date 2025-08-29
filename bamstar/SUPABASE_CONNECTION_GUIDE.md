# Supabase 연결 가이드

## 🔐 CLI 웹 로그인 (필수)

```bash
# Supabase CLI 웹 로그인 - 브라우저가 열리면 로그인
supabase login
```

## 🔑 프로젝트 정보
- **Project Reference ID**: `tflvicpgyycvhttctcek`
- **Database Password**: `!@Wnrsmsek1`
- **URL Encoded Password**: `%21%40Wnrsmsek1`
- **Supabase CLI Token**: `sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b`

## ✅ 작동 확인된 연결 방법 (2025-08-29)

### 1. PostgreSQL URL 직접 연결 (가장 안정적)
```bash
# URL 인코딩된 패스워드 사용 - 가장 안정적
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres"

# 예시 명령어들
# 테이블 목록 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "\dt public.*"

# 특정 테이블 구조 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "\d member_profiles"

# 데이터 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "SELECT * FROM users LIMIT 5;"

# 함수 목록 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "\df public.*"

# Enum 타입 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "\dT+ *_enum"
```

### 2. 환경변수를 사용한 연결 (대안)
```bash
# 환경변수 설정 후 연결
export PGPASSWORD='!@Wnrsmsek1'
psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek

# 단일 명령으로 실행
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek -c "SELECT * FROM roles;"
```

## 📊 자주 사용하는 데이터베이스 조회 명령어

### 테이블 관련
```bash
# 모든 테이블 목록
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "\dt public.*"

# 테이블 구조 상세 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "\d+ [테이블명]"

# 테이블 컬럼 정보만 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "SELECT column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_name = '[테이블명]' ORDER BY ordinal_position;"
```

### Enum 타입 조회
```bash
# 모든 Enum 타입과 값 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "SELECT t.typname as enum_name, e.enumlabel as enum_value FROM pg_type t JOIN pg_enum e ON t.oid = e.enumtypid WHERE t.typtype = 'e' ORDER BY t.typname, e.enumsortorder;"

# 특정 Enum 타입 값 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "SELECT unnest(enum_range(NULL::[enum_name]));"
```

### 함수 및 트리거
```bash
# 모든 함수 목록
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "\df public.*"

# 트리거 목록
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "SELECT * FROM information_schema.triggers WHERE trigger_schema = 'public';"
```

### RLS 정책 조회
```bash
# 특정 테이블의 RLS 정책
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "SELECT * FROM pg_policies WHERE tablename = '[테이블명]';"
```

## 📝 실행했던 주요 명령어들 (히스토리)

### 1. 프로젝트 연결 및 확인
```bash
# 프로젝트 목록 확인
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase projects list

# 프로젝트 링크
supabase link --project-ref tflvicpgyycvhttctcek
```

### 2. 데이터베이스 테이블 생성
```bash
# Place 테이블 생성
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek -f sql/01_create_place_tables.sql

# Interaction 테이블 생성
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek -f sql/02_create_interaction_tables.sql

# Matching 테이블 생성
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek -f sql/03_create_matching_tables.sql

# Helper 함수 생성
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek -f sql/04_create_helper_functions.sql
```

### 3. Edge Functions 배포
```bash
# 디렉토리 복사 (경로 문제 해결)
cp -r /Users/deneb/Desktop/Project/BamStar/bamstar/supabase /Users/deneb/Desktop/Project/BamStar/

# Edge Function 배포
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy match-calculator --project-ref tflvicpgyycvhttctcek

SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy match-finder --project-ref tflvicpgyycvhttctcek

SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy hearts-manager --project-ref tflvicpgyycvhttctcek

# Functions 목록 확인
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions list --project-ref tflvicpgyycvhttctcek
```

### 4. RLS 정책 적용
```bash
# RLS 활성화 스크립트 실행
chmod +x scripts/apply_rls.sh && ./scripts/apply_rls.sh

# 마이그레이션 생성
supabase migration new add_rls_policies

# 마이그레이션 파일 편집 후 대시보드에서 실행
```

### 5. 데이터베이스 조회
```bash
# 테이블 목록 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "\dt public.*"

# RLS 상태 확인
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' AND rowsecurity = true;"

# 함수 목록 조회
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "\df public.calculate*"
```

## 🚫 작동하지 않는 방법들

### Supabase CLI (Docker 필요)
```bash
# ❌ Docker가 필요하여 실패
supabase db dump --linked
supabase link --project-ref tflvicpgyycvhttctcek
```

### MCP Supabase 서버
```bash
# ❌ 토큰 인증 문제로 실패
mcp__supabase__execute_sql
mcp__supabase__list_tables
```

### 잘못된 사용자명 형식
```bash
# ❌ 틀린 형식 - postgres 사용자명만 사용
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres

# ✅ 올바른 형식 - postgres.프로젝트ID 사용
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek
```

## 📝 현재 테이블 목록 (2025-08-29 조회)

```
1. area_groups                  - 지역 그룹
2. area_keywords                - 지역 키워드
3. attributes                   - 속성 마스터 (업종, 직무, 스타일 등)
4. community_comments           - 커뮤니티 댓글
5. community_hashtags           - 해시태그
6. community_likes              - 좋아요
7. community_posts              - 게시물
8. community_reports            - 신고
9. community_subscriptions      - 구독
10. daily_hashtag_curation      - 일일 해시태그 큐레이션
11. devices                     - 디바이스 정보
12. main_categories             - 메인 카테고리
13. member_attributes_link      - 멤버 속성 연결
14. member_preferences_link     - 멤버 선호도 연결
15. member_preferred_area_groups- 멤버 선호 지역
16. member_profiles             - 멤버 프로필
17. post_hashtags               - 게시물-해시태그 연결
18. push_tokens                 - 푸시 토큰
19. roles                       - 역할
20. terms                       - 약관
21. trending_hashtags_cache     - 트렌딩 해시태그 캐시
22. user_blocks                 - 사용자 차단
23. user_term_agreements        - 약관 동의
24. users                       - 사용자
```

## 💡 팁

1. **패스워드 인코딩**: `!@Wnrsmsek1` → `%21%40Wnrsmsek1`
2. **사용자명 형식**: 반드시 `postgres.tflvicpgyycvhttctcek` 형식 사용
3. **연결 URL**: postgresql://[사용자명]:[인코딩된패스워드]@[호스트]:[포트]/[DB명]
4. **출력이 긴 경우**: 파이프로 `| less` 또는 `| head -n 50` 사용

## 🔧 문제 해결

### 패스워드 인증 실패
- URL에서 패스워드가 제대로 인코딩되었는지 확인
- 사용자명이 `postgres.tflvicpgyycvhttctcek` 형식인지 확인

### 연결 테스트
```bash
# 간단한 연결 테스트
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" -c "SELECT version();"
```