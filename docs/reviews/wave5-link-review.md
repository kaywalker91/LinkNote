# Wave 5 Code Review — Link 고급 시나리오

**Reviewer**: Claude Code (Session 32)
**Date**: 2026-04-15
**Baseline**: main `c94ea3b` (410 tests GREEN, analyze 0, CI 4/4 pass)
**Scope**: Wave 3 Link 리뷰 잔여 + 고급 시나리오 (URL sanitize 엣지, FetchMetadata 실패 경로, Share Intent, Provider 캐시 누수, moveToCollection cascade)
**Related**: `docs/review/wave3_link_review.md`, `docs/code_review/2026-04-13_wave2_core.md`

---

## Summary

| Severity | Count | Category |
|----------|-------|----------|
| P0       | 0     | - |
| P1       | 4     | OgTagService timeout/redirect/error UX + moveToCollection detail stale + Share Intent 부재 |
| P2       | 6     | URL edge(길이/IDN), OG 대용량, rollback, null→null invalidate, 잔여 P2-I |
| P3       | 6     | Wave 3 잔여 4건 + autoDispose 명시 + form dispose cancel |

**Total**: 16 findings (Wave 3 잔여 5건 롤오버 + Wave 5 신규 11건)

---

## Wave 3 잔여 (롤오버)

| Wave 3 ID | Wave 5 ID | 상태 확인 |
|-----------|-----------|-----------|
| P1-A/B/C/D | — | ✅ 모두 수정 완료 (Session 27) |
| P2-E/F/G/H/J/K/L | — | ✅ 모두 수정 완료 (Session 28) |
| **P2-I** | **P3-A'** | ❌ 잔존 — `link_repository_impl.dart:33-36` dead branch |
| **P3-C** | **P3-B'** | ❌ 잔존 — `LinkFormWidget` 미추출, ~50줄 중복 |
| **P3-D** | **P3-C'** | ❌ 잔존 — 태그 색상 `'#6750A4'` 하드코딩 |
| **P3-E** | **P3-D'** | ❌ 잔존 — i18n 혼재 (snackbar 한글 / AppBar 영문) |
| **P3-F** | **P3-E'** | ❌ 잔존 — `link_detail_screen.dart:37-39` favorite 토글 후 `linkDetailProvider` 미갱신 |

---

## P1 Findings (High)

### P1-A: OgTagService 실패 시 silent fail — UX 피드백 누락

**Files**: `lib/core/services/og_tag_service.dart:74-76`, `lib/features/link/presentation/provider/link_form_provider.dart:86`

```dart
} on Exception catch (_) {
  return const OgTagResult();
}
```

Dio timeout/네트워크 에러/malformed HTML 파싱 실패가 모두 `const OgTagResult()` 빈 결과로 수렴. form provider는 이를 "파싱 완료, 데이터 없음"으로 취급하여 사용자에게 실패 사유가 노출되지 않음. URL 오타/차단/타임아웃을 구분할 수 없다.

**Fix**: `Result<OgTagResult, Failure>` 반환으로 전환하거나, `LinkFormState`에 `ogParseError` 필드 추가 후 snackbar로 안내. 테스트: timeout/404/malformed HTML 각 경로에서 사용자 피드백 제공.

**재현**: 비접속 상태에서 URL 입력 → 10초 스피너 후 빈 상태, 에러 메시지 없음.

---

### P1-B: OgTagService 리다이렉트 정책 미검증 — HTTPS→HTTP downgrade 가능

**File**: `lib/core/services/og_tag_service.dart` (Dio 인스턴스 설정)

Dio 기본값은 `followRedirects: true, maxRedirects: 5`. HTTPS 입력이 HTTP로 리다이렉트돼도 따라감 → 중간자 공격 surface + 첩보 서버가 fetch 대상을 임의 제어 가능.

**Fix**:
- 옵션 1: `followRedirects: false` 후 3xx 응답 시 Location 헤더 검증(https 스킴만 허용) 수동 follow
- 옵션 2: `maxRedirects: 2` + 각 hop에서 scheme downgrade 차단 인터셉터

테스트: 3xx 응답 모킹으로 redirect chain 검증.

---

### P1-C: OgTagService 타임아웃/대용량 테스트 전무

