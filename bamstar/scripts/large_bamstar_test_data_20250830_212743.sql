-- BamStar 대량 테스트 데이터 삽입
-- 생성일: 2025-08-30 21:27:43
-- 스타 50명, 플레이스 30명

BEGIN;

-- 1. 사용자 데이터 (스타 50명)

INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '51caecf3-7a38-4b33-8560-1ac5ff48f797', 
    '스타#1', 
    'bamstar101@example.com', 
    '010-3000-9410', 
    2, 
    true, 
    NOW() - INTERVAL '81 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '742719fe-913f-4c19-a671-8bfdf21381a4', 
    '스타#2', 
    'bamstar102@example.com', 
    '010-3001-4839', 
    2, 
    true, 
    NOW() - INTERVAL '49 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '26e1e69b-e130-4e85-8951-e000ee892659', 
    '스타#3', 
    'bamstar103@example.com', 
    '010-3002-1156', 
    2, 
    true, 
    NOW() - INTERVAL '165 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 
    '스타#4', 
    'bamstar104@example.com', 
    '010-3003-2011', 
    2, 
    true, 
    NOW() - INTERVAL '19 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '318a0171-e17d-4108-a9cf-cb9d0b60d80e', 
    '스타#5', 
    'bamstar105@example.com', 
    '010-3004-6972', 
    2, 
    true, 
    NOW() - INTERVAL '137 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'cd9aa417-82cc-459b-a6b4-b3425417a488', 
    '스타#6', 
    'bamstar106@example.com', 
    '010-3005-8579', 
    2, 
    true, 
    NOW() - INTERVAL '114 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '1bacd029-cd7e-489d-ae62-dd910a8bc675', 
    '스타#7', 
    'bamstar107@example.com', 
    '010-3006-8677', 
    2, 
    true, 
    NOW() - INTERVAL '3 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'e51d25fd-a728-4b00-a4e4-70b306baea55', 
    '스타#8', 
    'bamstar108@example.com', 
    '010-3007-5332', 
    2, 
    true, 
    NOW() - INTERVAL '55 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'b9c4fec3-49c1-4e70-884c-f05f55052a84', 
    '스타#9', 
    'bamstar109@example.com', 
    '010-3008-6843', 
    2, 
    true, 
    NOW() - INTERVAL '180 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '3fb38fea-5ff5-4bff-b0ba-700d46b572cf', 
    '스타#10', 
    'bamstar110@example.com', 
    '010-3009-7572', 
    2, 
    true, 
    NOW() - INTERVAL '111 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '1579c7e6-470b-4847-8a12-1572484562e7', 
    '스타#11', 
    'bamstar111@example.com', 
    '010-3010-3802', 
    2, 
    true, 
    NOW() - INTERVAL '15 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 
    '스타#12', 
    'bamstar112@example.com', 
    '010-3011-3445', 
    2, 
    true, 
    NOW() - INTERVAL '147 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'c160979d-349d-4382-b2e6-ae3ddf998faa', 
    '스타#13', 
    'bamstar113@example.com', 
    '010-3012-4361', 
    2, 
    true, 
    NOW() - INTERVAL '21 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '68384370-1ba4-40cc-a1e4-78b002ce16fb', 
    '스타#14', 
    'bamstar114@example.com', 
    '010-3013-2808', 
    2, 
    true, 
    NOW() - INTERVAL '3 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 
    '스타#15', 
    'bamstar115@example.com', 
    '010-3014-3260', 
    2, 
    true, 
    NOW() - INTERVAL '141 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '966e6948-7c29-4e55-b0c4-00bee2e629d9', 
    '스타#16', 
    'bamstar116@example.com', 
    '010-3015-9654', 
    2, 
    true, 
    NOW() - INTERVAL '127 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '6555ad3d-d062-4b5c-a586-7953ea28cfd5', 
    '스타#17', 
    'bamstar117@example.com', 
    '010-3016-7036', 
    2, 
    true, 
    NOW() - INTERVAL '14 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 
    '스타#18', 
    'bamstar118@example.com', 
    '010-3017-2230', 
    2, 
    true, 
    NOW() - INTERVAL '179 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'b4162826-f99b-489a-a2c7-02ed18284b07', 
    '스타#19', 
    'bamstar119@example.com', 
    '010-3018-5205', 
    2, 
    true, 
    NOW() - INTERVAL '138 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 
    '스타#20', 
    'bamstar120@example.com', 
    '010-3019-7954', 
    2, 
    true, 
    NOW() - INTERVAL '44 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '222c926d-011d-4f29-9b97-2e9d870b4369', 
    '스타#21', 
    'bamstar121@example.com', 
    '010-3020-9285', 
    2, 
    true, 
    NOW() - INTERVAL '96 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '4184fe09-8409-436a-b5ec-4155c5f82426', 
    '스타#22', 
    'bamstar122@example.com', 
    '010-3021-2609', 
    2, 
    true, 
    NOW() - INTERVAL '31 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 
    '스타#23', 
    'bamstar123@example.com', 
    '010-3022-4809', 
    2, 
    true, 
    NOW() - INTERVAL '29 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 
    '스타#24', 
    'bamstar124@example.com', 
    '010-3023-3923', 
    2, 
    true, 
    NOW() - INTERVAL '116 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '33291db2-690a-43ae-bb34-45c2b30d5402', 
    '스타#25', 
    'bamstar125@example.com', 
    '010-3024-5458', 
    2, 
    true, 
    NOW() - INTERVAL '23 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'aa7945c1-5e43-4465-b3e8-084065baa034', 
    '스타#26', 
    'bamstar126@example.com', 
    '010-3025-5834', 
    2, 
    true, 
    NOW() - INTERVAL '97 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '31498511-39ba-49a9-a95f-473bf3cba204', 
    '스타#27', 
    'bamstar127@example.com', 
    '010-3026-8711', 
    2, 
    true, 
    NOW() - INTERVAL '98 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '96da66f5-ed48-4437-a173-91d298cad953', 
    '스타#28', 
    'bamstar128@example.com', 
    '010-3027-2948', 
    2, 
    true, 
    NOW() - INTERVAL '168 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '609f1d81-d232-4610-8817-670f0869ce80', 
    '스타#29', 
    'bamstar129@example.com', 
    '010-3028-7760', 
    2, 
    true, 
    NOW() - INTERVAL '3 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 
    '스타#30', 
    'bamstar130@example.com', 
    '010-3029-1880', 
    2, 
    true, 
    NOW() - INTERVAL '175 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '49ea00cb-f4e0-405e-b745-5402eb76e49c', 
    '스타#31', 
    'bamstar131@example.com', 
    '010-3030-1575', 
    2, 
    true, 
    NOW() - INTERVAL '108 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'a1a65c99-70a7-4d4d-b82f-b2a483850166', 
    '스타#32', 
    'bamstar132@example.com', 
    '010-3031-7650', 
    2, 
    true, 
    NOW() - INTERVAL '123 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '1703ca40-47ec-4409-bf67-ef8d21bafc45', 
    '스타#33', 
    'bamstar133@example.com', 
    '010-3032-2966', 
    2, 
    true, 
    NOW() - INTERVAL '131 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '95d15044-cc17-41d8-84e0-43a0379aaaf8', 
    '스타#34', 
    'bamstar134@example.com', 
    '010-3033-5572', 
    2, 
    true, 
    NOW() - INTERVAL '128 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 
    '스타#35', 
    'bamstar135@example.com', 
    '010-3034-6781', 
    2, 
    true, 
    NOW() - INTERVAL '148 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 
    '스타#36', 
    'bamstar136@example.com', 
    '010-3035-2287', 
    2, 
    true, 
    NOW() - INTERVAL '47 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 
    '스타#37', 
    'bamstar137@example.com', 
    '010-3036-8031', 
    2, 
    true, 
    NOW() - INTERVAL '169 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', 
    '스타#38', 
    'bamstar138@example.com', 
    '010-3037-7921', 
    2, 
    true, 
    NOW() - INTERVAL '45 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '13caad73-e12f-4cd4-87b2-650da89b8f18', 
    '스타#39', 
    'bamstar139@example.com', 
    '010-3038-7245', 
    2, 
    true, 
    NOW() - INTERVAL '1 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'd765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', 
    '스타#40', 
    'bamstar140@example.com', 
    '010-3039-7039', 
    2, 
    true, 
    NOW() - INTERVAL '177 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '9acf9937-e3d4-4c8c-b78f-068fe711e10a', 
    '스타#41', 
    'bamstar141@example.com', 
    '010-3040-9974', 
    2, 
    true, 
    NOW() - INTERVAL '119 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '5760c600-4d37-49da-849d-64537cf049b8', 
    '스타#42', 
    'bamstar142@example.com', 
    '010-3041-2311', 
    2, 
    true, 
    NOW() - INTERVAL '28 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'b48536e9-cf57-438c-9100-f249595563b7', 
    '스타#43', 
    'bamstar143@example.com', 
    '010-3042-9871', 
    2, 
    true, 
    NOW() - INTERVAL '165 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '932589e9-6c78-47f9-9382-4e09ea95c487', 
    '스타#44', 
    'bamstar144@example.com', 
    '010-3043-5582', 
    2, 
    true, 
    NOW() - INTERVAL '25 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '7516de8b-c125-464c-8016-cfbfab1b9761', 
    '스타#45', 
    'bamstar145@example.com', 
    '010-3044-6113', 
    2, 
    true, 
    NOW() - INTERVAL '84 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '64cf1711-01de-4138-9bd9-a346b3b9bec8', 
    '스타#46', 
    'bamstar146@example.com', 
    '010-3045-2000', 
    2, 
    true, 
    NOW() - INTERVAL '128 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', 
    '스타#47', 
    'bamstar147@example.com', 
    '010-3046-7667', 
    2, 
    true, 
    NOW() - INTERVAL '180 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'e7738aab-df79-42b1-9560-1daa00484091', 
    '스타#48', 
    'bamstar148@example.com', 
    '010-3047-5695', 
    2, 
    true, 
    NOW() - INTERVAL '75 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '9c189238-144d-4751-a9f7-18ed147b0ead', 
    '스타#49', 
    'bamstar149@example.com', 
    '010-3048-7904', 
    2, 
    true, 
    NOW() - INTERVAL '25 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', 
    '스타#50', 
    'bamstar150@example.com', 
    '010-3049-8056', 
    2, 
    true, 
    NOW() - INTERVAL '166 days', 
    NOW()
);

