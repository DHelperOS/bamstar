2. 화면 구성 요소 및 DB 연동 명세
2.1. 헤더 (Header)
타이틀: 🎯 나만의 매칭 스타일
설명: 원하는 활동 스타일을 알려주시면, AI가 스타님께 꼭 맞는 플레이스를 찾아줘요.
2.2. 섹션 1: 희망 업종 & 직무
UI: 각 소제목 아래에, 선택 가능한 모든 옵션을 '칩(Chip)' 그룹 형태로 나열. 다중 선택 가능.
데이터 소스:
소제목 '업종': attributes 테이블에서 type = 'INDUSTRY'인 행의 type_kor 값을 가져와 표시.
업종 선택지 (칩): attributes 테이블에서 type = 'INDUSTRY'인 모든 **name**을 불러와 표시.
소제목 '구하는 직무': attributes 테이블에서 type = 'JOB_ROLE'인 행의 type_kor 값을 가져와 표시.
직무 선택지 (칩): attributes 테이블에서 type = 'JOB_ROLE'인 모든 **name**을 불러와 표시.
데이터 저장:
사용자가 선택한 업종/직무에 해당하는 attributes 테이블의 id 값들을 member_preferences_link 테이블에 member_user_id와 함께 저장.
2.3. 섹션 2: 희망 근무 조건
UI: '페이 타입'은 select 드롭다운, '희망 금액'은 number 입력 필드, '희망 요일'은 chip 그룹으로 구성.
데이터 저장:
페이 타입: member_profiles 테이블의 desired_pay_type 컬럼에 저장.
희망 금액: member_profiles 테이블의 desired_pay_amount 컬럼에 저장.
희망 요일: member_profiles 테이블의 desired_working_days 컬럼에 ['화', '수', '금']과 같은 텍스트 배열(TEXT[]) 형태로 저장.
2.4. 섹션 3: 나의 스타일/강점
UI: '칩(Chip)' 그룹 형태로, 선택 가능한 모든 스타일/강점 태그 나열. 다중 선택 가능.
데이터 소스:
소제목 '나의 스타일/강점': attributes 테이블에서 type = 'MEMBER_STYLE'인 행의 type_kor 값을 가져와 표시.
선택지 (칩): attributes 테이블에서 type = 'MEMBER_STYLE'인 모든 **name**을 불러와 표시.
데이터 저장: 사용자가 선택한 스타일에 해당하는 attributes 테이블의 id 값들을 member_attributes_link 테이블에 member_user_id와 함께 저장.
2.5. 섹션 4: 선호 플레이스 특징 & 복지
UI: '가게 특징', '복지 및 혜택' 등 소제목으로 구분된 '칩(Chip)' 그룹들. 다중 선택 가능.
데이터 소스:
소제목 '가게 특징': attributes 테이블에서 type = 'PLACE_FEATURE'인 행의 type_kor 값을 가져와 표시.
선택지 (칩): attributes 테이블에서 type = 'PLACE_FEATURE'인 모든 **name**을 불러와 표시.
소제목 '복지 및 혜택': attributes 테이블에서 type = 'WELFARE'인 행의 type_kor 값을 가져와 표시.
선택지 (칩): attributes 테이블에서 type = 'WELFARE'인 모든 **name**을 불러와 표시.
데이터 저장: 사용자가 선택한 특징/복지에 해당하는 attributes 테이블의 id 값들을 member_preferences_link 테이블에 member_user_id와 함께 저장.
3. AI 프롬프트 생성 로직
사용자가 이 화면에서 모든 정보를 입력하고 [저장하기] 버튼을 누르면, 시스템은 다음과 같은 프로세스를 통해 AI에게 보낼 프롬프트를 생성하고, 그 결과를 **member_profiles 테이블의 AI 분석 결과 관련 컬럼 (예: matching_conditions JSONB)**에 저장한다.
3.1. 서버의 데이터 수집
서버는 사용자가 입력/선택한 모든 정보를 DB에서 다시 불러와 하나의 텍스트 덩어리로 조합한다.
bio 텍스트: member_profiles.bio
희망 조건 텍스트: desired_pay_type + desired_pay_amount + desired_working_days
선택된 태그 텍스트: member_attributes_link와 member_preferences_link를 통해 선택된 모든 **attributes.name**들을 불러와 조합.
3.2. AI 프롬프트 (한글)
이 프롬프트는 수집된 데이터를 바탕으로, AI가 최종적인 '4가지 바구니' 데이터를 생성하도록 지시한다.
[CONTEXT]
당신은 한국의 고급 밤 일자리 전문 리크루팅 컨설턴트입니다. 지금부터 한 명의 '스타(구인자)'가 자신의 프로필과 희망 조건을 작성한 내용을 드릴 겁니다. 이 내용을 분석해서, 매칭에 사용할 핵심적인 조건들을 구조화된 태그로 정리해주세요.
[DEFINITIONS & TYPES]
MUST_HAVE (필수 조건): 근무 지역, 업종, 직무, 페이, 숙소, 마이킹처럼 타협하기 힘든 핵심적인 조건입니다.
ENVIRONMENT (환경/분위기): '가족같은', '고급스러운', '텃세없음' 처럼 근무 환경이나 분위기에 대한 선호 조건입니다.
PEOPLE (사람/관계): '또래 동료 많음', '사장님 친절함', '나이 많은 손님' 처럼 함께 일하거나 상대하는 사람에 대한 선호 조건입니다.
AVOID (절대 불가 조건): '술 강요', '터치' 처럼 절대로 원하지 않는, 명백한 기피 조건입니다.
[사용자 입력 정보]
자기소개: {bio}
희망 조건:
페이: {desired_pay_type}, {desired_pay_amount} 이상
근무일: {desired_working_days}
나의 스타일/강점: {선택된 member_attributes.name 목록}
선호 플레이스 특징: {선택된 member_preferences.name 목록 (업종, 직무, 복지, 특징 포함)}
[TASK]
위에 제공된 [사용자 입력 정보] 전체를 종합적으로 분석해주세요.
각 요구사항을 짧고 명확한 **'태그'**로 요약해주세요.
이 태그들을 **[DEFINITIONS & TYPES]**에 정의된 4가지 카테고리(MUST_HAVE, ENVIRONMENT, PEOPLE, AVOID)에 맞게 분류해주세요.
오직 JSON 형식으로만 답변해주세요.
[JSON OUTPUT FORMAT]
code
JSON
{
  "MUST_HAVE": ["string", ...],
  "ENVIRONMENT": {
    "POSITIVE": ["string", ...],
    "NEGATIVE": ["string", ...]
  },
  "PEOPLE": {
    "POSITIVE": ["string", ...],
    "NEGATIVE": ["string", ...]
  },
  "AVOID": ["string", ...]
}

