# 신고 시스템 데이터베이스 수동 설정 가이드

## 1. Supabase Dashboard 접근
1. https://supabase.com/dashboard 접속
2. BamStar 프로젝트 선택 (tflvicpgyycvhttctcek)
3. 좌측 메뉴에서 **SQL Editor** 클릭

## 2. 테이블 생성 SQL 실행

### Step 1: community_reports 테이블 생성
다음 SQL을 SQL Editor에서 실행하세요:

```sql
-- 신고 테이블 생성
CREATE TABLE IF NOT EXISTS community_reports (
    id BIGSERIAL PRIMARY KEY,
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reported_post_id BIGINT NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    report_reason TEXT NOT NULL CHECK (
        report_reason IN ('inappropriate', 'spam', 'harassment', 'illegal', 'privacy', 'misinformation', 'other')
    ),
    report_details TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (
        status IN ('pending', 'resolved', 'dismissed')
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
```

### Step 2: user_blocks 테이블 생성
```sql
-- 차단 테이블 생성
CREATE TABLE IF NOT EXISTS user_blocks (
    id BIGSERIAL PRIMARY KEY,
    blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blocked_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL DEFAULT 'user_report',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_block_relationship UNIQUE(blocker_id, blocked_user_id),
    CONSTRAINT no_self_block CHECK (blocker_id != blocked_user_id)
);
```

### Step 3: 인덱스 생성 (성능 최적화)
```sql
-- 성능 최적화를 위한 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_community_reports_reporter_id ON community_reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_community_reports_reported_post_id ON community_reports(reported_post_id);
CREATE INDEX IF NOT EXISTS idx_community_reports_reported_user_id ON community_reports(reported_user_id);
CREATE INDEX IF NOT EXISTS idx_community_reports_status ON community_reports(status);
CREATE INDEX IF NOT EXISTS idx_community_reports_created_at ON community_reports(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker_id ON user_blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocked_user_id ON user_blocks(blocked_user_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_created_at ON user_blocks(created_at DESC);
```

### Step 4: RLS (Row Level Security) 활성화
```sql
-- 테이블 보안 정책 활성화
ALTER TABLE community_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;
```

### Step 5: RLS 정책 생성
```sql
-- 신고 테이블 정책
CREATE POLICY "Users can view their own reports" ON community_reports
    FOR SELECT USING (reporter_id = auth.uid());

CREATE POLICY "Users can create reports" ON community_reports
    FOR INSERT WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "Users can update their own reports" ON community_reports
    FOR UPDATE USING (reporter_id = auth.uid());

-- 차단 테이블 정책
CREATE POLICY "Users can view their own blocks" ON user_blocks
    FOR SELECT USING (blocker_id = auth.uid());

CREATE POLICY "Users can create blocks" ON user_blocks
    FOR INSERT WITH CHECK (blocker_id = auth.uid());

CREATE POLICY "Users can remove their own blocks" ON user_blocks
    FOR DELETE USING (blocker_id = auth.uid());
```

### Step 6: 자동 차단 트리거 함수 생성
```sql
-- 신고 시 자동 차단 함수
CREATE OR REPLACE FUNCTION auto_block_reported_user()
RETURNS TRIGGER AS $$
BEGIN
    -- 신고 대상 사용자가 존재하고 자기 자신이 아닌 경우에만 차단
    IF NEW.reported_user_id IS NOT NULL AND NEW.reported_user_id != NEW.reporter_id THEN
        -- user_blocks 테이블에 추가 (이미 존재하면 무시)
        INSERT INTO user_blocks (blocker_id, blocked_user_id, reason)
        VALUES (NEW.reporter_id, NEW.reported_user_id, 'auto_block_from_report')
        ON CONFLICT (blocker_id, blocked_user_id) DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 트리거 생성
CREATE TRIGGER trigger_auto_block_reported_user
    AFTER INSERT ON community_reports
    FOR EACH ROW
    EXECUTE FUNCTION auto_block_reported_user();
```

### Step 7: updated_at 자동 업데이트 함수
```sql
-- updated_at 자동 업데이트 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- community_reports에 대한 updated_at 트리거
CREATE TRIGGER trigger_update_community_reports_updated_at
    BEFORE UPDATE ON community_reports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### Step 8: 권한 부여
```sql
-- 인증된 사용자에게 필요한 권한 부여
GRANT SELECT, INSERT, UPDATE ON community_reports TO authenticated;
GRANT SELECT, INSERT, DELETE ON user_blocks TO authenticated;
GRANT USAGE ON SEQUENCE community_reports_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE user_blocks_id_seq TO authenticated;
```

## 3. 테이블 생성 확인
SQL Editor에서 다음 쿼리로 테이블이 올바르게 생성되었는지 확인:

```sql
-- 테이블 존재 확인
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('community_reports', 'user_blocks');

-- 컬럼 구조 확인
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name IN ('community_reports', 'user_blocks')
ORDER BY table_name, ordinal_position;
```

## 4. 확인 완료 후
테이블이 성공적으로 생성되면 댓글로 **"테이블 생성 완료"** 라고 알려주세요!

그러면 Flutter 앱의 API 코드와 ReportDialog 통합을 계속 진행하겠습니다.

## 트러블슈팅

### 에러: "relation does not exist" 
- `community_posts` 테이블이 없을 경우 발생
- 기존 테이블명을 확인하고 올바른 테이블명으로 수정 필요

### 에러: "permission denied"
- 권한 부여 SQL(Step 8)을 다시 실행
- 또는 Supabase Dashboard에서 Authentication > Users 확인

### 에러: "constraint violation"
- 기존 데이터와 충돌하는 경우
- 테이블을 DROP 하고 다시 생성하거나 기존 데이터 정리 필요