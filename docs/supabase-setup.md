# Supabase Setup Guide

LinkNote backend setup guide for Supabase.

---

## 1. Project Creation

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note your **Project URL** and **anon key** from Settings > API
3. Copy to `.env`:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

4. Regenerate environment constants:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 2. Authentication

Enable **Email/Password** provider in Authentication > Providers.

No OAuth providers are required. The app uses `signInWithPassword` and `signUp` only.

---

## 3. Database Schema

Run the following SQL in the SQL Editor (in order):

### 3.1 Tables

```sql
-- ============================================================
-- tags
-- ============================================================
CREATE TABLE public.tags (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name        text NOT NULL,
  color       text NOT NULL DEFAULT '#9E9E9E',
  UNIQUE (user_id, name)
);

-- ============================================================
-- collections
-- ============================================================
CREATE TABLE public.collections (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name            text NOT NULL,
  description     text,
  cover_image_url text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- links
-- ============================================================
CREATE TABLE public.links (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  url             text NOT NULL,
  title           text NOT NULL,
  description     text,
  thumbnail_url   text,
  collection_id   uuid REFERENCES public.collections(id) ON DELETE SET NULL,
  memo            text,
  is_favorite     boolean NOT NULL DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

-- Full-text search generated column
ALTER TABLE public.links
  ADD COLUMN fts tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english',
      coalesce(title, '') || ' ' ||
      coalesce(description, '') || ' ' ||
      coalesce(memo, '')
    )
  ) STORED;

CREATE INDEX links_fts_idx ON public.links USING gin(fts);

-- ============================================================
-- link_tags (join table)
-- ============================================================
CREATE TABLE public.link_tags (
  link_id uuid NOT NULL REFERENCES public.links(id) ON DELETE CASCADE,
  tag_id  uuid NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
  PRIMARY KEY (link_id, tag_id)
);
```

### 3.2 Indexes

```sql
CREATE INDEX links_user_id_idx ON public.links(user_id);
CREATE INDEX links_collection_id_idx ON public.links(collection_id);
CREATE INDEX links_created_at_idx ON public.links(created_at DESC);
CREATE INDEX collections_user_id_idx ON public.collections(user_id);
CREATE INDEX collections_created_at_idx ON public.collections(created_at DESC);
CREATE INDEX tags_user_id_idx ON public.tags(user_id);
CREATE INDEX link_tags_link_id_idx ON public.link_tags(link_id);
CREATE INDEX link_tags_tag_id_idx ON public.link_tags(tag_id);
```

### 3.3 Updated-at Trigger

```sql
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER links_updated_at
  BEFORE UPDATE ON public.links
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER collections_updated_at
  BEFORE UPDATE ON public.collections
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
```

---

## 4. Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE public.links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.link_tags ENABLE ROW LEVEL SECURITY;

-- links: owner-only access
CREATE POLICY "Users can CRUD own links"
  ON public.links FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- collections: owner-only access
CREATE POLICY "Users can CRUD own collections"
  ON public.collections FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- tags: owner-only access
CREATE POLICY "Users can CRUD own tags"
  ON public.tags FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- link_tags: access if user owns the link
CREATE POLICY "Users can manage tags on own links"
  ON public.link_tags FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.links
      WHERE links.id = link_tags.link_id
        AND links.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.links
      WHERE links.id = link_tags.link_id
        AND links.user_id = auth.uid()
    )
  );
```

---

## 5. Entity Relationship Diagram

```
auth.users (Supabase managed)
  ├── links.user_id         (1:N)
  ├── collections.user_id   (1:N)
  └── tags.user_id          (1:N)

collections
  └── links.collection_id   (1:N, nullable)

links ──┐
        ├── link_tags (M:N join)
tags  ──┘
```

---

## 6. Storage

No Supabase Storage buckets are required. Thumbnails and cover images are stored as external URLs (OG tag images fetched at link creation time).

---

## 7. Verification

After running all SQL, verify in the Table Editor that:

- [ ] 4 tables exist: `links`, `collections`, `tags`, `link_tags`
- [ ] RLS is enabled (lock icon) on all 4 tables
- [ ] Create a test user in Authentication > Users
- [ ] Run the Flutter app and sign in with the test user
- [ ] Create a link and verify it appears in the `links` table
