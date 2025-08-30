-- Create report system tables
-- This migration creates tables for community reporting and user blocking system

-- Create community_reports table
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

-- Create user_blocks table
CREATE TABLE IF NOT EXISTS user_blocks (
    id BIGSERIAL PRIMARY KEY,
    blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blocked_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL DEFAULT 'user_report',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_block_relationship UNIQUE(blocker_id, blocked_user_id),
    CONSTRAINT no_self_block CHECK (blocker_id != blocked_user_id)
);

-- Create indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_community_reports_reporter_id ON community_reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_community_reports_reported_post_id ON community_reports(reported_post_id);
CREATE INDEX IF NOT EXISTS idx_community_reports_reported_user_id ON community_reports(reported_user_id);
CREATE INDEX IF NOT EXISTS idx_community_reports_status ON community_reports(status);
CREATE INDEX IF NOT EXISTS idx_community_reports_created_at ON community_reports(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker_id ON user_blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocked_user_id ON user_blocks(blocked_user_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_created_at ON user_blocks(created_at DESC);

-- Enable Row Level Security
ALTER TABLE community_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;

-- RLS Policies for community_reports
CREATE POLICY "Users can view their own reports" ON community_reports
    FOR SELECT USING (reporter_id = auth.uid());

CREATE POLICY "Users can create reports" ON community_reports
    FOR INSERT WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "Users can update their own reports" ON community_reports
    FOR UPDATE USING (reporter_id = auth.uid());

-- RLS Policies for user_blocks  
CREATE POLICY "Users can view their own blocks" ON user_blocks
    FOR SELECT USING (blocker_id = auth.uid());

CREATE POLICY "Users can create blocks" ON user_blocks
    FOR INSERT WITH CHECK (blocker_id = auth.uid());

CREATE POLICY "Users can remove their own blocks" ON user_blocks
    FOR DELETE USING (blocker_id = auth.uid());

-- Create function to automatically block user after report
CREATE OR REPLACE FUNCTION auto_block_reported_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Only auto-block if the reported user exists (not anonymous post)
    IF NEW.reported_user_id IS NOT NULL AND NEW.reported_user_id != NEW.reporter_id THEN
        -- Insert into user_blocks, ignore if already exists
        INSERT INTO user_blocks (blocker_id, blocked_user_id, reason)
        VALUES (NEW.reporter_id, NEW.reported_user_id, 'auto_block_from_report')
        ON CONFLICT (blocker_id, blocked_user_id) DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for auto-blocking
CREATE TRIGGER trigger_auto_block_reported_user
    AFTER INSERT ON community_reports
    FOR EACH ROW
    EXECUTE FUNCTION auto_block_reported_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updating updated_at on community_reports
CREATE TRIGGER trigger_update_community_reports_updated_at
    BEFORE UPDATE ON community_reports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE ON community_reports TO authenticated;
GRANT SELECT, INSERT, DELETE ON user_blocks TO authenticated;
GRANT USAGE ON SEQUENCE community_reports_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE user_blocks_id_seq TO authenticated;