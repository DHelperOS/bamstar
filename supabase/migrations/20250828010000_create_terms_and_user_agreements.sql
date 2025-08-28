
CREATE TABLE terms (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title TEXT NOT NULL,
    subtitle TEXT,
    type TEXT NOT NULL CHECK (type IN ('mandatory', 'optional')),
    content TEXT,
    version TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_agreements (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    term_id BIGINT REFERENCES terms(id) ON DELETE CASCADE,
    agreed BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, term_id)
);

INSERT INTO terms (title, subtitle, type, version, content) VALUES
('밤스타 이용약관', '서비스 이용을 위한 기본 약관', 'mandatory', '1.0', '서비스 이용약관 내용'),
('개인정보 처리 방침', '개인정보 보호에 관한 정책', 'mandatory', '1.0', '개인정보 처리 방침 내용'),
('개인정보 수집 및 이용 동의', '서비스 제공을 위한 개인정보 활용', 'mandatory', '1.0', '개인정보 수집 및 이용 동의 내용'),
('개인정보 제 3자 정보 제공 동의', '파트너사와의 정보 공유', 'mandatory', '1.0', '개인정보 제 3자 정보 제공 동의 내용'),
('푸시 알림 동의', '중요한 정보와 업데이트 알림', 'optional', '1.0', '푸시 알림 동의 내용'),
('이벤트 알림 동의', '특별 이벤트 및 혜택 정보', 'optional', '1.0', '이벤트 알림 동의 내용'),
('마케팅 활용 동의', '맞춤형 광고 및 마케팅 정보 수신', 'optional', '1.0', '마케팅 활용 동의 내용');
