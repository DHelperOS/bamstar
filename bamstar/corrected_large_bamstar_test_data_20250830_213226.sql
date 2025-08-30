-- BamStar 대량 테스트 데이터 삽입 (수정 버전)
-- 생성일: 2025-08-30 21:32:26
-- 스타 50명, 플레이스 30명

BEGIN;

-- 1. 스타 사용자 50명
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', '스타#1', 'bamstar_large1@example.com', '010-3000-5831', 2, NOW() - INTERVAL '156 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', '스타#2', 'bamstar_large2@example.com', '010-3001-2499', 2, NOW() - INTERVAL '166 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('26e1e69b-e130-4e85-8951-e000ee892659', '스타#3', 'bamstar_large3@example.com', '010-3002-1142', 2, NOW() - INTERVAL '65 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', '스타#4', 'bamstar_large4@example.com', '010-3003-2721', 2, NOW() - INTERVAL '131 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', '스타#5', 'bamstar_large5@example.com', '010-3004-5933', 2, NOW() - INTERVAL '93 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', '스타#6', 'bamstar_large6@example.com', '010-3005-3498', 2, NOW() - INTERVAL '147 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', '스타#7', 'bamstar_large7@example.com', '010-3006-2672', 2, NOW() - INTERVAL '111 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', '스타#8', 'bamstar_large8@example.com', '010-3007-9787', 2, NOW() - INTERVAL '40 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', '스타#9', 'bamstar_large9@example.com', '010-3008-2208', 2, NOW() - INTERVAL '12 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('3fb38fea-5ff5-4bff-b0ba-700d46b572cf', '스타#10', 'bamstar_large10@example.com', '010-3009-6398', 2, NOW() - INTERVAL '109 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', '스타#11', 'bamstar_large11@example.com', '010-3010-3881', 2, NOW() - INTERVAL '118 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', '스타#12', 'bamstar_large12@example.com', '010-3011-5337', 2, NOW() - INTERVAL '23 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', '스타#13', 'bamstar_large13@example.com', '010-3012-3069', 2, NOW() - INTERVAL '76 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('68384370-1ba4-40cc-a1e4-78b002ce16fb', '스타#14', 'bamstar_large14@example.com', '010-3013-6690', 2, NOW() - INTERVAL '38 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', '스타#15', 'bamstar_large15@example.com', '010-3014-9676', 2, NOW() - INTERVAL '143 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', '스타#16', 'bamstar_large16@example.com', '010-3015-9443', 2, NOW() - INTERVAL '165 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('6555ad3d-d062-4b5c-a586-7953ea28cfd5', '스타#17', 'bamstar_large17@example.com', '010-3016-7950', 2, NOW() - INTERVAL '157 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', '스타#18', 'bamstar_large18@example.com', '010-3017-1255', 2, NOW() - INTERVAL '47 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', '스타#19', 'bamstar_large19@example.com', '010-3018-8994', 2, NOW() - INTERVAL '108 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', '스타#20', 'bamstar_large20@example.com', '010-3019-1036', 2, NOW() - INTERVAL '91 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('222c926d-011d-4f29-9b97-2e9d870b4369', '스타#21', 'bamstar_large21@example.com', '010-3020-6913', 2, NOW() - INTERVAL '105 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('4184fe09-8409-436a-b5ec-4155c5f82426', '스타#22', 'bamstar_large22@example.com', '010-3021-6087', 2, NOW() - INTERVAL '119 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', '스타#23', 'bamstar_large23@example.com', '010-3022-7350', 2, NOW() - INTERVAL '44 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', '스타#24', 'bamstar_large24@example.com', '010-3023-8974', 2, NOW() - INTERVAL '9 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('33291db2-690a-43ae-bb34-45c2b30d5402', '스타#25', 'bamstar_large25@example.com', '010-3024-8316', 2, NOW() - INTERVAL '103 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', '스타#26', 'bamstar_large26@example.com', '010-3025-3561', 2, NOW() - INTERVAL '123 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', '스타#27', 'bamstar_large27@example.com', '010-3026-1260', 2, NOW() - INTERVAL '162 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('96da66f5-ed48-4437-a173-91d298cad953', '스타#28', 'bamstar_large28@example.com', '010-3027-7821', 2, NOW() - INTERVAL '112 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('609f1d81-d232-4610-8817-670f0869ce80', '스타#29', 'bamstar_large29@example.com', '010-3028-4096', 2, NOW() - INTERVAL '77 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', '스타#30', 'bamstar_large30@example.com', '010-3029-8546', 2, NOW() - INTERVAL '70 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', '스타#31', 'bamstar_large31@example.com', '010-3030-7021', 2, NOW() - INTERVAL '147 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', '스타#32', 'bamstar_large32@example.com', '010-3031-7318', 2, NOW() - INTERVAL '163 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', '스타#33', 'bamstar_large33@example.com', '010-3032-6659', 2, NOW() - INTERVAL '167 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', '스타#34', 'bamstar_large34@example.com', '010-3033-6275', 2, NOW() - INTERVAL '120 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', '스타#35', 'bamstar_large35@example.com', '010-3034-4419', 2, NOW() - INTERVAL '79 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', '스타#36', 'bamstar_large36@example.com', '010-3035-2826', 2, NOW() - INTERVAL '68 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', '스타#37', 'bamstar_large37@example.com', '010-3036-9464', 2, NOW() - INTERVAL '166 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', '스타#38', 'bamstar_large38@example.com', '010-3037-6837', 2, NOW() - INTERVAL '156 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('13caad73-e12f-4cd4-87b2-650da89b8f18', '스타#39', 'bamstar_large39@example.com', '010-3038-5319', 2, NOW() - INTERVAL '127 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', '스타#40', 'bamstar_large40@example.com', '010-3039-9366', 2, NOW() - INTERVAL '107 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', '스타#41', 'bamstar_large41@example.com', '010-3040-4245', 2, NOW() - INTERVAL '45 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('5760c600-4d37-49da-849d-64537cf049b8', '스타#42', 'bamstar_large42@example.com', '010-3041-2260', 2, NOW() - INTERVAL '162 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b48536e9-cf57-438c-9100-f249595563b7', '스타#43', 'bamstar_large43@example.com', '010-3042-4512', 2, NOW() - INTERVAL '102 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', '스타#44', 'bamstar_large44@example.com', '010-3043-5086', 2, NOW() - INTERVAL '36 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', '스타#45', 'bamstar_large45@example.com', '010-3044-3313', 2, NOW() - INTERVAL '116 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', '스타#46', 'bamstar_large46@example.com', '010-3045-4542', 2, NOW() - INTERVAL '142 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', '스타#47', 'bamstar_large47@example.com', '010-3046-2845', 2, NOW() - INTERVAL '113 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('e7738aab-df79-42b1-9560-1daa00484091', '스타#48', 'bamstar_large48@example.com', '010-3047-5431', 2, NOW() - INTERVAL '28 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', '스타#49', 'bamstar_large49@example.com', '010-3048-7358', 2, NOW() - INTERVAL '42 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', '스타#50', 'bamstar_large50@example.com', '010-3049-6887', 2, NOW() - INTERVAL '71 days', NOW());

