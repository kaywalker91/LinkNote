# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 32 — Wave 5 범위 결정 (Link 고급 시나리오 or Tag or Notification)

## 미션 한 줄

Wave 4 Collection 리뷰가 완료되었으므로, Wave 5 리뷰 대상 feature를 결정하고 착수한다.

## 배경

Session 31에서:
- Wave 4 P2/P3 6건 완전 수정 (P2-A/B/C/D, P3-A/B)
- `collection_remote_datasource_test.dart` / `collection_detail_provider_test.dart` 신규 (13 tests)
- 베이스라인: **406 tests GREEN**, analyze 0, CI 4 job green
- PR #12 머지 완료 (예정)

후보 Wave 5 대상:

1. **Link 고급 시나리오** — 즐겨찾기 토글, 컬렉션 간 이동, 대용량 스크랩 에러 핸들링
2. **Tag feature** — 아직 code review 수행되지 않음 (저장/조회/연결 레이어 전체)
3. **Notification feature** — FCM 수신 경로 + Hive 저장 + 화면 표시 플로우
4. **공통 Core** — network retry, offline queue, Firebase Crashlytics/Analytics 연동 검증

현재 상태:
- **브랜치**: main (clean)
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **docs-only 단독 PR 금지** 원칙 유지

## 가장 먼저 할 일 (순서 엄수)

### 0. 상태 확인 + Wave 5 대상 결정
```bash
cd ~/AndroidStudioProjects/LinkNote
git status && git log --oneline -5
flutter analyze --fatal-warnings
flutter test --reporter compact 2>&1 | tail -3   # 406 GREEN 확인
```

사용자와 Wave 5 대상 협의 후 리뷰 진행:
- 리뷰 문서 포맷은 `docs/review/wave4_collection_review.md` 참조
- P0~P3 심각도 분류 + 파일:line 참조 + 수정 권장안 포함

### 1. 브랜치 생성 (wave 5 리뷰 브랜치)
```bash
git checkout -b chore/wave5-review
```

### 2. 리뷰 작성
- `docs/review/wave5_<feature>_review.md` 신규
- Review checklist:
  - 아키텍처 레이어 경계 (presentation ↔ domain ↔ data)
  - Result/Failure 전파 경로
  - Provider 생명주기 + 캐시 invalidate 누락
  - 테스트 커버리지 갭 (remote datasource, provider)
  - RLS/보안 취약점
  - UX 에러 핸들링

### 3. 리뷰 PR 머지 후 P0/P1 수정 스프린트

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **TDD RED → GREEN** 준수
- `.env`, keystore, Firebase service account key 커밋 금지
- Provider Failure 전파는 `Error.throwWithStackTrace(failure, StackTrace.current)` 패턴 사용
- docs-only 단독 PR 지양 — 코드와 묶음

## 완료 기준

- [ ] Wave 5 대상 feature 합의
- [ ] 리뷰 문서 작성 + PR 머지
- [ ] P0/P1 수정 + 테스트 + PR 머지
- [ ] Session 32 daily log + memory 업데이트

## 참조 문서

- **Wave 4 리뷰**: `docs/review/wave4_collection_review.md`
- **Session 31 로그**: `docs/daily_task_log/2026-04-17_session31.md`
- **RLS 정책**: `docs/security/rls_policies.md`

## Session 31 lessons (반드시 검토)

- **`dart:core Iterable.firstOrNull`**: `package:collection` 없이도 `.where(...).firstOrNull` 패턴으로 해결. Dart 3.0+ 기본 제공
- **Invalidate 테스트**: family provider(`fooProvider(id)`) 무효화 검증은 `container.listen`으로 kept-alive 구독 + 사용량 카운터 mock으로 재호출 횟수 측정이 표준 패턴
- **cascade_invocations lint**: `ref.invalidate(a); ref.invalidate(b);` 2줄 구조는 lint 위반 → `ref..invalidate(a)..invalidate(b)` cascade로 통일

## 세션 경계

Wave 5 리뷰 작성 + P0/P1 수정 PR 머지까지. Wave 5의 P2/P3는 Session 33에서.
```
