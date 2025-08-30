-- BamStar 빠른 테스트 데이터 삽입 (실제 auth.users ID 사용)
-- 생성일: 2025-08-30

-- 1. users 테이블 (처음 20개 auth 유저 사용)
INSERT INTO users (id, role_id, ci, is_adult, email, phone, created_at, profile_img, nickname, last_sign_in, updated_at) VALUES
('9091f5af-ba21-4fd6-b1f5-998dd46432ae', 3, NULL, true, 'bamstar1@example.com', '010-1234-5678', NOW() - INTERVAL '30 days', 'https://picsum.photos/300/300?random=1001', '플레이스#1', NOW() - INTERVAL '1 day', NOW()),
('16f1bacb-18b5-4e45-ac4e-649cc338c921', 3, NULL, true, 'bamstar10@example.com', '010-1234-5679', NOW() - INTERVAL '25 days', 'https://picsum.photos/300/300?random=1002', '플레이스#2', NOW() - INTERVAL '2 days', NOW()),
('cd1adddb-bbe3-4bb8-8dfd-cbdf06391f4d', 3, NULL, true, 'bamstar11@example.com', '010-1234-5680', NOW() - INTERVAL '20 days', 'https://picsum.photos/300/300?random=1003', '플레이스#3', NOW() - INTERVAL '1 day', NOW()),
('53dfbd58-ac2e-4aeb-bd95-0ce73cdbf2f8', 3, NULL, true, 'bamstar12@example.com', '010-1234-5681', NOW() - INTERVAL '15 days', 'https://picsum.photos/300/300?random=1004', '플레이스#4', NOW() - INTERVAL '3 days', NOW()),
('516f6bd5-e54a-4b4d-8863-c3f447b4091e', 3, NULL, true, 'bamstar13@example.com', '010-1234-5682', NOW() - INTERVAL '10 days', 'https://picsum.photos/300/300?random=1005', '플레이스#5', NOW() - INTERVAL '1 day', NOW()),
('10cf399b-6923-4874-a5e1-7169e451e012', 3, NULL, true, 'bamstar14@example.com', '010-1234-5683', NOW() - INTERVAL '45 days', 'https://picsum.photos/300/300?random=1006', '플레이스#6', NOW() - INTERVAL '4 days', NOW()),
('85fa2bfc-46d4-4ac4-a3bd-f3a124b4544d', 2, NULL, true, 'bamstar15@example.com', '010-2234-5678', NOW() - INTERVAL '60 days', 'https://picsum.photos/300/300?random=2001', '스타#1', NOW() - INTERVAL '1 day', NOW()),
('c4e71e2e-ac80-4325-85d2-269503e25a7b', 2, NULL, true, 'bamstar16@example.com', '010-2234-5679', NOW() - INTERVAL '35 days', 'https://picsum.photos/300/300?random=2002', '스타#2', NOW() - INTERVAL '2 days', NOW()),
('f26817a7-e0fa-4abc-98fb-d737ed9e798e', 2, NULL, true, 'bamstar17@example.com', '010-2234-5680', NOW() - INTERVAL '40 days', 'https://picsum.photos/300/300?random=2003', '스타#3', NOW() - INTERVAL '1 day', NOW()),
('567c6026-fcd5-4588-a3f4-92b30709a240', 2, NULL, true, 'bamstar18@example.com', '010-2234-5681', NOW() - INTERVAL '50 days', 'https://picsum.photos/300/300?random=2004', '스타#4', NOW() - INTERVAL '3 days', NOW()),
('718ac269-22da-4015-9efd-ca589a379a64', 2, NULL, true, 'bamstar19@example.com', '010-2234-5682', NOW() - INTERVAL '55 days', 'https://picsum.photos/300/300?random=2005', '스타#5', NOW() - INTERVAL '1 day', NOW()),
('e948c242-2fba-43b1-8887-d5e6894f0721', 2, NULL, true, 'bamstar2@example.com', '010-2234-5683', NOW() - INTERVAL '30 days', 'https://picsum.photos/300/300?random=2006', '스타#6', NOW() - INTERVAL '2 days', NOW()),
('5b0dabc4-21ba-4d0b-8823-df9a9207f3b9', 1, NULL, true, 'bamstar20@example.com', '010-3234-5678', NOW() - INTERVAL '70 days', 'https://picsum.photos/300/300?random=3001', '게스트#1', NOW() - INTERVAL '1 day', NOW()),
('950b4e2f-0502-462d-b00b-3327c9f61561', 1, NULL, true, 'bamstar21@example.com', '010-3234-5679', NOW() - INTERVAL '80 days', 'https://picsum.photos/300/300?random=3002', '게스트#2', NOW() - INTERVAL '3 days', NOW()),
('d480341d-e894-4c40-b9b1-67b981968488', 1, NULL, true, 'bamstar22@example.com', '010-3234-5680', NOW() - INTERVAL '90 days', 'https://picsum.photos/300/300?random=3003', '게스트#3', NOW() - INTERVAL '1 day', NOW()),
('cbd69cda-b25e-4da9-bedf-e13bf16ec256', 1, NULL, true, 'bamstar23@example.com', '010-3234-5681', NOW() - INTERVAL '100 days', 'https://picsum.photos/300/300?random=3004', '게스트#4', NOW() - INTERVAL '2 days', NOW());

