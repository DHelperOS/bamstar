# RLS 보안 정책 배포 현황

## ✅ 완료된 작업

### 1. RLS 활성화 (완료)
모든 테이블에 Row Level Security가 활성화되었습니다:

| 테이블 | RLS 상태 |
|--------|---------|
| place_profiles | ✅ Enabled |
| place_attributes_link | ✅ Enabled |
| place_preferences_link | ✅ Enabled |
| place_industries | ✅ Enabled |
| member_hearts | ✅ Enabled |
| place_hearts | ✅ Enabled |
| member_favorites | ✅ Enabled |
| place_favorites | ✅ Enabled |
| matching_scores | ✅ Enabled |
| matching_weights | ✅ Enabled |
| matching_filters | ✅ Enabled |
| matching_queue | ✅ Enabled |
| matching_history | ✅ Enabled |

### 2. RLS 정책 파일 생성 (완료)
다음 파일들이 생성되었습니다:
- `/sql/05_enable_rls_policies.sql` - 전체 RLS 정책
- `/supabase/migrations/20250829154045_add_rls_policies.sql` - 마이그레이션 파일
- `/scripts/apply_rls_policies.sql` - 실행 가능한 정책 스크립트

## 🔄 다음 단계: RLS 정책 적용

### 방법 1: Supabase 대시보드에서 직접 실행
1. [Supabase Dashboard](https://supabase.com/dashboard/project/tflvicpgyycvhttctcek/sql/new) 접속
2. `/supabase/migrations/20250829154045_add_rls_policies.sql` 내용 복사
3. SQL Editor에서 실행

### 방법 2: Supabase CLI 사용 (로그인 후)
```bash
# 이미 로그인됨
supabase db push --linked
```

### 방법 3: 직접 SQL 실행
```bash
# scripts/apply_rls_policies.sql 실행
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com \
  -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek \
  -f /Users/deneb/Desktop/Project/BamStar/bamstar/scripts/apply_rls_policies.sql
```

## 📋 RLS 정책 요약

### 🔍 조회 권한 차별화 (핵심 변경사항)
- **Member (스타)**: 
  - ✅ 모든 Place 프로필 자유롭게 조회 가능
  - ✅ 다른 Member 프로필도 조회 가능
  
- **Place (플레이스)**:
  - ⛔ Member가 수락한 경우만 Member 프로필 조회 가능
  - ✅ 자신의 프로필만 수정 가능

### Place 관련 정책
- **Member 조회**: Member는 모든 Place 프로필/속성/선호도 자유롭게 조회 가능
- **Place 조회**: Place는 자신의 데이터만 조회 가능
- **수정**: 본인 소유 데이터만 수정 가능 (auth.uid() = user_id)

### Member 관련 정책
- **Place의 조회 제한**: Place는 다음 경우만 Member 조회 가능:
  1. Place가 보낸 좋아요를 Member가 수락한 경우
  2. Member가 보낸 좋아요를 Place가 수락한 경우 (상호 매칭)
- **Member끼리 조회**: Member는 다른 Member 프로필 조회 가능

### Hearts (좋아요) 정책
- **전송**: 본인 계정으로만 좋아요 전송 가능
- **조회**: 본인이 보낸/받은 좋아요만 조회 가능
- **수정/삭제**: 본인이 보낸 좋아요만 관리 가능

### Favorites (즐겨찾기) 정책
- **전체 권한**: 본인 즐겨찾기만 관리 가능

### Matching 시스템 정책
- **매칭 점수**: 본인 관련 점수만 조회 가능
- **가중치/필터**: 본인 설정만 관리 가능
- **큐/히스토리**: 본인 데이터만 접근 가능
- **Service Role**: Edge Functions만 매칭 점수 생성/수정 가능

## ⚠️ 주의사항

1. **정책 적용 전 테스트**: 개발 환경에서 먼저 테스트 권장
2. **기존 데이터 확인**: RLS 적용 후 접근 권한 확인 필요
3. **Edge Functions**: Service Role Key 사용 확인 필요

## 🔍 정책 검증 쿼리

```sql
-- RLS 상태 확인
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;

-- 정책 목록 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

## 📞 문제 발생 시

1. RLS로 인한 데이터 접근 불가 시:
   - Service Role Key 사용 확인
   - auth.uid() 값 확인
   
2. 정책 충돌 시:
   - 기존 정책 삭제 후 재적용
   ```sql
   DROP POLICY IF EXISTS "policy_name" ON table_name;
   ```

3. 긴급 비활성화:
   ```sql
   ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;
   ```

---

**마지막 업데이트**: 2025-08-29 15:40 KST
**상태**: RLS 활성화 완료, 정책 적용 대기 중