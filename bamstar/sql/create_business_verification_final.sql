-- ================================================
-- Business Verification System - Final Database Schema
-- ================================================
-- 사업자 등록증 인증 시스템 최종 데이터베이스 스키마

-- ================================================
-- 1. ENUM 타입 생성
-- ================================================
DO $$ 
BEGIN
    -- 전체 인증 상태 ENUM
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'business_verification_status') THEN
        CREATE TYPE business_verification_status AS ENUM (
            'draft',                    -- 작성 중
            'nts_failed',              -- 국세청 조회 실패 (고객센터 문의)
            'ai_low_score',            -- AI 30% 이하 (재업로드 필요)
            'pending_admin_review',     -- AI 31-69% (관리자 검토 대기)
            'auto_verified',           -- AI 70% 이상 (자동 승인)
            'admin_approved',          -- 관리자 승인
            'admin_rejected'           -- 관리자 거부
        );
    END IF;

    -- 단계별 상태 ENUM
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'verification_step_status') THEN
        CREATE TYPE verification_step_status AS ENUM (
            'pending',
            'success', 
            'failed'
        );
    END IF;

    -- 문서 처리 상태 ENUM
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'document_processing_status') THEN
        CREATE TYPE document_processing_status AS ENUM (
            'pending',
            'processed',
            'failed'
        );
    END IF;
END $$;

-- ================================================
-- 2. 사업자 인증 요청 테이블 (business_verifications)
-- ================================================
CREATE TABLE IF NOT EXISTS public.business_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 최신 기록 관리
    is_latest BOOLEAN DEFAULT TRUE,  -- 사용자당 최신 인증 기록 표시
    
    -- 입력된 정보 (Step 1)
    business_number VARCHAR(10) NOT NULL,  -- 사업자등록번호 (10자리)
    representative_name VARCHAR(100) NOT NULL,  -- 대표자명
    opening_date VARCHAR(8) NOT NULL,  -- 개업일자 (YYYYMMDD)
    representative_name2 VARCHAR(100),  -- 대표자명2 (선택)
    business_name VARCHAR(200),  -- 상호명 (선택)
    corporate_number VARCHAR(13),  -- 법인등록번호 (선택)
    main_business_type VARCHAR(100),  -- 주업태 (선택)
    sub_business_type VARCHAR(100),  -- 주종목 (선택)
    business_address TEXT,  -- 사업장소재지 (선택)
    
    -- 국세청 API 조회 결과 (Step 2)
    nts_verification_status verification_step_status DEFAULT 'pending',
    nts_response JSONB,  -- 국세청 API 전체 응답 저장
    nts_verified_at TIMESTAMP WITH TIME ZONE,
    nts_error_message TEXT,  -- 국세청 API 오류 메시지
    
    -- AI 문서 검증 결과 (Step 3)
    document_verification_status verification_step_status DEFAULT 'pending',
    ai_match_percentage DECIMAL(5,2),  -- AI 일치율 (0.00 ~ 100.00)
    ai_extracted_data JSONB,  -- AI가 추출한 문서 데이터
    ai_verified_at TIMESTAMP WITH TIME ZONE,
    ai_error_message TEXT,  -- AI 처리 오류 메시지
    
    -- 전체 인증 상태
    overall_status business_verification_status DEFAULT 'draft',
    
    -- 관리자 검토 관련
    admin_reviewed_by UUID REFERENCES auth.users(id),
    admin_reviewed_at TIMESTAMP WITH TIME ZONE,
    admin_review_note TEXT,  -- 관리자 검토 메모
    
    -- 관리 정보
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 days')  -- 인증 만료일
);

-- 인덱스 생성
CREATE UNIQUE INDEX IF NOT EXISTS idx_business_verifications_user_latest 
ON public.business_verifications(user_id) 
WHERE is_latest = TRUE;  -- 사용자당 최신 기록 1개만 허용

CREATE INDEX IF NOT EXISTS idx_business_verifications_user_id ON public.business_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_business_verifications_business_number ON public.business_verifications(business_number);
CREATE INDEX IF NOT EXISTS idx_business_verifications_overall_status ON public.business_verifications(overall_status);
CREATE INDEX IF NOT EXISTS idx_business_verifications_created_at ON public.business_verifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_business_verifications_admin_review ON public.business_verifications(overall_status) WHERE overall_status = 'pending_admin_review';

