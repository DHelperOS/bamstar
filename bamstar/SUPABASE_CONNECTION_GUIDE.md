# Supabase 연결 가이드

이 가이드는 BamStar 프로젝트에서 Supabase CLI를 사용하여 데이터베이스에 연결하는 방법을 설명합니다.

## 🔑 인증 토큰 정보

### CLI 접속용 토큰 (Project API Token)
```bash
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b
```

### 프로젝트 정보
- **Project Reference ID**: `tflvicpgyycvhttctcek`
- **Organization ID**: `eqdgldtaktbmvuuqyygf`
- **Database Password**: `!@Wnrsmsek1`
- **Encoded Password (URL용)**: `%21%40Wnrsmsek1`
- **Database URL**: `postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres`
- **Supabase URL**: `https://tflvicpgyycvhttctcek.supabase.co`

## ⚠️ 중요: 패스워드 인코딩
**데이터베이스 연결 시 오류가 발생하면 반드시 패스워드를 URL 인코딩하여 사용해야 합니다:**
- 원본 패스워드: `!@Wnrsmsek1`
- URL 인코딩된 패스워드: `%21%40Wnrsmsek1`

```bash
# 패스워드 인코딩 방법
python3 -c "import urllib.parse; print(urllib.parse.quote('!@Wnrsmsek1'))"
```

---

## 🖥️ Supabase CLI 사용법 (필수)

**⚠️ 모든 데이터베이스 작업은 반드시 Supabase CLI를 통해서만 수행합니다.**

### 1. 환경 변수 설정
```bash
export SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b
```

### 2. 프로젝트 연결
```bash
# 프로젝트 링크
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase link --project-ref tflvicpgyycvhttctcek

# 패스워드 입력 시: !@Wnrsmsek1
```

### 3. 데이터베이스 작업

#### 직접 SQL 실행 (psql 사용)
```bash
# 원본 패스워드 사용
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek -c "SELECT * FROM public.roles;"

# URL 인코딩된 패스워드 사용 (연결 문자열)
psql "postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres"
```

#### 마이그레이션 관리
```bash
# 마이그레이션 목록 확인
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase migration list --project-ref tflvicpgyycvhttctcek

# 새 마이그레이션 생성
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase migration new <migration_name>

# 데이터베이스 푸시
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db push --project-ref tflvicpgyycvhttctcek
```

#### 스키마 관리
```bash
# 원격 스키마 가져오기
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db pull --project-ref tflvicpgyycvhttctcek

# 스키마 덤프
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db dump --linked -f schema_dump.sql

# SQL 파일 실행
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db push --project-ref tflvicpgyycvhttctcek --include-all
```

#### Edge Functions 관리
```bash
# Function 목록
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions list --project-ref tflvicpgyycvhttctcek

# Function 배포
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy [function-name] --project-ref tflvicpgyycvhttctcek

# JWT 검증 없이 배포 (개발용)
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy [function-name] --project-ref tflvicpgyycvhttctcek --no-verify-jwt
```

---

## 🛠️ 로컬 개발 환경

### 로컬 Supabase 시작
```bash
# 로컬 서비스 시작
supabase start

# 로컬 서비스 상태 확인
supabase status

# 로컬 데이터베이스 접속
PGPASSWORD=postgres psql -h 127.0.0.1 -p 54322 -U postgres -d postgres
```

### 로컬 테스트 쿼리
```bash
# roles 테이블 확인
PGPASSWORD=postgres psql -h 127.0.0.1 -p 54322 -U postgres -d postgres -c "SELECT * FROM public.roles ORDER BY id;"
```

---

## 🔍 문제해결

### 1. 패스워드 인증 실패
```bash
# 오류: password authentication failed
# 해결: 패스워드를 URL 인코딩하여 사용

# 잘못된 예
postgresql://postgres.tflvicpgyycvhttctcek:!@Wnrsmsek1@...

# 올바른 예
postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@...
```

### 2. "Unauthorized" 에러
```bash
# 토큰이 올바른지 확인
echo $SUPABASE_ACCESS_TOKEN
# 출력: sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b
```

### 3. 연결 테스트
```bash
# CLI 연결 테스트
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase projects list

# 데이터베이스 직접 연결 테스트
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek -c "SELECT version();"
```

---

## 📝 빠른 참조

### 자주 사용하는 명령어
```bash
# 프로젝트 목록
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase projects list

# roles 테이블 확인
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek -c "SELECT * FROM public.roles ORDER BY id;"

# users 테이블 확인
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek -c "SELECT id, role_id, email FROM public.users LIMIT 10;"
```

### 현재 roles 테이블 구조
```sql
-- id | name  | kor_name
-- 1  | GUEST | 게스트
-- 2  | STAR  | 스타
-- 3  | PLACE | 플레이스
-- 4  | ADMIN | 관리자
-- 6  | MEMBER| 멤버
```

---

**⚠️ 보안 주의사항**
- 토큰을 공개 저장소에 커밋하지 마세요
- 패스워드는 반드시 환경 변수로 관리하세요
- 프로덕션 환경에서는 더 강력한 패스워드를 사용하세요