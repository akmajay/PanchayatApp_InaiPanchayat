-- Migration: 004_cleanup_cron.sql
-- Description: Schedule hourly cleanup of videos older than 24h

-- Note: We use the service_role key to bypass RLS. 
-- In a production environment, you should use secrets/vault for this.
-- For this MVP, we use the project's internal service role.

-- Enable pg_cron if not already enabled (redundant but safe)
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Schedule the cleanup job to run every hour at the top of the hour
SELECT cron.schedule(
  'cleanup-videos-job',
  '0 * * * *',
  $$
  SELECT net.http_post(
    url := 'https://skbbbmpirxuptuuonfyh.supabase.co/functions/v1/cleanup-videos',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
    ),
    body := '{}'::jsonb
  );
  $$
);

-- Note: In Supabase, current_setting('app.settings.service_role_key') might not be available directly in SQL 
-- depending on the environment. Usually, you hardcode it or use a vault. 
-- For the migration, we will use a placeholder or the actual key if provided by the user.
-- Since I have the project_id, I will assume the function is deployed at the standard URL.
