# Supabase 연결 가이드

이 가이드는 BamStar 프로젝트에서 Supabase CLI와 MCP 서버에 연결하는 방법을 설명합니다.

## 🔑 인증 토큰 정보

### CLI 접속용 토큰 (Project API Token)
```bash
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b
```

### MCP 서버용 토큰 (Service Role Key)
```bash
MCP_AUTH_TOKEN=sb_secret_6gi2ZmG0XtspzcWuGVUkFw_OLfPWItH
```

### 프로젝트 정보
- **Project Reference ID**: `tflvicpgyycvhttctcek`
- **Organization ID**: `eqdgldtaktbmvuuqyygf`
- **Database URL**: `postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres`
- **Supabase URL**: `https://tflvicpgyycvhttctcek.supabase.co`

---

## 🖥️ Supabase CLI 연결

### 1. 환경 변수 설정
```bash
export SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b
```

### 2. 프로젝트 목록 확인
```bash
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase projects list
```

### 3. 데이터베이스 작업 예시

#### 마이그레이션 목록 확인
```bash
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase migration list --project-ref tflvicpgyycvhttctcek
```

#### 데이터베이스 푸시
```bash
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db push --project-ref tflvicpgyycvhttctcek
```

#### Edge Function 배포
```bash
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy [function-name] --project-ref tflvicpgyycvhttctcek
```

---

## 🤖 MCP 서버 연결

### 1. 환경 변수 설정 (.env 파일에서)
```bash
MCP_AUTH_TOKEN=sb_secret_6gi2ZmG0XtspzcWuGVUkFw_OLfPWItH
```

### 2. Claude Code에서 MCP 서버 사용

#### 프로젝트 목록 확인
```
mcp__supabase__list_projects
```

#### 데이터베이스 쿼리 실행
```
mcp__supabase__execute_sql --project-id tflvicpgyycvhttctcek --query "SELECT * FROM member_profiles LIMIT 5;"
```

#### 테이블 목록 확인
```
mcp__supabase__list_tables --project-id tflvicpgyycvhttctcek
```

#### Edge Function 목록 확인
```
mcp__supabase__list_edge_functions --project-id tflvicpgyycvhttctcek
```

---

## 🔧 주요 명령어 모음

### 데이터베이스 관련
```bash
# 스키마 덤프
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db dump --linked -f schema_dump.sql

# SQL 파일 실행
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --file your_file.sql

# 데이터베이스 리셋 (주의!)
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db reset --db-url "postgresql://postgres.tflvicpgyycvhttctcek:!@Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres" --linked
```

### Edge Functions 관련
```bash
# Function 목록
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions list --project-ref tflvicpgyycvhttctcek

# Function 배포
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy [function-name] --project-ref tflvicpgyycvhttctcek

# JWT 검증 없이 배포 (개발용)
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy [function-name] --project-ref tflvicpgyycvhttctcek --no-verify-jwt
```

---

## 🔍 문제해결

### 1. "Unauthorized" 에러
- 토큰 만료 확인
- 환경 변수 제대로 설정되었는지 확인
- CLI: `sbp_` 형식 토큰 사용
- MCP: `sb_secret_` 형식 토큰 사용

### 2. "Invalid access token format" 에러
- CLI에는 `sbp_` 형식만 사용 가능
- Service role key (`sb_secret_`)는 CLI에서 사용 불가

### 3. 연결 테스트 방법
```bash
# CLI 연결 테스트
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase projects list

# MCP 연결 테스트 (Claude Code에서)
mcp__supabase__list_projects
```

### 4. 자주 사용하는 디버깅 명령어
```bash
# 환경 변수 확인
printenv | grep SUPABASE

# 토큰 형식 확인
echo $SUPABASE_ACCESS_TOKEN | head -c 10  # should show "sbp_b4e5bf"
echo $MCP_AUTH_TOKEN | head -c 10         # should show "sb_secret_"
```

---

## 📝 빠른 참조

### 한 줄로 실행하기
```bash
# 프로젝트 목록
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase projects list

# member_profiles 테이블 확인 (MCP)
mcp__supabase__execute_sql --project-id tflvicpgyycvhttctcek --query "SELECT user_id, real_name, profile_image_urls FROM member_profiles;"
```

### 자주 사용하는 테이블
- `member_profiles` - 사용자 기본 정보
- `users` - Supabase Auth 사용자
- `hashtag_*` - 해시태그 관련 테이블들

---

**⚠️ 보안 주의사항**
- 토큰을 공개 저장소에 커밋하지 마세요
- Service role key는 서버사이드에서만 사용
- 정기적으로 토큰을 갱신하세요