-- 2. member_profiles 테이블 (스타 유저용)
INSERT INTO member_profiles (user_id, real_name, gender, contact_phone, profile_image_urls, social_links, bio, experience_level, desired_pay_type, desired_pay_amount, desired_working_days, available_from, can_relocate, level, experience_points, title, updated_at, age, matching_conditions, business_verification_id, is_business_verified, business_verification_level, business_verified_at) VALUES
('85fa2bfc-46d4-4ac4-a3bd-f3a124b4544d', '김민준', 'MALE', '010-2234-5678', '{"https://picsum.photos/400/500?random=2101","https://picsum.photos/400/500?random=2102"}', '{"service":"카카오톡","handle":"star101"}', 'junior 레벨의 전문 서비스를 제공합니다.', 'JUNIOR', 'TC', 4200000, '{화,목,금,토}', NULL, true, 3, 1200, '새로운 스타', NOW(), 24, '{"MUST_HAVE": ["모던 바", "가라오케", "매니저", "페이: TC 4200000원", "근무일: 화, 목, 금, 토", "경력: junior"], "PEOPLE": {"team_dynamics": [], "communication_style": ["긍정적", "활발함"]}, "ENVIRONMENT": {"workplace_features": ["초보환영", "편안한", "당일지급", "식사 제공"], "location_preferences": ["강남·서초", "홍대·합정·마포·서대문"]}, "AVOID": []}', NULL, false, 'none', NULL),
('c4e71e2e-ac80-4325-85d2-269503e25a7b', '이서윤', 'FEMALE', '010-2234-5679', '{"https://picsum.photos/400/500?random=2201","https://picsum.photos/400/500?random=2202"}', '{"service":"인스타그램","handle":"star102"}', 'senior 레벨의 전문 서비스를 제공합니다.', 'SENIOR', 'DAILY', 5800000, '{월,수,금,토,일}', NULL, false, 6, 3200, '새로운 스타', NOW(), 28, '{"MUST_HAVE": ["토크 바", "캐주얼 펍", "바텐더", "스탭", "페이: DAILY 5800000원", "근무일: 월, 수, 금, 토, 일", "경력: senior"], "PEOPLE": {"team_dynamics": [], "communication_style": ["차분함", "성실함", "대화리드"]}, "ENVIRONMENT": {"workplace_features": ["경력자우대", "고급스러운", "자유복장", "인센티브", "헤어/메이크업"], "location_preferences": ["종로·중구", "용산·이태원·한남"]}, "AVOID": []}', NULL, false, 'none', NULL),
('f26817a7-e0fa-4abc-98fb-d737ed9e798e', '박도윤', 'MALE', '010-2234-5680', '{"https://picsum.photos/400/500?random=2301"}', '{"service":"카카오톡","handle":"star103"}', 'professional 레벨의 전문 서비스를 제공합니다.', 'PROFESSIONAL', 'MONTHLY', 7500000, '{화,수,목,금,토}', NULL, true, 8, 4800, '새로운 스타', NOW(), 32, '{"MUST_HAVE": ["테라피", "라이브 방송", "매니저", "실장", "페이: MONTHLY 7500000원", "근무일: 화, 수, 목, 금, 토", "경력: professional"], "PEOPLE": {"team_dynamics": [], "communication_style": ["차분함", "대화리드", "패션센스"]}, "ENVIRONMENT": {"workplace_features": ["가족같은", "파티분위기", "4대보험", "퇴직금", "숙소 제공"], "location_preferences": ["잠실·송파·강동"]}, "AVOID": []}', NULL, false, 'none', NULL),
('567c6026-fcd5-4588-a3f4-92b30709a240', '최예은', 'FEMALE', '010-2234-5681', '{"https://picsum.photos/400/500?random=2401","https://picsum.photos/400/500?random=2402"}', '{"service":"인스타그램","handle":"star104"}', 'newbie 레벨의 전문 서비스를 제공합니다.', 'NEWBIE', 'TC', 3200000, '{목,금,토}', NULL, false, 2, 450, '새로운 스타', NOW(), 21, '{"MUST_HAVE": ["카페", "이벤트", "스탭", "페이: TC 3200000원", "근무일: 목, 금, 토", "경력: newbie"], "PEOPLE": {"team_dynamics": [], "communication_style": ["긍정적", "활발함", "리액션요정"]}, "ENVIRONMENT": {"workplace_features": ["초보환영", "편안한", "텃세없음", "당일지급", "교통비 지원"], "location_preferences": ["건대·성수·왕십리", "대학로·성북·동대문"]}, "AVOID": []}', NULL, false, 'none', NULL),
('718ac269-22da-4015-9efd-ca589a379a64', '정시우', 'MALE', '010-2234-5682', '{"https://picsum.photos/400/500?random=2501","https://picsum.photos/400/500?random=2502"}', '{"service":"카카오톡","handle":"star105"}', 'junior 레벨의 전문 서비스를 제공합니다.', 'JUNIOR', 'TC', 4800000, '{월,화,금,토,일}', NULL, true, 4, 1850, '새로운 스타', NOW(), 25, '{"MUST_HAVE": ["모던 바", "토크 바", "BJ", "페이: TC 4800000원", "근무일: 월, 화, 금, 토, 일", "경력: junior"], "PEOPLE": {"team_dynamics": [], "communication_style": ["활발함", "성실함"]}, "ENVIRONMENT": {"workplace_features": ["친구랑같이", "술강요없음", "선불/마이킹", "의상/유니폼"], "location_preferences": ["홍대·합정·마포·서대문", "영등포·여의도·강서"]}, "AVOID": []}', NULL, false, 'none', NULL),
('e948c242-2fba-43b1-8887-d5e6894f0721', '강하은', 'FEMALE', '010-2234-5683', '{"https://picsum.photos/400/500?random=2601"}', '{"service":"인스타그램","handle":"star106"}', 'senior 레벨의 전문 서비스를 제공합니다.', 'SENIOR', 'MONTHLY', 6200000, '{수,목,금,토}', NULL, false, 7, 3600, '새로운 스타', NOW(), 29, '{"MUST_HAVE": ["캐주얼 펍", "가라오케", "주방", "페이: MONTHLY 6200000원", "근무일: 수, 목, 금, 토", "경력: senior"], "PEOPLE": {"team_dynamics": [], "communication_style": ["차분함", "좋은비율"]}, "ENVIRONMENT": {"workplace_features": ["경력자우대", "고급스러운", "경조사비", "휴가/월차"], "location_preferences": ["구로·관악·동작", "노원·중랑·강북"]}, "AVOID": []}', NULL, false, 'none', NULL);

