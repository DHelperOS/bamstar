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
RETURNS TABLE (profile_image_url TEXT) LANGUAGE sql STABLE AS $$
  WITH recent_commenters AS (
    SELECT author_id, MAX(created_at) AS last_comment_time
    FROM public.community_comments
    WHERE post_id = post_id_in AND is_anonymous = false
    GROUP BY author_id
    ORDER BY last_comment_time DESC
    LIMIT limit_in
  )
  SELECT u.profile_image_url
  FROM public.users u
  JOIN recent_commenters rc ON u.id = rc.author_id
  ORDER BY rc.last_comment_time DESC;
$$;
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