-- ============================================
-- Supabase Storage Buckets and RLS Policies
-- Migration: 003_storage_buckets.sql
-- ============================================

-- 1. Create buckets (These usually need to be created via Dashboard or API, 
-- but we can define policies here assuming they exist or using the extensions if available)
-- Note: 'storage.buckets' and 'storage.objects' are the tables to target.

-- Insert buckets if they don't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('permanent_images', 'permanent_images', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('temp_videos', 'temp_videos', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Set up RLS Policies for 'permanent_images'
-- SELECT: Public access to all files
CREATE POLICY "Public Access for Images"
ON storage.objects FOR SELECT
USING ( bucket_id = 'permanent_images' );

-- INSERT: Authenticated users can upload to their own folder
CREATE POLICY "Users can upload their own images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'permanent_images' AND (storage.foldername(name))[1] = auth.uid()::text
);

-- DELETE: Users can delete their own files
CREATE POLICY "Users can delete their own images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'permanent_images' AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 3. Set up RLS Policies for 'temp_videos'
-- SELECT: Public access
CREATE POLICY "Public Access for Videos"
ON storage.objects FOR SELECT
USING ( bucket_id = 'temp_videos' );

-- INSERT: Authenticated users can upload
CREATE POLICY "Users can upload their own videos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'temp_videos' AND (storage.foldername(name))[1] = auth.uid()::text
);

-- DELETE: Users can delete their own
CREATE POLICY "Users can delete their own videos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'temp_videos' AND (storage.foldername(name))[1] = auth.uid()::text
);
