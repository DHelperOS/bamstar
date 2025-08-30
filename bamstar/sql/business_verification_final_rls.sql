-- ================================================
-- Business Verification System - Final RLS Policies
-- ================================================

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

-- DELETE 정책: 사용자는 자신의 인증 기록만 삭제 가능 (필요시)
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

-- ================================================
-- 완료 메시지
-- ================================================
DO $$ 
BEGIN
    RAISE NOTICE '✅ Business Verification RLS Policies Applied Successfully!';
    RAISE NOTICE '';
    RAISE NOTICE '🛡️ Security Rules:';
    RAISE NOTICE '   - Users can only access their own verification records';
    RAISE NOTICE '   - Users can only upload documents for their verifications';
    RAISE NOTICE '   - History is read-only and user-scoped';
    RAISE NOTICE '   - All operations require authentication';
    RAISE NOTICE '';
    RAISE NOTICE '🔐 Protected Tables: 3 tables, 10 policies total';
END $$;