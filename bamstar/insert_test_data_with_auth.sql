-- BamStar 테스트 데이터 삽입 (auth.users 포함)
-- 생성일: 2025-08-30

-- 1단계: auth.users에 테스트 유저 생성
INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at, 
    invited_at, confirmation_token, confirmation_sent_at, recovery_token, 
    recovery_sent_at, email_change_token_new, email_change, 
    email_change_sent_at, last_sign_in_at, raw_app_meta_data, 
    raw_user_meta_data, is_super_admin, created_at, updated_at, 
    phone, phone_confirmed_at, phone_change, phone_change_token, 
    phone_change_sent_at, email_change_token_current, 
    email_change_confirm_status, banned_until, reauthentication_token, 
    reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous
) 
SELECT 
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'bamstar' || generate_series(1,60) || '@example.com',
    '$2a$10$dummy.encrypted.password.hash.for.testing.only',
    NOW(),
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NOW() - INTERVAL '1 day' * (random() * 7)::int,
    '{"provider":"email","providers":["email"]}',
    '{"test":true}',
    false,
    NOW() - INTERVAL '1 day' * (random() * 180)::int,
    NOW(),
    NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, false, NULL, false;

-- 확인용: 생성된 auth.users 확인
-- SELECT COUNT(*) as created_auth_users FROM auth.users WHERE email LIKE 'bamstar%@example.com';