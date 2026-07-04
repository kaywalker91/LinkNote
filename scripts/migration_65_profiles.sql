-- migration_65_profiles.sql
-- 목적: `profiles` 테이블 + 가입 시 자동 행 생성 트리거 + RLS + 백필.
-- 배경: 앱은 profiles 테이블을 .single()로 조회하지만(profile_remote_datasource.dart),
--       supabase-setup.md 스키마에 profiles 테이블/트리거가 없어 prod에 미존재 → 프로필 화면 "서버 오류".
-- 성격: 멱등(idempotent). prod SQL Editor에서 그대로 실행. 실행 후 이미 설치된 앱이 재빌드 없이 정상화됨.
-- 컬럼 근거: lib/features/profile/data/dto/user_profile_dto.dart
--   id(required), email(required, non-null), display_name?, avatar_url?,
--   link_count(default 0), collection_count(default 0), created_at?, updated_at?

-- 1) profiles 테이블 (base table — updateProfile 이 update() 하므로 뷰 불가)
create table if not exists public.profiles (
  id               uuid primary key references auth.users(id) on delete cascade,
  email            text not null default '',
  display_name     text,
  avatar_url       text,
  link_count       integer not null default 0,
  collection_count integer not null default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- 2) RLS: 본인 행만 select/update
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select to authenticated
  using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- 3) 신규 가입 시 profiles 행 자동 생성 (SECURITY DEFINER 로 RLS 우회 insert)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, coalesce(new.email, ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4) 기존 사용자 백필 (이미 가입한 내부 테스트 계정의 행 생성 → 현재 빌드 즉시 복구)
insert into public.profiles (id, email)
select u.id, coalesce(u.email, '')
from auth.users u
on conflict (id) do nothing;

-- 5) 카운트 초기값 백필 (프로필 화면의 링크/컬렉션 개수가 0으로 보이지 않도록)
update public.profiles p set
  link_count       = coalesce((select count(*) from public.links       l where l.user_id = p.id), 0),
  collection_count = coalesce((select count(*) from public.collections c where c.user_id = p.id), 0);

-- 6) 카운트 동기화 트리거 (링크/컬렉션 추가·삭제 시 profiles 카운트 갱신)
--    ※ 정확한 카운트가 필요 없으면 6번 블록은 생략 가능(그 경우 카운트는 5번 백필 시점 값으로 고정).
create or replace function public.sync_profile_counts()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := coalesce(new.user_id, old.user_id);
begin
  update public.profiles p set
    link_count       = coalesce((select count(*) from public.links       l where l.user_id = uid), 0),
    collection_count = coalesce((select count(*) from public.collections c where c.user_id = uid), 0)
  where p.id = uid;
  return coalesce(new, old);
end;
$$;

drop trigger if exists links_sync_profile_counts on public.links;
create trigger links_sync_profile_counts
  after insert or delete on public.links
  for each row execute function public.sync_profile_counts();

drop trigger if exists collections_sync_profile_counts on public.collections;
create trigger collections_sync_profile_counts
  after insert or delete on public.collections
  for each row execute function public.sync_profile_counts();
