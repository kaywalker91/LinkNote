-- Migration 59: Add visibility and locked_at to collections
-- Documentation only — do NOT execute from application code.
-- Apply manually via Supabase dashboard or psql before Sprint 2 read-model changes.

ALTER TABLE collections ADD COLUMN visibility text NOT NULL DEFAULT 'private';
ALTER TABLE collections ADD COLUMN locked_at timestamptz DEFAULT NULL;