-- 3. place_profiles 테이블 (플레이스 유저용)
INSERT INTO place_profiles (user_id, place_name, business_type, business_number, business_verified, address, detail_address, postcode, road_address, jibun_address, latitude, longitude, area_group_id, manager_name, manager_phone, manager_gender, sns_type, sns_handle, intro, profile_image_urls, representative_image_index, operating_hours, offered_pay_type, offered_min_pay, offered_max_pay, desired_experience_level, desired_working_days, created_at, updated_at) VALUES
('9091f5af-ba21-4fd6-b1f5-998dd46432ae', '강남 프리미엄 모던 바', '모던 바', '123-45-67890', true, '서울시 강남구 테헤란로 123', '5층', '06234', '서울시 강남구 테헤란로 123', '서울시 강남구 역삼동 123-45', 37.50123456, 127.03654321, 1, '김매니저', '010-1111-2222', '남', '카카오톡', 'place101', '모던 바 전문점으로 최고의 서비스를 제공합니다.', '{"https://picsum.photos/600/400?random=3101","https://picsum.photos/600/400?random=3102"}', 0, '{"days": ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"], "start_hour": 19.0, "end_hour": 3.0}', 'TC', 3500000, 6500000, '주니어', '{월,화,수,목,금,토}', NOW() - INTERVAL '30 days', NOW()),
('16f1bacb-18b5-4e45-ac4e-649cc338c921', '홍대 로얄 토크 바', '토크 바', '234-56-78901', false, '서울시 마포구 홍익로 234', '3층', '04567', '서울시 마포구 홍익로 234', '서울시 마포구 홍대동 234-56', 37.55987654, 126.92345678, 5, '이실장', '010-2222-3333', '여', '인스타그램', 'place102', '토크 바 전문점으로 최고의 서비스를 제공합니다.', '{"https://picsum.photos/600/400?random=3201","https://picsum.photos/600/400?random=3202"}', 0, '{"days": ["tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"], "start_hour": 20.0, "end_hour": 2.0}', '일급', 3200000, 5800000, '무관', '{화,수,목,금,토,일}', NOW() - INTERVAL '25 days', NOW()),
('cd1adddb-bbe3-4bb8-8dfd-cbdf06391f4d', '압구정 VIP 캐주얼 펍', '캐주얼 펍', '345-67-89012', true, '서울시 강남구 압구정로 345', NULL, '06789', '서울시 강남구 압구정로 345', '서울시 강남구 압구정동 345-67', 37.52765432, 127.04123456, 1, '박매니저', '010-3333-4444', '남', '카카오톡', 'place103', '캐주얼 펍 전문점으로 최고의 서비스를 제공합니다.', '{"https://picsum.photos/600/400?random=3301"}', 0, '{"days": ["wednesday", "thursday", "friday", "saturday"], "start_hour": 18.0, "end_hour": 2.0}', 'TC', 2800000, 5200000, '신입', '{수,목,금,토}', NOW() - INTERVAL '20 days', NOW()),
('53dfbd58-ac2e-4aeb-bd95-0ce73cdbf2f8', '이태원 골든 가라오케', '가라오케', '456-78-90123', false, '서울시 용산구 이태원로 456', '2층 201호', '04321', '서울시 용산구 이태원로 456', '서울시 용산구 이태원동 456-78', 37.53456789, 126.99876543, 4, '최사장', '010-4444-5555', '여', '기타', 'place104', '가라오케 전문점으로 최고의 서비스를 제공합니다.', '{"https://picsum.photos/600/400?random=3401","https://picsum.photos/600/400?random=3402"}', 0, '{"days": ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"], "start_hour": 19.0, "end_hour": 4.0}', '월급', 2500000, 4800000, '무관', '{월,화,수,목,금,토,일}', NOW() - INTERVAL '15 days', NOW()),
('516f6bd5-e54a-4b4d-8863-c3f447b4091e', '건대 다이아몬드 카페', '카페', '567-89-01234', true, '서울시 광진구 능동로 567', '1층', '05432', '서울시 광진구 능동로 567', '서울시 광진구 건대동 567-89', 37.54123456, 127.07654321, 8, '윤매니저', '010-5555-6666', '남', '카카오톡', 'place105', '카페 전문점으로 최고의 서비스를 제공합니다.', '{"https://picsum.photos/600/400?random=3501"}', 0, '{"days": ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday"], "start_hour": 18.0, "end_hour": 3.0}', 'TC', 2300000, 4200000, '신입', '{월,화,수,목,금,토}', NOW() - INTERVAL '10 days', NOW()),
('10cf399b-6923-4874-a5e1-7169e451e012', '신촌 플래티넘 테라피', '테라피', '678-90-12345', false, '서울시 서대문구 신촌로 678', '4층', '03210', '서울시 서대문구 신촌로 678', '서울시 서대문구 신촌동 678-90', 37.55654321, 126.93789012, 5, '장원장', '010-6666-7777', '여', '인스타그램', 'place106', '테라피 전문점으로 최고의 서비스를 제공합니다.', '{"https://picsum.photos/600/400?random=3601","https://picsum.photos/600/400?random=3602"}', 0, '{"days": ["tuesday", "wednesday", "thursday", "friday", "saturday"], "start_hour": 20.0, "end_hour": 2.0}', '일급', 4200000, 8500000, '시니어', '{화,수,목,금,토}', NOW() - INTERVAL '45 days', NOW());