-- ================================================
-- 3. 사업자 등록증 문서 테이블 (business_registration_documents)
-- ================================================
CREATE TABLE IF NOT EXISTS public.business_registration_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verification_id UUID NOT NULL REFERENCES public.business_verifications(id) ON DELETE CASCADE,
    
    -- 문서 정보
    file_name VARCHAR(255) NOT NULL,
    file_size INTEGER NOT NULL,
    file_type VARCHAR(50) NOT NULL,  -- image/jpeg, image/png
    storage_path TEXT NOT NULL,  -- Supabase Storage 경로
    storage_bucket VARCHAR(100) DEFAULT 'business-documents',
    
    -- AI 처리 결과
    ocr_text TEXT,  -- 추출된 텍스트 (영구 보관)
    processing_status document_processing_status DEFAULT 'pending',
    processed_at TIMESTAMP WITH TIME ZONE,
    processing_error TEXT,  -- 처리 오류 메시지
    
    -- 관리 정보
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_business_documents_verification_id ON public.business_registration_documents(verification_id);
CREATE INDEX IF NOT EXISTS idx_business_documents_processing_status ON public.business_registration_documents(processing_status);
CREATE INDEX IF NOT EXISTS idx_business_documents_uploaded_at ON public.business_registration_documents(uploaded_at DESC);

-- ================================================
-- 4. 인증 이력 테이블 (business_verification_history)
-- ================================================
CREATE TABLE IF NOT EXISTS public.business_verification_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verification_id UUID NOT NULL REFERENCES public.business_verifications(id) ON DELETE CASCADE,
    
    -- 변경 사항
    action VARCHAR(50) NOT NULL,  -- created, nts_verified, document_uploaded, ai_verified, status_changed, admin_reviewed
    previous_status business_verification_status,
    new_status business_verification_status,
    details JSONB,  -- 추가 세부 정보
    
    -- 관리 정보
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_verification_history_verification_id ON public.business_verification_history(verification_id);
CREATE INDEX IF NOT EXISTS idx_verification_history_created_at ON public.business_verification_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_verification_history_action ON public.business_verification_history(action);

-- ================================================
-- 5. member_profiles 테이블 확장
-- ================================================
DO $$ 
BEGIN
    -- business_verification_id 컬럼 추가 (최신 인증 기록 참조)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'member_profiles' 
        AND column_name = 'business_verification_id'
    ) THEN
        ALTER TABLE public.member_profiles 
        ADD COLUMN business_verification_id UUID REFERENCES public.business_verifications(id);
    END IF;
    
    -- is_business_verified 컬럼 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'member_profiles' 
        AND column_name = 'is_business_verified'
    ) THEN
        ALTER TABLE public.member_profiles 
        ADD COLUMN is_business_verified BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- business_verified_at 컬럼 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'member_profiles' 
        AND column_name = 'business_verified_at'
    ) THEN
        ALTER TABLE public.member_profiles 
        ADD COLUMN business_verified_at TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_member_profiles_business_verified ON public.member_profiles(is_business_verified);

-- ================================================
-- 6. 트리거 함수 생성
-- ================================================

-- updated_at 자동 업데이트 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- business_verifications 테이블에 updated_at 트리거 적용
DROP TRIGGER IF EXISTS update_business_verifications_updated_at ON public.business_verifications;
CREATE TRIGGER update_business_verifications_updated_at
    BEFORE UPDATE ON public.business_verifications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 새로운 인증 기록 생성 시 이전 기록을 is_latest = false로 변경
CREATE OR REPLACE FUNCTION manage_latest_business_verification()
RETURNS TRIGGER AS $$
BEGIN
    -- 새로운 기록이 is_latest = true로 생성되는 경우
    IF NEW.is_latest = TRUE THEN
        -- 동일 사용자의 이전 기록들을 is_latest = false로 변경
        UPDATE public.business_verifications 
        SET is_latest = FALSE 
        WHERE user_id = NEW.user_id 
          AND id != NEW.id 
          AND is_latest = TRUE;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 적용
DROP TRIGGER IF EXISTS trigger_manage_latest_business_verification ON public.business_verifications;
CREATE TRIGGER trigger_manage_latest_business_verification
    BEFORE INSERT OR UPDATE ON public.business_verifications
    FOR EACH ROW
    EXECUTE FUNCTION manage_latest_business_verification();

