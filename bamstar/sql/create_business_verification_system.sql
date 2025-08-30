-- ================================================
-- Business Verification System Database Schema
-- ================================================
-- 사업자 등록증 인증 시스템을 위한 데이터베이스 테이블 생성

-- ================================================
-- 1. 사업자 인증 요청 테이블 (business_verifications)
-- ================================================
CREATE TABLE IF NOT EXISTS public.business_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
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
    nts_verification_status VARCHAR(20) DEFAULT 'pending',  -- pending, success, failed
    nts_response JSONB,  -- 국세청 API 전체 응답 저장
    nts_verified_at TIMESTAMP WITH TIME ZONE,
    
    -- AI 문서 검증 결과 (Step 3)
    document_verification_status VARCHAR(20) DEFAULT 'pending',  -- pending, success, failed
    ai_match_percentage DECIMAL(5,2),  -- AI 일치율 (0.00 ~ 100.00)
    ai_extracted_data JSONB,  -- AI가 추출한 문서 데이터
    ai_verified_at TIMESTAMP WITH TIME ZONE,
    
    -- 전체 인증 상태
    overall_status VARCHAR(20) DEFAULT 'pending',  -- pending, verified, rejected
    verification_level VARCHAR(20) DEFAULT 'none',  -- none, basic, full
    
    -- 관리 정보
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 days')  -- 인증 만료일
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_business_verifications_user_id ON public.business_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_business_verifications_business_number ON public.business_verifications(business_number);
CREATE INDEX IF NOT EXISTS idx_business_verifications_overall_status ON public.business_verifications(overall_status);
CREATE INDEX IF NOT EXISTS idx_business_verifications_created_at ON public.business_verifications(created_at DESC);

-- ================================================
-- 2. 사업자 등록증 문서 테이블 (business_registration_documents)
-- ================================================
CREATE TABLE IF NOT EXISTS public.business_registration_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verification_id UUID NOT NULL REFERENCES public.business_verifications(id) ON DELETE CASCADE,
    
    -- 문서 정보
    file_name VARCHAR(255) NOT NULL,
    file_size INTEGER NOT NULL,
    file_type VARCHAR(50) NOT NULL,  -- image/jpeg, image/png
    storage_path TEXT NOT NULL,  -- Supabase Storage 경로
    
    -- AI 처리 결과
    ocr_text TEXT,  -- 추출된 텍스트
    processing_status VARCHAR(20) DEFAULT 'pending',  -- pending, processed, failed
    processed_at TIMESTAMP WITH TIME ZONE,
    
    -- 관리 정보
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_business_documents_verification_id ON public.business_registration_documents(verification_id);
CREATE INDEX IF NOT EXISTS idx_business_documents_processing_status ON public.business_registration_documents(processing_status);

-- ================================================
-- 3. 인증 이력 테이블 (business_verification_history)
-- ================================================
CREATE TABLE IF NOT EXISTS public.business_verification_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verification_id UUID NOT NULL REFERENCES public.business_verifications(id) ON DELETE CASCADE,
    
    -- 변경 사항
    action VARCHAR(50) NOT NULL,  -- created, nts_verified, document_uploaded, ai_verified, status_changed
    previous_status VARCHAR(20),
    new_status VARCHAR(20),
    details JSONB,  -- 추가 세부 정보
    
    -- 관리 정보
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_verification_history_verification_id ON public.business_verification_history(verification_id);
CREATE INDEX IF NOT EXISTS idx_verification_history_created_at ON public.business_verification_history(created_at DESC);

-- ================================================
-- 4. 사업자 프로필 확장 (member_profiles에 비즈니스 정보 추가)
-- ================================================
-- member_profiles 테이블에 사업자 인증 관련 컬럼 추가
DO $$ 
BEGIN
    -- business_verification_id 컬럼 추가 (nullable)
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
    
    -- business_verification_level 컬럼 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'member_profiles' 
        AND column_name = 'business_verification_level'
    ) THEN
        ALTER TABLE public.member_profiles 
        ADD COLUMN business_verification_level VARCHAR(20) DEFAULT 'none';  -- none, basic, full
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
CREATE INDEX IF NOT EXISTS idx_member_profiles_verification_level ON public.member_profiles(business_verification_level);

-- ================================================
-- 5. 트리거 함수 생성
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

