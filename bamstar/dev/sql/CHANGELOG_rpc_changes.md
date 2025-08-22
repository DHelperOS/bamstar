RPC 변경/생성 요약

파일: `dev/sql/community_search_and_rpcs.sql` (수정됨)
- 수정된 RPC
  - `get_post_commenter_avatars_batch(post_ids_in bigint[], limit_in int)`
    - 변경: 기존 DISTINCT/ORDER 방식에서 윈도우 기반(rank) 접근으로 변경.
    - 동작: 각 post_id, author_id 쌍에 대해 최신 코멘트 시간을 산출한 뒤, post별로 최신 작성자 상위 N명을 반환합니다. 익명/NULL 작성자는 제외.
  - `get_post_commenter_avatars(post_id_in bigint, limit_in int)`
    - 변경: author별 MAX(created_at)을 사용해 중복 작성자 제거 및 최신순 정렬.
  - `get_top_posts_by_metric(window_days integer, metric text, limit_val integer, offset_val integer)`
    - 변경: 이전에 잘못 중단된/오탈자 있는 구현을 정리하고 안정적 구현으로 재작성. window(기간)내 posts를 집계(likes/comments)하여 metric 기준으로 정렬하여 반환.

새로 생성된 파일
- `dev/sql/get_post_recent_interactors.sql` (신규)
  - 목적: 댓글 작성자와 좋아요 누른 사용자(likers)를 통합하여, 각 포스트별 최근 상호작용자(top N)를 반환.
  - 함수:
    - `get_post_recent_interactors_batch(post_ids_in bigint[], limit_in int)` -> RETURNS TABLE(post_id bigint, profile_img text)
    - `get_post_recent_interactors(post_id_in bigint, limit_in int)` -> RETURNS TABLE(profile_img text)
  - 동작 요약:
    1. `community_comments` (익명 제외)와 `community_likes`에서 (post_id, user_id, created_at)을 모읍니다.
    2. (post_id, user_id)별로 최신 상호작용 시각을 취합니다.
    3. 각 post별로 최신 상호작용자 순서대로 top N을 선택합니다.
    4. `users.profile_img`가 있는 사용자만 반환합니다.
  - 비고: RLS가 설정된 DB에서는 `users.profile_img` 접근이 차단될 수 있으며, 이 경우 `SECURITY DEFINER` 버전의 함수 또는 적절한 GRANT가 필요합니다.

권장 추가/검토 사항 (배포 전 반드시 확인)
- RLS/권한: `users` 테이블에 RLS가 있으면 anon 역할로는 profile_img를 읽을 수 없습니다. 다음 중 하나를 적용하세요:
  1. 함수에 `SECURITY DEFINER`를 추가하고 함수 소유자를 신뢰할 수 있는 서비스 계정으로 설정.
  2. `GRANT EXECUTE`로 특정 역할에 함수 실행 권한 부여하고, 필요한 경우 `users`에 대한 읽기 정책을 추가.
- 테스트 쿼리 (스테이징에서 실행):
  - `SELECT * FROM public.get_post_recent_interactors(123, 3);`
  - `SELECT * FROM public.get_post_recent_interactors_batch(ARRAY[1,2,3]::bigint[], 3);`
  - `SELECT * FROM public.get_post_commenter_avatars(123, 3);` (수정된 기존 RPC 검증)
  - `SELECT * FROM public.get_top_posts_by_metric(7, 'likes', 10, 0);` (수정된 인기 포스트 RPC 검증)

롤백/주의
- 기존 함수들은 `CREATE OR REPLACE`로 덮어써졌습니다. 필요시 이전 버전을 백업해 두었다가 복원하세요.

문의
- RLS 환경에서 `SECURITY DEFINER` 적용을 원하시면, 어느 DB 사용자(예: `postgres` 또는 `service_role`)를 소유자로 설정할지 알려주시면 해당 버전의 SQL을 생성해 드립니다.
