-- BamStar 대량 테스트 데이터 삽입 (수정 버전)
-- 생성일: 2025-08-30 21:34:00
-- 스타 50명, 플레이스 30명

BEGIN;

-- 1. 스타 사용자 50명
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', '스타#1', 'bamstar_large1@example.com', '010-3000-2860', 2, NOW() - INTERVAL '48 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', '스타#2', 'bamstar_large2@example.com', '010-3001-7032', 2, NOW() - INTERVAL '98 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('26e1e69b-e130-4e85-8951-e000ee892659', '스타#3', 'bamstar_large3@example.com', '010-3002-7471', 2, NOW() - INTERVAL '159 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', '스타#4', 'bamstar_large4@example.com', '010-3003-7092', 2, NOW() - INTERVAL '131 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', '스타#5', 'bamstar_large5@example.com', '010-3004-9176', 2, NOW() - INTERVAL '72 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', '스타#6', 'bamstar_large6@example.com', '010-3005-6947', 2, NOW() - INTERVAL '131 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', '스타#7', 'bamstar_large7@example.com', '010-3006-5935', 2, NOW() - INTERVAL '165 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', '스타#8', 'bamstar_large8@example.com', '010-3007-5122', 2, NOW() - INTERVAL '118 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', '스타#9', 'bamstar_large9@example.com', '010-3008-3938', 2, NOW() - INTERVAL '30 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('3fb38fea-5ff5-4bff-b0ba-700d46b572cf', '스타#10', 'bamstar_large10@example.com', '010-3009-2338', 2, NOW() - INTERVAL '128 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', '스타#11', 'bamstar_large11@example.com', '010-3010-8446', 2, NOW() - INTERVAL '128 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', '스타#12', 'bamstar_large12@example.com', '010-3011-8086', 2, NOW() - INTERVAL '139 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', '스타#13', 'bamstar_large13@example.com', '010-3012-3967', 2, NOW() - INTERVAL '111 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('68384370-1ba4-40cc-a1e4-78b002ce16fb', '스타#14', 'bamstar_large14@example.com', '010-3013-9384', 2, NOW() - INTERVAL '173 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', '스타#15', 'bamstar_large15@example.com', '010-3014-9506', 2, NOW() - INTERVAL '179 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', '스타#16', 'bamstar_large16@example.com', '010-3015-4348', 2, NOW() - INTERVAL '30 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('6555ad3d-d062-4b5c-a586-7953ea28cfd5', '스타#17', 'bamstar_large17@example.com', '010-3016-1899', 2, NOW() - INTERVAL '128 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', '스타#18', 'bamstar_large18@example.com', '010-3017-3071', 2, NOW() - INTERVAL '105 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', '스타#19', 'bamstar_large19@example.com', '010-3018-9146', 2, NOW() - INTERVAL '33 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', '스타#20', 'bamstar_large20@example.com', '010-3019-9802', 2, NOW() - INTERVAL '7 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('222c926d-011d-4f29-9b97-2e9d870b4369', '스타#21', 'bamstar_large21@example.com', '010-3020-9451', 2, NOW() - INTERVAL '6 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('4184fe09-8409-436a-b5ec-4155c5f82426', '스타#22', 'bamstar_large22@example.com', '010-3021-4081', 2, NOW() - INTERVAL '8 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', '스타#23', 'bamstar_large23@example.com', '010-3022-4208', 2, NOW() - INTERVAL '160 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', '스타#24', 'bamstar_large24@example.com', '010-3023-2780', 2, NOW() - INTERVAL '41 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('33291db2-690a-43ae-bb34-45c2b30d5402', '스타#25', 'bamstar_large25@example.com', '010-3024-4182', 2, NOW() - INTERVAL '146 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', '스타#26', 'bamstar_large26@example.com', '010-3025-2538', 2, NOW() - INTERVAL '104 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', '스타#27', 'bamstar_large27@example.com', '010-3026-5935', 2, NOW() - INTERVAL '145 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('96da66f5-ed48-4437-a173-91d298cad953', '스타#28', 'bamstar_large28@example.com', '010-3027-3685', 2, NOW() - INTERVAL '14 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('609f1d81-d232-4610-8817-670f0869ce80', '스타#29', 'bamstar_large29@example.com', '010-3028-5285', 2, NOW() - INTERVAL '37 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', '스타#30', 'bamstar_large30@example.com', '010-3029-6864', 2, NOW() - INTERVAL '157 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', '스타#31', 'bamstar_large31@example.com', '010-3030-1684', 2, NOW() - INTERVAL '50 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', '스타#32', 'bamstar_large32@example.com', '010-3031-9863', 2, NOW() - INTERVAL '107 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', '스타#33', 'bamstar_large33@example.com', '010-3032-8806', 2, NOW() - INTERVAL '34 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', '스타#34', 'bamstar_large34@example.com', '010-3033-4869', 2, NOW() - INTERVAL '11 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', '스타#35', 'bamstar_large35@example.com', '010-3034-2349', 2, NOW() - INTERVAL '79 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', '스타#36', 'bamstar_large36@example.com', '010-3035-3845', 2, NOW() - INTERVAL '124 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', '스타#37', 'bamstar_large37@example.com', '010-3036-7139', 2, NOW() - INTERVAL '105 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', '스타#38', 'bamstar_large38@example.com', '010-3037-4248', 2, NOW() - INTERVAL '125 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('13caad73-e12f-4cd4-87b2-650da89b8f18', '스타#39', 'bamstar_large39@example.com', '010-3038-2752', 2, NOW() - INTERVAL '119 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', '스타#40', 'bamstar_large40@example.com', '010-3039-4146', 2, NOW() - INTERVAL '35 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', '스타#41', 'bamstar_large41@example.com', '010-3040-9406', 2, NOW() - INTERVAL '70 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('5760c600-4d37-49da-849d-64537cf049b8', '스타#42', 'bamstar_large42@example.com', '010-3041-6640', 2, NOW() - INTERVAL '36 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b48536e9-cf57-438c-9100-f249595563b7', '스타#43', 'bamstar_large43@example.com', '010-3042-6558', 2, NOW() - INTERVAL '25 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', '스타#44', 'bamstar_large44@example.com', '010-3043-3999', 2, NOW() - INTERVAL '73 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', '스타#45', 'bamstar_large45@example.com', '010-3044-6383', 2, NOW() - INTERVAL '6 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', '스타#46', 'bamstar_large46@example.com', '010-3045-2166', 2, NOW() - INTERVAL '68 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', '스타#47', 'bamstar_large47@example.com', '010-3046-5467', 2, NOW() - INTERVAL '124 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('e7738aab-df79-42b1-9560-1daa00484091', '스타#48', 'bamstar_large48@example.com', '010-3047-7657', 2, NOW() - INTERVAL '32 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', '스타#49', 'bamstar_large49@example.com', '010-3048-7749', 2, NOW() - INTERVAL '119 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', '스타#50', 'bamstar_large50@example.com', '010-3049-2432', 2, NOW() - INTERVAL '98 days', NOW());