-- 4. 속성 연결 테이블 (샘플)
-- member_attributes_link (멤버 스타일 속성)
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES
('85fa2bfc-46d4-4ac4-a3bd-f3a124b4544d', 41), -- 긍정적
('85fa2bfc-46d4-4ac4-a3bd-f3a124b4544d', 42), -- 활발함
('c4e71e2e-ac80-4325-85d2-269503e25a7b', 43), -- 차분함
('c4e71e2e-ac80-4325-85d2-269503e25a7b', 44), -- 성실함
('c4e71e2e-ac80-4325-85d2-269503e25a7b', 45), -- 대화리드
('f26817a7-e0fa-4abc-98fb-d737ed9e798e', 43), -- 차분함
('f26817a7-e0fa-4abc-98fb-d737ed9e798e', 45), -- 대화리드
('f26817a7-e0fa-4abc-98fb-d737ed9e798e', 47), -- 패션센스
('567c6026-fcd5-4588-a3f4-92b30709a240', 41), -- 긍정적
('567c6026-fcd5-4588-a3f4-92b30709a240', 42), -- 활발함
('567c6026-fcd5-4588-a3f4-92b30709a240', 46), -- 리액션요정
('718ac269-22da-4015-9efd-ca589a379a64', 42), -- 활발함
('718ac269-22da-4015-9efd-ca589a379a64', 44), -- 성실함
('e948c242-2fba-43b1-8887-d5e6894f0721', 43), -- 차분함
('e948c242-2fba-43b1-8887-d5e6894f0721', 48); -- 좋은비율