**Files**: `test/core/services/` 에 `og_tag_service_test.dart` **없음**

OgTagService는 link 저장 플로우의 핵심 경로지만 단위 테스트가 0건. timeout / 4xx / 5xx / malformed HTML / UTF-8 깨짐 / 대용량 응답(10MB 이상) 모두 미검증.

**Fix**: `MockAdapter` 또는 `DioAdapter`로 경로별 테스트 추가 (10+ cases). 커버리지 목표: 타임아웃, HTTP 에러, 성공 파싱, og 태그 없음, charset 이슈, redirect.

---

### P1-D: moveToCollection 성공 후 `linkDetailProvider` 미갱신

**File**: `lib/features/link/presentation/provider/link_list_provider.dart:151-162`

```dart
ref
  ..invalidate(collectionLinksProvider(existing.collectionId!))
  ..invalidate(collectionDetailProvider(existing.collectionId!));
// ... linkDetailProvider(linkId) 누락
ref.invalidate(collectionListProvider);
```

LinkDetail 화면에서 "Move to Collection" 실행 → 성공했지만 detail의 `collectionId` 필드가 stale. 사용자가 같은 화면에 머무르면 변경이 반영되지 않음.

**Fix**: 성공 경로에 `ref.invalidate(linkDetailProvider(linkId))` 추가. cascade 연산자 체인에 결합.

**재현**: 실기기 QA — LinkDetail에서 이동 후 collection badge 미갱신.

**Related memory**: `~/.claude/projects/-Users-kaywalker-AndroidStudioProjects-LinkNote/memory/feedback_aggregate_invalidate.md`

---

## P2 Findings (Medium)

### P2-A: URL 길이 제한 없음 — DOS 위험

**File**: `lib/shared/utils/url_sanitizer.dart`

정규식 `r'https?://\S+'`에 길이 상한 없음. 공유 텍스트로 수MB URL이 들어오면 파싱/DB/네트워크 전 경로가 비정상 지연.

**Fix**: `\S{1,2048}` 상한 + Uri 파싱 전 길이 사전 검증. 테스트: 2049자 URL 거부.

---

### P2-B: IDN (유니코드 도메인) 미테스트

**File**: `test/shared/utils/url_sanitizer_test.dart`

`https://münchen.de`, `https://日本.jp` 등 IDN 입력 시 `Uri.tryParse` 동작이 미검증. Punycode 변환 정책 부재.

**Fix**: IDN 입력 허용 또는 거부 정책 결정 후 테스트 추가. 허용 시 `Uri.parse(...).host`가 punycode(xn--...) 로 정규화되는지 확인.

---

### P2-C: OgTagService 대용량 응답 미검증

**File**: `lib/core/services/og_tag_service.dart`

`receiveTimeout: 10s`만 있음. 10MB HTML은 타임아웃 내 수신 가능하지만 메모리 비효율. max body size 제한 없음.

**Fix**: Dio `ResponseType.plain` + 스트림 커트오프 또는 `contentLength > maxBytes` 헤더 검사. 테스트: 1MB 응답에서 조기 중단.

---

### P2-D: moveToCollection optimistic rollback 부재

**File**: `lib/features/link/presentation/provider/link_list_provider.dart:122-163`

실패 시 `Error.throwWithStackTrace`만 수행. 이미 낙관적으로 바뀐 UI 상태는 invalidate 타이밍에만 복구됨. 롤백 path가 explicit하지 않음.

**Fix**: `deleteLink`/`toggleFavorite` 패턴과 유사하게 rollback 명시. 사용자 snackbar "이동 실패 — 되돌렸습니다" 제공.

---

### P2-E: null → null 컬렉션 이동 불필요 invalidate

**File**: `link_list_provider.dart:151,157`

`existing.collectionId == null && collectionId == null` 경우 양쪽 조건이 모두 false → 잘못된 invalidate는 없지만, 상위에서 early return이 없어 무의미한 원격 호출 수행. UX 영향은 미미.

**Fix**: 메서드 상단에 `if (existing.collectionId == collectionId) return;` 가드.

---

### P2-I (잔존): Repository `getLinks` dead branch

**File**: `lib/features/link/data/repository/link_repository_impl.dart:33-36`

if/else 양 분기가 동일한 `cacheLinks` 호출. 조건부 제거 후 단일 호출.