-- 사업자 인증 완료 시 member_profiles 업데이트 트리거
CREATE OR REPLACE FUNCTION update_member_business_verification()
RETURNS TRIGGER AS $$
BEGIN
    -- 인증 상태가 verified로 변경된 경우
    IF NEW.overall_status = 'verified' AND (OLD.overall_status IS NULL OR OLD.overall_status != 'verified') THEN
        UPDATE public.member_profiles 
        SET 
            business_verification_id = NEW.id,
            is_business_verified = TRUE,
            business_verification_level = NEW.verification_level,
            business_verified_at = NOW()
        WHERE user_id = NEW.user_id;
        
        -- 이력 기록
        INSERT INTO public.business_verification_history (
            verification_id, action, new_status, details, created_by
        ) VALUES (
            NEW.id, 
            'member_profile_updated', 
            'verified',
            jsonb_build_object(
                'verification_level', NEW.verification_level,
                'ai_match_percentage', NEW.ai_match_percentage
            ),
            NEW.user_id
        );
    END IF;
    
    -- 인증 상태가 rejected로 변경된 경우
    IF NEW.overall_status = 'rejected' AND (OLD.overall_status IS NULL OR OLD.overall_status != 'rejected') THEN
        UPDATE public.member_profiles 
        SET 
            is_business_verified = FALSE,
            business_verification_level = 'none'
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

-- ================================================
-- 6. 유틸리티 함수들
-- ================================================

-- 사업자 번호 유효성 검사 함수
CREATE OR REPLACE FUNCTION validate_business_number(business_number TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- 10자리 숫자인지 확인
    IF business_number IS NULL OR length(business_number) != 10 THEN
        RETURN FALSE;
    END IF;
    
    -- 숫자만 포함하는지 확인
    IF business_number !~ '^[0-9]+$' THEN
        RETURN FALSE;
    END IF;
    
    -- 사업자 번호 체크섬 로직 (간단 버전)
    -- 실제 구현에서는 더 정확한 체크섬 알고리즘 필요
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 사용자의 최신 사업자 인증 정보 조회 함수
CREATE OR REPLACE FUNCTION get_user_latest_business_verification(p_user_id UUID)
RETURNS TABLE (
    verification_id UUID,
    business_number VARCHAR(10),
    overall_status VARCHAR(20),
    verification_level VARCHAR(20),
    ai_match_percentage DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bv.id,
        bv.business_number,
        bv.overall_status,
        bv.verification_level,
        bv.ai_match_percentage,
        bv.created_at
    FROM public.business_verifications bv
    WHERE bv.user_id = p_user_id
    ORDER BY bv.created_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- 7. 초기 데이터 및 제약조건
-- ================================================

-- Check 제약조건 추가
ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_business_number_format 
CHECK (business_number ~ '^[0-9]{10}$');

ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_opening_date_format 
CHECK (opening_date ~ '^[0-9]{8}$');

ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_nts_verification_status 
CHECK (nts_verification_status IN ('pending', 'success', 'failed'));

ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_document_verification_status 
CHECK (document_verification_status IN ('pending', 'success', 'failed'));

ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_overall_status 
CHECK (overall_status IN ('pending', 'verified', 'rejected'));

ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_verification_level 
CHECK (verification_level IN ('none', 'basic', 'full'));

ALTER TABLE public.business_verifications 
ADD CONSTRAINT check_ai_match_percentage 
CHECK (ai_match_percentage >= 0 AND ai_match_percentage <= 100);

-- business_registration_documents 제약조건
ALTER TABLE public.business_registration_documents 
ADD CONSTRAINT check_file_type 
CHECK (file_type IN ('image/jpeg', 'image/png', 'image/jpg'));

ALTER TABLE public.business_registration_documents 
ADD CONSTRAINT check_processing_status 
CHECK (processing_status IN ('pending', 'processed', 'failed'));

-- member_profiles 제약조건
ALTER TABLE public.member_profiles 
ADD CONSTRAINT check_business_verification_level 
CHECK (business_verification_level IN ('none', 'basic', 'full'));

-- ================================================
-- 8. 권한 설정 (기본 authenticated 사용자 권한)
-- ================================================

-- authenticated 사용자에게 테이블 접근 권한 부여
GRANT SELECT, INSERT, UPDATE ON public.business_verifications TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.business_registration_documents TO authenticated;
GRANT SELECT, INSERT ON public.business_verification_history TO authenticated;

-- 시퀀스 권한 부여 (UUID 사용하므로 불필요하지만 안전을 위해)
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ================================================
-- 완료 메시지
-- ================================================
DO $$ 
BEGIN
    RAISE NOTICE '✅ Business Verification System Database Schema Created Successfully!';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Created Tables:';
    RAISE NOTICE '   - business_verifications (main verification records)';
    RAISE NOTICE '   - business_registration_documents (uploaded documents)';
    RAISE NOTICE '   - business_verification_history (audit trail)';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 Enhanced Tables:';
    RAISE NOTICE '   - member_profiles (added business verification fields)';
    RAISE NOTICE '';
    RAISE NOTICE '⚙️  Created Functions:';
    RAISE NOTICE '   - validate_business_number()';
    RAISE NOTICE '   - get_user_latest_business_verification()';
    RAISE NOTICE '   - Auto-update triggers';
    RAISE NOTICE '';
    RAISE NOTICE '🛡️  Next Step: Apply RLS policies for security';
END $$;