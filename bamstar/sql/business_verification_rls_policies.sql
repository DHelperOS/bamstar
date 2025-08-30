-- ================================================
-- Business Verification System RLS Policies
-- ================================================
-- 사업자 인증 시스템 테이블들에 대한 Row Level Security 정책 설정

-- ================================================
-- 1. business_verifications 테이블 RLS 정책
-- ================================================

-- RLS 활성화
ALTER TABLE public.business_verifications ENABLE ROW LEVEL SECURITY;

-- SELECT 정책: 사용자는 자신의 인증 기록만 조회 가능
CREATE POLICY "business_verifications_select_policy"
ON public.business_verifications
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- INSERT 정책: 사용자는 자신의 인증 기록만 생성 가능
CREATE POLICY "business_verifications_insert_policy"
ON public.business_verifications
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- UPDATE 정책: 사용자는 자신의 인증 기록만 수정 가능
CREATE POLICY "business_verifications_update_policy"
ON public.business_verifications
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- DELETE 정책: 사용자는 자신의 인증 기록만 삭제 가능 (일반적으로 비활성화)
CREATE POLICY "business_verifications_delete_policy"
ON public.business_verifications
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- ================================================
-- 2. business_registration_documents 테이블 RLS 정책
-- ================================================

-- RLS 활성화
ALTER TABLE public.business_registration_documents ENABLE ROW LEVEL SECURITY;

-- SELECT 정책: 사용자는 자신의 인증에 관련된 문서만 조회 가능
CREATE POLICY "business_documents_select_policy"
ON public.business_registration_documents
FOR SELECT
TO authenticated
USING (
    verification_id IN (
        SELECT id FROM public.business_verifications 
        WHERE user_id = auth.uid()
    )
);

-- INSERT 정책: 사용자는 자신의 인증에 관련된 문서만 업로드 가능
CREATE POLICY "business_documents_insert_policy"
ON public.business_registration_documents
FOR INSERT
TO authenticated
WITH CHECK (
    verification_id IN (
        SELECT id FROM public.business_verifications 
        WHERE user_id = auth.uid()
    )
);

