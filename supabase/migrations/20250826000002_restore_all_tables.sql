-- 전체 스키마 복구용 SQL
-- BamStar 데이터베이스 완전 복구

-- ==============================================
-- 1. 기본 테이블들
-- ==============================================

-- roles 테이블
CREATE TABLE IF NOT EXISTS public.roles (
  id serial primary key,
  name text unique not null,
  kor_name text not null default '게스트'
);

INSERT INTO public.roles (name, kor_name) VALUES
  ('GUEST', '게스트'), 
  ('MEMBER', '멤버'), 
  ('PLACE', '플레이스'), 
  ('ADMIN', '관리자')
ON CONFLICT (name) DO NOTHING;

-- users 테이블
CREATE TABLE IF NOT EXISTS public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  role_id integer not null references public.roles(id),
  ci text unique,
  is_adult boolean not null default false,
  email text unique,
  phone text unique,
  created_at timestamptz not null default now(),
  profile_img text,
  nickname text default '',
  index bigint not null
);

-- users 기본 역할 설정 함수
CREATE OR REPLACE FUNCTION public.set_default_guest_role()
RETURNS trigger as $$
BEGIN
  IF NEW.role_id IS NULL THEN
    SELECT r.id INTO NEW.role_id FROM public.roles r WHERE r.name = 'GUEST';
  END IF;
  RETURN NEW;
END;
$$ language plpgsql;

DROP TRIGGER IF EXISTS trg_users_default_role on public.users;
CREATE TRIGGER trg_users_default_role
BEFORE INSERT ON public.users
FOR EACH ROW EXECUTE FUNCTION public.set_default_guest_role();

-- devices 테이블
CREATE TABLE IF NOT EXISTS public.devices (
  id bigserial primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  device_uuid text,
  device_os text,
  last_login_at timestamptz
);

-- ==============================================
-- 2. 카테고리 및 지역 테이블들
-- ==============================================

-- main_categories 테이블
CREATE TABLE IF NOT EXISTS public.main_categories (
  category_id serial primary key,
  name varchar(50) not null
);

-- area_groups 테이블
CREATE TABLE IF NOT EXISTS public.area_groups (
  group_id serial primary key,
  category_id integer not null references public.main_categories(category_id),
  name varchar(100) not null
);

-- area_keywords 테이블
CREATE TABLE IF NOT EXISTS public.area_keywords (
  keyword_id serial primary key,
  keyword varchar(50) not null unique,
  group_id integer not null references public.area_groups(group_id)
);

-- ==============================================
-- 3. 커뮤니티 테이블들
-- ==============================================

-- community_hashtags 테이블
CREATE TABLE IF NOT EXISTS public.community_hashtags (
  id serial primary key,
  name text not null unique,
  category text,
  post_count integer not null default 0,
  subscriber_count integer not null default 0,
  last_used_at timestamptz,
  created_at timestamptz not null default now(),
  description text
);

-- community_posts 테이블
CREATE TABLE IF NOT EXISTS public.community_posts (
  id bigserial primary key,
  author_id uuid not null references public.users(id),
  content text not null,
  is_anonymous boolean not null default false,
  image_urls text[],
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  view_count integer not null default 0
);

-- community_comments 테이블
CREATE TABLE IF NOT EXISTS public.community_comments (
  id bigserial primary key,
  post_id bigint not null references public.community_posts(id) on delete cascade,
  author_id uuid not null references public.users(id),
  content text,
  is_anonymous boolean not null default false,
  parent_comment_id bigint references public.community_comments(id),
  created_at timestamptz not null default now(),
  image_url text
);