-- ==========[ 밤스타 - 멤버 관련 DB 추가 스키마 (오류 수정 최종본) ]==========
-- 이 스크립트는 기존의 roles, main_categories, area_groups 테이블이 존재한다고 가정하고,
-- 멤버 관련 기능에 필요한 모든 것을 안전하게 생성하고 초기 데이터를 채웁니다.

-- 1. ENUM 타입 정의 (없는 것만 생성)
DO $$ BEGIN CREATE TYPE public.gender_enum AS ENUM ('MALE', 'FEMALE', 'OTHER'); EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'enum type gender_enum already exists, skipping.'; END $$;
DO $$ BEGIN CREATE TYPE public.experience_level_enum AS ENUM ('NEWBIE', 'JUNIOR', 'SENIOR', 'PROFESSIONAL'); EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'enum type experience_level_enum already exists, skipping.'; END $$;
DO $$ BEGIN CREATE TYPE public.pay_type_enum AS ENUM ('TC', 'DAILY', 'WEEKLY', 'MONTHLY', 'NEGOTIABLE'); EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'enum type pay_type_enum already exists, skipping.'; END $$;


-- 2. 통합 속성 사전 (attributes)
CREATE TABLE IF NOT EXISTS public.attributes (
  id SERIAL PRIMARY KEY,
  type TEXT NOT NULL,
  type_kor TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  icon_name TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  CONSTRAINT unique_type_name UNIQUE (type, name)
);