-- 2. 플레이스 사용자 30명
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', '플레이스#1', 'bamstar_large51@example.com', '010-4000-8031', 3, NOW() - INTERVAL '41 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', '플레이스#2', 'bamstar_large52@example.com', '010-4001-4943', 3, NOW() - INTERVAL '102 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', '플레이스#3', 'bamstar_large53@example.com', '010-4002-2003', 3, NOW() - INTERVAL '121 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', '플레이스#4', 'bamstar_large54@example.com', '010-4003-5600', 3, NOW() - INTERVAL '155 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', '플레이스#5', 'bamstar_large55@example.com', '010-4004-9868', 3, NOW() - INTERVAL '39 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', '플레이스#6', 'bamstar_large56@example.com', '010-4005-2603', 3, NOW() - INTERVAL '136 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', '플레이스#7', 'bamstar_large57@example.com', '010-4006-5176', 3, NOW() - INTERVAL '95 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', '플레이스#8', 'bamstar_large58@example.com', '010-4007-7019', 3, NOW() - INTERVAL '16 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', '플레이스#9', 'bamstar_large59@example.com', '010-4008-7730', 3, NOW() - INTERVAL '47 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', '플레이스#10', 'bamstar_large60@example.com', '010-4009-5017', 3, NOW() - INTERVAL '14 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('8675ad69-5eae-4066-971e-048300b3e622', '플레이스#11', 'bamstar_large61@example.com', '010-4010-3664', 3, NOW() - INTERVAL '88 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', '플레이스#12', 'bamstar_large62@example.com', '010-4011-9311', 3, NOW() - INTERVAL '173 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', '플레이스#13', 'bamstar_large63@example.com', '010-4012-4478', 3, NOW() - INTERVAL '143 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', '플레이스#14', 'bamstar_large64@example.com', '010-4013-1721', 3, NOW() - INTERVAL '170 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', '플레이스#15', 'bamstar_large65@example.com', '010-4014-3065', 3, NOW() - INTERVAL '21 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', '플레이스#16', 'bamstar_large66@example.com', '010-4015-3232', 3, NOW() - INTERVAL '8 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', '플레이스#17', 'bamstar_large67@example.com', '010-4016-5498', 3, NOW() - INTERVAL '15 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('471c7578-d00e-497b-8684-49478e200953', '플레이스#18', 'bamstar_large68@example.com', '010-4017-7996', 3, NOW() - INTERVAL '166 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', '플레이스#19', 'bamstar_large69@example.com', '010-4018-3782', 3, NOW() - INTERVAL '63 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('3007a012-9378-4883-910b-53706fb1511c', '플레이스#20', 'bamstar_large70@example.com', '010-4019-8837', 3, NOW() - INTERVAL '55 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', '플레이스#21', 'bamstar_large71@example.com', '010-4020-7113', 3, NOW() - INTERVAL '17 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', '플레이스#22', 'bamstar_large72@example.com', '010-4021-7683', 3, NOW() - INTERVAL '12 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', '플레이스#23', 'bamstar_large73@example.com', '010-4022-5755', 3, NOW() - INTERVAL '123 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', '플레이스#24', 'bamstar_large74@example.com', '010-4023-8166', 3, NOW() - INTERVAL '15 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', '플레이스#25', 'bamstar_large75@example.com', '010-4024-9662', 3, NOW() - INTERVAL '179 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', '플레이스#26', 'bamstar_large76@example.com', '010-4025-4128', 3, NOW() - INTERVAL '85 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', '플레이스#27', 'bamstar_large77@example.com', '010-4026-3048', 3, NOW() - INTERVAL '163 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', '플레이스#28', 'bamstar_large78@example.com', '010-4027-7434', 3, NOW() - INTERVAL '105 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', '플레이스#29', 'bamstar_large79@example.com', '010-4028-5834', 3, NOW() - INTERVAL '178 days', NOW());
INSERT INTO users (id, nickname, email, phone, role_id, created_at, updated_at)
VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', '플레이스#30', 'bamstar_large80@example.com', '010-4029-4236', 3, NOW() - INTERVAL '45 days', NOW());

