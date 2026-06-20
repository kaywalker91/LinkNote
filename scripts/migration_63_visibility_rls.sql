-- Migration 63: Make collection RLS visibility-aware (private enforcement)
-- Documentation only — do NOT execute from application code.
-- Apply manually via Supabase dashboard or psql.
-- Idempotent: safe to re-run (DROP POLICY IF EXISTS + CREATE).
--
-- Context
-- -------
-- Session 59/60 (#46/#47) added `collections.visibility` ('public'|'private')
-- and `locked_at` as a read-model attribute (migration_59.sql). Session 63
-- (#54) shipped the in-app visibility/lock toggle. The toggle persists the
-- field, but `visibility` had NO backend access-control effect: the app reads
-- collections owner-scoped only (RLS + explicit `.eq('user_id', ...)` on single
-- rows; `getCollections` relies on RLS alone), and there is no public/anon read
-- path anywhere in the client.
--
-- Decision (Session 64): keep collections strictly owner-only. `private` is
-- therefore ALREADY enforced — a non-owner can read neither public nor private
-- rows. `public` remains a display-only marker (drives the pill + toggle UI)
-- with no backend effect, by design. Opening a non-owner read path for public
-- collections is deferred to a deliberate future "public/share view" feature
-- (see docs/security/rls-policies.md → "visibility 컬럼과 RLS").
--
-- This migration re-asserts the owner-only SELECT policy idempotently so the
-- private guarantee is explicit and version-controlled alongside the feature.
-- It intentionally does NOT add `OR visibility = 'public'`.

ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;

-- SELECT: owner-only. This is what enforces `visibility = 'private'`.
-- A row is readable iff the caller owns it, regardless of visibility value.
DROP POLICY IF EXISTS "collections_select_own" ON public.collections;
CREATE POLICY "collections_select_own"
  ON public.collections
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Verification (run as a non-owner session; both must return zero rows):
--   SELECT count(*) FROM public.collections WHERE visibility = 'private';
--   SELECT count(*) FROM public.collections WHERE visibility = 'public';
--
-- NOTE: applying/verifying against the live dev/staging DB still requires
-- Supabase dashboard access, which is currently blocked (see next-session
-- prompt "알려진 인접 이슈"). This file is the source of truth for the intended
-- policy until that access is restored.