-- 2. 플레이스 사용자 30명
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', '플레이스#1', 'bamstar_large51@example.com', '010-4000-8056', 3, NOW() - INTERVAL '172 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', '플레이스#2', 'bamstar_large52@example.com', '010-4001-6915', 3, NOW() - INTERVAL '158 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', '플레이스#3', 'bamstar_large53@example.com', '010-4002-3843', 3, NOW() - INTERVAL '75 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', '플레이스#4', 'bamstar_large54@example.com', '010-4003-6118', 3, NOW() - INTERVAL '123 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', '플레이스#5', 'bamstar_large55@example.com', '010-4004-6752', 3, NOW() - INTERVAL '110 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', '플레이스#6', 'bamstar_large56@example.com', '010-4005-5610', 3, NOW() - INTERVAL '15 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', '플레이스#7', 'bamstar_large57@example.com', '010-4006-8950', 3, NOW() - INTERVAL '47 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', '플레이스#8', 'bamstar_large58@example.com', '010-4007-9485', 3, NOW() - INTERVAL '96 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', '플레이스#9', 'bamstar_large59@example.com', '010-4008-7334', 3, NOW() - INTERVAL '93 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', '플레이스#10', 'bamstar_large60@example.com', '010-4009-2822', 3, NOW() - INTERVAL '39 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('8675ad69-5eae-4066-971e-048300b3e622', '플레이스#11', 'bamstar_large61@example.com', '010-4010-7059', 3, NOW() - INTERVAL '104 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', '플레이스#12', 'bamstar_large62@example.com', '010-4011-7846', 3, NOW() - INTERVAL '57 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', '플레이스#13', 'bamstar_large63@example.com', '010-4012-1053', 3, NOW() - INTERVAL '53 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', '플레이스#14', 'bamstar_large64@example.com', '010-4013-3481', 3, NOW() - INTERVAL '29 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', '플레이스#15', 'bamstar_large65@example.com', '010-4014-6602', 3, NOW() - INTERVAL '90 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', '플레이스#16', 'bamstar_large66@example.com', '010-4015-7739', 3, NOW() - INTERVAL '104 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', '플레이스#17', 'bamstar_large67@example.com', '010-4016-9267', 3, NOW() - INTERVAL '12 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('471c7578-d00e-497b-8684-49478e200953', '플레이스#18', 'bamstar_large68@example.com', '010-4017-1544', 3, NOW() - INTERVAL '176 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', '플레이스#19', 'bamstar_large69@example.com', '010-4018-2017', 3, NOW() - INTERVAL '25 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('3007a012-9378-4883-910b-53706fb1511c', '플레이스#20', 'bamstar_large70@example.com', '010-4019-7817', 3, NOW() - INTERVAL '115 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', '플레이스#21', 'bamstar_large71@example.com', '010-4020-6661', 3, NOW() - INTERVAL '62 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', '플레이스#22', 'bamstar_large72@example.com', '010-4021-7901', 3, NOW() - INTERVAL '10 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', '플레이스#23', 'bamstar_large73@example.com', '010-4022-9705', 3, NOW() - INTERVAL '87 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', '플레이스#24', 'bamstar_large74@example.com', '010-4023-8430', 3, NOW() - INTERVAL '171 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', '플레이스#25', 'bamstar_large75@example.com', '010-4024-4053', 3, NOW() - INTERVAL '152 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', '플레이스#26', 'bamstar_large76@example.com', '010-4025-9069', 3, NOW() - INTERVAL '28 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', '플레이스#27', 'bamstar_large77@example.com', '010-4026-6220', 3, NOW() - INTERVAL '180 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', '플레이스#28', 'bamstar_large78@example.com', '010-4027-4453', 3, NOW() - INTERVAL '119 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', '플레이스#29', 'bamstar_large79@example.com', '010-4028-1568', 3, NOW() - INTERVAL '61 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', '플레이스#30', 'bamstar_large80@example.com', '010-4029-7796', 3, NOW() - INTERVAL '24 days', NOW());