---

## P3 Findings (Nit)

### P3-A: Share Intent 진입점 부재 (feature request 성격) — ⏭️ Deferred (Session 35)

**Files**: `android/app/src/main/AndroidManifest.xml`, iOS Info.plist, `lib/main.dart`

`ACTION_SEND` intent-filter 없음. 브라우저 "공유 → LinkNote" 불가. Wave 5 리뷰 스코프로 식별됐으나 "버그"가 아닌 **미구현 기능**이므로 P3로 분류하고 별도 로드맵 항목으로 관리.

**Decision (2026-04-18, Session 35)**: 본 스프린트에서 제외하고 별도 Wave(가칭 "Share Intent Wave")로 이관. 구현 이전에 PRD에서 다음을 확정해야 함:

- 수신 payload 타입: URL / plain text / image — 각 케이스 UX 분기
- 앱 상태별 동작: cold start / warm resume — 라우팅 정책
- 권한 / iOS App Extension 필요성
- 패키지 후보: `receive_sharing_intent` vs Flutter 공식 플랫폼 채널

**Next step**: Share Intent PRD 초안을 별도 문서로 작성한 뒤 Wave 진입.

---

### P3-B: Provider autoDispose 명시

**Files**: `link_list_provider.dart`, `link_detail_provider.dart`, `link_form_provider.dart`

`@riverpod`의 keepAlive 정책이 소스에서 불명확. 코드 리뷰어가 의도를 추론해야 하는 상태.

**Fix**: 각 provider에 `@Riverpod(keepAlive: true/false)` 명시.

---

### P3-C: LinkFormProvider dispose 시 CancelableOperation cancel 누락

**File**: `link_form_provider.dart:37`

`_pendingOgParse` 필드는 새 parse 시에만 `cancel()` 호출. form 자체가 dispose될 때 cancel 여부 미검증.

**Fix**: `@riverpod` dispose lifecycle(`ref.onDispose`)에 `_pendingOgParse?.cancel()` 추가.

---

### P3-D' (잔존): LinkFormWidget 미추출 — add/edit 중복 ~50줄

### P3-C' (잔존): 태그 색상 `'#6750A4'` 하드코딩 (add/edit screens)

### P3-E' (잔존): `link_detail_screen.dart:37-39` favorite 토글 후 `linkDetailProvider` 미갱신

---

## 테스트 커버리지 갭

| 대상 | 현재 | 필요 |
|------|------|------|
| `og_tag_service.dart` | 0 tests | 10+ (timeout/4xx/5xx/malformed/large/redirect/charset) |
| `url_sanitizer` 엣지 | 13 tests | +3 (2049자, IDN, fragment) |
| moveToCollection detail invalidate | 4 tests (list 측) | +1 (detail invalidate 검증) |
| Share Intent | 0 | 별도 Wave |

---

## Fix Sprint 우선순위 권장

### P1 (필수, Session 32 스프린트)
1. **P1-D** — moveToCollection `linkDetailProvider` invalidate 추가 (1줄 + 테스트 1건)
2. **P1-A** — OgTagService 실패 UX 피드백 (Result/Failure 전환 + form에 error 노출)
3. **P1-C** — `og_tag_service_test.dart` 신규 (10+ cases)
4. **P1-B** — redirect 정책 명시 (`followRedirects: false` or scheme 검증 인터셉터)

### P2 (가능하면 같이)
- **P2-A** (URL 길이), **P2-I** (dead branch) — 1줄 수정, low risk

### P3 (Session 33 이월)
- P3-A Share Intent는 별도 PRD 이후
- 잔여 P3 리팩터링은 별도 cleanup PR

---

## 불변 원칙 (Wave 5)

- **TDD RED → GREEN**: P1-C는 RED 테스트 먼저 작성하여 실패 확인 후 구현
- **cascade invalidate**: P1-D는 Session 31 교훈 `feedback_aggregate_invalidate.md` 재확인
- **Provider Failure 전파**: `Error.throwWithStackTrace(failure, StackTrace.current)` 패턴 유지
- **docs-only PR 금지**: 본 리뷰 문서 + P1 fix 코드를 한 PR로 묶음
- **실기기 QA**: moveToCollection detail 화면 갱신, OgTag 타임아웃 UX