-- 3. 스타 프로필 50개
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '51caecf3-7a38-4b33-8560-1ac5ff48f797', '박지민', 'FEMALE', '010-5001-6456',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_51caecf3-7a38-4b33-8560-1ac5ff48f797_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_51caecf3-7a38-4b33-8560-1ac5ff48f797_2.jpg'], '박지민님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 6097641, ARRAY['TUESDAY', 'FRIDAY', 'THURSDAY', 'MONDAY', 'WEDNESDAY', 'SATURDAY'],
    '2025-09-01', true,
    9, 4936, '경력', 35, '{"preferred_business_types": ["토크 바", "캐주얼 펍", "테라피"], "work_style_preferences": ["stable", "team_work", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '742719fe-913f-4c19-a671-8bfdf21381a4', '윤하은', 'FEMALE', '010-5002-2131',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_742719fe-913f-4c19-a671-8bfdf21381a4_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_742719fe-913f-4c19-a671-8bfdf21381a4_2.jpg'], '윤하은님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 4091782, ARRAY['SATURDAY', 'WEDNESDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-12', true,
    10, 425, '경력', 35, '{"preferred_business_types": ["토크 바", "캐주얼 펍", "카페"], "work_style_preferences": ["stable"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '26e1e69b-e130-4e85-8951-e000ee892659', '장민서', 'FEMALE', '010-5003-1257',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_26e1e69b-e130-4e85-8951-e000ee892659_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_26e1e69b-e130-4e85-8951-e000ee892659_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_26e1e69b-e130-4e85-8951-e000ee892659_3.jpg'], '장민서님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'TC', 6311179, ARRAY['SATURDAY', 'THURSDAY', 'MONDAY', 'TUESDAY', 'FRIDAY'],
    '2025-09-13', true,
    2, 3880, '경력', 20, '{"preferred_business_types": ["가라오케", "캐주얼 펍"], "work_style_preferences": ["flexible", "team_work", "stable"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '517dd9b9-727d-4fcd-802c-6ddeb2ffa738', '이예준', 'MALE', '010-5004-3838',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_517dd9b9-727d-4fcd-802c-6ddeb2ffa738_1.jpg'], '이예준님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'TC', 3095980, ARRAY['WEDNESDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-21', true,
    3, 247, '경력', 20, '{"preferred_business_types": ["토크 바", "모던 바", "테라피", "가라오케"], "work_style_preferences": ["stable", "individual", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '318a0171-e17d-4108-a9cf-cb9d0b60d80e', '장서준', 'MALE', '010-5005-4762',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_318a0171-e17d-4108-a9cf-cb9d0b60d80e_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_318a0171-e17d-4108-a9cf-cb9d0b60d80e_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_318a0171-e17d-4108-a9cf-cb9d0b60d80e_3.jpg'], '장서준님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 6287001, ARRAY['FRIDAY', 'SATURDAY', 'SUNDAY', 'TUESDAY', 'THURSDAY', 'WEDNESDAY'],
    '2025-09-24', false,
    5, 4922, '경력', 21, '{"preferred_business_types": ["캐주얼 펍", "카페"], "work_style_preferences": ["individual", "team_work", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'cd9aa417-82cc-459b-a6b4-b3425417a488', '정지호', 'MALE', '010-5006-2403',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_cd9aa417-82cc-459b-a6b4-b3425417a488_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_cd9aa417-82cc-459b-a6b4-b3425417a488_2.jpg'], '정지호님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'MONTHLY', 7644783, ARRAY['TUESDAY', 'SATURDAY', 'MONDAY', 'SUNDAY'],
    '2025-09-16', true,
    3, 2233, '경력', 24, '{"preferred_business_types": ["카페", "가라오케"], "work_style_preferences": ["stable", "individual", "team_work"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1bacd029-cd7e-489d-ae62-dd910a8bc675', '최하은', 'FEMALE', '010-5007-8317',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1bacd029-cd7e-489d-ae62-dd910a8bc675_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1bacd029-cd7e-489d-ae62-dd910a8bc675_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1bacd029-cd7e-489d-ae62-dd910a8bc675_3.jpg'], '최하은님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'TC', 4040850, ARRAY['SATURDAY', 'THURSDAY', 'MONDAY', 'WEDNESDAY', 'FRIDAY'],
    '2025-09-11', false,
    5, 4132, '경력', 22, '{"preferred_business_types": ["가라오케", "토크 바", "캐주얼 펍"], "work_style_preferences": ["individual", "flexible", "team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'e51d25fd-a728-4b00-a4e4-70b306baea55', '임시우', 'MALE', '010-5008-6918',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_e51d25fd-a728-4b00-a4e4-70b306baea55_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_e51d25fd-a728-4b00-a4e4-70b306baea55_2.jpg'], '임시우님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'TC', 7570138, ARRAY['THURSDAY', 'MONDAY', 'SATURDAY', 'SUNDAY', 'TUESDAY'],
    '2025-09-12', true,
    2, 4683, '경력', 20, '{"preferred_business_types": ["토크 바", "캐주얼 펍", "테라피"], "work_style_preferences": ["stable", "team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b9c4fec3-49c1-4e70-884c-f05f55052a84', '정지호', 'MALE', '010-5009-3648',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b9c4fec3-49c1-4e70-884c-f05f55052a84_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b9c4fec3-49c1-4e70-884c-f05f55052a84_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b9c4fec3-49c1-4e70-884c-f05f55052a84_3.jpg'], '정지호님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 4108049, ARRAY['SATURDAY', 'MONDAY', 'FRIDAY', 'SUNDAY'],
    '2025-09-10', true,
    6, 2160, '경력', 30, '{"preferred_business_types": ["모던 바", "토크 바", "가라오케"], "work_style_preferences": ["stable", "team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '3fb38fea-5ff5-4bff-b0ba-700d46b572cf', '강하은', 'FEMALE', '010-5010-2732',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_3fb38fea-5ff5-4bff-b0ba-700d46b572cf_1.jpg'], '강하은님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'TC', 4355570, ARRAY['THURSDAY', 'SATURDAY', 'WEDNESDAY', 'MONDAY', 'FRIDAY'],
    '2025-09-04', false,
    5, 1716, '경력', 31, '{"preferred_business_types": ["테라피", "캐주얼 펍"], "work_style_preferences": ["stable"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1579c7e6-470b-4847-8a12-1572484562e7', '정서연', 'FEMALE', '010-5011-2745',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1579c7e6-470b-4847-8a12-1572484562e7_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1579c7e6-470b-4847-8a12-1572484562e7_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1579c7e6-470b-4847-8a12-1572484562e7_3.jpg'], '정서연님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 4369359, ARRAY['MONDAY', 'FRIDAY', 'WEDNESDAY', 'THURSDAY'],
    '2025-09-09', false,
    10, 1209, '경력', 34, '{"preferred_business_types": ["테라피", "캐주얼 펍"], "work_style_preferences": ["flexible", "stable", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'cdcf3109-7441-4bf5-8d07-828b0ecbfa57', '장지유', 'FEMALE', '010-5012-3733',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_cdcf3109-7441-4bf5-8d07-828b0ecbfa57_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_cdcf3109-7441-4bf5-8d07-828b0ecbfa57_2.jpg'], '장지유님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'TC', 7792020, ARRAY['TUESDAY', 'FRIDAY', 'THURSDAY', 'SATURDAY', 'WEDNESDAY', 'SUNDAY'],
    '2025-09-26', false,
    2, 2130, '경력', 30, '{"preferred_business_types": ["토크 바", "캐주얼 펍"], "work_style_preferences": ["stable", "flexible", "team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'c160979d-349d-4382-b2e6-ae3ddf998faa', '최채원', 'FEMALE', '010-5013-3684',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_c160979d-349d-4382-b2e6-ae3ddf998faa_1.jpg'], '최채원님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 6380580, ARRAY['FRIDAY', 'MONDAY', 'THURSDAY', 'SATURDAY', 'TUESDAY', 'WEDNESDAY'],
    '2025-09-07', true,
    7, 3367, '경력', 32, '{"preferred_business_types": ["가라오케", "토크 바"], "work_style_preferences": ["individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '68384370-1ba4-40cc-a1e4-78b002ce16fb', '조지호', 'MALE', '010-5014-3761',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_68384370-1ba4-40cc-a1e4-78b002ce16fb_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_68384370-1ba4-40cc-a1e4-78b002ce16fb_2.jpg'], '조지호님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 3092846, ARRAY['FRIDAY', 'TUESDAY', 'MONDAY', 'SATURDAY', 'SUNDAY', 'THURSDAY'],
    '2025-09-12', true,
    8, 4285, '경력', 23, '{"preferred_business_types": ["가라오케", "카페", "테라피"], "work_style_preferences": ["team_work", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', '이하준', 'MALE', '010-5015-7113',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3_1.jpg'], '이하준님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 6146210, ARRAY['TUESDAY', 'SATURDAY', 'SUNDAY', 'MONDAY'],
    '2025-09-25', true,
    3, 39, '경력', 20, '{"preferred_business_types": ["토크 바", "테라피", "카페", "모던 바"], "work_style_preferences": ["individual", "team_work", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '966e6948-7c29-4e55-b0c4-00bee2e629d9', '김예준', 'MALE', '010-5016-2510',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_966e6948-7c29-4e55-b0c4-00bee2e629d9_1.jpg'], '김예준님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 5600631, ARRAY['SATURDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-20', true,
    8, 4148, '경력', 32, '{"preferred_business_types": ["가라오케", "테라피"], "work_style_preferences": ["stable", "flexible", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '6555ad3d-d062-4b5c-a586-7953ea28cfd5', '강서윤', 'FEMALE', '010-5017-2118',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_6555ad3d-d062-4b5c-a586-7953ea28cfd5_1.jpg'], '강서윤님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 6342476, ARRAY['TUESDAY', 'SUNDAY', 'THURSDAY', 'WEDNESDAY'],
    '2025-09-02', true,
    6, 679, '경력', 31, '{"preferred_business_types": ["카페", "캐주얼 펍", "가라오케", "테라피"], "work_style_preferences": ["flexible", "team_work", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', '이지호', 'MALE', '010-5018-4970',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_670977a7-a1c9-4c3b-aeb8-a6fc484e0a19_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_670977a7-a1c9-4c3b-aeb8-a6fc484e0a19_2.jpg'], '이지호님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'TC', 7902657, ARRAY['SATURDAY', 'THURSDAY', 'WEDNESDAY', 'SUNDAY', 'FRIDAY'],
    '2025-09-16', false,
    4, 2497, '경력', 26, '{"preferred_business_types": ["모던 바", "토크 바", "캐주얼 펍"], "work_style_preferences": ["team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b4162826-f99b-489a-a2c7-02ed18284b07', '정서현', 'FEMALE', '010-5019-9848',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b4162826-f99b-489a-a2c7-02ed18284b07_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b4162826-f99b-489a-a2c7-02ed18284b07_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b4162826-f99b-489a-a2c7-02ed18284b07_3.jpg'], '정서현님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 4537715, ARRAY['MONDAY', 'SUNDAY', 'WEDNESDAY'],
    '2025-09-27', true,
    3, 1481, '경력', 27, '{"preferred_business_types": ["토크 바", "가라오케"], "work_style_preferences": ["team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', '김지호', 'MALE', '010-5020-9729',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf_2.jpg'], '김지호님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'TC', 3143412, ARRAY['SATURDAY', 'MONDAY', 'THURSDAY'],
    '2025-09-19', false,
    5, 172, '경력', 24, '{"preferred_business_types": ["테라피", "카페", "캐주얼 펍"], "work_style_preferences": ["flexible", "team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '222c926d-011d-4f29-9b97-2e9d870b4369', '정민준', 'MALE', '010-5021-7383',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_222c926d-011d-4f29-9b97-2e9d870b4369_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_222c926d-011d-4f29-9b97-2e9d870b4369_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_222c926d-011d-4f29-9b97-2e9d870b4369_3.jpg'], '정민준님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'DAILY', 6406453, ARRAY['SUNDAY', 'FRIDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'MONDAY'],
    '2025-09-22', false,
    10, 4157, '경력', 26, '{"preferred_business_types": ["캐주얼 펍", "모던 바", "카페"], "work_style_preferences": ["flexible", "stable"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '4184fe09-8409-436a-b5ec-4155c5f82426', '최도윤', 'MALE', '010-5022-4706',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_4184fe09-8409-436a-b5ec-4155c5f82426_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_4184fe09-8409-436a-b5ec-4155c5f82426_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_4184fe09-8409-436a-b5ec-4155c5f82426_3.jpg'], '최도윤님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 3771500, ARRAY['WEDNESDAY', 'SATURDAY', 'TUESDAY', 'THURSDAY'],
    '2025-09-05', true,
    9, 2892, '경력', 24, '{"preferred_business_types": ["가라오케", "테라피"], "work_style_preferences": ["team_work", "flexible", "stable"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', '김서연', 'FEMALE', '010-5023-9955',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c_2.jpg'], '김서연님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 3919613, ARRAY['SATURDAY', 'SUNDAY', 'MONDAY'],
    '2025-09-01', true,
    4, 4604, '경력', 25, '{"preferred_business_types": ["토크 바", "캐주얼 펍", "모던 바"], "work_style_preferences": ["stable"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '8a12d7f4-5fc3-46ee-98e3-6306cc03955c', '강우진', 'MALE', '010-5024-9109',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_8a12d7f4-5fc3-46ee-98e3-6306cc03955c_1.jpg'], '강우진님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 2625234, ARRAY['TUESDAY', 'SUNDAY', 'WEDNESDAY', 'THURSDAY', 'MONDAY'],
    '2025-09-06', false,
    5, 2311, '경력', 25, '{"preferred_business_types": ["테라피", "토크 바", "모던 바", "카페"], "work_style_preferences": ["stable", "individual", "flexible"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '33291db2-690a-43ae-bb34-45c2b30d5402', '최지우', 'FEMALE', '010-5025-6633',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_33291db2-690a-43ae-bb34-45c2b30d5402_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_33291db2-690a-43ae-bb34-45c2b30d5402_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_33291db2-690a-43ae-bb34-45c2b30d5402_3.jpg'], '최지우님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'TC', 2809653, ARRAY['THURSDAY', 'SATURDAY', 'FRIDAY', 'WEDNESDAY'],
    '2025-09-09', false,
    9, 3567, '경력', 33, '{"preferred_business_types": ["가라오케", "캐주얼 펍", "토크 바", "테라피"], "work_style_preferences": ["flexible", "individual"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'aa7945c1-5e43-4465-b3e8-084065baa034', '강주원', 'MALE', '010-5026-7396',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_aa7945c1-5e43-4465-b3e8-084065baa034_1.jpg'], '강주원님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 4121006, ARRAY['MONDAY', 'FRIDAY', 'WEDNESDAY', 'SUNDAY'],
    '2025-09-06', false,
    6, 3406, '경력', 22, '{"preferred_business_types": ["캐주얼 펍", "가라오케"], "work_style_preferences": ["stable", "individual", "team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '31498511-39ba-49a9-a95f-473bf3cba204', '정예준', 'MALE', '010-5027-3237',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_31498511-39ba-49a9-a95f-473bf3cba204_1.jpg'], '정예준님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 4437953, ARRAY['SUNDAY', 'FRIDAY', 'THURSDAY', 'MONDAY'],
    '2025-09-19', true,
    1, 27, '경력', 35, '{"preferred_business_types": ["모던 바", "카페", "캐주얼 펍", "가라오케"], "work_style_preferences": ["stable", "team_work", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '96da66f5-ed48-4437-a173-91d298cad953', '장서윤', 'FEMALE', '010-5028-6135',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_96da66f5-ed48-4437-a173-91d298cad953_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_96da66f5-ed48-4437-a173-91d298cad953_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_96da66f5-ed48-4437-a173-91d298cad953_3.jpg'], '장서윤님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'DAILY', 6480798, ARRAY['TUESDAY', 'MONDAY', 'WEDNESDAY', 'SATURDAY', 'THURSDAY', 'SUNDAY'],
    '2025-09-26', true,
    2, 4331, '경력', 24, '{"preferred_business_types": ["캐주얼 펍", "모던 바"], "work_style_preferences": ["team_work", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '609f1d81-d232-4610-8817-670f0869ce80', '윤예은', 'FEMALE', '010-5029-1031',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_609f1d81-d232-4610-8817-670f0869ce80_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_609f1d81-d232-4610-8817-670f0869ce80_2.jpg'], '윤예은님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 6136551, ARRAY['SUNDAY', 'TUESDAY', 'FRIDAY', 'THURSDAY', 'WEDNESDAY', 'MONDAY'],
    '2025-09-27', true,
    5, 823, '경력', 29, '{"preferred_business_types": ["가라오케", "토크 바"], "work_style_preferences": ["stable", "team_work", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'ae609368-fb4e-4ac3-a02d-42f3de07a8c0', '최채원', 'FEMALE', '010-5030-2703',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_ae609368-fb4e-4ac3-a02d-42f3de07a8c0_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_ae609368-fb4e-4ac3-a02d-42f3de07a8c0_2.jpg'], '최채원님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 3151897, ARRAY['THURSDAY', 'SATURDAY', 'TUESDAY', 'FRIDAY'],
    '2025-09-12', false,
    8, 3640, '경력', 25, '{"preferred_business_types": ["캐주얼 펍", "토크 바", "카페", "테라피"], "work_style_preferences": ["team_work", "individual", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '49ea00cb-f4e0-405e-b745-5402eb76e49c', '최지호', 'MALE', '010-5031-3061',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_49ea00cb-f4e0-405e-b745-5402eb76e49c_1.jpg'], '최지호님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'DAILY', 6056281, ARRAY['MONDAY', 'FRIDAY', 'SUNDAY', 'TUESDAY', 'WEDNESDAY', 'SATURDAY'],
    '2025-09-27', false,
    1, 4615, '경력', 30, '{"preferred_business_types": ["테라피", "카페"], "work_style_preferences": ["stable"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'a1a65c99-70a7-4d4d-b82f-b2a483850166', '장서윤', 'FEMALE', '010-5032-1015',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_a1a65c99-70a7-4d4d-b82f-b2a483850166_1.jpg'], '장서윤님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'MONTHLY', 4298901, ARRAY['WEDNESDAY', 'SUNDAY', 'TUESDAY', 'MONDAY', 'THURSDAY'],
    '2025-09-11', true,
    7, 4757, '경력', 32, '{"preferred_business_types": ["가라오케", "테라피"], "work_style_preferences": ["individual", "flexible", "stable"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1703ca40-47ec-4409-bf67-ef8d21bafc45', '김시우', 'MALE', '010-5033-9007',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1703ca40-47ec-4409-bf67-ef8d21bafc45_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1703ca40-47ec-4409-bf67-ef8d21bafc45_2.jpg'], '김시우님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'DAILY', 5697999, ARRAY['MONDAY', 'FRIDAY', 'SUNDAY'],
    '2025-09-02', true,
    6, 1174, '경력', 28, '{"preferred_business_types": ["가라오케", "캐주얼 펍"], "work_style_preferences": ["stable", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '95d15044-cc17-41d8-84e0-43a0379aaaf8', '최지호', 'MALE', '010-5034-1035',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_95d15044-cc17-41d8-84e0-43a0379aaaf8_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_95d15044-cc17-41d8-84e0-43a0379aaaf8_2.jpg'], '최지호님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'TC', 5316383, ARRAY['WEDNESDAY', 'SATURDAY', 'FRIDAY', 'MONDAY', 'SUNDAY', 'TUESDAY'],
    '2025-09-17', true,
    9, 4922, '경력', 34, '{"preferred_business_types": ["가라오케", "모던 바", "캐주얼 펍", "테라피"], "work_style_preferences": ["team_work", "individual", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'fcf84023-7adb-4d28-a9fb-e4b7fe711e44', '이서연', 'FEMALE', '010-5035-8766',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_fcf84023-7adb-4d28-a9fb-e4b7fe711e44_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_fcf84023-7adb-4d28-a9fb-e4b7fe711e44_2.jpg'], '이서연님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 3054302, ARRAY['THURSDAY', 'WEDNESDAY', 'FRIDAY'],
    '2025-09-28', true,
    8, 128, '경력', 20, '{"preferred_business_types": ["테라피", "캐주얼 펍", "가라오케"], "work_style_preferences": ["team_work", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1ce3fab2-a50e-48f6-a917-3f1669e6ec91', '강지유', 'FEMALE', '010-5036-7403',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1ce3fab2-a50e-48f6-a917-3f1669e6ec91_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1ce3fab2-a50e-48f6-a917-3f1669e6ec91_2.jpg'], '강지유님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'DAILY', 6466493, ARRAY['SATURDAY', 'MONDAY', 'FRIDAY', 'WEDNESDAY', 'SUNDAY'],
    '2025-09-19', false,
    5, 3658, '경력', 20, '{"preferred_business_types": ["토크 바", "가라오케", "모던 바"], "work_style_preferences": ["stable"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', '장민서', 'FEMALE', '010-5037-7692',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_aa689ae8-6ce3-4fd6-a844-ad18949bb6f8_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_aa689ae8-6ce3-4fd6-a844-ad18949bb6f8_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_aa689ae8-6ce3-4fd6-a844-ad18949bb6f8_3.jpg'], '장민서님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 2722543, ARRAY['SATURDAY', 'MONDAY', 'TUESDAY', 'SUNDAY'],
    '2025-09-26', true,
    5, 4804, '경력', 23, '{"preferred_business_types": ["가라오케", "테라피", "모던 바"], "work_style_preferences": ["flexible", "team_work", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', '윤지호', 'MALE', '010-5038-3099',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540_1.jpg'], '윤지호님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'TC', 7478401, ARRAY['SUNDAY', 'FRIDAY', 'MONDAY', 'SATURDAY', 'TUESDAY'],
    '2025-09-20', true,
    6, 1911, '경력', 24, '{"preferred_business_types": ["가라오케", "테라피", "카페"], "work_style_preferences": ["stable", "individual"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '13caad73-e12f-4cd4-87b2-650da89b8f18', '박지유', 'FEMALE', '010-5039-5992',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_13caad73-e12f-4cd4-87b2-650da89b8f18_1.jpg'], '박지유님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 3408083, ARRAY['THURSDAY', 'TUESDAY', 'SATURDAY', 'WEDNESDAY'],
    '2025-08-31', true,
    6, 2867, '경력', 27, '{"preferred_business_types": ["모던 바", "카페", "캐주얼 펍"], "work_style_preferences": ["team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'd765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', '이주원', 'MALE', '010-5040-5609',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5_3.jpg'], '이주원님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'TC', 6032801, ARRAY['SUNDAY', 'WEDNESDAY', 'SATURDAY'],
    '2025-09-20', false,
    1, 2095, '경력', 33, '{"preferred_business_types": ["모던 바", "캐주얼 펍", "토크 바", "가라오케"], "work_style_preferences": ["stable", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '9acf9937-e3d4-4c8c-b78f-068fe711e10a', '박주원', 'MALE', '010-5041-4521',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_9acf9937-e3d4-4c8c-b78f-068fe711e10a_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_9acf9937-e3d4-4c8c-b78f-068fe711e10a_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_9acf9937-e3d4-4c8c-b78f-068fe711e10a_3.jpg'], '박주원님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'TC', 5885663, ARRAY['MONDAY', 'FRIDAY', 'THURSDAY'],
    '2025-09-03', true,
    8, 1477, '경력', 25, '{"preferred_business_types": ["토크 바", "모던 바"], "work_style_preferences": ["team_work", "stable"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '5760c600-4d37-49da-849d-64537cf049b8', '윤우진', 'MALE', '010-5042-3971',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_5760c600-4d37-49da-849d-64537cf049b8_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_5760c600-4d37-49da-849d-64537cf049b8_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_5760c600-4d37-49da-849d-64537cf049b8_3.jpg'], '윤우진님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'DAILY', 2698409, ARRAY['SUNDAY', 'THURSDAY', 'FRIDAY', 'MONDAY'],
    '2025-09-17', false,
    8, 2787, '경력', 30, '{"preferred_business_types": ["토크 바", "가라오케"], "work_style_preferences": ["stable"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b48536e9-cf57-438c-9100-f249595563b7', '임우진', 'MALE', '010-5043-7839',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b48536e9-cf57-438c-9100-f249595563b7_1.jpg'], '임우진님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'DAILY', 5448165, ARRAY['SATURDAY', 'WEDNESDAY', 'TUESDAY', 'SUNDAY'],
    '2025-09-25', true,
    3, 2195, '경력', 22, '{"preferred_business_types": ["카페", "테라피"], "work_style_preferences": ["team_work", "flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '932589e9-6c78-47f9-9382-4e09ea95c487', '조서현', 'FEMALE', '010-5044-5455',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_932589e9-6c78-47f9-9382-4e09ea95c487_1.jpg'], '조서현님은 열정적인 밤알바 스타입니다.',
    'PROFESSIONAL', 'TC', 7499927, ARRAY['SATURDAY', 'FRIDAY', 'TUESDAY', 'SUNDAY', 'MONDAY', 'WEDNESDAY'],
    '2025-09-07', false,
    8, 1411, '경력', 31, '{"preferred_business_types": ["캐주얼 펍", "가라오케"], "work_style_preferences": ["flexible", "individual"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '7516de8b-c125-464c-8016-cfbfab1b9761', '최민서', 'FEMALE', '010-5045-2537',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_7516de8b-c125-464c-8016-cfbfab1b9761_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_7516de8b-c125-464c-8016-cfbfab1b9761_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_7516de8b-c125-464c-8016-cfbfab1b9761_3.jpg'], '최민서님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'DAILY', 4521818, ARRAY['SUNDAY', 'TUESDAY', 'THURSDAY'],
    '2025-09-07', true,
    6, 2770, '경력', 24, '{"preferred_business_types": ["모던 바", "카페", "캐주얼 펍"], "work_style_preferences": ["stable"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '64cf1711-01de-4138-9bd9-a346b3b9bec8', '강서연', 'FEMALE', '010-5046-3760',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_64cf1711-01de-4138-9bd9-a346b3b9bec8_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_64cf1711-01de-4138-9bd9-a346b3b9bec8_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_64cf1711-01de-4138-9bd9-a346b3b9bec8_3.jpg'], '강서연님은 열정적인 밤알바 스타입니다.',
    'JUNIOR', 'TC', 4581156, ARRAY['SATURDAY', 'SUNDAY', 'MONDAY'],
    '2025-09-01', false,
    9, 1341, '경력', 25, '{"preferred_business_types": ["테라피", "모던 바", "토크 바", "가라오케"], "work_style_preferences": ["flexible"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', '최하준', 'MALE', '010-5047-6768',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_a2f4bb71-3a79-4cfd-9532-b8ee2dd20594_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_a2f4bb71-3a79-4cfd-9532-b8ee2dd20594_2.jpg'], '최하준님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 3983153, ARRAY['FRIDAY', 'WEDNESDAY', 'MONDAY', 'THURSDAY', 'SATURDAY', 'SUNDAY'],
    '2025-09-10', true,
    1, 2955, '경력', 34, '{"preferred_business_types": ["카페", "모던 바"], "work_style_preferences": ["team_work"], "location_flexibility": "high"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'e7738aab-df79-42b1-9560-1daa00484091', '윤건우', 'MALE', '010-5048-9362',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_e7738aab-df79-42b1-9560-1daa00484091_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_e7738aab-df79-42b1-9560-1daa00484091_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_e7738aab-df79-42b1-9560-1daa00484091_3.jpg'], '윤건우님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'MONTHLY', 6349177, ARRAY['TUESDAY', 'FRIDAY', 'WEDNESDAY', 'MONDAY', 'THURSDAY'],
    '2025-09-21', true,
    7, 141, '경력', 26, '{"preferred_business_types": ["테라피", "카페"], "work_style_preferences": ["stable"], "location_flexibility": "medium"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '9c189238-144d-4751-a9f7-18ed147b0ead', '이예준', 'MALE', '010-5049-7545',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_9c189238-144d-4751-a9f7-18ed147b0ead_1.jpg'], '이예준님은 열정적인 밤알바 스타입니다.',
    'SENIOR', 'TC', 5548783, ARRAY['WEDNESDAY', 'TUESDAY', 'THURSDAY', 'SUNDAY', 'FRIDAY', 'MONDAY'],
    '2025-09-10', false,
    1, 3204, '경력', 24, '{"preferred_business_types": ["캐주얼 펍", "모던 바", "토크 바", "테라피"], "work_style_preferences": ["team_work"], "location_flexibility": "low"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', '윤지유', 'FEMALE', '010-5050-2894',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b642a4f1-9cc2-402d-bd3f-b87bc3e88dde_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b642a4f1-9cc2-402d-bd3f-b87bc3e88dde_2.jpg'], '윤지유님은 열정적인 밤알바 스타입니다.',
    'NEWBIE', 'MONTHLY', 2692805, ARRAY['FRIDAY', 'THURSDAY', 'MONDAY'],
    '2025-09-07', true,
    3, 3013, '경력', 32, '{"preferred_business_types": ["가라오케", "카페"], "work_style_preferences": ["stable", "flexible", "team_work"], "location_flexibility": "low"}'
);

