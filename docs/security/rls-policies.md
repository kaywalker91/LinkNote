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