-- 2. 사용자 데이터 (플레이스 30명)

INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '60b452ec-755a-4f39-ab24-ed54a9e94db1', 
    '플레이스#1', 
    'bamstar151@example.com', 
    '010-4000-5331', 
    3, 
    true, 
    NOW() - INTERVAL '128 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'aada73d8-7377-47a1-84e5-8848418e6ad3', 
    '플레이스#2', 
    'bamstar152@example.com', 
    '010-4001-7798', 
    3, 
    true, 
    NOW() - INTERVAL '18 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'cb4adae4-e34f-428a-8c15-0d791b9651e5', 
    '플레이스#3', 
    'bamstar153@example.com', 
    '010-4002-7342', 
    3, 
    true, 
    NOW() - INTERVAL '49 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '3b0cf39c-b889-4ddd-be05-b42514ef22f9', 
    '플레이스#4', 
    'bamstar154@example.com', 
    '010-4003-8197', 
    3, 
    true, 
    NOW() - INTERVAL '115 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'd9d96195-aa27-4f78-a23b-7cd820a1907c', 
    '플레이스#5', 
    'bamstar155@example.com', 
    '010-4004-2665', 
    3, 
    true, 
    NOW() - INTERVAL '93 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '14db3f09-abdd-46b0-964b-7febbec574a6', 
    '플레이스#6', 
    'bamstar156@example.com', 
    '010-4005-4996', 
    3, 
    true, 
    NOW() - INTERVAL '142 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '7b8abab2-be87-4e4f-817c-2bc3c297baea', 
    '플레이스#7', 
    'bamstar157@example.com', 
    '010-4006-4902', 
    3, 
    true, 
    NOW() - INTERVAL '147 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '192825ce-0bd1-4407-ade9-78e35ffbcac8', 
    '플레이스#8', 
    'bamstar158@example.com', 
    '010-4007-8852', 
    3, 
    true, 
    NOW() - INTERVAL '123 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '4423b96d-555e-40a4-9822-94a9e7470f7b', 
    '플레이스#9', 
    'bamstar159@example.com', 
    '010-4008-6805', 
    3, 
    true, 
    NOW() - INTERVAL '118 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '47bcaa2f-c706-467a-b62d-0d165b285236', 
    '플레이스#10', 
    'bamstar160@example.com', 
    '010-4009-6154', 
    3, 
    true, 
    NOW() - INTERVAL '65 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '8675ad69-5eae-4066-971e-048300b3e622', 
    '플레이스#11', 
    'bamstar161@example.com', 
    '010-4010-2141', 
    3, 
    true, 
    NOW() - INTERVAL '140 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '840f0d29-7959-49d6-afe8-0d0277b6abff', 
    '플레이스#12', 
    'bamstar162@example.com', 
    '010-4011-1830', 
    3, 
    true, 
    NOW() - INTERVAL '11 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '7867f93b-57b6-4b71-9337-f9349d624e14', 
    '플레이스#13', 
    'bamstar163@example.com', 
    '010-4012-4268', 
    3, 
    true, 
    NOW() - INTERVAL '98 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '78a12a3d-1474-4653-b8fb-f05de1c3d63b', 
    '플레이스#14', 
    'bamstar164@example.com', 
    '010-4013-9034', 
    3, 
    true, 
    NOW() - INTERVAL '174 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 
    '플레이스#15', 
    'bamstar165@example.com', 
    '010-4014-9949', 
    3, 
    true, 
    NOW() - INTERVAL '19 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 
    '플레이스#16', 
    'bamstar166@example.com', 
    '010-4015-4602', 
    3, 
    true, 
    NOW() - INTERVAL '156 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'ea261ead-93ef-4d7a-bec5-53c998256775', 
    '플레이스#17', 
    'bamstar167@example.com', 
    '010-4016-1844', 
    3, 
    true, 
    NOW() - INTERVAL '41 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '471c7578-d00e-497b-8684-49478e200953', 
    '플레이스#18', 
    'bamstar168@example.com', 
    '010-4017-2885', 
    3, 
    true, 
    NOW() - INTERVAL '177 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'e06e018c-331a-45ad-9489-9a45a94ee9e5', 
    '플레이스#19', 
    'bamstar169@example.com', 
    '010-4018-2093', 
    3, 
    true, 
    NOW() - INTERVAL '146 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '3007a012-9378-4883-910b-53706fb1511c', 
    '플레이스#20', 
    'bamstar170@example.com', 
    '010-4019-4117', 
    3, 
    true, 
    NOW() - INTERVAL '176 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'da0213cf-a61c-4997-b3f9-551eb49eec7e', 
    '플레이스#21', 
    'bamstar171@example.com', 
    '010-4020-3205', 
    3, 
    true, 
    NOW() - INTERVAL '39 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'f9771f09-da7c-4760-9fa6-fac71fb45a3d', 
    '플레이스#22', 
    'bamstar172@example.com', 
    '010-4021-5862', 
    3, 
    true, 
    NOW() - INTERVAL '159 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '7c7e6398-40e3-4914-ad70-cd52909d46eb', 
    '플레이스#23', 
    'bamstar173@example.com', 
    '010-4022-9953', 
    3, 
    true, 
    NOW() - INTERVAL '94 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '415bcfba-d910-4074-befd-2a87956e5d7d', 
    '플레이스#24', 
    'bamstar174@example.com', 
    '010-4023-7245', 
    3, 
    true, 
    NOW() - INTERVAL '94 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 
    '플레이스#25', 
    'bamstar175@example.com', 
    '010-4024-3192', 
    3, 
    true, 
    NOW() - INTERVAL '73 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'bb55d334-85e2-40c1-968b-3f67d4babd0b', 
    '플레이스#26', 
    'bamstar176@example.com', 
    '010-4025-9979', 
    3, 
    true, 
    NOW() - INTERVAL '86 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'fd960752-f0c8-492a-be2d-406316bbea03', 
    '플레이스#27', 
    'bamstar177@example.com', 
    '010-4026-2277', 
    3, 
    true, 
    NOW() - INTERVAL '122 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '9e8f606e-c7db-42d7-b654-6192f388faa8', 
    '플레이스#28', 
    'bamstar178@example.com', 
    '010-4027-4606', 
    3, 
    true, 
    NOW() - INTERVAL '55 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    '3f262ca9-2013-40dd-9850-42ee401e0957', 
    '플레이스#29', 
    'bamstar179@example.com', 
    '010-4028-7549', 
    3, 
    true, 
    NOW() - INTERVAL '82 days', 
    NOW()
);
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES (
    'fe7f3554-b44a-4090-87aa-b10f67192b42', 
    '플레이스#30', 
    'bamstar180@example.com', 
    '010-4029-7661', 
    3, 
    true, 
    NOW() - INTERVAL '159 days', 
    NOW()
);

-- 3. 스타 프로필 50명 생성

INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '51caecf3-7a38-4b33-8560-1ac5ff48f797',
    '서사랑',
    'FEMALE',
    '010-5001-3400',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_51caecf3-7a38-4b33-8560-1ac5ff48f797_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_51caecf3-7a38-4b33-8560-1ac5ff48f797_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_51caecf3-7a38-4b33-8560-1ac5ff48f797_3.jpg'],
    '서사랑님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'MONTHLY',
    2957719,
    ARRAY['TUESDAY', 'WEDNESDAY', 'MONDAY'],
    '2025-09-10',
    false,
    6,
    50,
    '신입',
    27,
    '{"preferred_business_types": ["모던 바", "카페", "캐주얼 펍"], "work_style_preferences": ["individual"], "location_flexibility": "low", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '742719fe-913f-4c19-a671-8bfdf21381a4',
    '강유준',
    'MALE',
    '010-5002-2230',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_742719fe-913f-4c19-a671-8bfdf21381a4_1.jpg'],
    '강유준님은 senior 레벨의 열정적인 스타입니다.',
    'SENIOR',
    'TC',
    6101324,
    ARRAY['SATURDAY', 'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'FRIDAY'],
    '2025-09-18',
    false,
    6,
    2922,
    '경력',
    20,
    '{"preferred_business_types": ["캐주얼 펍", "토크 바", "가라오케", "모던 바"], "work_style_preferences": ["stable"], "location_flexibility": "medium", "preferred_work_hours": "flexible"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '26e1e69b-e130-4e85-8951-e000ee892659',
    '박시우',
    'MALE',
    '010-5003-2126',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_26e1e69b-e130-4e85-8951-e000ee892659_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_26e1e69b-e130-4e85-8951-e000ee892659_2.jpg'],
    '박시우님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'MONTHLY',
    7600613,
    ARRAY['FRIDAY', 'MONDAY', 'THURSDAY', 'WEDNESDAY'],
    '2025-09-27',
    false,
    8,
    2607,
    '신입',
    33,
    '{"preferred_business_types": ["가라오케", "토크 바", "캐주얼 펍", "카페"], "work_style_preferences": ["flexible", "individual", "team_work"], "location_flexibility": "low", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '517dd9b9-727d-4fcd-802c-6ddeb2ffa738',
    '한지유',
    'FEMALE',
    '010-5004-2656',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_517dd9b9-727d-4fcd-802c-6ddeb2ffa738_1.jpg'],
    '한지유님은 senior 레벨의 열정적인 스타입니다.',
    'SENIOR',
    'DAILY',
    5727280,
    ARRAY['MONDAY', 'FRIDAY', 'SATURDAY'],
    '2025-09-08',
    true,
    8,
    1179,
    '신입',
    20,
    '{"preferred_business_types": ["카페", "테라피", "모던 바"], "work_style_preferences": ["flexible"], "location_flexibility": "low", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '318a0171-e17d-4108-a9cf-cb9d0b60d80e',
    '송예린',
    'FEMALE',
    '010-5005-4055',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_318a0171-e17d-4108-a9cf-cb9d0b60d80e_1.jpg'],
    '송예린님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'DAILY',
    4320891,
    ARRAY['WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SUNDAY', 'MONDAY', 'SATURDAY'],
    '2025-09-09',
    true,
    3,
    4370,
    '경력',
    22,
    '{"preferred_business_types": ["캐주얼 펍", "테라피"], "work_style_preferences": ["team_work", "flexible"], "location_flexibility": "medium", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'cd9aa417-82cc-459b-a6b4-b3425417a488',
    '송승민',
    'MALE',
    '010-5006-9931',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_cd9aa417-82cc-459b-a6b4-b3425417a488_1.jpg'],
    '송승민님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'DAILY',
    7384072,
    ARRAY['SATURDAY', 'WEDNESDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-15',
    false,
    1,
    3275,
    '전문가',
    32,
    '{"preferred_business_types": ["모던 바", "테라피", "토크 바"], "work_style_preferences": ["flexible", "stable"], "location_flexibility": "high", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1bacd029-cd7e-489d-ae62-dd910a8bc675',
    '최지호',
    'MALE',
    '010-5007-5960',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1bacd029-cd7e-489d-ae62-dd910a8bc675_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1bacd029-cd7e-489d-ae62-dd910a8bc675_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1bacd029-cd7e-489d-ae62-dd910a8bc675_3.jpg'],
    '최지호님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'MONTHLY',
    7681926,
    ARRAY['FRIDAY', 'SUNDAY', 'SATURDAY', 'MONDAY'],
    '2025-09-28',
    true,
    8,
    4775,
    '경력',
    33,
    '{"preferred_business_types": ["토크 바", "모던 바", "테라피", "가라오케"], "work_style_preferences": ["team_work"], "location_flexibility": "medium", "preferred_work_hours": "flexible"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'e51d25fd-a728-4b00-a4e4-70b306baea55',
    '송유준',
    'MALE',
    '010-5008-3684',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_e51d25fd-a728-4b00-a4e4-70b306baea55_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_e51d25fd-a728-4b00-a4e4-70b306baea55_2.jpg'],
    '송유준님은 senior 레벨의 열정적인 스타입니다.',
    'SENIOR',
    'TC',
    5357582,
    ARRAY['THURSDAY', 'TUESDAY', 'SUNDAY', 'WEDNESDAY'],
    '2025-09-23',
    true,
    7,
    2598,
    '리더',
    23,
    '{"preferred_business_types": ["카페", "테라피", "캐주얼 펍", "가라오케"], "work_style_preferences": ["stable", "flexible", "team_work"], "location_flexibility": "high", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b9c4fec3-49c1-4e70-884c-f05f55052a84',
    '김예은',
    'FEMALE',
    '010-5009-9945',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b9c4fec3-49c1-4e70-884c-f05f55052a84_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b9c4fec3-49c1-4e70-884c-f05f55052a84_2.jpg'],
    '김예은님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'TC',
    6772491,
    ARRAY['WEDNESDAY', 'SUNDAY', 'MONDAY', 'THURSDAY', 'SATURDAY', 'TUESDAY'],
    '2025-08-31',
    false,
    5,
    3708,
    '신입',
    31,
    '{"preferred_business_types": ["카페", "모던 바", "캐주얼 펍", "토크 바"], "work_style_preferences": ["flexible"], "location_flexibility": "medium", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '3fb38fea-5ff5-4bff-b0ba-700d46b572cf',
    '윤채원',
    'FEMALE',
    '010-5010-6540',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_3fb38fea-5ff5-4bff-b0ba-700d46b572cf_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_3fb38fea-5ff5-4bff-b0ba-700d46b572cf_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_3fb38fea-5ff5-4bff-b0ba-700d46b572cf_3.jpg'],
    '윤채원님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'MONTHLY',
    2704028,
    ARRAY['SATURDAY', 'TUESDAY', 'SUNDAY', 'FRIDAY', 'MONDAY', 'WEDNESDAY'],
    '2025-09-12',
    false,
    5,
    3137,
    '리더',
    20,
    '{"preferred_business_types": ["캐주얼 펍", "모던 바", "가라오케"], "work_style_preferences": ["stable"], "location_flexibility": "medium", "preferred_work_hours": "flexible"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1579c7e6-470b-4847-8a12-1572484562e7',
    '홍사랑',
    'FEMALE',
    '010-5011-7839',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1579c7e6-470b-4847-8a12-1572484562e7_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1579c7e6-470b-4847-8a12-1572484562e7_2.jpg'],
    '홍사랑님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'DAILY',
    3792718,
    ARRAY['MONDAY', 'WEDNESDAY', 'SATURDAY', 'THURSDAY', 'FRIDAY'],
    '2025-09-24',
    false,
    7,
    2886,
    '신입',
    32,
    '{"preferred_business_types": ["가라오케", "카페", "테라피"], "work_style_preferences": ["stable", "team_work", "individual"], "location_flexibility": "low", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'cdcf3109-7441-4bf5-8d07-828b0ecbfa57',
    '권건우',
    'MALE',
    '010-5012-9669',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_cdcf3109-7441-4bf5-8d07-828b0ecbfa57_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_cdcf3109-7441-4bf5-8d07-828b0ecbfa57_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_cdcf3109-7441-4bf5-8d07-828b0ecbfa57_3.jpg'],
    '권건우님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'DAILY',
    3602898,
    ARRAY['MONDAY', 'THURSDAY', 'TUESDAY', 'SATURDAY', 'WEDNESDAY'],
    '2025-09-21',
    true,
    9,
    2102,
    '리더',
    29,
    '{"preferred_business_types": ["캐주얼 펍", "토크 바", "모던 바"], "work_style_preferences": ["individual", "flexible", "stable"], "location_flexibility": "high", "preferred_work_hours": "flexible"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'c160979d-349d-4382-b2e6-ae3ddf998faa',
    '이민서',
    'FEMALE',
    '010-5013-2775',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_c160979d-349d-4382-b2e6-ae3ddf998faa_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_c160979d-349d-4382-b2e6-ae3ddf998faa_2.jpg'],
    '이민서님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'DAILY',
    6584259,
    ARRAY['TUESDAY', 'THURSDAY', 'SATURDAY', 'MONDAY', 'FRIDAY'],
    '2025-09-05',
    false,
    9,
    2122,
    '경력',
    30,
    '{"preferred_business_types": ["토크 바", "가라오케", "테라피"], "work_style_preferences": ["stable", "individual"], "location_flexibility": "medium", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '68384370-1ba4-40cc-a1e4-78b002ce16fb',
    '신유나',
    'FEMALE',
    '010-5014-5652',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_68384370-1ba4-40cc-a1e4-78b002ce16fb_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_68384370-1ba4-40cc-a1e4-78b002ce16fb_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_68384370-1ba4-40cc-a1e4-78b002ce16fb_3.jpg'],
    '신유나님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'MONTHLY',
    2919469,
    ARRAY['SUNDAY', 'WEDNESDAY', 'TUESDAY', 'SATURDAY', 'FRIDAY', 'MONDAY'],
    '2025-09-21',
    true,
    4,
    3993,
    '경력',
    23,
    '{"preferred_business_types": ["테라피", "모던 바", "캐주얼 펍"], "work_style_preferences": ["stable", "flexible", "individual"], "location_flexibility": "medium", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3',
    '강유준',
    'MALE',
    '010-5015-5791',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3_3.jpg'],
    '강유준님은 senior 레벨의 열정적인 스타입니다.',
    'SENIOR',
    'DAILY',
    5389965,
    ARRAY['THURSDAY', 'SUNDAY', 'SATURDAY', 'TUESDAY'],
    '2025-09-26',
    true,
    8,
    2791,
    '경력',
    21,
    '{"preferred_business_types": ["가라오케", "토크 바", "캐주얼 펍"], "work_style_preferences": ["stable", "flexible", "individual"], "location_flexibility": "high", "preferred_work_hours": "flexible"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '966e6948-7c29-4e55-b0c4-00bee2e629d9',
    '윤유나',
    'FEMALE',
    '010-5016-6455',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_966e6948-7c29-4e55-b0c4-00bee2e629d9_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_966e6948-7c29-4e55-b0c4-00bee2e629d9_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_966e6948-7c29-4e55-b0c4-00bee2e629d9_3.jpg'],
    '윤유나님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'TC',
    7051592,
    ARRAY['FRIDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'MONDAY'],
    '2025-09-02',
    false,
    6,
    500,
    '경력',
    22,
    '{"preferred_business_types": ["카페", "가라오케"], "work_style_preferences": ["flexible"], "location_flexibility": "high", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '6555ad3d-d062-4b5c-a586-7953ea28cfd5',
    '서우진',
    'MALE',
    '010-5017-5901',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_6555ad3d-d062-4b5c-a586-7953ea28cfd5_1.jpg'],
    '서우진님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'MONTHLY',
    6587992,
    ARRAY['SATURDAY', 'TUESDAY', 'SUNDAY', 'WEDNESDAY', 'MONDAY'],
    '2025-09-21',
    true,
    1,
    570,
    '경력',
    25,
    '{"preferred_business_types": ["토크 바", "테라피", "카페"], "work_style_preferences": ["individual", "flexible"], "location_flexibility": "high", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '670977a7-a1c9-4c3b-aeb8-a6fc484e0a19',
    '전승민',
    'MALE',
    '010-5018-2635',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_670977a7-a1c9-4c3b-aeb8-a6fc484e0a19_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_670977a7-a1c9-4c3b-aeb8-a6fc484e0a19_2.jpg'],
    '전승민님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'DAILY',
    6654455,
    ARRAY['WEDNESDAY', 'MONDAY', 'THURSDAY'],
    '2025-09-29',
    true,
    2,
    2623,
    '경력',
    26,
    '{"preferred_business_types": ["캐주얼 펍", "모던 바", "테라피"], "work_style_preferences": ["stable", "flexible", "individual"], "location_flexibility": "low", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b4162826-f99b-489a-a2c7-02ed18284b07',
    '황서윤',
    'FEMALE',
    '010-5019-9141',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b4162826-f99b-489a-a2c7-02ed18284b07_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b4162826-f99b-489a-a2c7-02ed18284b07_2.jpg'],
    '황서윤님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'TC',
    7236831,
    ARRAY['SATURDAY', 'SUNDAY', 'THURSDAY', 'WEDNESDAY'],
    '2025-09-29',
    false,
    10,
    696,
    '리더',
    28,
    '{"preferred_business_types": ["모던 바", "카페", "캐주얼 펍"], "work_style_preferences": ["team_work", "flexible"], "location_flexibility": "high", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf',
    '한채원',
    'FEMALE',
    '010-5020-2588',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf_2.jpg'],
    '한채원님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'DAILY',
    3175683,
    ARRAY['THURSDAY', 'FRIDAY', 'MONDAY', 'WEDNESDAY', 'SATURDAY', 'TUESDAY'],
    '2025-09-16',
    true,
    1,
    3048,
    '리더',
    31,
    '{"preferred_business_types": ["카페", "토크 바", "모던 바", "테라피"], "work_style_preferences": ["flexible", "stable", "individual"], "location_flexibility": "low", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '222c926d-011d-4f29-9b97-2e9d870b4369',
    '조정우',
    'MALE',
    '010-5021-6044',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_222c926d-011d-4f29-9b97-2e9d870b4369_1.jpg'],
    '조정우님은 senior 레벨의 열정적인 스타입니다.',
    'SENIOR',
    'TC',
    5410298,
    ARRAY['SATURDAY', 'TUESDAY', 'THURSDAY', 'SUNDAY', 'MONDAY'],
    '2025-09-06',
    false,
    7,
    475,
    '신입',
    32,
    '{"preferred_business_types": ["토크 바", "가라오케", "테라피"], "work_style_preferences": ["team_work"], "location_flexibility": "low", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '4184fe09-8409-436a-b5ec-4155c5f82426',
    '안예은',
    'FEMALE',
    '010-5022-9785',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_4184fe09-8409-436a-b5ec-4155c5f82426_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_4184fe09-8409-436a-b5ec-4155c5f82426_2.jpg'],
    '안예은님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'TC',
    2697691,
    ARRAY['SUNDAY', 'MONDAY', 'THURSDAY', 'WEDNESDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-26',
    true,
    2,
    4354,
    '리더',
    30,
    '{"preferred_business_types": ["카페", "토크 바"], "work_style_preferences": ["team_work", "individual", "stable"], "location_flexibility": "high", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c',
    '신시은',
    'FEMALE',
    '010-5023-4694',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c_3.jpg'],
    '신시은님은 senior 레벨의 열정적인 스타입니다.',
    'SENIOR',
    'DAILY',
    5085865,
    ARRAY['THURSDAY', 'FRIDAY', 'TUESDAY', 'SUNDAY', 'MONDAY', 'WEDNESDAY'],
    '2025-09-22',
    true,
    7,
    2205,
    '리더',
    30,
    '{"preferred_business_types": ["가라오케", "캐주얼 펍", "카페"], "work_style_preferences": ["flexible", "stable"], "location_flexibility": "medium", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '8a12d7f4-5fc3-46ee-98e3-6306cc03955c',
    '이도윤',
    'MALE',
    '010-5024-2433',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_8a12d7f4-5fc3-46ee-98e3-6306cc03955c_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_8a12d7f4-5fc3-46ee-98e3-6306cc03955c_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_8a12d7f4-5fc3-46ee-98e3-6306cc03955c_3.jpg'],
    '이도윤님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'DAILY',
    4814144,
    ARRAY['SATURDAY', 'SUNDAY', 'TUESDAY'],
    '2025-09-09',
    false,
    3,
    1383,
    '경력',
    30,
    '{"preferred_business_types": ["모던 바", "캐주얼 펍", "테라피", "카페"], "work_style_preferences": ["individual", "flexible"], "location_flexibility": "high", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '33291db2-690a-43ae-bb34-45c2b30d5402',
    '한정우',
    'MALE',
    '010-5025-4291',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_33291db2-690a-43ae-bb34-45c2b30d5402_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_33291db2-690a-43ae-bb34-45c2b30d5402_2.jpg'],
    '한정우님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'MONTHLY',
    3844458,
    ARRAY['SATURDAY', 'SUNDAY', 'MONDAY', 'THURSDAY', 'FRIDAY', 'TUESDAY'],
    '2025-09-01',
    false,
    2,
    2862,
    '리더',
    28,
    '{"preferred_business_types": ["가라오케", "캐주얼 펍", "테라피"], "work_style_preferences": ["flexible", "team_work"], "location_flexibility": "high", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'aa7945c1-5e43-4465-b3e8-084065baa034',
    '오윤서',
    'FEMALE',
    '010-5026-4770',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_aa7945c1-5e43-4465-b3e8-084065baa034_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_aa7945c1-5e43-4465-b3e8-084065baa034_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_aa7945c1-5e43-4465-b3e8-084065baa034_3.jpg'],
    '오윤서님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'TC',
    7416816,
    ARRAY['THURSDAY', 'SATURDAY', 'SUNDAY', 'WEDNESDAY', 'MONDAY'],
    '2025-09-11',
    false,
    7,
    4788,
    '경력',
    25,
    '{"preferred_business_types": ["캐주얼 펍", "카페", "테라피"], "work_style_preferences": ["stable"], "location_flexibility": "low", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '31498511-39ba-49a9-a95f-473bf3cba204',
    '정유진',
    'FEMALE',
    '010-5027-7185',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_31498511-39ba-49a9-a95f-473bf3cba204_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_31498511-39ba-49a9-a95f-473bf3cba204_2.jpg'],
    '정유진님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'TC',
    7579594,
    ARRAY['SATURDAY', 'MONDAY', 'TUESDAY', 'THURSDAY'],
    '2025-09-29',
    false,
    3,
    4057,
    '리더',
    35,
    '{"preferred_business_types": ["카페", "모던 바", "테라피"], "work_style_preferences": ["stable", "flexible"], "location_flexibility": "low", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '96da66f5-ed48-4437-a173-91d298cad953',
    '최연우',
    'MALE',
    '010-5028-2449',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_96da66f5-ed48-4437-a173-91d298cad953_1.jpg'],
    '최연우님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'MONTHLY',
    4073356,
    ARRAY['FRIDAY', 'TUESDAY', 'SATURDAY', 'THURSDAY', 'SUNDAY'],
    '2025-09-07',
    true,
    5,
    4355,
    '리더',
    28,
    '{"preferred_business_types": ["모던 바", "테라피", "카페"], "work_style_preferences": ["team_work", "individual", "stable"], "location_flexibility": "medium", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '609f1d81-d232-4610-8817-670f0869ce80',
    '전민재',
    'MALE',
    '010-5029-4007',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_609f1d81-d232-4610-8817-670f0869ce80_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_609f1d81-d232-4610-8817-670f0869ce80_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_609f1d81-d232-4610-8817-670f0869ce80_3.jpg'],
    '전민재님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'TC',
    2613081,
    ARRAY['SATURDAY', 'THURSDAY', 'SUNDAY', 'FRIDAY', 'MONDAY'],
    '2025-09-04',
    false,
    8,
    4061,
    '신입',
    26,
    '{"preferred_business_types": ["모던 바", "카페"], "work_style_preferences": ["team_work", "stable"], "location_flexibility": "low", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'ae609368-fb4e-4ac3-a02d-42f3de07a8c0',
    '최시우',
    'MALE',
    '010-5030-9657',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_ae609368-fb4e-4ac3-a02d-42f3de07a8c0_1.jpg'],
    '최시우님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'TC',
    6829070,
    ARRAY['TUESDAY', 'FRIDAY', 'MONDAY', 'WEDNESDAY'],
    '2025-09-14',
    false,
    6,
    1565,
    '리더',
    30,
    '{"preferred_business_types": ["테라피", "모던 바", "캐주얼 펍"], "work_style_preferences": ["team_work", "stable"], "location_flexibility": "medium", "preferred_work_hours": "flexible"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '49ea00cb-f4e0-405e-b745-5402eb76e49c',
    '황채원',
    'FEMALE',
    '010-5031-1326',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_49ea00cb-f4e0-405e-b745-5402eb76e49c_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_49ea00cb-f4e0-405e-b745-5402eb76e49c_2.jpg'],
    '황채원님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'DAILY',
    6766087,
    ARRAY['THURSDAY', 'SATURDAY', 'WEDNESDAY', 'FRIDAY'],
    '2025-09-06',
    true,
    7,
    2498,
    '경력',
    21,
    '{"preferred_business_types": ["가라오케", "카페", "모던 바"], "work_style_preferences": ["flexible", "stable", "team_work"], "location_flexibility": "low", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'a1a65c99-70a7-4d4d-b82f-b2a483850166',
    '오윤서',
    'FEMALE',
    '010-5032-1990',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_a1a65c99-70a7-4d4d-b82f-b2a483850166_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_a1a65c99-70a7-4d4d-b82f-b2a483850166_2.jpg'],
    '오윤서님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'TC',
    3642520,
    ARRAY['FRIDAY', 'THURSDAY', 'SATURDAY', 'WEDNESDAY'],
    '2025-09-27',
    true,
    10,
    2880,
    '리더',
    32,
    '{"preferred_business_types": ["모던 바", "테라피"], "work_style_preferences": ["team_work"], "location_flexibility": "medium", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1703ca40-47ec-4409-bf67-ef8d21bafc45',
    '홍유나',
    'FEMALE',
    '010-5033-6950',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1703ca40-47ec-4409-bf67-ef8d21bafc45_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1703ca40-47ec-4409-bf67-ef8d21bafc45_2.jpg'],
    '홍유나님은 senior 레벨의 열정적인 스타입니다.',
    'SENIOR',
    'MONTHLY',
    5477380,
    ARRAY['WEDNESDAY', 'FRIDAY', 'MONDAY'],
    '2025-09-05',
    false,
    9,
    1569,
    '리더',
    23,
    '{"preferred_business_types": ["토크 바", "캐주얼 펍", "모던 바", "카페"], "work_style_preferences": ["individual"], "location_flexibility": "high", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '95d15044-cc17-41d8-84e0-43a0379aaaf8',
    '장주원',
    'MALE',
    '010-5034-3991',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_95d15044-cc17-41d8-84e0-43a0379aaaf8_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_95d15044-cc17-41d8-84e0-43a0379aaaf8_2.jpg'],
    '장주원님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'DAILY',
    4735219,
    ARRAY['THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY', 'MONDAY'],
    '2025-08-31',
    true,
    6,
    1968,
    '경력',
    31,
    '{"preferred_business_types": ["테라피", "가라오케"], "work_style_preferences": ["stable", "team_work"], "location_flexibility": "high", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'fcf84023-7adb-4d28-a9fb-e4b7fe711e44',
    '권예린',
    'FEMALE',
    '010-5035-6006',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_fcf84023-7adb-4d28-a9fb-e4b7fe711e44_1.jpg'],
    '권예린님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'DAILY',
    7337573,
    ARRAY['SATURDAY', 'FRIDAY', 'MONDAY'],
    '2025-09-05',
    false,
    7,
    738,
    '전문가',
    23,
    '{"preferred_business_types": ["카페", "테라피", "모던 바"], "work_style_preferences": ["stable"], "location_flexibility": "high", "preferred_work_hours": "flexible"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '1ce3fab2-a50e-48f6-a917-3f1669e6ec91',
    '최지우',
    'FEMALE',
    '010-5036-2750',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_1ce3fab2-a50e-48f6-a917-3f1669e6ec91_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_1ce3fab2-a50e-48f6-a917-3f1669e6ec91_2.jpg'],
    '최지우님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'MONTHLY',
    3749530,
    ARRAY['MONDAY', 'WEDNESDAY', 'FRIDAY', 'TUESDAY', 'THURSDAY', 'SATURDAY'],
    '2025-09-21',
    false,
    1,
    1766,
    '신입',
    20,
    '{"preferred_business_types": ["테라피", "가라오케", "카페", "캐주얼 펍"], "work_style_preferences": ["flexible"], "location_flexibility": "low", "preferred_work_hours": "flexible"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'aa689ae8-6ce3-4fd6-a844-ad18949bb6f8',
    '홍우진',
    'MALE',
    '010-5037-2200',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_aa689ae8-6ce3-4fd6-a844-ad18949bb6f8_1.jpg'],
    '홍우진님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'DAILY',
    7756509,
    ARRAY['WEDNESDAY', 'SUNDAY', 'SATURDAY', 'MONDAY', 'THURSDAY'],
    '2025-09-05',
    false,
    4,
    1297,
    '전문가',
    25,
    '{"preferred_business_types": ["카페", "캐주얼 펍", "토크 바"], "work_style_preferences": ["flexible", "individual", "team_work"], "location_flexibility": "high", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540',
    '박승현',
    'MALE',
    '010-5038-5012',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540_1.jpg'],
    '박승현님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'TC',
    6897420,
    ARRAY['SATURDAY', 'THURSDAY', 'MONDAY'],
    '2025-09-01',
    true,
    4,
    2000,
    '경력',
    26,
    '{"preferred_business_types": ["테라피", "모던 바", "캐주얼 펍", "토크 바"], "work_style_preferences": ["team_work", "stable"], "location_flexibility": "high", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '13caad73-e12f-4cd4-87b2-650da89b8f18',
    '임지민',
    'FEMALE',
    '010-5039-5167',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_13caad73-e12f-4cd4-87b2-650da89b8f18_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_13caad73-e12f-4cd4-87b2-650da89b8f18_2.jpg'],
    '임지민님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'TC',
    4115524,
    ARRAY['TUESDAY', 'THURSDAY', 'SATURDAY', 'SUNDAY', 'FRIDAY', 'MONDAY'],
    '2025-09-22',
    true,
    1,
    2163,
    '리더',
    20,
    '{"preferred_business_types": ["캐주얼 펍", "테라피", "가라오케", "카페"], "work_style_preferences": ["individual", "flexible"], "location_flexibility": "medium", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'd765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5',
    '이현우',
    'MALE',
    '010-5040-1792',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5_3.jpg'],
    '이현우님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'MONTHLY',
    2830453,
    ARRAY['MONDAY', 'THURSDAY', 'SUNDAY', 'SATURDAY', 'WEDNESDAY', 'FRIDAY'],
    '2025-09-06',
    true,
    2,
    4168,
    '경력',
    20,
    '{"preferred_business_types": ["토크 바", "캐주얼 펍", "카페"], "work_style_preferences": ["individual", "flexible"], "location_flexibility": "medium", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '9acf9937-e3d4-4c8c-b78f-068fe711e10a',
    '김다은',
    'FEMALE',
    '010-5041-5181',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_9acf9937-e3d4-4c8c-b78f-068fe711e10a_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_9acf9937-e3d4-4c8c-b78f-068fe711e10a_2.jpg'],
    '김다은님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'TC',
    4047725,
    ARRAY['SUNDAY', 'TUESDAY', 'THURSDAY'],
    '2025-09-02',
    false,
    6,
    4119,
    '신입',
    29,
    '{"preferred_business_types": ["카페", "가라오케", "모던 바"], "work_style_preferences": ["individual", "flexible", "team_work"], "location_flexibility": "low", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '5760c600-4d37-49da-849d-64537cf049b8',
    '한현우',
    'MALE',
    '010-5042-8765',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_5760c600-4d37-49da-849d-64537cf049b8_1.jpg'],
    '한현우님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'MONTHLY',
    6824069,
    ARRAY['MONDAY', 'SUNDAY', 'FRIDAY', 'THURSDAY', 'SATURDAY', 'TUESDAY'],
    '2025-09-08',
    true,
    1,
    4337,
    '신입',
    28,
    '{"preferred_business_types": ["캐주얼 펍", "카페"], "work_style_preferences": ["stable", "individual", "flexible"], "location_flexibility": "high", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b48536e9-cf57-438c-9100-f249595563b7',
    '서예준',
    'MALE',
    '010-5043-7185',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b48536e9-cf57-438c-9100-f249595563b7_1.jpg'],
    '서예준님은 senior 레벨의 열정적인 스타입니다.',
    'SENIOR',
    'DAILY',
    6344216,
    ARRAY['THURSDAY', 'WEDNESDAY', 'TUESDAY', 'MONDAY', 'SUNDAY'],
    '2025-09-25',
    false,
    9,
    2799,
    '전문가',
    33,
    '{"preferred_business_types": ["테라피", "카페", "모던 바", "토크 바"], "work_style_preferences": ["flexible", "team_work", "individual"], "location_flexibility": "low", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '932589e9-6c78-47f9-9382-4e09ea95c487',
    '조윤서',
    'FEMALE',
    '010-5044-7952',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_932589e9-6c78-47f9-9382-4e09ea95c487_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_932589e9-6c78-47f9-9382-4e09ea95c487_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_932589e9-6c78-47f9-9382-4e09ea95c487_3.jpg'],
    '조윤서님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'MONTHLY',
    3709945,
    ARRAY['SUNDAY', 'MONDAY', 'FRIDAY', 'WEDNESDAY'],
    '2025-09-20',
    false,
    10,
    4138,
    '경력',
    25,
    '{"preferred_business_types": ["모던 바", "카페", "토크 바", "캐주얼 펍"], "work_style_preferences": ["individual", "flexible", "team_work"], "location_flexibility": "high", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '7516de8b-c125-464c-8016-cfbfab1b9761',
    '장승민',
    'MALE',
    '010-5045-8585',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_7516de8b-c125-464c-8016-cfbfab1b9761_1.jpg'],
    '장승민님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'DAILY',
    7562466,
    ARRAY['THURSDAY', 'MONDAY', 'SATURDAY', 'SUNDAY', 'WEDNESDAY'],
    '2025-09-06',
    true,
    9,
    4750,
    '경력',
    26,
    '{"preferred_business_types": ["모던 바", "캐주얼 펍"], "work_style_preferences": ["individual", "team_work"], "location_flexibility": "high", "preferred_work_hours": "flexible"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '64cf1711-01de-4138-9bd9-a346b3b9bec8',
    '홍민서',
    'FEMALE',
    '010-5046-2739',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_64cf1711-01de-4138-9bd9-a346b3b9bec8_1.jpg'],
    '홍민서님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'MONTHLY',
    7477380,
    ARRAY['SUNDAY', 'WEDNESDAY', 'THURSDAY', 'SATURDAY', 'TUESDAY'],
    '2025-09-18',
    true,
    8,
    4385,
    '경력',
    22,
    '{"preferred_business_types": ["테라피", "카페"], "work_style_preferences": ["flexible", "team_work"], "location_flexibility": "low", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'a2f4bb71-3a79-4cfd-9532-b8ee2dd20594',
    '안서윤',
    'FEMALE',
    '010-5047-5273',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_a2f4bb71-3a79-4cfd-9532-b8ee2dd20594_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_a2f4bb71-3a79-4cfd-9532-b8ee2dd20594_2.jpg'],
    '안서윤님은 professional 레벨의 열정적인 스타입니다.',
    'PROFESSIONAL',
    'DAILY',
    7099950,
    ARRAY['TUESDAY', 'MONDAY', 'WEDNESDAY', 'SUNDAY'],
    '2025-09-03',
    true,
    10,
    1447,
    '신입',
    35,
    '{"preferred_business_types": ["가라오케", "캐주얼 펍", "모던 바"], "work_style_preferences": ["stable", "flexible"], "location_flexibility": "low", "preferred_work_hours": "late_night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'e7738aab-df79-42b1-9560-1daa00484091',
    '윤서윤',
    'FEMALE',
    '010-5048-2969',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_e7738aab-df79-42b1-9560-1daa00484091_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_e7738aab-df79-42b1-9560-1daa00484091_2.jpg'],
    '윤서윤님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'DAILY',
    3046029,
    ARRAY['WEDNESDAY', 'FRIDAY', 'SUNDAY', 'TUESDAY', 'MONDAY', 'SATURDAY'],
    '2025-09-02',
    false,
    7,
    1971,
    '리더',
    24,
    '{"preferred_business_types": ["테라피", "토크 바", "가라오케"], "work_style_preferences": ["stable"], "location_flexibility": "medium", "preferred_work_hours": "evening"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '9c189238-144d-4751-a9f7-18ed147b0ead',
    '권주원',
    'MALE',
    '010-5049-6628',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_9c189238-144d-4751-a9f7-18ed147b0ead_1.jpg'],
    '권주원님은 newbie 레벨의 열정적인 스타입니다.',
    'NEWBIE',
    'TC',
    2750936,
    ARRAY['THURSDAY', 'WEDNESDAY', 'SUNDAY', 'MONDAY', 'TUESDAY'],
    '2025-09-25',
    false,
    4,
    1684,
    '경력',
    33,
    '{"preferred_business_types": ["카페", "토크 바", "캐주얼 펍", "가라오케"], "work_style_preferences": ["stable", "team_work"], "location_flexibility": "medium", "preferred_work_hours": "night"}'
);
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    'b642a4f1-9cc2-402d-bd3f-b87bc3e88dde',
    '강시우',
    'MALE',
    '010-5050-1605',
    ARRAY['https://bamstar-profile.s3.amazonaws.com/star_b642a4f1-9cc2-402d-bd3f-b87bc3e88dde_1.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b642a4f1-9cc2-402d-bd3f-b87bc3e88dde_2.jpg', 'https://bamstar-profile.s3.amazonaws.com/star_b642a4f1-9cc2-402d-bd3f-b87bc3e88dde_3.jpg'],
    '강시우님은 junior 레벨의 열정적인 스타입니다.',
    'JUNIOR',
    'MONTHLY',
    4406229,
    ARRAY['FRIDAY', 'TUESDAY', 'WEDNESDAY', 'SUNDAY'],
    '2025-09-02',
    true,
    3,
    3097,
    '신입',
    23,
    '{"preferred_business_types": ["토크 바", "카페", "캐주얼 펍"], "work_style_preferences": ["team_work", "flexible", "individual"], "location_flexibility": "medium", "preferred_work_hours": "night"}'
);

-- 4. 플레이스 프로필 30명 생성

INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '60b452ec-755a-4f39-ab24-ed54a9e94db1',
    '연남동 에메랄드 테라피',
    '카페',
    '824-53-30663',
    false,
    '서울특별시 종로구 홍대동 347-42',
    '오사장',
    '010-6001-4267',
    '연남동 에메랄드 테라피는 카페 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_60b452ec-755a-4f39-ab24-ed54a9e94db1_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_60b452ec-755a-4f39-ab24-ed54a9e94db1_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    'TC',
    2193634,
    4699687,
    'NEWBIE',
    NOW() - INTERVAL '105 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'aada73d8-7377-47a1-84e5-8848418e6ad3',
    '등촌동 엘리트 카페',
    '캐주얼 펍',
    '521-81-41797',
    false,
    '서울특별시 강북구 홍대동 449-56',
    '오사장',
    '010-6002-9979',
    '등촌동 엘리트 카페는 캐주얼 펍 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_aada73d8-7377-47a1-84e5-8848418e6ad3_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_aada73d8-7377-47a1-84e5-8848418e6ad3_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '월급',
    2699879,
    5429572,
    'PROFESSIONAL',
    NOW() - INTERVAL '48 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'cb4adae4-e34f-428a-8c15-0d791b9651e5',
    '강서 프리미엄 바',
    '캐주얼 펍',
    '356-99-88594',
    true,
    '서울특별시 강북구 청담동 182-13',
    '이실장',
    '010-6003-3707',
    '강서 프리미엄 바는 캐주얼 펍 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_cb4adae4-e34f-428a-8c15-0d791b9651e5_5.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    'TC',
    2557895,
    5358331,
    'JUNIOR',
    NOW() - INTERVAL '106 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '3b0cf39c-b889-4ddd-be05-b42514ef22f9',
    '역삼 다이아몬드 카페',
    '캐주얼 펍',
    '456-60-39857',
    false,
    '서울특별시 동대문구 청담동 289-29',
    '강이사',
    '010-6004-9376',
    '역삼 다이아몬드 카페는 캐주얼 펍 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3b0cf39c-b889-4ddd-be05-b42514ef22f9_3.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2508170,
    5581391,
    'SENIOR',
    NOW() - INTERVAL '32 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'd9d96195-aa27-4f78-a23b-7cd820a1907c',
    '망원동 마스터 펍',
    '토크 바',
    '575-20-75496',
    true,
    '서울특별시 중구 압구정동 552-80',
    '오사장',
    '010-6005-5233',
    '망원동 마스터 펍는 토크 바 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_d9d96195-aa27-4f78-a23b-7cd820a1907c_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2973726,
    6270886,
    'PROFESSIONAL',
    NOW() - INTERVAL '123 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '14db3f09-abdd-46b0-964b-7febbec574a6',
    '목동 모던 토크바',
    '테라피',
    '415-17-26563',
    false,
    '서울특별시 동대문구 압구정동 263-92',
    '김매니저',
    '010-6006-7071',
    '목동 모던 토크바는 테라피 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_14db3f09-abdd-46b0-964b-7febbec574a6_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_14db3f09-abdd-46b0-964b-7febbec574a6_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    'TC',
    3997863,
    8661229,
    'PROFESSIONAL',
    NOW() - INTERVAL '18 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '7b8abab2-be87-4e4f-817c-2bc3c297baea',
    '미아역 프라임 카페',
    '카페',
    '761-40-54550',
    false,
    '서울특별시 중구 서초동 296-47',
    '박매니저',
    '010-6007-5991',
    '미아역 프라임 카페는 카페 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7b8abab2-be87-4e4f-817c-2bc3c297baea_3.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2068332,
    4679953,
    'PROFESSIONAL',
    NOW() - INTERVAL '173 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '192825ce-0bd1-4407-ade9-78e35ffbcac8',
    '노원구 모던 바',
    '가라오케',
    '810-74-51952',
    false,
    '서울특별시 서초구 청담동 182-66',
    '한실장',
    '010-6008-7686',
    '노원구 모던 바는 가라오케 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_192825ce-0bd1-4407-ade9-78e35ffbcac8_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_192825ce-0bd1-4407-ade9-78e35ffbcac8_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_192825ce-0bd1-4407-ade9-78e35ffbcac8_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_192825ce-0bd1-4407-ade9-78e35ffbcac8_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_192825ce-0bd1-4407-ade9-78e35ffbcac8_5.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '월급',
    2270752,
    4949905,
    'JUNIOR',
    NOW() - INTERVAL '17 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '4423b96d-555e-40a4-9822-94a9e7470f7b',
    '압구정역 엘리트 바',
    '캐주얼 펍',
    '898-91-70134',
    true,
    '서울특별시 동대문구 청담동 664-48',
    '박매니저',
    '010-6009-5948',
    '압구정역 엘리트 바는 캐주얼 펍 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_4423b96d-555e-40a4-9822-94a9e7470f7b_5.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2583746,
    5278214,
    'NEWBIE',
    NOW() - INTERVAL '1 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '47bcaa2f-c706-467a-b62d-0d165b285236',
    '서초역 퀸즈 카페',
    '카페',
    '426-50-64487',
    true,
    '서울특별시 중구 홍대동 975-94',
    '이실장',
    '010-6010-5967',
    '서초역 퀸즈 카페는 카페 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_47bcaa2f-c706-467a-b62d-0d165b285236_5.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    'TC',
    2176689,
    4377279,
    'SENIOR',
    NOW() - INTERVAL '119 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '8675ad69-5eae-4066-971e-048300b3e622',
    '강북구 럭셔리 토크바',
    '카페',
    '139-88-41001',
    false,
    '서울특별시 강북구 압구정동 370-78',
    '정부장',
    '010-6011-8284',
    '강북구 럭셔리 토크바는 카페 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_8675ad69-5eae-4066-971e-048300b3e622_4.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2029970,
    4247006,
    'SENIOR',
    NOW() - INTERVAL '162 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '840f0d29-7959-49d6-afe8-0d0277b6abff',
    '미아역 프라임 카페',
    '토크 바',
    '579-97-91672',
    false,
    '서울특별시 용산구 역삼동 543-51',
    '한실장',
    '010-6012-6533',
    '미아역 프라임 카페는 토크 바 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_840f0d29-7959-49d6-afe8-0d0277b6abff_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_840f0d29-7959-49d6-afe8-0d0277b6abff_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_840f0d29-7959-49d6-afe8-0d0277b6abff_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_840f0d29-7959-49d6-afe8-0d0277b6abff_4.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '월급',
    3155432,
    6123234,
    'JUNIOR',
    NOW() - INTERVAL '59 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '7867f93b-57b6-4b71-9337-f9349d624e14',
    '상수동 프리미엄 펍',
    '모던 바',
    '382-39-21826',
    true,
    '서울특별시 강남구 청담동 260-84',
    '최사장',
    '010-6013-8973',
    '상수동 프리미엄 펍는 모던 바 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7867f93b-57b6-4b71-9337-f9349d624e14_3.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    'TC',
    3380979,
    6799666,
    'JUNIOR',
    NOW() - INTERVAL '8 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '78a12a3d-1474-4653-b8fb-f05de1c3d63b',
    '강남 프리미엄 모던 바',
    '카페',
    '864-84-77965',
    true,
    '서울특별시 강북구 홍대동 947-75',
    '오사장',
    '010-6014-3996',
    '강남 프리미엄 모던 바는 카페 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_78a12a3d-1474-4653-b8fb-f05de1c3d63b_3.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '월급',
    2241172,
    4236384,
    'SENIOR',
    NOW() - INTERVAL '118 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '64b311f6-8b59-4d1f-8f3b-a7eef6e679e3',
    '중랑구 골든 카페',
    '테라피',
    '881-21-32553',
    true,
    '서울특별시 동대문구 서초동 619-82',
    '정부장',
    '010-6015-9518',
    '중랑구 골든 카페는 테라피 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_64b311f6-8b59-4d1f-8f3b-a7eef6e679e3_3.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '월급',
    3907059,
    8635864,
    'PROFESSIONAL',
    NOW() - INTERVAL '171 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30',
    '교대역 크라운 카페',
    '토크 바',
    '173-48-33372',
    false,
    '서울특별시 강남구 역삼동 969-60',
    '윤매니저',
    '010-6016-8387',
    '교대역 크라운 카페는 토크 바 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    3048509,
    5937706,
    'PROFESSIONAL',
    NOW() - INTERVAL '97 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'ea261ead-93ef-4d7a-bec5-53c998256775',
    '중랑구 골든 카페',
    '가라오케',
    '181-52-98890',
    true,
    '서울특별시 중구 청담동 501-6',
    '윤매니저',
    '010-6017-4060',
    '중랑구 골든 카페는 가라오케 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_ea261ead-93ef-4d7a-bec5-53c998256775_5.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    'TC',
    2212588,
    5244399,
    'JUNIOR',
    NOW() - INTERVAL '123 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '471c7578-d00e-497b-8684-49478e200953',
    '신사동 VIP 캐주얼 펍',
    '가라오케',
    '904-45-75997',
    false,
    '서울특별시 성북구 홍대동 268-56',
    '박매니저',
    '010-6018-4486',
    '신사동 VIP 캐주얼 펍는 가라오케 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_471c7578-d00e-497b-8684-49478e200953_3.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2404108,
    4836437,
    'NEWBIE',
    NOW() - INTERVAL '36 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'e06e018c-331a-45ad-9489-9a45a94ee9e5',
    '상수동 프리미엄 펍',
    '카페',
    '155-38-76238',
    true,
    '서울특별시 중구 홍대동 439-75',
    '김매니저',
    '010-6019-3340',
    '상수동 프리미엄 펍는 카페 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_e06e018c-331a-45ad-9489-9a45a94ee9e5_4.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2119447,
    4346648,
    'SENIOR',
    NOW() - INTERVAL '78 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '3007a012-9378-4883-910b-53706fb1511c',
    '상수역 다이아몬드 클럽',
    '카페',
    '477-18-33121',
    true,
    '서울특별시 동대문구 압구정동 791-8',
    '김매니저',
    '010-6020-2731',
    '상수역 다이아몬드 클럽는 카페 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3007a012-9378-4883-910b-53706fb1511c_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '월급',
    2220636,
    4310770,
    'NEWBIE',
    NOW() - INTERVAL '5 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'da0213cf-a61c-4997-b3f9-551eb49eec7e',
    '미아역 프라임 카페',
    '테라피',
    '950-20-52675',
    false,
    '서울특별시 동대문구 역삼동 652-1',
    '김매니저',
    '010-6021-2876',
    '미아역 프라임 카페는 테라피 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_da0213cf-a61c-4997-b3f9-551eb49eec7e_5.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    'TC',
    4162171,
    8835686,
    'JUNIOR',
    NOW() - INTERVAL '66 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'f9771f09-da7c-4760-9fa6-fac71fb45a3d',
    '서초역 퀸즈 카페',
    '테라피',
    '858-28-95193',
    false,
    '서울특별시 마포구 역삼동 529-79',
    '이실장',
    '010-6022-8121',
    '서초역 퀸즈 카페는 테라피 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_f9771f09-da7c-4760-9fa6-fac71fb45a3d_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_f9771f09-da7c-4760-9fa6-fac71fb45a3d_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '월급',
    3981416,
    8505157,
    'JUNIOR',
    NOW() - INTERVAL '75 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '7c7e6398-40e3-4914-ad70-cd52909d46eb',
    '청담 골든 가라오케',
    '카페',
    '747-65-72154',
    true,
    '서울특별시 성북구 홍대동 255-27',
    '박매니저',
    '010-6023-1229',
    '청담 골든 가라오케는 카페 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_7c7e6398-40e3-4914-ad70-cd52909d46eb_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2286312,
    4228390,
    'SENIOR',
    NOW() - INTERVAL '120 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '415bcfba-d910-4074-befd-2a87956e5d7d',
    '홍익대 골든 바',
    '테라피',
    '454-85-18398',
    false,
    '서울특별시 성북구 청담동 807-97',
    '윤매니저',
    '010-6024-2751',
    '홍익대 골든 바는 테라피 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_415bcfba-d910-4074-befd-2a87956e5d7d_5.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    4110342,
    8656954,
    'SENIOR',
    NOW() - INTERVAL '26 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '91c9b640-6d2e-41ee-94e9-dc70ce3e65a8',
    '압구정역 엘리트 바',
    '캐주얼 펍',
    '320-20-23072',
    true,
    '서울특별시 중구 서초동 296-65',
    '최사장',
    '010-6025-5425',
    '압구정역 엘리트 바는 캐주얼 펍 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_91c9b640-6d2e-41ee-94e9-dc70ce3e65a8_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    'TC',
    2709096,
    5681306,
    'SENIOR',
    NOW() - INTERVAL '65 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'bb55d334-85e2-40c1-968b-3f67d4babd0b',
    '서초 플래티넘 테라피',
    '테라피',
    '245-87-89711',
    true,
    '서울특별시 마포구 서초동 925-71',
    '한실장',
    '010-6026-6224',
    '서초 플래티넘 테라피는 테라피 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_bb55d334-85e2-40c1-968b-3f67d4babd0b_5.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '월급',
    4177905,
    8817688,
    'SENIOR',
    NOW() - INTERVAL '47 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'fd960752-f0c8-492a-be2d-406316bbea03',
    '미아역 프라임 카페',
    '가라오케',
    '344-91-26391',
    false,
    '서울특별시 종로구 청담동 141-70',
    '한실장',
    '010-6027-1372',
    '미아역 프라임 카페는 가라오케 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_fd960752-f0c8-492a-be2d-406316bbea03_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fd960752-f0c8-492a-be2d-406316bbea03_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fd960752-f0c8-492a-be2d-406316bbea03_3.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2416986,
    4879109,
    'SENIOR',
    NOW() - INTERVAL '87 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '9e8f606e-c7db-42d7-b654-6192f388faa8',
    '등촌동 엘리트 카페',
    '카페',
    '963-89-63527',
    false,
    '서울특별시 동대문구 홍대동 397-97',
    '장원장',
    '010-6028-8394',
    '등촌동 엘리트 카페는 카페 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_2.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_3.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_4.jpg', 'https://bamstar-place.s3.amazonaws.com/place_9e8f606e-c7db-42d7-b654-6192f388faa8_5.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    2136899,
    4293679,
    'NEWBIE',
    NOW() - INTERVAL '31 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '3f262ca9-2013-40dd-9850-42ee401e0957',
    '홍대거리 프라임 바',
    '토크 바',
    '408-23-71753',
    false,
    '서울특별시 동대문구 청담동 303-61',
    '정부장',
    '010-6029-4127',
    '홍대거리 프라임 바는 토크 바 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_3f262ca9-2013-40dd-9850-42ee401e0957_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    '일급',
    3009055,
    5848057,
    'PROFESSIONAL',
    NOW() - INTERVAL '138 days',
    NOW()
);
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    'fe7f3554-b44a-4090-87aa-b10f67192b42',
    '강북역 플래티넘 클럽',
    '모던 바',
    '957-77-63975',
    false,
    '서울특별시 용산구 서초동 359-16',
    '박매니저',
    '010-6030-3128',
    '강북역 플래티넘 클럽는 모던 바 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY['https://bamstar-place.s3.amazonaws.com/place_fe7f3554-b44a-4090-87aa-b10f67192b42_1.jpg', 'https://bamstar-place.s3.amazonaws.com/place_fe7f3554-b44a-4090-87aa-b10f67192b42_2.jpg'],
    '{"monday": {"open": "18:00", "close": "02:00"}, "tuesday": {"open": "18:00", "close": "02:00"}, "wednesday": {"open": "18:00", "close": "02:00"}, "thursday": {"open": "18:00", "close": "03:00"}, "friday": {"open": "18:00", "close": "04:00"}, "saturday": {"open": "18:00", "close": "04:00"}, "sunday": {"open": "18:00", "close": "01:00"}}',
    'TC',
    3347206,
    6765452,
    'NEWBIE',
    NOW() - INTERVAL '46 days',
    NOW()
);