-- place_industries (플레이스 업종 연결)
INSERT INTO place_industries (place_user_id, attribute_id) VALUES
('9091f5af-ba21-4fd6-b1f5-998dd46432ae', 1), -- 모던 바
('16f1bacb-18b5-4e45-ac4e-649cc338c921', 2), -- 토크 바
('cd1adddb-bbe3-4bb8-8dfd-cbdf06391f4d', 3), -- 캐주얼 펍
('53dfbd58-ac2e-4aeb-bd95-0ce73cdbf2f8', 4), -- 가라오케
('516f6bd5-e54a-4b4d-8863-c3f447b4091e', 5), -- 카페
('10cf399b-6923-4874-a5e1-7169e451e012', 6); -- 테라피

-- place_attributes_link (플레이스 특징 속성)
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES
('9091f5af-ba21-4fd6-b1f5-998dd46432ae', 32), -- 경력자우대
('9091f5af-ba21-4fd6-b1f5-998dd46432ae', 35), -- 고급스러운
('9091f5af-ba21-4fd6-b1f5-998dd46432ae', 37), -- 텃세없음
('16f1bacb-18b5-4e45-ac4e-649cc338c921', 31), -- 초보환영
('16f1bacb-18b5-4e45-ac4e-649cc338c921', 33), -- 가족같은
('16f1bacb-18b5-4e45-ac4e-649cc338c921', 36), -- 편안한
('cd1adddb-bbe3-4bb8-8dfd-cbdf06391f4d', 34), -- 파티분위기
('cd1adddb-bbe3-4bb8-8dfd-cbdf06391f4d', 38), -- 친구랑같이
('cd1adddb-bbe3-4bb8-8dfd-cbdf06391f4d', 40); -- 자유복장