-- community_likes 테이블
CREATE TABLE IF NOT EXISTS public.community_likes (
  id bigserial primary key,
  user_id uuid not null references public.users(id),
  post_id bigint references public.community_posts(id) on delete cascade,
  comment_id bigint references public.community_comments(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- post_hashtags 연결 테이블
CREATE TABLE IF NOT EXISTS public.post_hashtags (
  post_id bigint not null references public.community_posts(id) on delete cascade,
  hashtag_id integer not null references public.community_hashtags(id) on delete cascade,
  primary key (post_id, hashtag_id)
);

-- community_subscriptions 테이블
CREATE TABLE IF NOT EXISTS public.community_subscriptions (
  id bigserial primary key,
  subscriber_id uuid not null references public.users(id),
  target_hashtag_id integer references public.community_hashtags(id),
  target_member_id uuid references public.users(id),
  created_at timestamptz not null default now()
);

-- ==============================================
-- 4. 인덱스들
-- ==============================================

-- 기존 인덱스 생성
CREATE UNIQUE INDEX IF NOT EXISTS uq_devices_user_device_uuid ON public.devices (user_id, device_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS users_index_key ON public.users (index);
CREATE UNIQUE INDEX IF NOT EXISTS unique_post_like ON public.community_likes (user_id, post_id) WHERE post_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS unique_comment_like ON public.community_likes (user_id, comment_id) WHERE comment_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS unique_subscription_check ON public.community_subscriptions (subscriber_id, COALESCE(target_hashtag_id, -1), COALESCE(target_member_id::text, ''));

-- 성능 인덱스들
CREATE INDEX IF NOT EXISTS idx_community_posts_created_at ON public.community_posts (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_comments_post_created_at ON public.community_comments (post_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_comments_postid_createdat ON public.community_comments (post_id, created_at);
CREATE INDEX IF NOT EXISTS idx_community_comments_postid_anonymous ON public.community_comments (post_id, is_anonymous);
CREATE INDEX IF NOT EXISTS idx_community_likes_post_created_at ON public.community_likes (post_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_area_keywords_keyword ON public.area_keywords (keyword);

-- 텍스트 검색 인덱스 (확장 기능 필요시)
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX IF NOT EXISTS idx_community_posts_content_trgm ON public.community_posts USING gin (content gin_trgm_ops);

-- ==============================================
-- 5. RLS (Row Level Security) 정책들
-- ==============================================

-- 모든 테이블에 RLS 활성화
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_subscriptions ENABLE ROW LEVEL SECURITY;

-- Users 정책들
DROP POLICY IF EXISTS users_insert_self ON public.users;
CREATE POLICY users_insert_self ON public.users
  FOR INSERT TO authenticated WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS users_select_self ON public.users;
CREATE POLICY users_select_self ON public.users
  FOR SELECT TO authenticated USING (id = auth.uid());

DROP POLICY IF EXISTS users_update_self ON public.users;
CREATE POLICY users_update_self ON public.users
  FOR UPDATE TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());

-- Devices 정책들
DROP POLICY IF EXISTS devices_insert_own ON public.devices;
CREATE POLICY devices_insert_own ON public.devices
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS devices_select_own ON public.devices;
CREATE POLICY devices_select_own ON public.devices
  FOR SELECT TO authenticated USING (user_id = auth.uid());

DROP POLICY IF EXISTS devices_update_own ON public.devices;
CREATE POLICY devices_update_own ON public.devices
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Community Posts 정책들
DROP POLICY IF EXISTS posts_select_all ON public.community_posts;
CREATE POLICY posts_select_all ON public.community_posts
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS posts_insert_authenticated ON public.community_posts;
CREATE POLICY posts_insert_authenticated ON public.community_posts
  FOR INSERT TO authenticated WITH CHECK (author_id = auth.uid());

DROP POLICY IF EXISTS posts_update_own ON public.community_posts;
CREATE POLICY posts_update_own ON public.community_posts
  FOR UPDATE TO authenticated USING (author_id = auth.uid()) WITH CHECK (author_id = auth.uid());

DROP POLICY IF EXISTS posts_delete_own ON public.community_posts;
CREATE POLICY posts_delete_own ON public.community_posts
  FOR DELETE TO authenticated USING (author_id = auth.uid());

-- Community Comments 정책들
DROP POLICY IF EXISTS comments_select_all ON public.community_comments;
CREATE POLICY comments_select_all ON public.community_comments
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS comments_insert_authenticated ON public.community_comments;
CREATE POLICY comments_insert_authenticated ON public.community_comments
  FOR INSERT TO authenticated WITH CHECK (author_id = auth.uid());

DROP POLICY IF EXISTS comments_update_own ON public.community_comments;
CREATE POLICY comments_update_own ON public.community_comments
  FOR UPDATE TO authenticated USING (author_id = auth.uid()) WITH CHECK (author_id = auth.uid());

DROP POLICY IF EXISTS comments_delete_own ON public.community_comments;
CREATE POLICY comments_delete_own ON public.community_comments
  FOR DELETE TO authenticated USING (author_id = auth.uid());

-- Community Likes 정책들
DROP POLICY IF EXISTS likes_select_all ON public.community_likes;
CREATE POLICY likes_select_all ON public.community_likes
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS likes_insert_own ON public.community_likes;
CREATE POLICY likes_insert_own ON public.community_likes
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS likes_delete_own ON public.community_likes;
CREATE POLICY likes_delete_own ON public.community_likes
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Community Subscriptions 정책들
DROP POLICY IF EXISTS subscriptions_select_own ON public.community_subscriptions;
CREATE POLICY subscriptions_select_own ON public.community_subscriptions
  FOR SELECT TO authenticated USING (subscriber_id = auth.uid());

DROP POLICY IF EXISTS subscriptions_insert_own ON public.community_subscriptions;
CREATE POLICY subscriptions_insert_own ON public.community_subscriptions
  FOR INSERT TO authenticated WITH CHECK (subscriber_id = auth.uid());

DROP POLICY IF EXISTS subscriptions_delete_own ON public.community_subscriptions;
CREATE POLICY subscriptions_delete_own ON public.community_subscriptions
  FOR DELETE TO authenticated USING (subscriber_id = auth.uid());

-- ==============================================
-- 6. 테이블 권한 설정
-- ==============================================

-- 공개 읽기 테이블들
GRANT SELECT ON public.roles TO anon, authenticated;
GRANT SELECT ON public.main_categories TO anon, authenticated;
GRANT SELECT ON public.area_groups TO anon, authenticated;  
GRANT SELECT ON public.area_keywords TO anon, authenticated;
GRANT SELECT ON public.community_hashtags TO anon, authenticated;

-- 인증된 사용자 전체 액세스
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.devices TO authenticated;
GRANT ALL ON public.community_posts TO authenticated;
GRANT ALL ON public.community_comments TO authenticated;
GRANT ALL ON public.community_likes TO authenticated;
GRANT ALL ON public.post_hashtags TO authenticated;
GRANT ALL ON public.community_subscriptions TO authenticated;

-- 시퀀스 권한
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;