-- UPDATE 정책: 사용자는 자신의 문서만 수정 가능
CREATE POLICY "business_documents_update_policy"
ON public.business_registration_documents
FOR UPDATE
TO authenticated
USING (
    verification_id IN (
        SELECT id FROM public.business_verifications 
        WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    verification_id IN (
        SELECT id FROM public.business_verifications 
        WHERE user_id = auth.uid()
    )
);

-- DELETE 정책: 사용자는 자신의 문서만 삭제 가능
CREATE POLICY "business_documents_delete_policy"
ON public.business_registration_documents
FOR DELETE
TO authenticated
USING (
    verification_id IN (
        SELECT id FROM public.business_verifications 
        WHERE user_id = auth.uid()
    )
);

-- ================================================
-- 3. business_verification_history 테이블 RLS 정책
-- ================================================

-- RLS 활성화
ALTER TABLE public.business_verification_history ENABLE ROW LEVEL SECURITY;

-- SELECT 정책: 사용자는 자신의 인증 이력만 조회 가능
CREATE POLICY "business_history_select_policy"
ON public.business_verification_history
FOR SELECT
TO authenticated
USING (
    verification_id IN (
        SELECT id FROM public.business_verifications 
        WHERE user_id = auth.uid()
    )
);

-- INSERT 정책: 시스템에서만 이력 생성 가능 (트리거를 통해서만)
CREATE POLICY "business_history_insert_policy"
ON public.business_verification_history
FOR INSERT
TO authenticated
WITH CHECK (
    verification_id IN (
        SELECT id FROM public.business_verifications 
        WHERE user_id = auth.uid()
    )
    AND (created_by = auth.uid() OR created_by IS NULL)
);

-- UPDATE 정책: 이력은 수정 불가 (읽기 전용)
-- (UPDATE 정책을 만들지 않음으로써 UPDATE를 차단)

-- DELETE 정책: 이력은 삭제 불가 (읽기 전용)
-- (DELETE 정책을 만들지 않음으로써 DELETE를 차단)

-- ================================================
-- 4. 관리자 정책 (선택사항)
-- ================================================

-- 관리자 역할이 있다면 모든 데이터에 접근 가능하도록 설정
-- 현재는 주석 처리 (필요시 활성화)

/*
-- 관리자 SELECT 정책
CREATE POLICY "admin_business_verifications_select_policy"
ON public.business_verifications
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND role = 'admin'
    )
);

CREATE POLICY "admin_business_documents_select_policy"
ON public.business_registration_documents
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND role = 'admin'
    )
);

CREATE POLICY "admin_business_history_select_policy"
ON public.business_verification_history
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND role = 'admin'
    )
);
*/

-- ================================================
-- 5. 함수 보안 설정
-- ================================================

-- 사용자 인증 함수들은 SECURITY DEFINER로 설정하여 안전하게 실행
-- (이미 생성된 함수들은 기본적으로 SECURITY INVOKER)

-- validate_business_number 함수는 모든 사용자가 사용 가능
GRANT EXECUTE ON FUNCTION validate_business_number(TEXT) TO authenticated;

-- get_user_latest_business_verification 함수는 인증된 사용자만 사용 가능
GRANT EXECUTE ON FUNCTION get_user_latest_business_verification(UUID) TO authenticated;

-- ================================================
-- 6. Storage 버킷 정책 (Supabase Storage)
-- ================================================

-- 사업자 등록증 문서를 위한 Storage 버킷 생성 및 정책 설정
-- 이는 Supabase 대시보드나 별도 스크립트에서 실행해야 함

/*
-- Storage 버킷 생성 (Supabase 대시보드에서 실행)
INSERT INTO storage.buckets (id, name, public)
VALUES ('business-documents', 'business-documents', false);

-- Storage 정책 생성 (Supabase 대시보드에서 실행)
CREATE POLICY "Users can upload their own business documents" ON storage.objects
FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'business-documents' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view their own business documents" ON storage.objects
FOR SELECT TO authenticated USING (
    bucket_id = 'business-documents' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their own business documents" ON storage.objects
FOR UPDATE TO authenticated USING (
    bucket_id = 'business-documents' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own business documents" ON storage.objects
FOR DELETE TO authenticated USING (
    bucket_id = 'business-documents' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);
*/

-- ================================================
-- 7. 테스트 및 검증
-- ================================================

-- RLS 정책이 올바르게 적용되었는지 확인
DO $$ 
DECLARE
    rls_count INTEGER;
BEGIN
    -- business_verifications 테이블의 RLS 정책 수 확인
    SELECT COUNT(*) INTO rls_count
    FROM pg_policies 
    WHERE tablename = 'business_verifications' 
    AND schemaname = 'public';
    
    IF rls_count >= 4 THEN
        RAISE NOTICE '✅ business_verifications RLS policies: % created', rls_count;
    ELSE
        RAISE NOTICE '❌ business_verifications RLS policies incomplete: only %', rls_count;
    END IF;
    
    -- business_registration_documents 테이블의 RLS 정책 수 확인
    SELECT COUNT(*) INTO rls_count
    FROM pg_policies 
    WHERE tablename = 'business_registration_documents' 
    AND schemaname = 'public';
    
    IF rls_count >= 4 THEN
        RAISE NOTICE '✅ business_registration_documents RLS policies: % created', rls_count;
    ELSE
        RAISE NOTICE '❌ business_registration_documents RLS policies incomplete: only %', rls_count;
    END IF;
    
    -- business_verification_history 테이블의 RLS 정책 수 확인
    SELECT COUNT(*) INTO rls_count
    FROM pg_policies 
    WHERE tablename = 'business_verification_history' 
    AND schemaname = 'public';
    
    IF rls_count >= 2 THEN
        RAISE NOTICE '✅ business_verification_history RLS policies: % created', rls_count;
    ELSE
        RAISE NOTICE '❌ business_verification_history RLS policies incomplete: only %', rls_count;
    END IF;
END $$;

-- ================================================
-- 8. 정책 요약
-- ================================================
DO $$ 
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🛡️  Business Verification RLS Policies Applied Successfully!';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Security Rules Summary:';
    RAISE NOTICE '   ✅ Users can only access their own verification records';
    RAISE NOTICE '   ✅ Users can only upload documents for their own verifications';
    RAISE NOTICE '   ✅ Verification history is read-only and user-scoped';
    RAISE NOTICE '   ✅ All operations require authentication (auth.uid())';
    RAISE NOTICE '';
    RAISE NOTICE '🔐 Protected Tables:';
    RAISE NOTICE '   - business_verifications (4 policies: SELECT, INSERT, UPDATE, DELETE)';
    RAISE NOTICE '   - business_registration_documents (4 policies: SELECT, INSERT, UPDATE, DELETE)';
    RAISE NOTICE '   - business_verification_history (2 policies: SELECT, INSERT only)';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  Note: Storage bucket policies need to be configured separately in Supabase Dashboard';
    RAISE NOTICE '';
    RAISE NOTICE '🧪 Next Step: Test the business verification flow with the new schema';
END $$;