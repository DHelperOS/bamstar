[밤스타] 커뮤니티 기능 상세 명세서
1. 핵심 철학 및 목표
1.1. 목표
멤버(스타)들에게 강력한 소속감과 정서적 유대를 제공하여, 채용 활동이 끝나도 앱을 계속 사용하게 만드는 **'떠날 수 없는 커뮤니티'**를 구축한다.
1.2. 핵심 원칙
멤버(스타) 전용 공간: 플레이스의 접근을 원천적으로 차단하여, 스타들만의 **완벽한 '안전지대'**를 보장한다.
자유와 질서의 조화: 스타들의 자유로운 표현을 최대한 보장하되, 시스템(AI)이 뒤에서 조용히 질서를 유지하고 정보의 가치를 높인다.
정보의 공공재화: 스타 간 1:1 채팅을 금지하여, 모든 유용한 정보가 커뮤니티라는 '공개된 광장'에 축적되도록 한다.
2. 주요 기능 및 UI/UX 설계
2.1. 메인 피드 (Community Home)
UI: 개인화된 세로 스크롤 통합 피드.
콘텐츠: 구독한 #채널/스타의 글, AI 추천 글, 인기 글이 혼합 노출.
필터: 화면 상단에 구독 채널 목록을 '가로 스크롤 칩(Chip)' 형태로 제공하여, 탭으로 피드를 필터링.
게시글 카드:
댓글 작성자 스택: 댓글 단 스타들의 프로필 사진을 동그랗게 겹쳐 보이는 '스택(Stack)' UI로 글의 활성도를 시각화.
익명 글 시각적 구분: '익명 전용 아이콘'과 닉네임, 그리고 카드 좌측에 '표시 바'를 두어 명확히 구분.
2.2. 글쓰기 (Create Post)
진입점: 화면 우측 하단의 플로팅 액션 버튼(FAB).
핵심 기능: 익명 스위치
UI: 글쓰기 에디터 하단의 직관적인 토글 스위치.
스위치 OFF: 본래 닉네임/프로필로 게시. (일상/소셜용)
스위치 ON: '익명의 스타'로 게시. (민감 정보 공유용)
첨부 기능: 텍스트, 이미지(여러 장) 첨부 가능.
2.3. 댓글 (Comments)
계층 구조: **대댓글(Threaded Comments)**을 지원하여 깊이 있는 대화가 가능하도록 설계.
첨부 기능: 텍스트와 함께, **이미지(1장)**를 첨부하여 '짤'이나 인증샷 등으로 풍부한 소통이 가능하도록 지원.
상호작용: 개별 댓글에도 **'좋아요'**를 누를 수 있음.
2.4. #해시태그 채널 시스템
채널 자동 생성: 스타가 글 작성 시, 존재하지 않던 #해시태그를 사용하면 해당 '채널'이 자동으로 생성됨.
유사 채널 난립 방지 ('보이지 않는' 자동화):
AI 태그 통합: 백그라운드에서 주기적으로 AI가 유사 태그를 자동으로 그룹핑하고 **'대표 채널'**을 지정.
AI 설명 생성: AI가 신규 채널의 이름과 초기 게시글 맥락을 분석하여 '채널 설명'을 자동으로 생성.
태그 자동완성: 글쓰기 시, 인기 있는 '대표 채널'을 먼저 추천하여 표준화된 태그 사용 유도.
2.5. 채널 탐색 (Channel Explorer)
진입점: 커뮤니티 홈 헤더의 🧭 아이콘.
UI 구성:
검색 바: 채널명 직접 검색.
랭킹: 👑 지금 뜨는 채널, 🏆 명예의 전당 등으로 발견의 재미 제공.
카테고리: AI가 자동으로 분류한 [📍 지역 정보], [💡 업무 노하우] 등으로 체계적 탐색.
3. 데이터베이스 스키마 (Supabase/PostgreSQL)
3.1. 테이블 생성 SQL (Full)
code
SQL
-- ==========[ 섹션 0: 사전 준비 - 공용 자동화 함수 생성 ]==========
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========[ 섹션 1: 커뮤니티 핵심 테이블 생성 ]==========
CREATE TABLE public.community_posts (
  id BIGSERIAL PRIMARY KEY,
  author_id UUID NOT NULL REFERENCES public.users(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  is_anonymous BOOLEAN NOT NULL DEFAULT false,
  image_urls TEXT[],
  view_count BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE public.community_hashtags (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  category TEXT,
  post_count INT NOT NULL DEFAULT 0,
  subscriber_count INT NOT NULL DEFAULT 0,
  last_used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  parent_hashtag_id INT REFERENCES public.community_hashtags(id) -- 유사 태그 그룹핑용
);

CREATE TABLE public.post_hashtags (
  post_id BIGINT NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
  hashtag_id INT NOT NULL REFERENCES public.community_hashtags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, hashtag_id)
);

CREATE TABLE public.community_subscriptions (
  id BIGSERIAL PRIMARY KEY,
  subscriber_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  target_hashtag_id INT REFERENCES public.community_hashtags(id) ON DELETE CASCADE,
  target_member_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT unique_subscription_check UNIQUE (subscriber_id, target_hashtag_id, target_member_id),
  CONSTRAINT target_presence_check CHECK (num_nonnulls(target_hashtag_id, target_member_id) = 1)
);

CREATE TABLE public.community_comments (
  id BIGSERIAL PRIMARY KEY,
  post_id BIGINT NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES public.users(id) ON DELETE SET NULL,
  content TEXT, 
  image_url TEXT, 
  is_anonymous BOOLEAN NOT NULL DEFAULT false,
  parent_comment_id BIGINT REFERENCES public.community_comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT content_or_image_check CHECK (num_nonnulls(content, image_url) > 0)
);

CREATE TABLE public.community_likes (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  post_id BIGINT REFERENCES public.community_posts(id) ON DELETE CASCADE,
  comment_id BIGINT REFERENCES public.community_comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT unique_post_like UNIQUE (user_id, post_id),
  CONSTRAINT unique_comment_like UNIQUE (user_id, comment_id),
  CONSTRAINT target_like_check CHECK (num_nonnulls(post_id, comment_id) = 1)
);

-- ==========[ 섹션 2: 자동화를 위한 함수 및 트리거 ]==========
-- (이전 답변과 동일한 handle_post_hashtags, trigger_handle_post_hashtags, update_hashtag_subscriber_count 등 함수 및 트리거)

### 3.2. 데이터베이스 함수 (RPC)
```sql
-- 댓글 작성자 프로필 스택 조회를 위한 DB 함수 (users 테이블 직접 조회)
CREATE OR REPLACE FUNCTION public.get_post_commenter_avatars(post_id_in BIGINT, limit_in INT)
RETURNS TABLE (profile_img TEXT) LANGUAGE sql STABLE AS $$
  WITH recent_commenters AS (
    SELECT author_id, MAX(created_at) AS last_comment_time
    FROM public.community_comments
    WHERE post_id = post_id_in AND is_anonymous = false
    GROUP BY author_id
    ORDER BY last_comment_time DESC
    LIMIT limit_in
  )
  SELECT u.profile_img
  FROM public.users u
  JOIN recent_commenters rc ON u.id = rc.author_id
  ORDER BY rc.last_comment_time DESC;
$$;

-- Server-side aggregation RPC: return per-post counts for likes and comments
CREATE OR REPLACE FUNCTION public.get_post_counts(post_ids_in BIGINT[])
RETURNS TABLE(post_id BIGINT, likes_count INT, comments_count INT) LANGUAGE sql STABLE AS $$
  SELECT p.id::bigint as post_id,
    COALESCE(l.likes_count, 0) AS likes_count,
    COALESCE(c.comments_count, 0) AS comments_count
  FROM (
    SELECT unnest(post_ids_in) AS id
  ) p
  LEFT JOIN (
    SELECT post_id, COUNT(*)::int AS comments_count
    FROM public.community_comments
    WHERE post_id = ANY(post_ids_in)
    GROUP BY post_id
  ) c ON c.post_id = p.id
  LEFT JOIN (
    SELECT post_id, COUNT(*)::int AS likes_count
    FROM public.community_likes
    WHERE post_id = ANY(post_ids_in)
    GROUP BY post_id
  ) l ON l.post_id = p.id;
$$;

-- Returns post_ids the current authenticated user has liked from the provided list
CREATE OR REPLACE FUNCTION public.get_user_liked_posts(post_ids_in BIGINT[])
RETURNS TABLE(post_id BIGINT) LANGUAGE sql STABLE AS $$
  SELECT post_id
  FROM public.community_likes
  WHERE user_id = auth.uid() AND post_id = ANY(post_ids_in);
$$;

-- Increment view_count for a post and return the new count
CREATE OR REPLACE FUNCTION public.increment_post_view(post_id_in BIGINT)
RETURNS TABLE(new_count BIGINT) LANGUAGE sql VOLATILE AS $$
  UPDATE public.community_posts
  SET view_count = view_count + 1
  WHERE id = post_id_in
  RETURNING view_count AS new_count;
$$;

-- -----------------------------------------------------------------------------
-- Server-side ranking RPC: get_top_posts_by_metric
-- -----------------------------------------------------------------------------
-- 설명:
-- "인기 순"(comments 기준) 또는 "좋아요 순"(likes 기준) 정렬을 클라이언트에서
-- 페이지네이션하면서 정확하게 구현하려면 DB에서 집계·정렬된 결과를 직접 받아야 합니다.
-- 아래 RPC는 주어진 최근 윈도우(예: 7일) 내의 게시글을 metric( 'comments' | 'likes' ) 으로
-- 정렬하여 반환합니다. 반환값에는 likes_count, comments_count 필드가 포함되어 있습니다.
-- 사용 예:
-- SELECT * FROM public.get_top_posts_by_metric(7, 'comments', 20, 0);
-- SELECT * FROM public.get_top_posts_by_metric(7, 'likes', 20, 0);

-- 권장 인덱스:
-- - community_comments(post_id, created_at)
-- - community_likes(post_id, created_at)
-- - community_posts(created_at)
-- 이러한 인덱스들은 윈도우 기반 필터링(최근 N일)과 집계 쿼리를 가속화합니다.

4. 보안 (Row Level Security)
4.1. RLS 정책 SQL
code
SQL
-- 게시글 (community_posts)
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read access to authenticated users" ON public.community_posts FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow users to manage their own posts" ON public.community_posts FOR INSERT, UPDATE, DELETE USING (auth.uid() = author_id);

-- 댓글 (community_comments)
ALTER TABLE public.community_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read access to authenticated users" ON public.community_comments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow users to manage their own comments" ON public.community_comments FOR INSERT, UPDATE, DELETE USING (auth.uid() = author_id);

-- 공감/좋아요 (community_likes)
ALTER TABLE public.community_likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read access to authenticated users" ON public.community_likes FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow users to manage their own likes" ON public.community_likes FOR INSERT, DELETE USING (auth.uid() = user_id);

-- 구독 (community_subscriptions)
ALTER TABLE public.community_subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow users to read their own subscriptions" ON public.community_subscriptions FOR SELECT USING (auth.uid() = subscriber_id);
CREATE POLICY "Allow users to manage their own subscriptions" ON public.community_subscriptions FOR INSERT, DELETE USING (auth.uid() = subscriber_id);

-- #해시태그 테이블 (읽기 전용)
ALTER TABLE public.community_hashtags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read access to all users" ON public.community_hashtags FOR SELECT USING (true);

-- 1. 트리거가 호출할 '함수'를 먼저 생성합니다.
--    이 함수의 역할은 오직 '기본 채널 구독' 정보를 추가하는 것 하나뿐입니다.
CREATE OR REPLACE FUNCTION public.subscribe_default_channels_on_signup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- 신규 사용자(NEW.id)가 '8번' 채널을 구독하도록 INSERT
  INSERT INTO public.community_subscriptions (subscriber_id, target_hashtag_id)
  VALUES (NEW.id, 8);
  
  -- (만약 9번 채널도 기본 구독시키고 싶다면 아래 줄의 주석을 푸세요)
  -- INSERT INTO public.community_subscriptions (subscriber_id, target_hashtag_id)
  -- VALUES (NEW.id, 9);

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.subscribe_default_channels_on_signup() IS '신규 가입 시, 사용자를 미리 지정된 기본 커뮤니티 채널에 자동으로 구독시킵니다.';


-- 2. '트리거'를 생성하여 위 함수와 Supabase 인증 시스템을 연결합니다.
--    이 트리거는 'auth.users' 테이블에 새로운 행이 추가될 때마다 작동합니다.

-- (혹시 모를 충돌을 방지하기 위해, 같은 이름의 기존 트리거가 있다면 먼저 삭제합니다)
DROP TRIGGER IF EXISTS on_auth_user_created_subscribe_default ON auth.users;

CREATE TRIGGER on_auth_user_created_subscribe_default
  AFTER INSERT ON auth.users -- 'auth.users' 테이블에
  FOR EACH ROW               -- 새로운 행이 추가될 때마다
  EXECUTE PROCEDURE public.subscribe_default_channels_on_signup(); -- 위에서 만든 함수를 실행시켜라.




  -- 1단계: 기존의 복합 기본키(Primary Key) 제약조건을 먼저 제거합니다.
-- (Supabase가 자동으로 생성한 이름은 보통 'community_likes_pkey' 입니다.)
ALTER TABLE public.community_likes
  DROP CONSTRAINT IF EXISTS community_likes_pkey;


-- 2단계: 각 '좋아요' 행위를 위한 고유 ID 컬럼(id)을 추가하고, 이를 새로운 기본키로 설정합니다.
-- (IF NOT EXISTS 구문으로, 컬럼이 이미 존재하면 오류 없이 넘어갑니다.)
ALTER TABLE public.community_likes
  ADD COLUMN IF NOT EXISTS id BIGSERIAL PRIMARY KEY;


-- 3단계: 댓글을 참조할 수 있는 comment_id 컬럼을 추가합니다.
ALTER TABLE public.community_likes
  ADD COLUMN IF NOT EXISTS comment_id BIGINT REFERENCES public.community_comments(id) ON DELETE CASCADE;


-- 4단계: post_id 컬럼이 더 이상 항상 값이 있을 필요가 없으므로, NOT NULL 제약조건을 제거합니다.
ALTER TABLE public.community_likes
  ALTER COLUMN post_id DROP NOT NULL;


-- 5단계: 새로운 규칙을 적용하기 위한 제약조건(Constraint)들을 추가합니다.
-- (오류 방지를 위해, 기존에 같은 이름의 제약조건이 있다면 먼저 삭제합니다.)
ALTER TABLE public.community_likes
  DROP CONSTRAINT IF EXISTS unique_post_like,
  DROP CONSTRAINT IF EXISTS unique_comment_like,
  DROP CONSTRAINT IF EXISTS target_like_check;

-- 제약조건 5.1: 한 사람이 같은 '게시글'에 중복으로 좋아요 누르는 것을 방지
ALTER TABLE public.community_likes
  ADD CONSTRAINT unique_post_like UNIQUE (user_id, post_id);

-- 제약조건 5.2: 한 사람이 같은 '댓글'에 중복으로 좋아요 누르는 것을 방지
ALTER TABLE public.community_likes
  ADD CONSTRAINT unique_comment_like UNIQUE (user_id, comment_id);

-- 제약조건 5.3: '좋아요'의 대상은 게시글 또는 댓글, 둘 중 하나여야 함을 강제
ALTER TABLE public.community_likes
  ADD CONSTRAINT target_like_check CHECK (num_nonnulls(post_id, comment_id) = 1);


-- 6단계: RLS 정책을 새로운 구조에 맞게 다시 정의합니다.
-- (기존 정책들을 안전하게 삭제하고, 올바른 문법으로 다시 생성합니다.)
DROP POLICY IF EXISTS "Allow read access to authenticated users" ON public.community_likes;
DROP POLICY IF EXISTS "Allow users to manage their own likes" ON public.community_likes;
DROP POLICY IF EXISTS "Allow users to insert their own likes" ON public.community_likes;
DROP POLICY IF EXISTS "Allow users to delete their own likes" ON public.community_likes;

CREATE POLICY "Allow read access to authenticated users" ON public.community_likes FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow users to insert their own likes" ON public.community_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Allow users to delete their own likes" ON public.community_likes FOR DELETE USING (auth.uid() = user_id);


-- 7단계: 테이블과 컬럼에 대한 주석(Comment)을 업데이트하여, 새로운 구조를 명확히 설명합니다.
COMMENT ON TABLE public.community_likes IS '멤버가 게시글 또는 댓글에 누른 공감(좋아요) 정보. (댓글 좋아요 지원)';
COMMENT ON COLUMN public.community_likes.post_id IS '좋아요 대상 (게시글 ID). 댓글에 좋아요를 누른 경우 NULL.';
COMMENT ON COLUMN public.community_likes.comment_id IS '좋아요 대상 (댓글 ID). 게시글에 좋아요를 누른 경우 NULL.';


CREATE TABLE public.community_likes (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- '좋아요'의 대상은 post 또는 comment 둘 중 하나입니다.
  post_id BIGINT REFERENCES public.community_posts(id) ON DELETE CASCADE,
  comment_id BIGINT REFERENCES public.community_comments(id) ON DELETE CASCADE,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- 제약조건 1: 한 사람이 같은 '게시글'에 중복으로 좋아요 누르는 것을 방지합니다.
  CONSTRAINT unique_post_like UNIQUE (user_id, post_id),

  -- 제약조건 2: 한 사람이 같은 '댓글'에 중복으로 좋아요 누르는 것을 방지합니다.
  CONSTRAINT unique_comment_like UNIQUE (user_id, comment_id),

  -- 제약조건 3: '좋아요'의 대상은 게시글 또는 댓글, 둘 중 하나여야 함을 강제합니다.
  CONSTRAINT target_like_check CHECK (num_nonnulls(post_id, comment_id) = 1)
);


-- 2. 테이블 및 컬럼에 대한 주석(Comment) 추가
COMMENT ON TABLE public.community_likes IS '멤버가 게시글 또는 댓글에 누른 공감(좋아요) 정보.';
COMMENT ON COLUMN public.community_likes.post_id IS '좋아요 대상 (게시글 ID). 댓글에 좋아요를 누른 경우 NULL.';
COMMENT ON COLUMN public.community_likes.comment_id IS '좋아요 대상 (댓글 ID). 게시글에 좋아요를 누른 경우 NULL.';


-- 3. RLS (Row Level Security) 활성화 및 정책 정의
ALTER TABLE public.community_likes ENABLE ROW LEVEL SECURITY;

-- 정책 3.1: 로그인한 사용자는 모든 좋아요 정보를 '읽을(SELECT)' 수 있습니다.
CREATE POLICY "Allow read access to authenticated users"
  ON public.community_likes
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- 정책 3.2: 사용자는 자신의 좋아요만 '누를(INSERT)' 수 있습니다.
CREATE POLICY "Allow users to insert their own likes"
  ON public.community_likes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 정책 3.3: 사용자는 자신의 좋아요만 '취소(DELETE)'할 수 있습니다.
CREATE POLICY "Allow users to delete their own likes"
  ON public.community_likes
  FOR DELETE
  USING (auth.uid() = user_id);