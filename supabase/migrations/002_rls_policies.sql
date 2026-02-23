-- ============================================
-- PanchayatApp RLS Policies
-- Migration: 002_rls_policies.sql
-- Created: 2026-02-06
-- ============================================

-- ============================================
-- ADMIN HELPER FUNCTION
-- Check if current user is an admin
-- ============================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if user email is in admin list
    -- Add admin emails here
    RETURN (
        SELECT email IN (
            'gemini2.jay.com@gmail.com',
            'life.jay.com@gmail.com'
        )
        FROM auth.users
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.is_admin IS 'Returns true if the current user is an admin';

-- ============================================
-- PROFILES TABLE - Enable RLS
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read profiles (for displaying names on posts)
CREATE POLICY "profiles_select_public"
ON public.profiles
FOR SELECT
TO public
USING (true);

-- Policy: Users can only update their own profile
CREATE POLICY "profiles_update_own"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Policy: Admins can update any profile (for banning users)
CREATE POLICY "profiles_update_admin"
ON public.profiles
FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- ============================================
-- POSTS TABLE - Enable RLS
-- ============================================
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read non-hidden posts
CREATE POLICY "posts_select_public"
ON public.posts
FOR SELECT
TO public
USING (is_hidden = false);

-- Policy: Admins can read all posts including hidden
CREATE POLICY "posts_select_admin"
ON public.posts
FOR SELECT
TO authenticated
USING (public.is_admin());

-- Policy: Authenticated users can insert posts
-- user_id must match their own ID
CREATE POLICY "posts_insert_authenticated"
ON public.posts
FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() IS NOT NULL 
    AND user_id = auth.uid()
);

-- Policy: Users can update their own posts
CREATE POLICY "posts_update_own"
ON public.posts
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Admins can update any post (for moderation)
CREATE POLICY "posts_update_admin"
ON public.posts
FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Policy: Users can delete their own posts
CREATE POLICY "posts_delete_own"
ON public.posts
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Admins can delete any post
CREATE POLICY "posts_delete_admin"
ON public.posts
FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================
-- GRANT PERMISSIONS
-- ============================================
-- Allow authenticated and anon roles to use the is_admin function
GRANT EXECUTE ON FUNCTION public.is_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin TO anon;
