-- migration_66_orphan_tags.sql
-- 목적: 링크에 더 이상 연결되지 않은 "고아 태그"를 DB 원천에서 제거.
--       (1) AFTER DELETE 트리거로 앞으로 생기는 고아를 즉시 정리
--       (2) 현재 쌓여 있는 기존 고아를 1회성으로 청소
-- 배경: link_tags 는 (link_id, tag_id) 모두 ON DELETE CASCADE 지만, 링크를 삭제하면
--       연결 행(link_tags)만 사라지고 tags 행은 아무도 지우지 않아 서치탭 태그 목록에
--       고아 태그가 계속 노출됨 (search_remote_datasource.fetchUserTags). 링크 수정 시
--       태그를 떼어내는 경로(_syncTags 의 stale link_tags 삭제)에서도 동일하게 발생.
-- 성격: 멱등(idempotent). prod SQL Editor 에서 그대로 실행. 클라이언트 코드는 이 트리거가
--       없어도 정상 동작(fetchUserTags 가 inner join 으로 이미 고아를 숨김)하므로 배포 순서
--       제약 없음. 이 마이그레이션은 UI 회피가 아닌 DB 원천 정리를 담당.
-- 전제: lib/features/link/data/datasource/link_remote_datasource.dart 의 _syncTags 는
--       "연결 upsert → stale 연결만 delete" 순서여야 함(add-before-remove). 그래야 이 트리거가
--       유지되는 태그를 순간적으로 0-링크로 오판해 삭제하는 일이 없음.

-- 1) 고아 정리 함수: 방금 삭제된 link_tags 의 tag_id 가 더 이상 어떤 링크에도
--    연결돼 있지 않으면 tags 에서 해당 태그를 삭제.
--    SECURITY DEFINER 로 RLS 를 우회해, cascade 삭제(트리거가 auth 컨텍스트 밖에서
--    발화하는 경우 포함)에서도 확실히 정리되도록 함.
create or replace function public.cleanup_orphan_tag()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if not exists (
    select 1 from public.link_tags lt where lt.tag_id = old.tag_id
  ) then
    delete from public.tags t where t.id = old.tag_id;
  end if;
  return old;
end;
$$;

-- 2) link_tags 행 삭제(직접 삭제 + 링크 cascade 삭제 모두 포함) 후 발화하는 row 트리거.
--    링크 삭제·태그 교체 모든 경로를 DB 한 곳에서 커버.
drop trigger if exists link_tags_cleanup_orphan_tag on public.link_tags;
create trigger link_tags_cleanup_orphan_tag
  after delete on public.link_tags
  for each row execute function public.cleanup_orphan_tag();

-- 3) 1회성 청소: 현재 어떤 link_tags 에도 참조되지 않는 기존 고아 태그 일괄 삭제.
--    (참고) 이 앱은 태그를 링크 저장 경로(_syncTags)에서만 생성하므로, link_tags 참조가
--    전혀 없는 tags 행은 항상 삭제로 인해 남겨진 고아임.
delete from public.tags t
where not exists (
  select 1 from public.link_tags lt where lt.tag_id = t.id
);