-- place_preferences_link (플레이스 복지 혜택)
INSERT INTO place_preferences_link (place_user_id, attribute_id) VALUES
('9091f5af-ba21-4fd6-b1f5-998dd46432ae', 16), -- 당일지급
('9091f5af-ba21-4fd6-b1f5-998dd46432ae', 18), -- 인센티브
('9091f5af-ba21-4fd6-b1f5-998dd46432ae', 25), -- 식사 제공
('16f1bacb-18b5-4e45-ac4e-649cc338c921', 17), -- 선불/마이킹
('16f1bacb-18b5-4e45-ac4e-649cc338c921', 23), -- 교통비 지원
('16f1bacb-18b5-4e45-ac4e-649cc338c921', 26), -- 의상/유니폼
('cd1adddb-bbe3-4bb8-8dfd-cbdf06391f4d', 19), -- 4대보험
('cd1adddb-bbe3-4bb8-8dfd-cbdf06391f4d', 20), -- 퇴직금
('cd1adddb-bbe3-4bb8-8dfd-cbdf06391f4d', 24); -- 주차 지원

-- member_preferences_link (멤버 선호 직무)  
INSERT INTO member_preferences_link (member_user_id, attribute_id) VALUES
('85fa2bfc-46d4-4ac4-a3bd-f3a124b4544d', 9),  -- 매니저
('85fa2bfc-46d4-4ac4-a3bd-f3a124b4544d', 12), -- 스탭
('c4e71e2e-ac80-4325-85d2-269503e25a7b', 11), -- 바텐더
('c4e71e2e-ac80-4325-85d2-269503e25a7b', 12), -- 스탭
('f26817a7-e0fa-4abc-98fb-d737ed9e798e', 9),  -- 매니저
('f26817a7-e0fa-4abc-98fb-d737ed9e798e', 10), -- 실장
('567c6026-fcd5-4588-a3f4-92b30709a240', 12), -- 스탭
('718ac269-22da-4015-9efd-ca589a379a64', 15), -- BJ
('e948c242-2fba-43b1-8887-d5e6894f0721', 14); -- 주방

-- member_preferred_area_groups (멤버 선호 지역)
INSERT INTO member_preferred_area_groups (member_user_id, group_id) VALUES
('85fa2bfc-46d4-4ac4-a3bd-f3a124b4544d', 1), -- 강남·서초
('85fa2bfc-46d4-4ac4-a3bd-f3a124b4544d', 5), -- 홍대·합정·마포·서대문
('c4e71e2e-ac80-4325-85d2-269503e25a7b', 3), -- 종로·중구
('c4e71e2e-ac80-4325-85d2-269503e25a7b', 4), -- 용산·이태원·한남
('f26817a7-e0fa-4abc-98fb-d737ed9e798e', 2), -- 잠실·송파·강동
('567c6026-fcd5-4588-a3f4-92b30709a240', 8), -- 건대·성수·왕십리
('567c6026-fcd5-4588-a3f4-92b30709a240', 9), -- 대학로·성북·동대문
('718ac269-22da-4015-9efd-ca589a379a64', 5), -- 홍대·합정·마포·서대문
('718ac269-22da-4015-9efd-ca589a379a64', 6), -- 영등포·여의도·강서
('e948c242-2fba-43b1-8887-d5e6894f0721', 7), -- 구로·관악·동작
('e948c242-2fba-43b1-8887-d5e6894f0721', 10); -- 노원·중랑·강북

-- 데이터 삽입 완료
SELECT 'BamStar 테스트 데이터 삽입 완료! 🎉' as status;