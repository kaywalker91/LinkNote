-- Migration 59: Add visibility and locked_at to collections
-- Documentation only — do NOT execute from application code.
-- Apply manually via Supabase dashboard or psql before Sprint 2 read-model changes.
-- Idempotent: safe to re-run.

ALTER TABLE collections ADD COLUMN IF NOT EXISTS visibility text NOT NULL DEFAULT 'private';
ALTER TABLE collections ADD COLUMN IF NOT EXISTS locked_at timestamptz DEFAULT NULL;

-- Domain constraint: visibility must be a known value (matches CollectionVisibility enum).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'collections_visibility_chk'
  ) THEN
    ALTER TABLE collections
      ADD CONSTRAINT collections_visibility_chk CHECK (visibility IN ('public', 'private'));
  END IF;
END $$;
