# Supabase Row Level Security (RLS) Policies

LinkNote의 모든 Supabase 테이블은 **Row Level Security(RLS)**가 반드시 활성화되어 있어야 한다.
클라이언트에서 `user_id` 필터를 추가하는 것은 **방어 심층(defense in depth)** 목적일 뿐, 실질
격리는 DB 레벨에서 수행된다.

## 원칙

1. 인증된 사용자는 본인 소유(`user_id = auth.uid()`) 레코드만 조회/수정/삭제할 수 있다.
2. INSERT 시 `user_id`는 반드시 `auth.uid()`와 동일해야 한다.
3. 익명 사용자는 모든 쓰기 권한에서 배제된다.
4. 클라이언트 쿼리에서도 `.eq('user_id', userId)` 필터를 유지한다 — RLS 설정 누락/롤백
   시 즉시 실패하도록 조기 경보 역할.

## collections 테이블

```sql
-- 1. RLS 활성화 (한 번만 실행)
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;

-- 2. SELECT: 본인 컬렉션만 조회
CREATE POLICY "collections_select_own"
  ON public.collections
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- 3. INSERT: user_id 는 반드시 현재 사용자
CREATE POLICY "collections_insert_own"
  ON public.collections
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- 4. UPDATE: 본인 컬렉션만
CREATE POLICY "collections_update_own"
  ON public.collections
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- 5. DELETE: 본인 컬렉션만
CREATE POLICY "collections_delete_own"
  ON public.collections
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
```

## visibility 컬럼과 RLS

`collections.visibility`(`'public'` | `'private'`, migration_59)와 in-app 토글
(#54)은 **읽기 접근 제어를 변경하지 않는다**. 위 `collections_select_own`
정책은 `user_id = auth.uid()` owner-only 이므로:

- `private` 는 **이미 강제됨** — 비소유자는 visibility 값과 무관하게 어떤 행도
  읽을 수 없다. 별도 정책이 필요 없다.
- `public` 은 현재 **백엔드 무효과** — 비소유자/익명 read 경로가 클라이언트
  코드에도, RLS 에도 존재하지 않는다. pill·토글 UI 표시용 마커일 뿐이다.

owner-only 를 유지하는 것이 의도된 설계다(Session 64 결정). `public` 컬렉션을
비소유자에게 노출하려면 SELECT 정책에 `OR visibility = 'public'` 을 추가해야
하는데, 이는 **데이터 노출 경로를 신설**하므로 공유/공개 뷰 기능을 실제로
구현하는 별도의 의도적 결정에서만 수행한다. migration_63 은 이 owner-only
정책을 멱등하게 재선언해 private 보장을 버전 관리에 명문화한다.

> ⚠️ `getCollections`(목록 조회)는 명시적 `.eq('user_id', ...)` 필터 없이 RLS
> 에만 의존한다. 따라서 위 정책이 라이브 DB 에 **실제 enable** 되어 있어야
> 격리가 성립한다. 적용·검증은 Supabase 대시보드 액세스가 필요하다.

## links 테이블

```sql
ALTER TABLE public.links ENABLE ROW LEVEL SECURITY;

CREATE POLICY "links_select_own" ON public.links
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY "links_insert_own" ON public.links
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "links_update_own" ON public.links
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY "links_delete_own" ON public.links
  FOR DELETE TO authenticated USING (user_id = auth.uid());
```

## tags / collection_links 등 조인 테이블

조인 테이블은 관련 부모 레코드 소유자 기준으로 조건을 건다.

```sql
-- 예: collection_links (collection_id, link_id)
ALTER TABLE public.collection_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY "collection_links_own" ON public.collection_links
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.collections c
      WHERE c.id = collection_id AND c.user_id = auth.uid()
    )
  );
```

## 클라이언트의 이중 필터 이유

- RLS가 정확히 설정되었더라도 **마이그레이션 누락·정책 롤백·개발 DB 설정 오류**가 발생할 수 있다.
- 클라이언트 쿼리에 `.eq('user_id', userId)`를 유지하면:
  - RLS 해제 시 데이터 노출을 **앱 레벨에서 차단**.
  - 정책 버그가 쿼리 단위 로그로 조기 포착.
  - 서버 쿼리 플래너가 추가 필터를 인덱스와 결합해 성능 저하가 거의 없음.

## 검증 체크리스트

Supabase 대시보드 → Authentication → Policies 에서 다음을 확인:

- [ ] 모든 프로덕션 테이블에 RLS enabled 표시
- [ ] 각 테이블마다 SELECT/INSERT/UPDATE/DELETE 정책이 존재
- [ ] `anon` 역할에 부여된 정책 없음 (public read가 필요한 경우만 예외)
- [ ] 테스트 스크립트로 타 유저 레코드 접근 시 empty result / 403 확인

## 참고

- Supabase RLS 공식 문서: https://supabase.com/docs/guides/auth/row-level-security
- Postgres RLS: https://www.postgresql.org/docs/current/ddl-rowsecurity.html