-- 사업자 인증 완료 시 member_profiles 업데이트 트리거
CREATE OR REPLACE FUNCTION update_member_business_verification()
RETURNS TRIGGER AS $$
BEGIN
    -- 인증 상태가 auto_verified 또는 admin_approved로 변경된 경우
    IF NEW.overall_status IN ('auto_verified', 'admin_approved') 
       AND NEW.is_latest = TRUE
       AND (OLD.overall_status IS NULL OR OLD.overall_status NOT IN ('auto_verified', 'admin_approved')) THEN
        
        UPDATE public.member_profiles 
        SET 
            business_verification_id = NEW.id,
            is_business_verified = TRUE,
            business_verified_at = NOW()
        WHERE user_id = NEW.user_id;
        
        -- 이력 기록
        INSERT INTO public.business_verification_history (
            verification_id, action, new_status, details, created_by
        ) VALUES (
            NEW.id, 
            'member_profile_updated', 
            NEW.overall_status,
            jsonb_build_object(
                'ai_match_percentage', NEW.ai_match_percentage,
                'previous_verification_status', OLD.overall_status
            ),
            NEW.user_id
        );
    END IF;
    
    -- 인증이 거부되거나 실패한 경우
    IF NEW.overall_status IN ('admin_rejected', 'ai_low_score', 'nts_failed')
       AND NEW.is_latest = TRUE THEN
        
        UPDATE public.member_profiles 
        SET 
            is_business_verified = FALSE,
            business_verified_at = NULL
        WHERE user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 적용
DROP TRIGGER IF EXISTS trigger_update_member_business_verification ON public.business_verifications;
CREATE TRIGGER trigger_update_member_business_verification
    AFTER UPDATE ON public.business_verifications
    FOR EACH ROW
    EXECUTE FUNCTION update_member_business_verification();