-- 4. 플레이스 프로필 30개
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '60b452ec-755a-4f39-ab24-ed54a9e94db1', '성수동 아틀리에 카페', '캐주얼 펍', '499-50-67127', true,
    '서울특별시 중구 역삼동 802-56', '이실장', '010-6001-3635',
    '성수동 아틀리에 카페는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_60b452ec-755a-4f39-ab24-ed54a9e94db1_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_60b452ec-755a-4f39-ab24-ed54a9e94db1_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    2598043, 5423537, 'SENIOR',
    NOW() - INTERVAL '23 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'aada73d8-7377-47a1-84e5-8848418e6ad3', '마포구 크리스탈 테라피', '카페', '865-12-45717', false,
    '서울특별시 중구 역삼동 460-2', '윤매니저', '010-6002-7506',
    '마포구 크리스탈 테라피는 카페 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_aada73d8-7377-47a1-84e5-8848418e6ad3_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_aada73d8-7377-47a1-84e5-8848418e6ad3_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_aada73d8-7377-47a1-84e5-8848418e6ad3_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2228858, 4343438, 'SENIOR',
    NOW() - INTERVAL '42 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'cb4adae4-e34f-428a-8c15-0d791b9651e5', '교대역 크라운 카페', '모던 바', '848-39-72343', false,
    '서울특별시 강남구 역삼동 433-31', '윤매니저', '010-6003-3860',
    '교대역 크라운 카페는 모던 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    3438433, 6993474, 'NEWBIE',
    NOW() - INTERVAL '55 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '3b0cf39c-b889-4ddd-be05-b42514ef22f9', '동대문 크리스탈 바', '캐주얼 펍', '320-57-83399', true,
    '서울특별시 마포구 역삼동 653-4', '김매니저', '010-6004-4613',
    '동대문 크리스탈 바는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    2568095, 5685112, 'NEWBIE',
    NOW() - INTERVAL '110 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'd9d96195-aa27-4f78-a23b-7cd820a1907c', '서초 플래티넘 테라피', '토크 바', '288-47-84499', false,
    '서울특별시 강남구 역삼동 215-52', '김매니저', '010-6005-8864',
    '서초 플래티넘 테라피는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    3017184, 5838742, 'SENIOR',
    NOW() - INTERVAL '97 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '14db3f09-abdd-46b0-964b-7febbec574a6', '홍대 로얄 토크 바', '캐주얼 펍', '855-72-36552', false,
    '서울특별시 서초구 역삼동 723-60', '장원장', '010-6006-9275',
    '홍대 로얄 토크 바는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_14db3f09-abdd-46b0-964b-7febbec574a6_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_14db3f09-abdd-46b0-964b-7febbec574a6_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    2710161, 5242843, 'PROFESSIONAL',
    NOW() - INTERVAL '161 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '7b8abab2-be87-4e4f-817c-2bc3c297baea', '홍대거리 프라임 바', '토크 바', '350-24-86683', true,
    '서울특별시 서초구 역삼동 89-99', '장원장', '010-6007-9456',
    '홍대거리 프라임 바는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    2905485, 6095502, 'NEWBIE',
    NOW() - INTERVAL '130 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '192825ce-0bd1-4407-ade9-78e35ffbcac8', '송파 엘리트 가라오케', '카페', '482-17-11806', true,
    '서울특별시 마포구 역삼동 61-76', '최사장', '010-6008-5207',
    '송파 엘리트 가라오케는 카페 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_192825ce-0bd1-4407-ade9-78e35ffbcac8_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_192825ce-0bd1-4407-ade9-78e35ffbcac8_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2228714, 4466406, 'JUNIOR',
    NOW() - INTERVAL '128 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '4423b96d-555e-40a4-9822-94a9e7470f7b', '강남역 로얄 클럽', '카페', '302-16-31821', false,
    '서울특별시 서초구 역삼동 240-68', '윤매니저', '010-6009-3174',
    '강남역 로얄 클럽는 카페 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    2242805, 4654365, 'SENIOR',
    NOW() - INTERVAL '106 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '47bcaa2f-c706-467a-b62d-0d165b285236', '상수동 엘리트 펍', '토크 바', '205-38-69653', false,
    '서울특별시 중구 역삼동 37-89', '박매니저', '010-6010-4330',
    '상수동 엘리트 펍는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3193947, 6225809, 'JUNIOR',
    NOW() - INTERVAL '54 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '8675ad69-5eae-4066-971e-048300b3e622', '건대 스타 펍', '테라피', '947-89-66246', false,
    '서울특별시 종로구 역삼동 799-29', '윤매니저', '010-6011-8169',
    '건대 스타 펍는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    4116428, 8884724, 'JUNIOR',
    NOW() - INTERVAL '71 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '840f0d29-7959-49d6-afe8-0d0277b6abff', '마포구 크리스탈 테라피', '캐주얼 펍', '301-24-14547', false,
    '서울특별시 강남구 역삼동 729-88', '박매니저', '010-6012-6583',
    '마포구 크리스탈 테라피는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_840f0d29-7959-49d6-afe8-0d0277b6abff_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_840f0d29-7959-49d6-afe8-0d0277b6abff_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2664302, 5364183, 'PROFESSIONAL',
    NOW() - INTERVAL '129 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '7867f93b-57b6-4b71-9337-f9349d624e14', '서초 플래티넘 테라피', '캐주얼 펍', '620-59-26413', false,
    '서울특별시 중구 역삼동 594-98', '최사장', '010-6013-8688',
    '서초 플래티넘 테라피는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    2735809, 5559296, 'JUNIOR',
    NOW() - INTERVAL '44 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '78a12a3d-1474-4653-b8fb-f05de1c3d63b', '노원 프라임 테라피', '토크 바', '601-96-99378', true,
    '서울특별시 서초구 역삼동 323-17', '이실장', '010-6014-3779',
    '노원 프라임 테라피는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    3153922, 5875459, 'SENIOR',
    NOW() - INTERVAL '115 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', '노원 프라임 테라피', '모던 바', '123-52-30648', true,
    '서울특별시 강남구 역삼동 842-26', '장원장', '010-6015-2390',
    '노원 프라임 테라피는 모던 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3238866, 6752166, 'JUNIOR',
    NOW() - INTERVAL '48 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', '건대 스타 펍', '카페', '396-69-99521', true,
    '서울특별시 마포구 역삼동 244-58', '최사장', '010-6016-9437',
    '건대 스타 펍는 카페 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    2205432, 4549559, 'SENIOR',
    NOW() - INTERVAL '41 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'ea261ead-93ef-4d7a-bec5-53c998256775', '명동 로얄 카페', '토크 바', '395-50-47792', false,
    '서울특별시 종로구 역삼동 79-46', '윤매니저', '010-6017-9810',
    '명동 로얄 카페는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3071638, 5874999, 'NEWBIE',
    NOW() - INTERVAL '77 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '471c7578-d00e-497b-8684-49478e200953', '서초 플래티넘 테라피', '테라피', '787-81-32136', false,
    '서울특별시 강남구 역삼동 522-14', '김매니저', '010-6018-8308',
    '서초 플래티넘 테라피는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3919118, 8561820, 'JUNIOR',
    NOW() - INTERVAL '100 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'e06e018c-331a-45ad-9489-9a45a94ee9e5', '홍대거리 프라임 바', '가라오케', '865-27-40627', false,
    '서울특별시 강남구 역삼동 159-78', '박매니저', '010-6019-6660',
    '홍대거리 프라임 바는 가라오케 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2235804, 4806991, 'SENIOR',
    NOW() - INTERVAL '81 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '3007a012-9378-4883-910b-53706fb1511c', '홍대거리 프라임 바', '토크 바', '125-46-10864', false,
    '서울특별시 종로구 역삼동 921-85', '최사장', '010-6020-9940',
    '홍대거리 프라임 바는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    3052700, 5967732, 'NEWBIE',
    NOW() - INTERVAL '145 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'da0213cf-a61c-4997-b3f9-551eb49eec7e', '홍대입구 플래티넘 가라오케', '캐주얼 펍', '769-50-78893', true,
    '서울특별시 서초구 역삼동 795-55', '김매니저', '010-6021-3016',
    '홍대입구 플래티넘 가라오케는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_4.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2665583, 5288943, 'JUNIOR',
    NOW() - INTERVAL '105 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'f9771f09-da7c-4760-9fa6-fac71fb45a3d', '홍익대 골든 바', '캐주얼 펍', '241-19-19482', true,
    '서울특별시 서초구 역삼동 759-61', '장원장', '010-6022-4476',
    '홍익대 골든 바는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_f9771f09-da7c-4760-9fa6-fac71fb45a3d_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_f9771f09-da7c-4760-9fa6-fac71fb45a3d_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_f9771f09-da7c-4760-9fa6-fac71fb45a3d_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    2721489, 5414799, 'JUNIOR',
    NOW() - INTERVAL '102 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '7c7e6398-40e3-4914-ad70-cd52909d46eb', '노원 프라임 테라피', '토크 바', '580-36-77001', false,
    '서울특별시 종로구 역삼동 546-38', '이실장', '010-6023-4267',
    '노원 프라임 테라피는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_5.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    2984354, 6122552, 'NEWBIE',
    NOW() - INTERVAL '180 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '415bcfba-d910-4074-befd-2a87956e5d7d', '건대 스타 펍', '테라피', '809-79-99924', false,
    '서울특별시 중구 역삼동 364-92', '최사장', '010-6024-9359',
    '건대 스타 펍는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    4139173, 8724703, 'SENIOR',
    NOW() - INTERVAL '10 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', '종로 다이아몬드 토크바', '카페', '342-73-11611', false,
    '서울특별시 용산구 역삼동 21-64', '이실장', '010-6025-4262',
    '종로 다이아몬드 토크바는 카페 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    2166193, 4478016, 'PROFESSIONAL',
    NOW() - INTERVAL '164 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'bb55d334-85e2-40c1-968b-3f67d4babd0b', '압구정 럭셔리 토크 바', '테라피', '474-22-92981', false,
    '서울특별시 종로구 역삼동 705-11', '이실장', '010-6026-6282',
    '압구정 럭셔리 토크 바는 테라피 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_2.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    3957138, 8700356, 'NEWBIE',
    NOW() - INTERVAL '163 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'fd960752-f0c8-492a-be2d-406316bbea03', '신촌 골든 바', '가라오케', '911-10-94148', true,
    '서울특별시 강남구 역삼동 698-55', '김매니저', '010-6027-3946',
    '신촌 골든 바는 가라오케 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_fd960752-f0c8-492a-be2d-406316bbea03_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fd960752-f0c8-492a-be2d-406316bbea03_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fd960752-f0c8-492a-be2d-406316bbea03_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '월급',
    2351956, 4986370, 'NEWBIE',
    NOW() - INTERVAL '21 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '9e8f606e-c7db-42d7-b654-6192f388faa8', '교대역 크라운 카페', '캐주얼 펍', '603-50-68414', false,
    '서울특별시 종로구 역삼동 265-95', '이실장', '010-6028-8109',
    '교대역 크라운 카페는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2701844, 5423418, 'SENIOR',
    NOW() - INTERVAL '70 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '3f262ca9-2013-40dd-9850-42ee401e0957', '홍대 로얄 토크 바', '캐주얼 펍', '296-84-58875', true,
    '서울특별시 마포구 역삼동 24-31', '박매니저', '010-6029-8386',
    '홍대 로얄 토크 바는 캐주얼 펍 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', '일급',
    2715646, 5462655, 'SENIOR',
    NOW() - INTERVAL '121 days', NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'fe7f3554-b44a-4090-87aa-b10f67192b42', '합정역 모던 카페', '토크 바', '706-49-70939', false,
    '서울특별시 종로구 역삼동 698-11', '이실장', '010-6030-3605',
    '합정역 모던 카페는 토크 바 전문 업체입니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_fe7f3554-b44a-4090-87aa-b10f67192b42_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fe7f3554-b44a-4090-87aa-b10f67192b42_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fe7f3554-b44a-4090-87aa-b10f67192b42_3.jpg'], '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}', 'TC',
    3082192, 6225463, 'SENIOR',
    NOW() - INTERVAL '116 days', NOW()
);