-- 3. 멤버 상세 프로필 (member_profiles) - 오타 수정
CREATE TABLE IF NOT EXISTS public.member_profiles (
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  real_name TEXT,
  nickname TEXT UNIQUE NOT NULL,
  birthdate DATE,
  gender gender_enum,
  contact_phone TEXT,
  profile_image_urls TEXT[],
  social_links JSONB,
  bio TEXT,
  experience_level experience_level_enum,
  desired_pay_type pay_type_enum,
  desired_pay_amount INT,
  desired_working_days TEXT[],
  available_from DATE,
  can_relocate BOOLEAN DEFAULT false,
  level INT NOT NULL DEFAULT 1,
  experience_points BIGINT NOT NULL DEFAULT 0,
  title TEXT DEFAULT '새로운 스타',
  updated_at TIMESTAMPTZ -- TIMESTPTZ -> TIMESTAMPTZ 로 오타 수정
);


-- 4. 멤버와 속성/지역을 연결하는 테이블들
CREATE TABLE IF NOT EXISTS public.member_attributes_link (
  member_user_id UUID NOT NULL REFERENCES public.member_profiles(user_id) ON DELETE CASCADE,
  attribute_id INT NOT NULL REFERENCES public.attributes(id) ON DELETE CASCADE,
  PRIMARY KEY (member_user_id, attribute_id)
);

CREATE TABLE IF NOT EXISTS public.member_preferences_link (
  member_user_id UUID NOT NULL REFERENCES public.member_profiles(user_id) ON DELETE CASCADE,
  attribute_id INT NOT NULL REFERENCES public.attributes(id) ON DELETE CASCADE,
  PRIMARY KEY (member_user_id, attribute_id)
);

CREATE TABLE IF NOT EXISTS public.member_preferred_area_groups (
  member_user_id UUID NOT NULL REFERENCES public.member_profiles(user_id) ON DELETE CASCADE,
  group_id INT NOT NULL REFERENCES public.area_groups(group_id) ON DELETE CASCADE,
  PRIMARY KEY (member_user_id, group_id)
);


