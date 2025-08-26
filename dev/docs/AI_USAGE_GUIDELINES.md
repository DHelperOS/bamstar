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

운영/개발 워크플로 규정 (중요)
--------------------------------
- 모든 로컬 개발, 테스트, 그리고 AI 기반 코드 생성/검토 작업은 반드시 저장소에 포함된 MCP 서버들(`mcp/context7-mcp`, `mcp/serena-mcp`, `mcp/sequential-mcp`)을 통해 실행해야 합니다.
- 외부에서 직접 DB나 Supabase에 접속해 작업을 수행하거나 AI가 직접 원격에 변경을 가하도록 허용하지 마세요. 대신 해당 작업은 MCP를 경유해 수행하도록 설계되어야 합니다.
- PR 본문에는 사용한 MCP 이름과 `MCP_AUTH_TOKEN`이 아닌 환경/연결 방식(예: local .env, CI secrets)을 명시하세요. (민감 정보는 절대 포함 금지)

이 규정은 저장소의 자동화된 테스트, 마이그레이션 실행, Edge Function 배포, 그리고 AI가 생성하는 데이터 액세스 경로에 일관성을 보장하기 위해 존재합니다.