-- 상태 변경 이력 자동 기록 트리거
CREATE OR REPLACE FUNCTION log_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- 상태가 변경된 경우에만 이력 기록
    IF OLD.overall_status IS DISTINCT FROM NEW.overall_status THEN
        INSERT INTO public.business_verification_history (
            verification_id, 
            action, 
            previous_status, 
            new_status, 
            details,
            created_by
        ) VALUES (
            NEW.id,
            'status_changed',
            OLD.overall_status,
            NEW.overall_status,
            jsonb_build_object(
                'ai_match_percentage', NEW.ai_match_percentage,
                'nts_status', NEW.nts_verification_status,
                'document_status', NEW.document_verification_status
            ),
            NEW.user_id
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 적용
DROP TRIGGER IF EXISTS trigger_log_status_change ON public.business_verifications;
CREATE TRIGGER trigger_log_status_change
    AFTER UPDATE ON public.business_verifications
    FOR EACH ROW
    EXECUTE FUNCTION log_status_change();

-- ================================================
-- 7. 유틸리티 함수들
-- ================================================

-- 사업자 번호 유효성 검사 함수 (개선된 버전)
CREATE OR REPLACE FUNCTION validate_business_number(business_number TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    check_sum INTEGER;
    weight_sum INTEGER;
    i INTEGER;
BEGIN
    -- NULL 또는 빈 문자열 체크
    IF business_number IS NULL OR length(trim(business_number)) = 0 THEN
        RETURN FALSE;
    END IF;
    
    -- 10자리 숫자인지 확인
    IF length(business_number) != 10 THEN
        RETURN FALSE;
    END IF;
    
    -- 숫자만 포함하는지 확인
    IF business_number !~ '^[0-9]+$' THEN
        RETURN FALSE;
    END IF;
    
    -- 사업자 번호 체크섬 검증 (한국 사업자등록번호 알고리즘)
    weight_sum := 0;
    FOR i IN 1..9 LOOP
        weight_sum := weight_sum + (substring(business_number, i, 1)::INTEGER * 
            CASE i 
                WHEN 1 THEN 1 WHEN 2 THEN 3 WHEN 3 THEN 7 WHEN 4 THEN 1 WHEN 5 THEN 3
                WHEN 6 THEN 7 WHEN 7 THEN 1 WHEN 8 THEN 3 WHEN 9 THEN 5
            END);
    END LOOP;
    
    check_sum := (weight_sum + (substring(business_number, 9, 1)::INTEGER * 5) / 10) % 10;
    IF check_sum != 0 THEN
        check_sum := 10 - check_sum;
    END IF;
    
    RETURN check_sum = substring(business_number, 10, 1)::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- 사용자의 최신 사업자 인증 정보 조회 함수
CREATE OR REPLACE FUNCTION get_user_latest_business_verification(p_user_id UUID)
RETURNS TABLE (
    verification_id UUID,
    business_number VARCHAR(10),
    overall_status business_verification_status,
    ai_match_percentage DECIMAL(5,2),
    nts_verification_status verification_step_status,
    document_verification_status verification_step_status,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bv.id,
        bv.business_number,
        bv.overall_status,
        bv.ai_match_percentage,
        bv.nts_verification_status,
        bv.document_verification_status,
        bv.created_at,
        bv.updated_at
    FROM public.business_verifications bv
    WHERE bv.user_id = p_user_id
      AND bv.is_latest = TRUE
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- AI 검증 결과에 따른 상태 자동 결정 함수
CREATE OR REPLACE FUNCTION determine_verification_status(ai_percentage DECIMAL)
RETURNS business_verification_status AS $$
BEGIN
    IF ai_percentage IS NULL THEN
        RETURN 'draft';
    ELSIF ai_percentage <= 30 THEN
        RETURN 'ai_low_score';
    ELSIF ai_percentage < 70 THEN
        RETURN 'pending_admin_review';
    ELSE
        RETURN 'auto_verified';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- 8. 제약조건 추가
-- ================================================

-- business_verifications 제약조건
ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_business_number_format 
CHECK (business_number ~ '^[0-9]{10}$');

ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_opening_date_format 
CHECK (opening_date ~ '^[0-9]{8}$');

ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_ai_match_percentage 
CHECK (ai_match_percentage IS NULL OR (ai_match_percentage >= 0 AND ai_match_percentage <= 100));

-- business_registration_documents 제약조건
ALTER TABLE public.business_registration_documents 
ADD CONSTRAINT check_file_type 
CHECK (file_type IN ('image/jpeg', 'image/png', 'image/jpg'));

ALTER TABLE public.business_registration_documents 
ADD CONSTRAINT check_file_size 
CHECK (file_size > 0 AND file_size <= 10485760);  -- 10MB 제한

-- ================================================
-- 9. 권한 설정
-- ================================================

-- authenticated 사용자에게 테이블 접근 권한 부여
GRANT SELECT, INSERT, UPDATE ON public.business_verifications TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.business_registration_documents TO authenticated;
GRANT SELECT, INSERT ON public.business_verification_history TO authenticated;

-- 함수 실행 권한 부여
GRANT EXECUTE ON FUNCTION validate_business_number(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_latest_business_verification(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION determine_verification_status(DECIMAL) TO authenticated;

-- ================================================
-- 완료 메시지
-- ================================================
DO $$ 
BEGIN
    RAISE NOTICE '✅ Business Verification System Final Schema Created Successfully!';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Status Flow:';
    RAISE NOTICE '   draft → nts_failed (고객센터 문의)';
    RAISE NOTICE '   draft → ai_low_score (30%이하, 재업로드)';
    RAISE NOTICE '   draft → pending_admin_review (31-69%, 관리자검토)';
    RAISE NOTICE '   draft → auto_verified (70%이상, 자동승인)';
    RAISE NOTICE '   pending_admin_review → admin_approved/admin_rejected';
    RAISE NOTICE '';
    RAISE NOTICE '🗂️  Tables Created:';
    RAISE NOTICE '   - business_verifications (최신 기록 관리)';
    RAISE NOTICE '   - business_registration_documents (영구 보관)';
    RAISE NOTICE '   - business_verification_history (상태 이력)';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 Enhanced:';
    RAISE NOTICE '   - member_profiles (사업자 인증 연동)';
    RAISE NOTICE '';
    RAISE NOTICE '⚙️  Functions & Triggers:';
    RAISE NOTICE '   - 사업자번호 검증, 상태 자동 결정, 이력 관리';
    RAISE NOTICE '   - 최신 기록 관리, member_profiles 자동 업데이트';
    RAISE NOTICE '';
    RAISE NOTICE '🛡️  Next: Apply RLS policies and integrate with Flutter app';
END $$;