-- 5. 스타 속성 연결
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('26e1e69b-e130-4e85-8951-e000ee892659', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('26e1e69b-e130-4e85-8951-e000ee892659', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('26e1e69b-e130-4e85-8951-e000ee892659', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('3fb38fea-5ff5-4bff-b0ba-700d46b572cf', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('3fb38fea-5ff5-4bff-b0ba-700d46b572cf', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('68384370-1ba4-40cc-a1e4-78b002ce16fb', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('68384370-1ba4-40cc-a1e4-78b002ce16fb', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('68384370-1ba4-40cc-a1e4-78b002ce16fb', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('6555ad3d-d062-4b5c-a586-7953ea28cfd5', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('6555ad3d-d062-4b5c-a586-7953ea28cfd5', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('222c926d-011d-4f29-9b97-2e9d870b4369', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('222c926d-011d-4f29-9b97-2e9d870b4369', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('4184fe09-8409-436a-b5ec-4155c5f82426', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('4184fe09-8409-436a-b5ec-4155c5f82426', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('33291db2-690a-43ae-bb34-45c2b30d5402', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('33291db2-690a-43ae-bb34-45c2b30d5402', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('96da66f5-ed48-4437-a173-91d298cad953', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('96da66f5-ed48-4437-a173-91d298cad953', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('609f1d81-d232-4610-8817-670f0869ce80', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('609f1d81-d232-4610-8817-670f0869ce80', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('13caad73-e12f-4cd4-87b2-650da89b8f18', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('13caad73-e12f-4cd4-87b2-650da89b8f18', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('5760c600-4d37-49da-849d-64537cf049b8', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('5760c600-4d37-49da-849d-64537cf049b8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('5760c600-4d37-49da-849d-64537cf049b8', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b48536e9-cf57-438c-9100-f249595563b7', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b48536e9-cf57-438c-9100-f249595563b7', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', 23);

-- 6. 플레이스 산업 연결
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 5);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 5);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 5);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 2);

-- 7. 플레이스 특성 연결
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 38);

COMMIT;

-- 검증 쿼리
SELECT 'Total Users' as type, COUNT(*) as count FROM users WHERE email LIKE 'bamstar_large%@example.com';
SELECT 'Stars' as type, COUNT(*) as count FROM member_profiles mp JOIN users u ON mp.user_id = u.id WHERE u.email LIKE 'bamstar_large%@example.com';
SELECT 'Places' as type, COUNT(*) as count FROM place_profiles pp JOIN users u ON pp.user_id = u.id WHERE u.email LIKE 'bamstar_large%@example.com';
