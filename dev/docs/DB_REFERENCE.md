## 데이터베이스 및 서버리스 함수 레퍼런스

이 문서는 로컬 개발 환경의 Supabase Postgres 인스턴스에서 추출한 테이블/뷰, SQL 함수(프로시저)와 트리거 목록, 그리고 프로젝트에 포함된 Supabase Edge Functions(프로젝트 파일)를 요약합니다. AI가 이 레퍼런스를 참고하여 코드 수정, 쿼리 작성, 또는 문서화를 할 수 있도록 설계되었습니다.

---

### 1) 테이블 및 뷰

생성된 파일: `dev/docs/tables_and_views.txt`

내용 예시(파일을 참조하세요):

- 스키마.테이블명|TABLE/VIEW

이 파일은 데이터베이스 내 모든 사용자 스키마의 테이블 및 뷰를 한 줄씩 나열합니다. AI는 특정 테이블을 찾거나 열 이름/관계를 파악할 때 이 목록을 먼저 확인해야 합니다.

---

### 2) SQL 함수(및 정의)

생성된 파일: `dev/docs/functions.sql`

이 파일은 다음 정보를 포함합니다: 함수 시그니처, 반환 타입, 그리고 전체 함수 정의(바디). 예제 항목은 파일 상단에 `--- schema.function(args) RETURNS type` 식으로 구분되어 있습니다.

사용 지침 (AI용):
- 함수 변경 전: 항상 해당 함수를 DROP + CREATE 해야 할지, 또는 ALTER로 충분한지 검토하세요. Postgres는 반환 타입 변경에 대해 DROP+CREATE를 요구할 수 있습니다.
- 권한/보안: RLS가 적용된 테이블에서 다른 스키마(users 등)의 칼럼을 읽어야 하는 함수는 `SECURITY DEFINER`로 정의하고 소유자를 신뢰된 역할(service_role)로 설정해야 합니다. 변경 시 운영자 승인 필요.
- 테스트: 함수 수정 후 `psql`로 간단한 샘플 입력을 호출해 반환 형태와 데이터 존재 여부를 확인하세요.

---

### 3) 트리거

생성된 파일: `dev/docs/triggers.txt`

이 파일은 각 트리거의 호출 테이블, 시점(AFTER/BEFORE), 조작(INSERT/UPDATE/DELETE)과 동작문(action_statement)을 나열합니다.

사용 지침 (AI용):
- 트리거는 데이터 일관성/카운트 업데이트 등을 자동화합니다. 트리거를 변경하거나 비활성화하면 관련 카운트/인덱스 로직에 사이드 이펙트가 발생할 수 있으니 주석과 테스트를 남기세요.

---

### 4) Supabase Edge Functions (프로젝트 내 파일)

발견된 경로 예시:

- `dev/supabase/functions/image-safety-web/index.ts`

사용 지침 (AI용):
- Edge Function 코드가 외부 API 키나 비밀을 참조할 경우에는 `.env` 또는 Supabase 프로젝트의 Secrets 에 안전히 보관되어 있는지 확인하세요.
- Edge Function을 변경하면 로컬에서 `supabase functions serve`로 테스트하고 배포 시 `supabase functions deploy <name>` 루틴을 따르세요.

---

### 5) 권장 워크플로(운영자/AI용 체크리스트)

1. 변경 범위 식별: 테이블, 함수, 트리거 또는 Edge Function 중 어느 것을 변경할지 명확히 합니다.
2. 로컬 검증: `psql` 또는 Supabase CLI로 샘플 호출을 실행해 반환값과 권한을 확인합니다.
3. 보안 검토: RLS 영향, `SECURITY DEFINER` 필요 여부, 함수 소유자 변경 필요 여부를 검토합니다.
4. 마이그레이션 스크립트: 변경사항은 `dev/sql/`에 idempotent한 SQL 스크립트로 추가합니다 (DROP/CREATE 또는 ALTER; 주석 포함).
5. 배포 및 확인: staging에 적용 후 `psql`로 권한/작동을 확인하고, 그 다음 프로덕션에 롤아웃하세요.

---

### 6) 참고 파일

- `dev/docs/tables_and_views.txt` — 테이블/뷰 원시 목록
- `dev/docs/functions.sql` — 함수 정의 원본
- `dev/docs/triggers.txt` — 트리거 목록

끝.