-- 5. attributes 테이블에 초기 데이터 삽입 (ON CONFLICT로 중복 방지)
INSERT INTO public.attributes (type, type_kor, name) VALUES
('INDUSTRY', '업종', '모던 바'),
('INDUSTRY', '업종', '토크 바'),
('INDUSTRY', '업종', '캐주얼 펍'),
('INDUSTRY', '업종', '가라오케'),
('INDUSTRY', '업종', '카페'),
('INDUSTRY', '업종', '테라피'),
('INDUSTRY', '업종', '라이브 방송'),
('INDUSTRY', '업종', '이벤트'),
('JOB_ROLE', '구하는 직무', '매니저'),
('JOB_ROLE', '구하는 직무', '실장'),
('JOB_ROLE', '구하는 직무', '바텐더'),
('JOB_ROLE', '구하는 직무', '스탭'),
('JOB_ROLE', '구하는 직무', '가드'),
('JOB_ROLE', '구하는 직무', '주방'),
('JOB_ROLE', '구하는 직무', 'DJ'),
('WELFARE', '복지 및 혜택', '당일지급'),
('WELFARE', '복지 및 혜택', '선불/마이킹'),
('WELFARE', '복지 및 혜택', '인센티브'),
('WELFARE', '복지 및 혜택', '4대보험'),
('WELFARE', '복지 및 혜택', '퇴직금'),
('WELFARE', '복지 및 혜택', '경조사비'),
('WELFARE', '복지 및 혜택', '숙소 제공'),
('WELFARE', '복지 및 혜택', '교통비 지원'),
('WELFARE', '복지 및 혜택', '주차 지원'),
('WELFARE', '복지 및 혜택', '식사 제공'),
('WELFARE', '복지 및 혜택', '의상/유니폼'),
('WELFARE', '복지 및 혜택', '자유 출퇴근'),
('WELFARE', '복지 및 혜택', '헤어/메이크업'),
('WELFARE', '복지 및 혜택', '성형 지원'),
('WELFARE', '복지 및 혜택', '휴가/월차'),
('PLACE_FEATURE', '가게 특징', '초보환영'),
('PLACE_FEATURE', '가게 특징', '경력자우대'),
('PLACE_FEATURE', '가게 특징', '가족같은'),
('PLACE_FEATURE', '가게 특징', '파티분위기'),
('PLACE_FEATURE', '가게 특징', '고급스러운'),
('PLACE_FEATURE', '가게 특징', '편안한'),
('PLACE_FEATURE', '가게 특징', '텃세없음'),
('PLACE_FEATURE', '가게 특징', '친구랑같이'),
('PLACE_FEATURE', '가게 특징', '술강요없음'),
('PLACE_FEATURE', '가게 특징', '자유복장'),
('MEMBER_STYLE', '나의 스타일/강점', '긍정적'),
('MEMBER_STYLE', '나의 스타일/강점', '활발함'),
('MEMBER_STYLE', '나의 스타일/강점', '차분함'),
('MEMBER_STYLE', '나의 스타일/강점', '성실함'),
('MEMBER_STYLE', '나의 스타일/강점', '대화리드'),
('MEMBER_STYLE', '나의 스타일/강점', '리액션요정'),
('MEMBER_STYLE', '나의 스타일/강점', '패션센스'),
('MEMBER_STYLE', '나의 스타일/강점', '좋은비율')
ON CONFLICT (type, name) DO NOTHING;


-- 6. 자동화를 위한 함수 및 트리거 (안전하게 생성)
CREATE OR REPLACE FUNCTION public.handle_updated_at() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$ LANGUAGE plpgsql;

DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_member_profiles_updated') THEN CREATE TRIGGER on_member_profiles_updated BEFORE UPDATE ON public.member_profiles FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at(); END IF; END; $$;

CREATE OR REPLACE FUNCTION public.add_experience_points(user_id_in UUID, points_to_add INT) RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  current_exp BIGINT; new_exp BIGINT; current_level INT; new_level INT; new_title TEXT;
BEGIN
  -- FOR UPDATE를 사용하여 행에 락을 걸어 동시성 문제를 방지합니다.
  SELECT experience_points, level INTO current_exp, current_level FROM public.member_profiles WHERE user_id = user_id_in FOR UPDATE;
  
  new_exp := current_exp + points_to_add;
  new_level := floor(new_exp / 100) + 1; -- 100 EXP당 1레벨업 (조정 가능)
  
  IF new_level > current_level THEN
    new_title := CASE
      WHEN new_level >= 20 THEN '밤의 슈퍼스타'
      WHEN new_level >= 10 THEN '빛나는 샛별'
      WHEN new_level >= 5 THEN '반짝이는 스타'
      ELSE '새로운 스타'
    END;
  ELSE
    -- 레벨업이 아닐 경우, 기존 칭호를 그대로 유지하기 위해 다시 조회합니다.
    SELECT title INTO new_title FROM public.member_profiles WHERE user_id = user_id_in;
  END IF;
  
  UPDATE public.member_profiles SET experience_points = new_exp, level = new_level, title = new_title WHERE user_id = user_id_in;
END;
$$;