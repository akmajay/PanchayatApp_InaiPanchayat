-- ============================================
-- PanchayatApp Initial Database Schema
-- Migration: 001_initial_schema.sql
-- Created: 2026-02-06
-- ============================================

-- ============================================
-- TABLE: profiles
-- User identity, linked to Supabase Auth
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    phone TEXT UNIQUE,
    ward_no INTEGER NOT NULL CHECK (ward_no >= 1 AND ward_no <= 15),
    is_banned BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Add comment for documentation
COMMENT ON TABLE public.profiles IS 'User profiles linked to Supabase Auth users';
COMMENT ON COLUMN public.profiles.ward_no IS 'Ward number (1-15) for the user';
COMMENT ON COLUMN public.profiles.is_banned IS 'Flag to ban users from posting';

-- ============================================
-- ENUM TYPES for posts table
-- ============================================
DO $$ BEGIN
    CREATE TYPE media_type_enum AS ENUM ('image', 'video_10s', 'youtube', 'text');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE category_enum AS ENUM ('corruption', 'road', 'ration', 'water', 'school', 'other');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ============================================
-- TABLE: posts
-- Main grievance feed
-- ============================================
CREATE TABLE IF NOT EXISTS public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    media_url TEXT,
    media_type media_type_enum DEFAULT 'text',
    category category_enum DEFAULT 'other',
    is_anonymous BOOLEAN DEFAULT false,
    ward_no INTEGER,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    report_count INTEGER DEFAULT 0,
    is_hidden BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON public.posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_ward_no ON public.posts(ward_no);
CREATE INDEX IF NOT EXISTS idx_posts_category ON public.posts(category);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON public.posts(created_at DESC);

-- Add comments for documentation
COMMENT ON TABLE public.posts IS 'Main grievance/complaint feed for the Panchayat app';
COMMENT ON COLUMN public.posts.media_type IS 'Type of media attached: image, video_10s, youtube, or text';
COMMENT ON COLUMN public.posts.category IS 'Category of grievance: corruption, road, ration, water, school, or other';
COMMENT ON COLUMN public.posts.is_anonymous IS 'If true, user identity is hidden from public view';
COMMENT ON COLUMN public.posts.report_count IS 'Number of times this post has been reported';
COMMENT ON COLUMN public.posts.is_hidden IS 'If true, post is hidden from feed (moderation)';

-- ============================================
-- FUNCTION: Auto-create profile on signup
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, ward_no)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Unknown User'),
        1  -- Default ward_no, user can update later
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGER: Create profile when user signs up
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- FUNCTION: Auto-set ward_no on post creation
-- ============================================
CREATE OR REPLACE FUNCTION public.set_post_ward_no()
RETURNS TRIGGER AS $$
BEGIN
    -- If ward_no not provided, fetch from user's profile
    IF NEW.ward_no IS NULL THEN
        SELECT ward_no INTO NEW.ward_no
        FROM public.profiles
        WHERE id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGER: Auto-set ward_no on post insert
-- ============================================
DROP TRIGGER IF EXISTS set_post_ward_no_trigger ON public.posts;
CREATE TRIGGER set_post_ward_no_trigger
    BEFORE INSERT ON public.posts
    FOR EACH ROW EXECUTE FUNCTION public.set_post_ward_no();
