-- Migration 64: Public collection read-only share (non-owner read path).
-- Documentation only — do NOT execute from application code.
-- Apply manually via Supabase dashboard or psql.
-- Idempotent: safe to re-run (DROP POLICY IF EXISTS + CREATE).
--
-- Context
-- -------
-- Through migration_63, collections were strictly owner-only and `visibility`
-- ('public'|'private') had NO backend access-control effect — it drove the pill
-- and toggle UI only. The "public/share view" deferred there is now implemented
-- (Session 65): a logged-in non-owner can open a `public` collection read-only
-- via a `linknote://collections/public/<id>` deep link.
--
-- This migration opens the deliberate, documented data-exposure path:
--   1. collections SELECT: owner OR any authenticated user when public.
--   2. links SELECT: an additive policy allowing read when the parent
--      collection is public (links_select_own stays intact for owners).
-- Audience is `authenticated` only — the `anon` role is NOT granted any policy,
-- so public collections are not exposed to unauthenticated/web callers.

ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;

-- SELECT: owner OR any authenticated user when the collection is public.
-- Replaces the owner-only `collections_select_own` from migration_63.
DROP POLICY IF EXISTS "collections_select_own" ON public.collections;
DROP POLICY IF EXISTS "collections_select_own_or_public" ON public.collections;
CREATE POLICY "collections_select_own_or_public"
  ON public.collections
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR visibility = 'public');

ALTER TABLE public.links ENABLE ROW LEVEL SECURITY;

-- SELECT (additive): read a link when its parent collection is public.
-- Postgres ORs multiple permissive SELECT policies, so `links_select_own`
-- (owner-only) remains intact; this only widens reads, never writes.
DROP POLICY IF EXISTS "links_select_public_collection" ON public.links;
CREATE POLICY "links_select_public_collection"
  ON public.links
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.collections c
      WHERE c.id = links.collection_id
        AND c.visibility = 'public'
    )
  );

-- INSERT/UPDATE/DELETE on both tables remain owner-only (unchanged), so a
-- non-owner's access to a public collection is strictly read-only.
--
-- Verification (run as a NON-owner authenticated session):
--   SELECT count(*) FROM public.collections WHERE visibility = 'public';  -- > 0
--   SELECT count(*) FROM public.collections WHERE visibility = 'private'; -- 0
--   SELECT count(*) FROM public.links
--     WHERE collection_id IN (
--       SELECT id FROM public.collections WHERE visibility = 'public'
--     ); -- returns the public collection's links; private stay hidden.
--
-- NOTE: applying/verifying against the live dev/staging/prod DB requires
-- Supabase dashboard access, currently blocked (see next-session prompt
-- "알려진 인접 이슈"). Until applied live, non-owner reads return zero rows and
-- the client feature is inert for its actual audience — migration application
-- is a hard release gate. This file is the source of truth for the policy.
