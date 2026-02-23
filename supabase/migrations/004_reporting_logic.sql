-- ============================================
-- Reporting Logic and Auto-moderation
-- Migration: 004_reporting_logic.sql
-- ============================================

-- Function to increment report count and auto-hide post
CREATE OR REPLACE FUNCTION public.report_post(p_id UUID)
RETURNS VOID AS $$
BEGIN
    -- Increment the report count
    UPDATE public.posts
    SET report_count = report_count + 1
    WHERE id = p_id;

    -- Auto-hide if reports reach 5 or more
    UPDATE public.posts
    SET is_hidden = true
    WHERE id = p_id AND report_count >= 5;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comment for documentation
COMMENT ON FUNCTION public.report_post(UUID) IS 'Increments report_count and auto-hides post if threshold (5) is reached';
