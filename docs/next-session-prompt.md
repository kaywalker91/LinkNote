# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 38 — Share Intent Phase 1: Android URL-only PoC 구현 + Session 37 PRD 갱신 동반 PR

## 미션 한 줄

`receive_sharing_intent` 1.8.1 도입 + Android ACTION_SEND 수신 → cold start 시 GoRouter `initialLocation` 분기 → `link/add` 폼 prefill 까지 구현하고 실기기 검증 후 Session 37 PRD Decided 커밋과 함께 PR 을 낸다.

## 배경

최근 세션 히스토리:
- **Session 36 (2026-04-18)** — Share Intent PRD Draft 작성 + Wave 3 i18n 확장 (PR #17, `0b2b59a`)
- **Session 37 (2026-04-21)** — Open Decision 4건 합의 → PRD Decided 승격. Phase 1 착수는 세션 경계 판단으로 Session 38 이월. 산출물은 로컬 브랜치 `docs/session37-share-intent-decided` 에 보관 (원격 push 미수행)

현재 상태 (Session 38 시작 전):
- `main` @ `0b2b59a`, 원격 깨끗
- 로컬 브랜치 `docs/session37-share-intent-decided` 에 PRD 갱신 커밋 존재 — **Session 38 에서 이 브랜치를 기반으로 확장**
- 437 tests GREEN, analyze 0
- Branch Protection 활성화 — PR + CI 4 job green 필수

## Phase 1 범위 (PRD Section 3 Decided 에 기반)

- **Android only** (iOS Share Extension 은 Phase 2)
- **URL payload only** (plain text / image 는 Phase 3+)
- **Cold start**: GoRouter `initialLocation` 동적 분기 `/link/add?prefill=<encoded-url>`
- **Warm / foreground**: bottom sheet (작업 중 입력 보호) — Phase 1 후반 또는 연장 범위
- **패키지**: `receive_sharing_intent` 1.8.1

## 가장 먼저 할 일 (순서 엄수)

### 0. 상태 확인 + 브랜치 정렬
```bash
cd ~/AndroidStudioProjects/LinkNote
git fetch origin
git branch -vv                                    # docs/session37-share-intent-decided 확인
git checkout docs/session37-share-intent-decided  # Session 37 PRD 갱신 베이스
git log -1                                        # Session 37 커밋 확인
flutter analyze --fatal-warnings
flutter test --reporter=failures-only 2>&1 | tail -3   # +437 기대
```

> 브랜치 리네임 필요 시: Phase 1 코드와 섞이므로 `feat/share-intent-phase1-android` 로 리네임 권장 — `git branch -m feat/share-intent-phase1-android`

### 1. Plan 작성 (ai-coding-pipeline Stage 2)

5+ 파일 변경 + 플랫폼 설정 + 부트 시퀀스 개편이라 Plan 필수. 작성 포인트:
- `receive_sharing_intent` API 최신 사용법 Context7 조회 — getter(`getInitialMedia`/`getInitialText`) vs stream 구분
- `bootstrap.dart` 의 현재 부트 순서와 `runApp` 호출 지점 확인 → initial payload 조회 삽입 위치
- `app_router.dart` 의 `initialLocation: Routes.splash` 와 splash redirect 로직에 payload 우회 경로 설계
- `LinkAddScreen` 이 현재 `const` 인스턴스 — `prefill` 파라미터 확장 시 기존 라우트 호출부 영향

### 2. TDD RED → GREEN (Domain 선행)

필수 적용 레이어(TDD 강제):
- `lib/features/share_intent/domain/service/shared_intent_service.dart` (신규) — payload → URL 추출 + `UrlSanitizer` 재사용
- `test/features/share_intent/domain/shared_intent_service_test.dart` — RED 케이스:
  - plain URL payload → 정상 추출
  - "제목 + URL" 혼합 텍스트 payload → URL 만 추출 (Session 19 URL sanitizer 3계층 배치 적용)
  - URL 없는 텍스트 → 실패 (`Failure` 반환)
  - malformed URL → 실패
- Domain 레이어 GREEN 확인 후 Presentation / bootstrap 진입

### 3. 플랫폼 설정 (Android)

- `pubspec.yaml` — `receive_sharing_intent: ^1.8.1` 추가 (알파벳 순)
- `flutter pub get`
- `android/app/src/main/AndroidManifest.xml` — `<activity>` 내부에 `<intent-filter>` 추가
  - `ACTION_SEND` + `category.DEFAULT` + `mimeType="text/plain"`
  - 필요 시 `ACTION_SEND` + `mimeType="text/*"` 도 (Twitter/YouTube 동작 확인)

### 4. 부트 시퀀스 + 라우트 분기

- `lib/bootstrap.dart` — `runApp` 전에 `ReceiveSharingIntent.getInitialText()` 호출 후 `ProviderScope.overrides` 로 GoRouter initial payload 주입 (또는 일회성 `initialLocation` 계산)
- `lib/app/router/app_router.dart`:
  - `Routes.linkAdd` 의 `builder` 가 `state.uri.queryParameters['prefill']` 조회 → `LinkAddScreen(initialUrl: ...)` 로 전달
  - 또는 `GoRouter.initialLocation` 을 payload 기준으로 동적 계산 (splash auth flow 와 충돌 주의 — 인증 완료 후 home 대신 linkAdd 로 redirect 하는 경로가 더 안전할 가능성)
- `lib/features/link/presentation/screens/link_add_screen.dart` — `initialUrl` 파라미터 추가, URL 필드 초기값 세팅

### 5. Widget 테스트

- `LinkAddScreen(initialUrl: 'https://example.com')` → URL 필드가 해당 값으로 초기화되는지
- (시간 허락 시) GoRouter prefill query → `LinkAddScreen` 초기값 전달 플로우

### 6. 실기기 / 에뮬레이터 검증

- YouTube / Chrome / Twitter 공유 시트 → LinkNote 선택 → 폼 prefill 확인 (최소 2 앱)
- Cold start / warm resume 각각 검증
- URL sanitizer 3계층 배치가 Session 19 때처럼 작동하는지 확인 ("제목 + URL" 페이스트 방지)

### 7. PRD / memory / 문서

- `docs/prds/share-intent.md` Section 7 결정 로그 — "2026-xx-xx Phase 1 구현 완료 (Session 38)" entry 추가
- 신규 memory: `project_share_intent.md` — Phase 1 Android PoC 완료, Phase 2 iOS Extension 대기 상태
- `docs/daily_task_log/YYYY-MM-DD_session38.md`
- CHANGELOG Session 38 섹션
- `project_code_review_roadmap.md` Session 38 항목

### 8. PR + 머지

- 브랜치: `feat/share-intent-phase1-android` (Session 37 docs 커밋 포함)
- PR 제목: `feat(share-intent): Phase 1 Android URL-only PoC + PRD Decided`
- CI 4 job green 확인 후 **사용자 명시 승인** → merge

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection** — PR + CI 4 job green 필수
- **TDD RED → GREEN** — Domain `SharedIntentService` 예외 없이 RED 선행
- **ai-coding-pipeline** — 5+ 파일 변경 시 Plan 단계 선행
- `.env`, keystore, Firebase service account key 커밋 금지
- Provider Failure 전파: `Error.throwWithStackTrace(failure, StackTrace.current)`
- **i18n Option B** — bottom sheet/스낵바 UX 카피는 한글, 운영 exception/snackbar 는 영문
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion` 으로 확인
- **Aggregate invalidate** — 새 링크 저장 후 list/detail/collection 공급자 cascade invalidate 확인
- **AsyncNotifier in-flight** — optimistic UX 시 Session 33 교훈 적용

## 완료 기준

- [ ] `receive_sharing_intent` 1.8.1 도입 + AndroidManifest intent-filter 설정
- [ ] `SharedIntentService` Domain TDD RED → GREEN
- [ ] Cold start 에서 공유된 URL → `link/add` 폼 prefill 확인 (실기기 2 앱 이상)
- [ ] PRD 결정 로그 Session 38 entry 추가
- [ ] CI 4 job green + 사용자 승인 머지
- [ ] Session 38 daily log + CHANGELOG + memory 업데이트

## 참조 문서

- **Session 37 로그**: `docs/daily_task_log/2026-04-21_session37.md` — 후속 작업 카드 상세
- **Share Intent PRD Decided**: `docs/prds/share-intent.md`
- **Session 19 URL sanitizer 교훈**: `project_url_launcher_bug_resolved.md` — "제목+URL" 페이스트 방어
- **i18n 정책 메모리**: `feedback_i18n_policy.md`
- **Aggregate invalidate 메모리**: `feedback_aggregate_invalidate.md`
- **receive_sharing_intent pub.dev**: https://pub.dev/packages/receive_sharing_intent
- **Android ACTION_SEND 공식**: https://developer.android.com/training/sharing/receive

## 세션 경계

Phase 1 Android URL-only PoC + 실기기 검증 + PR 머지까지. warm/foreground bottom sheet 는 Phase 1 후반 또는 별도 세션 판단. iOS Share Extension / plain text / image 는 Phase 2+ 별도 세션.
```