-- 5. 스타 속성 연결 (각 스타마다 2-4개 스타일)
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('51caecf3-7a38-4b33-8560-1ac5ff48f797', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('742719fe-913f-4c19-a671-8bfdf21381a4', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('26e1e69b-e130-4e85-8951-e000ee892659', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('26e1e69b-e130-4e85-8951-e000ee892659', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('517dd9b9-727d-4fcd-802c-6ddeb2ffa738', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('318a0171-e17d-4108-a9cf-cb9d0b60d80e', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cd9aa417-82cc-459b-a6b4-b3425417a488', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1bacd029-cd7e-489d-ae62-dd910a8bc675', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e51d25fd-a728-4b00-a4e4-70b306baea55', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b9c4fec3-49c1-4e70-884c-f05f55052a84', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('3fb38fea-5ff5-4bff-b0ba-700d46b572cf', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('3fb38fea-5ff5-4bff-b0ba-700d46b572cf', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1579c7e6-470b-4847-8a12-1572484562e7', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('cdcf3109-7441-4bf5-8d07-828b0ecbfa57', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('c160979d-349d-4382-b2e6-ae3ddf998faa', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('68384370-1ba4-40cc-a1e4-78b002ce16fb', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('68384370-1ba4-40cc-a1e4-78b002ce16fb', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b3fbdb05-9ccd-4b2e-b87d-7fc019798bd3', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('966e6948-7c29-4e55-b0c4-00bee2e629d9', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('6555ad3d-d062-4b5c-a586-7953ea28cfd5', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('6555ad3d-d062-4b5c-a586-7953ea28cfd5', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('6555ad3d-d062-4b5c-a586-7953ea28cfd5', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('670977a7-a1c9-4c3b-aeb8-a6fc484e0a19', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b4162826-f99b-489a-a2c7-02ed18284b07', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('30ed3419-a29f-44c2-b9e9-b7e7f1f72eaf', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('222c926d-011d-4f29-9b97-2e9d870b4369', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('222c926d-011d-4f29-9b97-2e9d870b4369', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('4184fe09-8409-436a-b5ec-4155c5f82426', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('4184fe09-8409-436a-b5ec-4155c5f82426', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('4184fe09-8409-436a-b5ec-4155c5f82426', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('2c7f17f0-ae3b-451c-a3b3-cbdb94b1150c', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('8a12d7f4-5fc3-46ee-98e3-6306cc03955c', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('33291db2-690a-43ae-bb34-45c2b30d5402', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('33291db2-690a-43ae-bb34-45c2b30d5402', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('33291db2-690a-43ae-bb34-45c2b30d5402', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa7945c1-5e43-4465-b3e8-084065baa034', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('31498511-39ba-49a9-a95f-473bf3cba204', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('96da66f5-ed48-4437-a173-91d298cad953', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('96da66f5-ed48-4437-a173-91d298cad953', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('609f1d81-d232-4610-8817-670f0869ce80', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('609f1d81-d232-4610-8817-670f0869ce80', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('609f1d81-d232-4610-8817-670f0869ce80', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('ae609368-fb4e-4ac3-a02d-42f3de07a8c0', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('49ea00cb-f4e0-405e-b745-5402eb76e49c', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a1a65c99-70a7-4d4d-b82f-b2a483850166', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1703ca40-47ec-4409-bf67-ef8d21bafc45', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('95d15044-cc17-41d8-84e0-43a0379aaaf8', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('fcf84023-7adb-4d28-a9fb-e4b7fe711e44', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('1ce3fab2-a50e-48f6-a917-3f1669e6ec91', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('aa689ae8-6ce3-4fd6-a844-ad18949bb6f8', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9b31bb49-d938-4bb7-bbcf-8ea8c1ab9540', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('13caad73-e12f-4cd4-87b2-650da89b8f18', 20);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('13caad73-e12f-4cd4-87b2-650da89b8f18', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('d765c70e-d0f4-4a4b-a9a9-ca227ed3f9b5', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9acf9937-e3d4-4c8c-b78f-068fe711e10a', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('5760c600-4d37-49da-849d-64537cf049b8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('5760c600-4d37-49da-849d-64537cf049b8', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b48536e9-cf57-438c-9100-f249595563b7', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b48536e9-cf57-438c-9100-f249595563b7', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('932589e9-6c78-47f9-9382-4e09ea95c487', 17);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('7516de8b-c125-464c-8016-cfbfab1b9761', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', 21);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('64cf1711-01de-4138-9bd9-a346b3b9bec8', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('a2f4bb71-3a79-4cfd-9532-b8ee2dd20594', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 19);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('e7738aab-df79-42b1-9560-1daa00484091', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', 18);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('9c189238-144d-4751-a9f7-18ed147b0ead', 22);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', 23);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', 16);
INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('b642a4f1-9cc2-402d-bd3f-b87bc3e88dde', 20);

-- 6. 플레이스 산업 연결
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 5);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 2);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 1);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 6);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 5);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 4);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 3);
INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 4);

-- 7. 플레이스 특성 연결 (각 플레이스마다 2-4개 특성)
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('60b452ec-755a-4f39-ab24-ed54a9e94db1', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('aada73d8-7377-47a1-84e5-8848418e6ad3', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('cb4adae4-e34f-428a-8c15-0d791b9651e5', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3b0cf39c-b889-4ddd-be05-b42514ef22f9', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('d9d96195-aa27-4f78-a23b-7cd820a1907c', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('14db3f09-abdd-46b0-964b-7febbec574a6', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7b8abab2-be87-4e4f-817c-2bc3c297baea', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('192825ce-0bd1-4407-ade9-78e35ffbcac8', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('4423b96d-555e-40a4-9822-94a9e7470f7b', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('47bcaa2f-c706-467a-b62d-0d165b285236', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('8675ad69-5eae-4066-971e-048300b3e622', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('840f0d29-7959-49d6-afe8-0d0277b6abff', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7867f93b-57b6-4b71-9337-f9349d624e14', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('78a12a3d-1474-4653-b8fb-f05de1c3d63b', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('64b311f6-8b59-4d1f-8f3b-a7eef6e679e3', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('dfb1dbae-9ea5-44c0-a521-fcf55c1f6e30', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('ea261ead-93ef-4d7a-bec5-53c998256775', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('471c7578-d00e-497b-8684-49478e200953', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('e06e018c-331a-45ad-9489-9a45a94ee9e5', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3007a012-9378-4883-910b-53706fb1511c', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('da0213cf-a61c-4997-b3f9-551eb49eec7e', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('f9771f09-da7c-4760-9fa6-fac71fb45a3d', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('7c7e6398-40e3-4914-ad70-cd52909d46eb', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('415bcfba-d910-4074-befd-2a87956e5d7d', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('91c9b640-6d2e-41ee-94e9-dc70ce3e65a8', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('bb55d334-85e2-40c1-968b-3f67d4babd0b', 38);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 33);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fd960752-f0c8-492a-be2d-406316bbea03', 39);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('9e8f606e-c7db-42d7-b654-6192f388faa8', 36);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 34);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('3f262ca9-2013-40dd-9850-42ee401e0957', 31);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 37);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 35);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 32);
INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('fe7f3554-b44a-4090-87aa-b10f67192b42', 34);

COMMIT;

-- 검증 쿼리
SELECT 'Total Users' as type, COUNT(*) as count FROM users WHERE email LIKE 'bamstar%@example.com';
SELECT 'Stars' as type, COUNT(*) as count FROM member_profiles mp JOIN users u ON mp.user_id = u.id WHERE u.email LIKE 'bamstar%@example.com';
SELECT 'Places' as type, COUNT(*) as count FROM place_profiles pp JOIN users u ON pp.user_id = u.id WHERE u.email LIKE 'bamstar%@example.com';
SELECT 'Member Attributes' as type, COUNT(*) as count FROM member_attributes_link mal JOIN users u ON mal.member_user_id = u.id WHERE u.email LIKE 'bamstar%@example.com';
SELECT 'Place Industries' as type, COUNT(*) as count FROM place_industries pi JOIN users u ON pi.place_user_id = u.id WHERE u.email LIKE 'bamstar%@example.com';
SELECT 'Place Features' as type, COUNT(*) as count FROM place_attributes_link pal JOIN users u ON pal.place_user_id = u.id WHERE u.email LIKE 'bamstar%@example.com';