-- 3. 스타 프로필 50개
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '51caecf3-7a38-4b33-8560-1ac5ff48f797', '이서준', 'MALE', '010-5001-6263',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_51caecf3-7a38-4b33-8560-1ac5ff48f797_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_51caecf3-7a38-4b33-8560-1ac5ff48f797_2.jpg'], '이서준님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'MONTHLY', 6598339, ARRAY['TUESDAY', 'SUNDAY', 'SATURDAY', 'WEDNESDAY'],
    '2025-09-14', true,
    8, 4084, '경력', 34, '{"preferred_business_types": ["토크 바", "카페", "캐주얼 펍", "가라오케"], "work_style_preferences": ["stable", "flexible", "team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '742719fe-913f-4c19-a671-8bfdf21381a4', '조시우', 'MALE', '010-5002-2742',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_742719fe-913f-4c19-a671-8bfdf21381a4_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_742719fe-913f-4c19-a671-8bfdf21381a4_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_742719fe-913f-4c19-a671-8bfdf21381a4_3.jpg'], '조시우님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'TC', 3112900, ARRAY['THURSDAY', 'SATURDAY', 'TUESDAY', 'SUNDAY', 'MONDAY'],
    '2025-09-04', true,
    6, 4405, '경력', 25, '{"preferred_business_types": ["모던 바", "토크 바", "가라오케", "테라피"], "work_style_preferences": ["stable", "team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '26e1e69b-e130-4e85-8951-e000ee892659', '정예은', 'FEMALE', '010-5003-6101',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_26e1e69b-e130-4e85-8951-e000ee892659_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_26e1e69b-e130-4e85-8951-e000ee892659_2.jpg'], '정예은님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 2647581, ARRAY['THURSDAY', 'SATURDAY', 'MONDAY', 'FRIDAY', 'SUNDAY', 'WEDNESDAY'],
    '2025-08-31', false,
    8, 2153, '경력', 24, '{"preferred_business_types": ["카페", "가라오케", "모던 바", "테라피"], "work_style_preferences": ["flexible", "individual"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '517dd9b9-727d-4fcd-802c-6ddeb2ffa738', '조예은', 'FEMALE', '010-5004-8076',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_517dd9b9-727d-4fcd-802c-6ddeb2ffa738_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_517dd9b9-727d-4fcd-802c-6ddeb2ffa738_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_517dd9b9-727d-4fcd-802c-6ddeb2ffa738_3.jpg'], '조예은님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 3892401, ARRAY['SUNDAY', 'SATURDAY', 'WEDNESDAY', 'TUESDAY'],
    '2025-09-17', false,
    8, 3433, '경력', 24, '{"preferred_business_types": ["모던 바", "테라피"], "work_style_preferences": ["team_work", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '318a0171-e17d-4108-a9cf-cb9d0b60d80e', '최하은', 'FEMALE', '010-5005-3378',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_318a0171-e17d-4108-a9cf-cb9d0b60d80e_1.jpg'], '최하은님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'DAILY', 5102213, ARRAY['WEDNESDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-15', true,
    5, 192, '경력', 29, '{"preferred_business_types": ["카페", "캐주얼 펍", "모던 바"], "work_style_preferences": ["flexible"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'cd9aa417-82cc-459b-a6b4-b3425417a488', '이지우', 'FEMALE', '010-5006-9865',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_cd9aa417-82cc-459b-a6b4-b3425417a488_1.jpg'], '이지우님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 5388493, ARRAY['TUESDAY', 'SUNDAY', 'FRIDAY', 'SATURDAY'],
    '2025-09-25', false,
    4, 3479, '경력', 24, '{"preferred_business_types": ["테라피", "캐주얼 펍", "토크 바", "가라오케"], "work_style_preferences": ["team_work", "individual", "stable"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1bacd029-cd7e-489d-ae62-dd910a8bc675', '최건우', 'MALE', '010-5007-9161',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1bacd029-cd7e-489d-ae62-dd910a8bc675_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1bacd029-cd7e-489d-ae62-dd910a8bc675_2.jpg'], '최건우님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 5378186, ARRAY['THURSDAY', 'WEDNESDAY', 'FRIDAY'],
    '2025-09-13', false,
    10, 4821, '경력', 23, '{"preferred_business_types": ["카페", "모던 바"], "work_style_preferences": ["individual", "flexible"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'e51d25fd-a728-4b00-a4e4-70b306baea55', '임예은', 'FEMALE', '010-5008-5149',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_e51d25fd-a728-4b00-a4e4-70b306baea55_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_e51d25fd-a728-4b00-a4e4-70b306baea55_2.jpg'], '임예은님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'TC', 4521802, ARRAY['TUESDAY', 'THURSDAY', 'SUNDAY', 'WEDNESDAY'],
    '2025-09-02', true,
    6, 3192, '경력', 22, '{"preferred_business_types": ["테라피", "토크 바"], "work_style_preferences": ["flexible", "stable", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b9c4fec3-49c1-4e70-884c-f05f55052a84', '김건우', 'MALE', '010-5009-4424',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b9c4fec3-49c1-4e70-884c-f05f55052a84_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b9c4fec3-49c1-4e70-884c-f05f55052a84_2.jpg'], '김건우님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'TC', 5230489, ARRAY['WEDNESDAY', 'THURSDAY', 'MONDAY'],
    '2025-09-23', true,
    8, 4771, '경력', 21, '{"preferred_business_types": ["가라오케", "테라피", "카페", "캐주얼 펍"], "work_style_preferences": ["stable"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '3fb38fea-5ff5-4bff-b0ba-700d46b572cf', '최채원', 'FEMALE', '010-5010-5241',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_3fb38fea-5ff5-4bff-b0ba-700d46b572cf_1.jpg'], '최채원님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 2700936, ARRAY['THURSDAY', 'SATURDAY', 'WEDNESDAY', 'TUESDAY', 'MONDAY'],
    '2025-09-04', true,
    10, 863, '경력', 23, '{"preferred_business_types": ["테라피", "모던 바"], "work_style_preferences": ["team_work", "flexible"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1579c7e6-470b-4847-8a12-1572484562e7', '박우진', 'MALE', '010-5011-7275',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1579c7e6-470b-4847-8a12-1572484562e7_1.jpg'], '박우진님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'TC', 3631107, ARRAY['FRIDAY', 'MONDAY', 'WEDNESDAY', 'TUESDAY'],
    '2025-09-27', true,
    6, 1401, '경력', 32, '{"preferred_business_types": ["토크 바", "모던 바", "가라오케"], "work_style_preferences": ["flexible", "stable", "team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'cdcf3109-7441-4bf5-8d07-828b0ecbfa57', '조건우', 'MALE', '010-5012-7177',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_cdcf3109-7441-4bf5-8d07-828b0ecbfa57_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_cdcf3109-7441-4bf5-8d07-828b0ecbfa57_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_cdcf3109-7441-4bf5-8d07-828b0ecbfa57_3.jpg'], '조건우님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 3902269, ARRAY['SATURDAY', 'THURSDAY', 'WEDNESDAY'],
    '2025-09-22', true,
    5, 1342, '경력', 20, '{"preferred_business_types": ["토크 바", "카페", "가라오케", "모던 바"], "work_style_preferences": ["flexible", "individual", "stable"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'c160979d-349d-4382-b2e6-ae3ddf998faa', '김지민', 'FEMALE', '010-5013-5717',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_c160979d-349d-4382-b2e6-ae3ddf998faa_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_c160979d-349d-4382-b2e6-ae3ddf998faa_2.jpg'], '김지민님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 3138824, ARRAY['TUESDAY', 'SUNDAY', 'FRIDAY', 'MONDAY', 'SATURDAY', 'WEDNESDAY'],
    '2025-09-20', false,
    9, 1032, '경력', 24, '{"preferred_business_types": ["테라피", "가라오케", "카페", "토크 바"], "work_style_preferences": ["flexible", "stable"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '68384370-1ba4-40cc-a1e4-78b002ce16fb', '이서윤', 'FEMALE', '010-5014-7112',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_68384370-1ba4-40cc-a1e4-78b002ce16fb_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_68384370-1ba4-40cc-a1e4-78b002ce16fb_2.jpg'], '이서윤님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'TC', 7702265, ARRAY['FRIDAY', 'SUNDAY', 'TUESDAY', 'THURSDAY', 'MONDAY', 'WEDNESDAY'],
    '2025-09-04', true,
    7, 4461, '경력', 31, '{"preferred_business_types": ["가라오케", "카페"], "work_style_preferences": ["individual", "flexible"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', '장하은', 'FEMALE', '010-5015-3137',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3_2.jpg'], '장하은님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 6092028, ARRAY['THURSDAY', 'SATURDAY', 'WEDNESDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-12', false,
    1, 1477, '경력', 35, '{"preferred_business_types": ["캐주얼 펍", "카페", "테라피"], "work_style_preferences": ["individual", "stable", "flexible"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '966e6948-7c29-4e55-b0c4-00bee2e629d9', '이민준', 'MALE', '010-5016-9385',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_966e6948-7c29-4e55-b0c4-00bee2e629d9_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_966e6948-7c29-4e55-b0c4-00bee2e629d9_2.jpg'], '이민준님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 5328201, ARRAY['THURSDAY', 'TUESDAY', 'FRIDAY', 'WEDNESDAY', 'SATURDAY', 'MONDAY'],
    '2025-09-08', false,
    6, 4390, '경력', 20, '{"preferred_business_types": ["모던 바", "카페"], "work_style_preferences": ["team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '6555ad3d-d062-4b5c-a586-7953ea28cfd5', '강하준', 'MALE', '010-5017-7072',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_6555ad3d-d062-4b5c-a586-7953ea28cfd5_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_6555ad3d-d062-4b5c-a586-7953ea28cfd5_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_6555ad3d-d062-4b5c-a586-7953ea28cfd5_3.jpg'], '강하준님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 3699618, ARRAY['THURSDAY', 'FRIDAY', 'MONDAY'],
    '2025-09-17', true,
    2, 3992, '경력', 33, '{"preferred_business_types": ["토크 바", "모던 바"], "work_style_preferences": ["team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', '윤지우', 'FEMALE', '010-5018-6865',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_670977a7-a1c9-4c3b-aeb8-a6fc484e0a19_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_670977a7-a1c9-4c3b-aeb8-a6fc484e0a19_2.jpg'], '윤지우님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 3974801, ARRAY['MONDAY', 'TUESDAY', 'WEDNESDAY', 'SUNDAY', 'THURSDAY', 'FRIDAY'],
    '2025-09-12', true,
    7, 2663, '경력', 32, '{"preferred_business_types": ["토크 바", "캐주얼 펍", "테라피", "모던 바"], "work_style_preferences": ["flexible", "stable", "individual"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b4162826-f99b-489a-a2c7-02ed18284b07', '장건우', 'MALE', '010-5019-4981',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b4162826-f99b-489a-a2c7-02ed18284b07_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b4162826-f99b-489a-a2c7-02ed18284b07_2.jpg'], '장건우님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 3986425, ARRAY['MONDAY', 'SATURDAY', 'WEDNESDAY'],
    '2025-09-20', false,
    1, 2303, '경력', 23, '{"preferred_business_types": ["테라피", "가라오케", "캐주얼 펍", "모던 바"], "work_style_preferences": ["individual", "team_work", "stable"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', '임채원', 'FEMALE', '010-5020-8740',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf_3.jpg'], '임채원님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 4611332, ARRAY['FRIDAY', 'SATURDAY', 'SUNDAY', 'MONDAY'],
    '2025-09-01', true,
    8, 2320, '경력', 23, '{"preferred_business_types": ["가라오케", "테라피"], "work_style_preferences": ["stable", "team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '222c926d-011d-4f29-9b97-2e9d870b4369', '임시우', 'MALE', '010-5021-7140',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_222c926d-011d-4f29-9b97-2e9d870b4369_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_222c926d-011d-4f29-9b97-2e9d870b4369_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_222c926d-011d-4f29-9b97-2e9d870b4369_3.jpg'], '임시우님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'TC', 6681123, ARRAY['TUESDAY', 'SUNDAY', 'THURSDAY'],
    '2025-09-24', false,
    5, 4609, '경력', 33, '{"preferred_business_types": ["토크 바", "카페", "모던 바"], "work_style_preferences": ["team_work"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '4184fe09-8409-436a-b5ec-4155c5f82426', '윤지유', 'FEMALE', '010-5022-3072',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_4184fe09-8409-436a-b5ec-4155c5f82426_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_4184fe09-8409-436a-b5ec-4155c5f82426_2.jpg'], '윤지유님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 3689691, ARRAY['TUESDAY', 'MONDAY', 'SATURDAY', 'WEDNESDAY'],
    '2025-09-11', false,
    10, 4327, '경력', 32, '{"preferred_business_types": ["테라피", "카페"], "work_style_preferences": ["team_work", "individual"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', '임시우', 'MALE', '010-5023-8566',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c_2.jpg'], '임시우님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 4165190, ARRAY['TUESDAY', 'THURSDAY', 'WEDNESDAY'],
    '2025-09-08', true,
    2, 3615, '경력', 33, '{"preferred_business_types": ["캐주얼 펍", "토크 바"], "work_style_preferences": ["team_work", "stable"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '8a12d7f4-5fc3-46ee-98e3-6306cc03955c', '조서준', 'MALE', '010-5024-2887',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_8a12d7f4-5fc3-46ee-98e3-6306cc03955c_1.jpg'], '조서준님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'TC', 6495396, ARRAY['TUESDAY', 'MONDAY', 'SATURDAY', 'FRIDAY', 'SUNDAY'],
    '2025-09-29', false,
    7, 1782, '경력', 34, '{"preferred_business_types": ["모던 바", "가라오케", "토크 바"], "work_style_preferences": ["flexible", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '33291db2-690a-43ae-bb34-45c2b30d5402', '조민서', 'FEMALE', '010-5025-7636',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_33291db2-690a-43ae-bb34-45c2b30d5402_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_33291db2-690a-43ae-bb34-45c2b30d5402_2.jpg'], '조민서님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'TC', 6016505, ARRAY['FRIDAY', 'SATURDAY', 'WEDNESDAY', 'MONDAY', 'THURSDAY'],
    '2025-09-13', false,
    2, 445, '경력', 32, '{"preferred_business_types": ["카페", "테라피", "토크 바", "캐주얼 펍"], "work_style_preferences": ["individual", "stable", "flexible"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'aa7945c1-5e43-4465-b3e8-084065baa034', '최채원', 'FEMALE', '010-5026-6883',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_aa7945c1-5e43-4465-b3e8-084065baa034_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_aa7945c1-5e43-4465-b3e8-084065baa034_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_aa7945c1-5e43-4465-b3e8-084065baa034_3.jpg'], '최채원님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'TC', 4853699, ARRAY['TUESDAY', 'SATURDAY', 'FRIDAY', 'WEDNESDAY', 'MONDAY'],
    '2025-09-11', true,
    5, 4696, '경력', 22, '{"preferred_business_types": ["테라피", "캐주얼 펍"], "work_style_preferences": ["team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '31498511-39ba-49a9-a95f-473bf3cba204', '정도윤', 'MALE', '010-5027-3485',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_31498511-39ba-49a9-a95f-473bf3cba204_1.jpg'], '정도윤님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 4076688, ARRAY['SATURDAY', 'TUESDAY', 'THURSDAY', 'FRIDAY', 'SUNDAY'],
    '2025-09-16', true,
    8, 3967, '경력', 33, '{"preferred_business_types": ["카페", "테라피", "캐주얼 펍", "모던 바"], "work_style_preferences": ["team_work", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '96da66f5-ed48-4437-a173-91d298cad953', '최지우', 'FEMALE', '010-5028-5122',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_96da66f5-ed48-4437-a173-91d298cad953_1.jpg'], '최지우님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 3953390, ARRAY['TUESDAY', 'MONDAY', 'FRIDAY', 'THURSDAY', 'SATURDAY'],
    '2025-09-13', true,
    1, 2552, '경력', 27, '{"preferred_business_types": ["가라오케", "토크 바", "카페", "캐주얼 펍"], "work_style_preferences": ["team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '609f1d81-d232-4610-8817-670f0869ce80', '정지유', 'FEMALE', '010-5029-1699',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_609f1d81-d232-4610-8817-670f0869ce80_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_609f1d81-d232-4610-8817-670f0869ce80_2.jpg'], '정지유님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 3969082, ARRAY['MONDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-18', false,
    9, 881, '경력', 27, '{"preferred_business_types": ["캐주얼 펍", "가라오케"], "work_style_preferences": ["individual", "stable", "flexible"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'ae609368-fb4e-4ac3-a02d-42f3de07a8c0', '이채원', 'FEMALE', '010-5030-9703',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_ae609368-fb4e-4ac3-a02d-42f3de07a8c0_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_ae609368-fb4e-4ac3-a02d-42f3de07a8c0_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_ae609368-fb4e-4ac3-a02d-42f3de07a8c0_3.jpg'], '이채원님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 2560343, ARRAY['THURSDAY', 'FRIDAY', 'SATURDAY', 'TUESDAY'],
    '2025-08-31', true,
    2, 3879, '경력', 33, '{"preferred_business_types": ["테라피", "토크 바"], "work_style_preferences": ["team_work", "flexible", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '49ea00cb-f4e0-405e-b745-5402eb76e49c', '장우진', 'MALE', '010-5031-3122',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_49ea00cb-f4e0-405e-b745-5402eb76e49c_1.jpg'], '장우진님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'DAILY', 7360376, ARRAY['THURSDAY', 'SUNDAY', 'TUESDAY', 'FRIDAY', 'MONDAY', 'SATURDAY'],
    '2025-09-03', false,
    7, 85, '경력', 32, '{"preferred_business_types": ["테라피", "카페", "토크 바", "캐주얼 펍"], "work_style_preferences": ["flexible", "team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'a1a65c99-70a7-4d4d-b82f-b2a483850166', '윤지우', 'FEMALE', '010-5032-6194',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_a1a65c99-70a7-4d4d-b82f-b2a483850166_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_a1a65c99-70a7-4d4d-b82f-b2a483850166_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_a1a65c99-70a7-4d4d-b82f-b2a483850166_3.jpg'], '윤지우님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'DAILY', 7373468, ARRAY['WEDNESDAY', 'SUNDAY', 'THURSDAY', 'TUESDAY', 'MONDAY', 'FRIDAY'],
    '2025-09-24', true,
    6, 4058, '경력', 20, '{"preferred_business_types": ["테라피", "캐주얼 펍"], "work_style_preferences": ["stable", "team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1703ca40-47ec-4409-bf67-ef8d21bafc45', '장지호', 'MALE', '010-5033-2107',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1703ca40-47ec-4409-bf67-ef8d21bafc45_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1703ca40-47ec-4409-bf67-ef8d21bafc45_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1703ca40-47ec-4409-bf67-ef8d21bafc45_3.jpg'], '장지호님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 4455979, ARRAY['SUNDAY', 'SATURDAY', 'THURSDAY', 'FRIDAY', 'MONDAY', 'TUESDAY'],
    '2025-09-19', true,
    3, 3750, '경력', 29, '{"preferred_business_types": ["카페", "가라오케", "모던 바", "캐주얼 펍"], "work_style_preferences": ["stable"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '95d15044-cc17-41d8-84e0-43a0379aaaf8', '조민서', 'FEMALE', '010-5034-3349',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_95d15044-cc17-41d8-84e0-43a0379aaaf8_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_95d15044-cc17-41d8-84e0-43a0379aaaf8_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_95d15044-cc17-41d8-84e0-43a0379aaaf8_3.jpg'], '조민서님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'MONTHLY', 6837610, ARRAY['WEDNESDAY', 'MONDAY', 'FRIDAY', 'SUNDAY'],
    '2025-09-02', true,
    10, 4289, '경력', 23, '{"preferred_business_types": ["테라피", "카페", "캐주얼 펍"], "work_style_preferences": ["team_work"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'fcf84023-7adb-4d28-a9fb-e4b7fe711e44', '정예은', 'FEMALE', '010-5035-4380',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_fcf84023-7adb-4d28-a9fb-e4b7fe711e44_1.jpg'], '정예은님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'TC', 7986583, ARRAY['TUESDAY', 'FRIDAY', 'SUNDAY', 'SATURDAY', 'MONDAY', 'THURSDAY'],
    '2025-09-04', false,
    4, 2518, '경력', 27, '{"preferred_business_types": ["토크 바", "테라피"], "work_style_preferences": ["individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1ce3fab2-a50e-48f6-a917-3f1669e6ec91', '강하은', 'FEMALE', '010-5036-8150',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1ce3fab2-a50e-48f6-a917-3f1669e6ec91_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1ce3fab2-a50e-48f6-a917-3f1669e6ec91_2.jpg'], '강하은님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 3686915, ARRAY['THURSDAY', 'FRIDAY', 'SATURDAY'],
    '2025-09-04', true,
    2, 1523, '경력', 34, '{"preferred_business_types": ["테라피", "카페"], "work_style_preferences": ["flexible", "stable"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', '강건우', 'MALE', '010-5037-4452',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_aa689ae8-6ce3-4fd6-a844-ad18949bb6f8_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_aa689ae8-6ce3-4fd6-a844-ad18949bb6f8_2.jpg'], '강건우님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'TC', 3652854, ARRAY['SUNDAY', 'FRIDAY', 'MONDAY'],
    '2025-09-16', true,
    10, 4864, '경력', 28, '{"preferred_business_types": ["토크 바", "테라피", "가라오케"], "work_style_preferences": ["flexible", "individual", "team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', '이서준', 'MALE', '010-5038-6382',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540_3.jpg'], '이서준님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'MONTHLY', 7302359, ARRAY['WEDNESDAY', 'SUNDAY', 'TUESDAY', 'THURSDAY', 'MONDAY', 'SATURDAY'],
    '2025-09-25', true,
    10, 1046, '경력', 21, '{"preferred_business_types": ["캐주얼 펍", "가라오케"], "work_style_preferences": ["flexible", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '13caad73-e12f-4cd4-87b2-650da89b8f18', '장주원', 'MALE', '010-5039-7794',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_13caad73-e12f-4cd4-87b2-650da89b8f18_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_13caad73-e12f-4cd4-87b2-650da89b8f18_2.jpg'], '장주원님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 3964785, ARRAY['THURSDAY', 'SUNDAY', 'WEDNESDAY'],
    '2025-09-06', false,
    4, 2225, '경력', 35, '{"preferred_business_types": ["테라피", "가라오케", "모던 바", "토크 바"], "work_style_preferences": ["team_work", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'd765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', '박지우', 'FEMALE', '010-5040-8568',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5_3.jpg'], '박지우님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'TC', 6225668, ARRAY['WEDNESDAY', 'MONDAY', 'TUESDAY', 'SATURDAY'],
    '2025-09-25', true,
    8, 3924, '경력', 27, '{"preferred_business_types": ["모던 바", "가라오케"], "work_style_preferences": ["flexible", "team_work", "stable"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '9acf9937-e3d4-4c8c-b78f-068fe711e10a', '이서윤', 'FEMALE', '010-5041-9591',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_9acf9937-e3d4-4c8c-b78f-068fe711e10a_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_9acf9937-e3d4-4c8c-b78f-068fe711e10a_2.jpg'], '이서윤님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 2917224, ARRAY['WEDNESDAY', 'SUNDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-16', true,
    4, 3562, '경력', 25, '{"preferred_business_types": ["캐주얼 펍", "모던 바"], "work_style_preferences": ["stable"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '5760c600-4d37-49da-849d-64537cf049b8', '윤지우', 'FEMALE', '010-5042-1847',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_5760c600-4d37-49da-849d-64537cf049b8_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_5760c600-4d37-49da-849d-64537cf049b8_2.jpg'], '윤지우님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'DAILY', 7334717, ARRAY['SUNDAY', 'FRIDAY', 'WEDNESDAY', 'TUESDAY'],
    '2025-09-21', false,
    2, 3276, '경력', 34, '{"preferred_business_types": ["캐주얼 펍", "카페", "토크 바"], "work_style_preferences": ["flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b48536e9-cf57-438c-9100-f249595563b7', '박서현', 'FEMALE', '010-5043-7268',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b48536e9-cf57-438c-9100-f249595563b7_1.jpg'], '박서현님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 4570431, ARRAY['FRIDAY', 'SUNDAY', 'TUESDAY', 'SATURDAY', 'WEDNESDAY'],
    '2025-09-11', true,
    2, 1699, '경력', 34, '{"preferred_business_types": ["토크 바", "캐주얼 펍", "가라오케"], "work_style_preferences": ["team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '932589e9-6c78-47f9-9382-4e09ea95c487', '최서윤', 'FEMALE', '010-5044-7861',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_932589e9-6c78-47f9-9382-4e09ea95c487_1.jpg'], '최서윤님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'MONTHLY', 7758170, ARRAY['THURSDAY', 'SUNDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-22', true,
    1, 4998, '경력', 29, '{"preferred_business_types": ["카페", "토크 바", "가라오케", "캐주얼 펍"], "work_style_preferences": ["flexible", "individual", "team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '7516de8b-c125-464c-8016-cfbfab1b9761', '이서준', 'MALE', '010-5045-6684',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_7516de8b-c125-464c-8016-cfbfab1b9761_1.jpg'], '이서준님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 2818146, ARRAY['WEDNESDAY', 'MONDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-08', true,
    3, 644, '경력', 34, '{"preferred_business_types": ["모던 바", "토크 바"], "work_style_preferences": ["team_work", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '64cf1711-01de-4138-9bd9-a346b3b9bec8', '장서윤', 'FEMALE', '010-5046-4042',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_64cf1711-01de-4138-9bd9-a346b3b9bec8_1.jpg'], '장서윤님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 5525163, ARRAY['MONDAY', 'SATURDAY', 'THURSDAY', 'SUNDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-08', true,
    5, 768, '경력', 32, '{"preferred_business_types": ["캐주얼 펍", "가라오케", "모던 바"], "work_style_preferences": ["team_work", "stable", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', '조서현', 'FEMALE', '010-5047-1119',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_a2f4bb71-3a79-4cfd-9532-b8ee2dd20594_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_a2f4bb71-3a79-4cfd-9532-b8ee2dd20594_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_a2f4bb71-3a79-4cfd-9532-b8ee2dd20594_3.jpg'], '조서현님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 3940409, ARRAY['WEDNESDAY', 'SATURDAY', 'FRIDAY', 'TUESDAY', 'THURSDAY', 'MONDAY'],
    '2025-09-06', false,
    6, 180, '경력', 27, '{"preferred_business_types": ["모던 바", "가라오케", "캐주얼 펍", "테라피"], "work_style_preferences": ["team_work"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'e7738aab-df79-42b1-9560-1daa00484091', '강서윤', 'FEMALE', '010-5048-1131',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_e7738aab-df79-42b1-9560-1daa00484091_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_e7738aab-df79-42b1-9560-1daa00484091_2.jpg'], '강서윤님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'TC', 7949033, ARRAY['SATURDAY', 'WEDNESDAY', 'FRIDAY', 'THURSDAY', 'TUESDAY', 'SUNDAY'],
    '2025-09-27', true,
    10, 4437, '경력', 34, '{"preferred_business_types": ["테라피", "토크 바"], "work_style_preferences": ["stable", "team_work", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '9c189238-144d-4751-a9f7-18ed147b0ead', '장민준', 'MALE', '010-5049-5630',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_9c189238-144d-4751-a9f7-18ed147b0ead_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_9c189238-144d-4751-a9f7-18ed147b0ead_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_9c189238-144d-4751-a9f7-18ed147b0ead_3.jpg'], '장민준님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 4740512, ARRAY['SATURDAY', 'FRIDAY', 'MONDAY', 'WEDNESDAY'],
    '2025-09-19', false,
    7, 4346, '경력', 22, '{"preferred_business_types": ["모던 바", "카페", "캐주얼 펍", "가라오케"], "work_style_preferences": ["flexible", "team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', '최하준', 'MALE', '010-5050-8653',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b642a4f1-9cc2-402d-bd3f-b87bc3e88dde_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b642a4f1-9cc2-402d-bd3f-b87bc3e88dde_2.jpg'], '최하준님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 5813950, ARRAY['FRIDAY', 'THURSDAY', 'TUESDAY', 'WEDNESDAY', 'MONDAY'],
    '2025-09-23', true,
    8, 192, '경력', 35, '{"preferred_business_types": ["모던 바", "카페", "토크 바", "캐주얼 펍"], "work_style_preferences": ["individual", "flexible", "team_work"], "location_flexibility": "high"}'
);

