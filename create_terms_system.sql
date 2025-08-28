-- ====================================
-- 약관 관리 시스템 데이터베이스 스키마
-- ====================================

-- 1. 약관 테이블 생성
CREATE TABLE public.terms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  content text NOT NULL,
  type text NOT NULL CHECK (type IN ('mandatory', 'optional')),
  category text NOT NULL, -- 'service', 'privacy', 'marketing', 'notification'
  version text NOT NULL DEFAULT '1.0',
  is_active boolean NOT NULL DEFAULT true,
  display_order integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- 2. 사용자 약관 동의 테이블 생성
CREATE TABLE public.user_term_agreements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) NOT NULL,
  term_id uuid REFERENCES public.terms(id) NOT NULL,
  is_agreed boolean NOT NULL,
  agreed_at timestamptz,
  version_agreed text NOT NULL,
  ip_address inet,
  user_agent text,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL,
  CONSTRAINT unique_user_term UNIQUE (user_id, term_id)
);

-- 3. 인덱스 생성
CREATE INDEX idx_terms_type_active ON public.terms (type, is_active, display_order);
CREATE INDEX idx_terms_category ON public.terms (category);
CREATE INDEX idx_user_agreements_user_id ON public.user_term_agreements (user_id);
CREATE INDEX idx_user_agreements_term_id ON public.user_term_agreements (term_id);
CREATE INDEX idx_user_agreements_agreed_at ON public.user_term_agreements (agreed_at);

-- 4. RLS 정책 활성화
ALTER TABLE public.terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_term_agreements ENABLE ROW LEVEL SECURITY;

-- 5. terms 테이블 RLS 정책 (모든 사용자가 읽기 가능, 관리자만 수정)
CREATE POLICY "Anyone can view active terms" ON public.terms
    FOR SELECT USING (is_active = true);

-- 6. user_term_agreements 테이블 RLS 정책
CREATE POLICY "Users can view their own agreements" ON public.user_term_agreements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own agreements" ON public.user_term_agreements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own agreements" ON public.user_term_agreements
    FOR UPDATE USING (auth.uid() = user_id);

-- 7. 자동 업데이트 함수 생성
CREATE OR REPLACE FUNCTION public.update_updated_at_terms()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_agreements()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

-- 8. 트리거 생성
CREATE TRIGGER update_terms_updated_at
  BEFORE UPDATE ON public.terms
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_terms();

CREATE TRIGGER update_agreements_updated_at
  BEFORE UPDATE ON public.user_term_agreements
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_agreements();

-- ====================================
-- 초기 데이터 삽입
-- ====================================

-- 필수 약관 데이터
INSERT INTO public.terms (title, description, content, type, category, version, display_order) VALUES
('밤스타 이용약관', '서비스 이용을 위한 기본 약관', '밤스타 서비스 이용약관 내용...', 'mandatory', 'service', '1.0', 1),
('개인정보 처리 방침', '개인정보 보호에 관한 정책', '개인정보 처리 방침 내용...', 'mandatory', 'privacy', '1.0', 2),
('개인정보 수집 및 이용 동의', '서비스 제공을 위한 개인정보 활용', '개인정보 수집 및 이용 동의 내용...', 'mandatory', 'privacy', '1.0', 3),
('개인정보 제3자 정보 제공 동의', '파트너사와의 정보 공유', '개인정보 제3자 정보 제공 동의 내용...', 'mandatory', 'privacy', '1.0', 4);

-- 선택 약관 데이터
INSERT INTO public.terms (title, description, content, type, category, version, display_order) VALUES
('푸시 알림 동의', '중요한 정보와 업데이트 알림', '푸시 알림 동의 내용...', 'optional', 'notification', '1.0', 5),
('이벤트 알림 동의', '특별 이벤트 및 혜택 정보', '이벤트 알림 동의 내용...', 'optional', 'notification', '1.0', 6),
('마케팅 활용 동의', '맞춤형 광고 및 마케팅 정보 수신', '마케팅 활용 동의 내용...', 'optional', 'marketing', '1.0', 7);