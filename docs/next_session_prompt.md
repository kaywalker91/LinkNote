# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Phase 4 구현 — Link 로컬 캐시 (Hive CE) + Remote-First/Local-Fallback

## 배경
- 2026-04-11 세션에서 Widget 테스트 보강 완료 (9b5a492). 60파일, 257 테스트 ALL GREEN.
- P0~P2 코드리뷰 로드맵 전체 완료.
- Phase 4 리서치/플랜 문서 이미 작성 완료:
  - `docs/research-phase4.md` — 현재 아키텍처 분석 + 캐시 전략 설계
  - `docs/plan-phase4.md` — 4단계 구현 계획 (4파일: 1 신규 + 3 수정)

## 목표
Link feature에 Hive CE 기반 로컬 캐시를 추가하여 오프라인 읽기를 지원한다.

## 구현 범위 (docs/plan-phase4.md 참조)

### Step 1: LinkLocalDataSource 생성
- `lib/features/link/data/datasource/link_local_datasource.dart` (신규)
- Box<Map> 사용, link.id를 key로 저장
- getCachedLinks, getCachedLinkById, cacheLinks, cacheSingleLink, removeCachedLink, updateCachedFavorite, clearAll

### Step 2: storage_service.dart 수정
- `initHive()`에 `'links'` Hive box 열기 추가

### Step 3: LinkRepositoryImpl 수정
- 생성자에 LinkLocalDataSource 추가
- Remote-First + Local-Fallback 패턴 적용

### Step 4: DI Provider 수정
- `link_di_providers.dart`에 linkLocalDataSourceProvider 추가
- linkRepositoryProvider 생성자에 local DS 전달

## 테스트 (TDD)
- LinkLocalDataSource 단위 테스트 (CRUD 동작)
- LinkRepositoryImpl 테스트 업데이트 (remote 실패 시 local fallback 검증)

## 수정하지 않는 것
- ILinkRepository 인터페이스 — 불변
- UseCase, Provider, Screen — Repository 내부 구현만 변경

## 완료 기준
- flutter analyze 0 errors
- flutter test ALL GREEN
- 오프라인 시 캐시된 링크 목록 표시 확인
- 커밋 + 푸시 (사용자 승인 후)
```