-- 4. 플레이스 프로필 30개
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '60b452ec-755a-4f39-ab24-ed54a9e94db1', '노원 프라임 테라피', '카페', '901-70-28679', true,
    '서울특별시 마포구 역삼동 727-4', '김매니저', '010-6001-5047',
    '노원 프라임 테라피는 카페 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_60b452ec-755a-4f39-ab24-ed54a9e94db1_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_60b452ec-755a-4f39-ab24-ed54a9e94db1_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    2076135, 4627247, '신입',
    NOW() - INTERVAL '142 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'aada73d8-7377-47a1-84e5-8848418e6ad3', '성수동 아틀리에 카페', '가라오케', '594-83-84195', false,
    '서울특별시 종로구 역삼동 698-6', '장원장', '010-6002-7273',
    '성수동 아틀리에 카페는 가라오케 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_aada73d8-7377-47a1-84e5-8848418e6ad3_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_aada73d8-7377-47a1-84e5-8848418e6ad3_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2280724, 5199183, '전문가',
    NOW() - INTERVAL '143 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'cb4adae4-e34f-428a-8c15-0d791b9651e5', '송파 엘리트 가라오케', '카페', '503-88-28543', true,
    '서울특별시 강남구 역삼동 446-18', '장원장', '010-6003-6271',
    '송파 엘리트 가라오케는 카페 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    2016150, 4573038, '신입',
    NOW() - INTERVAL '134 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '3b0cf39c-b889-4ddd-be05-b42514ef22f9', '교대역 크라운 카페', '테라피', '999-65-64939', false,
    '서울특별시 종로구 역삼동 229-61', '김매니저', '010-6004-6000',
    '교대역 크라운 카페는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    4183219, 8690639, '전문가',
    NOW() - INTERVAL '83 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'd9d96195-aa27-4f78-a23b-7cd820a1907c', '홍대거리 프라임 바', '테라피', '298-81-56252', true,
    '서울특별시 서초구 역삼동 314-97', '최사장', '010-6005-5492',
    '홍대거리 프라임 바는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    4101708, 8699859, '주니어',
    NOW() - INTERVAL '126 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '14db3f09-abdd-46b0-964b-7febbec574a6', '서초 플래티넘 테라피', '카페', '119-54-77556', false,
    '서울특별시 마포구 역삼동 412-44', '최사장', '010-6006-1051',
    '서초 플래티넘 테라피는 카페 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_14db3f09-abdd-46b0-964b-7febbec574a6_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_14db3f09-abdd-46b0-964b-7febbec574a6_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    2220081, 4291903, '주니어',
    NOW() - INTERVAL '113 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '7b8abab2-be87-4e4f-817c-2bc3c297baea', '신사동 VIP 캐주얼 펍', '캐주얼 펍', '175-25-20694', true,
    '서울특별시 서초구 역삼동 393-24', '박매니저', '010-6007-4943',
    '신사동 VIP 캐주얼 펍는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2670663, 5498611, '무관',
    NOW() - INTERVAL '108 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '192825ce-0bd1-4407-ade9-78e35ffbcac8', '노원 프라임 테라피', '카페', '237-12-67895', true,
    '서울특별시 용산구 역삼동 88-32', '이실장', '010-6008-1040',
    '노원 프라임 테라피는 카페 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_192825ce-0bd1-4407-ade9-78e35ffbcac8_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_192825ce-0bd1-4407-ade9-78e35ffbcac8_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2145900, 4630950, '주니어',
    NOW() - INTERVAL '52 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '4423b96d-555e-40a4-9822-94a9e7470f7b', '압구정역 엘리트 바', '모던 바', '614-72-71081', true,
    '서울특별시 종로구 역삼동 308-53', '김매니저', '010-6009-5267',
    '압구정역 엘리트 바는 모던 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3343324, 6826739, '신입',
    NOW() - INTERVAL '120 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '47bcaa2f-c706-467a-b62d-0d165b285236', '노원 프라임 테라피', '테라피', '368-73-30569', true,
    '서울특별시 용산구 역삼동 32-97', '윤매니저', '010-6010-4460',
    '노원 프라임 테라피는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    4171312, 8558962, '주니어',
    NOW() - INTERVAL '70 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '8675ad69-5eae-4066-971e-048300b3e622', '강남 프리미엄 모던 바', '가라오케', '868-56-64020', false,
    '서울특별시 용산구 역삼동 743-76', '김매니저', '010-6011-1894',
    '강남 프리미엄 모던 바는 가라오케 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2203325, 4907795, '신입',
    NOW() - INTERVAL '156 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '840f0d29-7959-49d6-afe8-0d0277b6abff', '마포구 크리스탈 테라피', '모던 바', '283-70-88955', false,
    '서울특별시 서초구 역삼동 308-47', '이실장', '010-6012-5725',
    '마포구 크리스탈 테라피는 모던 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_840f0d29-7959-49d6-afe8-0d0277b6abff_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_840f0d29-7959-49d6-afe8-0d0277b6abff_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    3442531, 6604540, '주니어',
    NOW() - INTERVAL '6 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '7867f93b-57b6-4b71-9337-f9349d624e14', '상수동 엘리트 펍', '테라피', '557-78-86305', false,
    '서울특별시 용산구 역삼동 341-10', '장원장', '010-6013-9638',
    '상수동 엘리트 펍는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3957078, 8764657, '신입',
    NOW() - INTERVAL '84 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '78a12a3d-1474-4653-b8fb-f05de1c3d63b', '동대문 크리스탈 바', '캐주얼 펍', '932-36-82502', true,
    '서울특별시 종로구 역삼동 480-4', '윤매니저', '010-6014-2429',
    '동대문 크리스탈 바는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2503522, 5686760, '신입',
    NOW() - INTERVAL '11 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', '상수동 프리미엄 펍', '토크 바', '127-82-14489', false,
    '서울특별시 종로구 역삼동 621-75', '장원장', '010-6015-8704',
    '상수동 프리미엄 펍는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    3187712, 5886405, '무관',
    NOW() - INTERVAL '35 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', '상수동 엘리트 펍', '테라피', '382-13-76968', true,
    '서울특별시 강남구 역삼동 345-78', '장원장', '010-6016-5084',
    '상수동 엘리트 펍는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    4150550, 8916363, '무관',
    NOW() - INTERVAL '37 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'ea261ead-93ef-4d7a-bec5-53c998256775', '신사동 VIP 캐주얼 펍', '모던 바', '913-51-66051', false,
    '서울특별시 서초구 역삼동 363-63', '박매니저', '010-6017-8686',
    '신사동 VIP 캐주얼 펍는 모던 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3225738, 6956556, '무관',
    NOW() - INTERVAL '164 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '471c7578-d00e-497b-8684-49478e200953', '강남역 로얄 클럽', '토크 바', '381-48-93333', true,
    '서울특별시 중구 역삼동 155-70', '이실장', '010-6018-8873',
    '강남역 로얄 클럽는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3194879, 6125207, '무관',
    NOW() - INTERVAL '170 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'e06e018c-331a-45ad-9489-9a45a94ee9e5', '청담 골든 가라오케', '가라오케', '167-33-20466', true,
    '서울특별시 서초구 역삼동 682-83', '박매니저', '010-6019-7291',
    '청담 골든 가라오케는 가라오케 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2216853, 4967169, '전문가',
    NOW() - INTERVAL '96 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '3007a012-9378-4883-910b-53706fb1511c', '신사동 VIP 캐주얼 펍', '테라피', '353-40-76811', true,
    '서울특별시 종로구 역삼동 675-68', '장원장', '010-6020-6664',
    '신사동 VIP 캐주얼 펍는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    4179043, 8772769, '무관',
    NOW() - INTERVAL '117 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'da0213cf-a61c-4997-b3f9-551eb49eec7e', '홍대입구 플래티넘 가라오케', '토크 바', '157-47-75897', true,
    '서울특별시 용산구 역삼동 47-51', '박매니저', '010-6021-4130',
    '홍대입구 플래티넘 가라오케는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    3037163, 6032635, '신입',
    NOW() - INTERVAL '92 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'f9771f09-da7c-4760-9fa6-fac71fb45a3d', '상수동 프리미엄 펍', '캐주얼 펍', '656-14-58284', true,
    '서울특별시 종로구 역삼동 235-43', '윤매니저', '010-6022-5452',
    '상수동 프리미엄 펍는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_f9771f09-da7c-4760-9fa6-fac71fb45a3d_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_f9771f09-da7c-4760-9fa6-fac71fb45a3d_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2766609, 5251819, '전문가',
    NOW() - INTERVAL '82 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '7c7e6398-40e3-4914-ad70-cd52909d46eb', '종로 다이아몬드 토크바', '테라피', '249-95-18697', false,
    '서울특별시 서초구 역삼동 415-99', '최사장', '010-6023-4872',
    '종로 다이아몬드 토크바는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    3941952, 8766242, '시니어',
    NOW() - INTERVAL '142 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '415bcfba-d910-4074-befd-2a87956e5d7d', '건대 스타 펍', '테라피', '385-22-70659', false,
    '서울특별시 중구 역삼동 694-49', '윤매니저', '010-6024-9119',
    '건대 스타 펍는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    4171225, 8981155, '무관',
    NOW() - INTERVAL '107 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', '성수동 아틀리에 카페', '캐주얼 펍', '914-29-49586', false,
    '서울특별시 중구 역삼동 772-97', '최사장', '010-6025-4221',
    '성수동 아틀리에 카페는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2601832, 5526804, '신입',
    NOW() - INTERVAL '167 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'bb55d334-85e2-40c1-968b-3f67d4babd0b', '이태원 프리미엄 클럽', '가라오케', '279-55-30486', false,
    '서울특별시 마포구 역삼동 956-69', '장원장', '010-6026-8242',
    '이태원 프리미엄 클럽는 가라오케 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2220448, 4912285, '주니어',
    NOW() - INTERVAL '22 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'fd960752-f0c8-492a-be2d-406316bbea03', '홍대입구 플래티넘 가라오케', '캐주얼 펍', '795-73-23151', false,
    '서울특별시 강남구 역삼동 365-68', '장원장', '010-6027-1436',
    '홍대입구 플래티넘 가라오케는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_fd960752-f0c8-492a-be2d-406316bbea03_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fd960752-f0c8-492a-be2d-406316bbea03_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fd960752-f0c8-492a-be2d-406316bbea03_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2671383, 5328192, '신입',
    NOW() - INTERVAL '48 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '9e8f606e-c7db-42d7-b654-6192f388faa8', '성수동 아틀리에 카페', '테라피', '153-34-26010', false,
    '서울특별시 용산구 역삼동 381-6', '이실장', '010-6028-4054',
    '성수동 아틀리에 카페는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    4105394, 8818193, '시니어',
    NOW() - INTERVAL '18 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '3f262ca9-2013-40dd-9850-42ee401e0957', '상수역 다이아몬드 클럽', '모던 바', '918-75-51464', false,
    '서울특별시 강남구 역삼동 687-62', '김매니저', '010-6029-1998',
    '상수역 다이아몬드 클럽는 모던 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3225739, 6736471, '전문가',
    NOW() - INTERVAL '72 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'fe7f3554-b44a-4090-87aa-b10f67192b42', '압구정 럭셔리 토크 바', '테라피', '846-95-21101', false,
    '서울특별시 중구 역삼동 19-23', '장원장', '010-6030-7444',
    '압구정 럭셔리 토크 바는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_fe7f3554-b44a-4090-87aa-b10f67192b42_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fe7f3554-b44a-4090-87aa-b10f67192b42_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fe7f3554-b44a-4090-87aa-b10f67192b42_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fe7f3554-b44a-4090-87aa-b10f67192b42_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    4084074, 8616164, '주니어',
    NOW() - INTERVAL '86 days', NOW()
);

