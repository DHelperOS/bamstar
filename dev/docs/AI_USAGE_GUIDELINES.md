AI 참고 지침 (데이터베이스 레퍼런스 사용법)

목적: AI가 `dev/docs/`에 있는 DB/함수/트리거 스냅샷을 안전하고 일관되게 활용하도록 안내합니다.

우선순위 요약:
1. 새로운 쿼리나 코드 변경 요청이 들어오면 먼저 `dev/docs/functions.sql`에서 관련 함수 시그니처와 반환 타입을 확인하세요.
2. 데이터 모델 수정 요청은 `dev/docs/tables_and_views.txt`를 참조하여 스키마 영향을 평가하세요.
3. 트리거 관련 변경은 `dev/docs/triggers.txt`를 확인해 의도치 않은 사이드 이펙트를 예방하세요.

보안/민감도 표시:
- `.env` 또는 `bamstar/.env` 파일에 민감한 키가 포함되어 있습니다. AI는 절대 민감 키를 로그나 공개 PR에 포함시키면 안 됩니다.
- 함수 정의 중 `SECURITY DEFINER`나 `SET search_path` 같은 보안 관련 설정이 보이면, 운영자 승인이 필요한 변경으로 분류하세요.

변경 제안 프로세스:
1. 제안된 SQL 변경은 `dev/sql/`에 idempotent한 스크립트로 추가하세요. (예: `-- DROP IF EXISTS` / CREATE OR REPLACE 주석 포함)
2. 변경 스크립트에 영향받는 테이블/함수/트리거의 목록을 헤더 주석으로 명시하세요.
3. 로컬에서 `psql`로 샘플 실행을 검증한 뒤 PR을 생성하세요.

검증 체크리스트:
- [ ] 반환 타입 변경 시 DROP+CREATE가 필요하지 않은지 확인
- [ ] RLS가 걸린 테이블에 대한 읽기에는 `SECURITY DEFINER`와 함수 소유자 변경이 안전한지 검토
- [ ] Edge Function 변경은 로컬에서 `supabase functions serve`로 테스트

끝.