-- 5. 스타 속성 연결
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('26e1e69b-e130-4e85-8951-e000ee892659', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('26e1e69b-e130-4e85-8951-e000ee892659', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('3fb38fea-5ff5-4bff-b0ba-700d46b572cf', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('3fb38fea-5ff5-4bff-b0ba-700d46b572cf', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('3fb38fea-5ff5-4bff-b0ba-700d46b572cf', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('68384370-1ba4-40cc-a1e4-78b002ce16fb', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('68384370-1ba4-40cc-a1e4-78b002ce16fb', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('6555ad3d-d062-4b5c-a586-7953ea28cfd5', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('6555ad3d-d062-4b5c-a586-7953ea28cfd5', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('222c926d-011d-4f29-9b97-2e9d870b4369', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('222c926d-011d-4f29-9b97-2e9d870b4369', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('4184fe09-8409-436a-b5ec-4155c5f82426', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('4184fe09-8409-436a-b5ec-4155c5f82426', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('33291db2-690a-43ae-bb34-45c2b30d5402', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('33291db2-690a-43ae-bb34-45c2b30d5402', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('96da66f5-ed48-4437-a173-91d298cad953', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('96da66f5-ed48-4437-a173-91d298cad953', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('96da66f5-ed48-4437-a173-91d298cad953', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('609f1d81-d232-4610-8817-670f0869ce80', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('609f1d81-d232-4610-8817-670f0869ce80', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('609f1d81-d232-4610-8817-670f0869ce80', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('13caad73-e12f-4cd4-87b2-650da89b8f18', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('13caad73-e12f-4cd4-87b2-650da89b8f18', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('5760c600-4d37-49da-849d-64537cf049b8', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('5760c600-4d37-49da-849d-64537cf049b8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('5760c600-4d37-49da-849d-64537cf049b8', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('5760c600-4d37-49da-849d-64537cf049b8', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b48536e9-cf57-438c-9100-f249595563b7', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b48536e9-cf57-438c-9100-f249595563b7', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b48536e9-cf57-438c-9100-f249595563b7', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', 17);

-- 6. 플레이스 산업 연결
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 5);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 5);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 3);

-- 7. 플레이스 특성 연결
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 39);

COMMIT;

-- 검증 쿼리
SELECT 'Total Users' as type, COUNT(*) as count FROM users WHERE email LIKE 'bamstar_large%@example.com';
SELECT 'Stars' as type, COUNT(*) as count FROM member_profiles mp JOIN users u ON mp.user_id = u.id WHERE u.email LIKE 'bamstar_large%@example.com';
SELECT 'Places' as type, COUNT(*) as count FROM place_profiles pp JOIN users u ON pp.user_id = u.id WHERE u.email LIKE 'bamstar_large%@example.com';
