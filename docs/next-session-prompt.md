# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 39 — Share Intent Phase 1 실기기 검증 결과 반영 + Phase 1 연장(warm/foreground bottom sheet) 판단

## 미션 한 줄

Session 38 에서 구현·빌드한 Phase 1 Android URL-only PoC 를 실기기 2앱(YouTube/Chrome/Twitter 중) 이상에서 검증하고, 결과에 따라 버그 패치 또는 Phase 1 연장(warm/foreground stream + bottom sheet) 진입 여부를 결정한다.

## 배경

Session 38 (2026-04-21):
- `receive_sharing_intent: ^1.8.1` 도입 + `ACTION_SEND text/plain` intent-filter
- Domain `SharedIntentService` TDD RED→GREEN (9 케이스), `PendingSharedUrl` Notifier (5 케이스), Widget prefill (2 케이스) — **453 tests GREEN** (+16)
- `bootstrap.dart` cold-start seed → GoRouter redirect consume → `LinkAddScreen.initialUrl` prefill
- `android/build.gradle.kts` subprojects JVM 17 정렬 (plugin 1.8.1 Kotlin 17 / Java 기본 1.8 충돌 해결)
- Android dev/staging debug APK 빌드 성공. **실기기 공유 시트 검증은 미수행** (세션 종료 시점 Android 디바이스 미연결)
- PRD `docs/prds/share-intent.md` 상태 `Phase 1 구현 (Session 38)` 로 갱신
- Session 37 PRD Decided 커밋 + Session 38 코드를 묶어 PR 생성 (`feat(share-intent): Phase 1 Android URL-only PoC + PRD Decided`)

현재 상태 (Session 39 시작 전):
- main 최신 — Session 38 PR 머지 상태 가정
- 453 tests GREEN, analyze 0, Branch Protection 활성

## Phase 1 검증 시나리오 (순서 엄수)

### 0. 사전 확인
```bash
cd ~/AndroidStudioProjects/LinkNote
git fetch origin
git checkout main && git pull
flutter analyze --fatal-warnings
flutter test --reporter=failures-only 2>&1 | tail -3    # +453 기대
adb devices                                             # Android 실기기 연결 확인
```

### 1. 실기기 설치 + 검증 (핵심)

```bash
flutter build apk --debug --flavor dev -t lib/main_dev.dart
adb install -r build/app/outputs/flutter-apk/app-dev-debug.apk
```

검증 체크리스트:
- **Cold start (앱 죽어있음)**:
  - YouTube 동영상 → 공유 시트 → LinkNote DEV 선택 → 로그인 후 `/links/new` 폼 URL 필드에 YouTube URL prefill 확인
  - Chrome 웹페이지 → 공유 시트 → LinkNote → URL prefill 확인
  - Twitter 트윗(제목+URL 혼합 텍스트) → 공유 시트 → LinkNote → URL 만 추출 prefill (Session 19 3계층 배치)
- **인증 상태별**:
  - 로그인 상태 유지 시: splash → 즉시 `/links/new?prefill=...`
  - 로그아웃 상태: splash → login → 성공 후 `/links/new?prefill=...` (pending URL 보존)
- **Warm resume (앱 백그라운드 복귀)**:
  - 앱 열어 둔 상태에서 공유 시 동작 — Phase 1 에는 미구현이므로 "공유 시트에 LinkNote 표시되지만 수신하지 않음" 이 예상 동작
  - 이 동작이 허용되는지 사용자 판단 후 Phase 1.5 착수 여부 결정

### 2. 결과별 분기

**A. 버그 발견 시** — 즉시 패치 PR
- Domain(`SharedIntentService`) / Provider / Router / Screen 중 원인 식별
- TDD RED → GREEN 로 재현 케이스 고정
- `feat/share-intent-phase1-fix` 브랜치 + CI 4 job green + 사용자 승인 머지

**B. 검증 통과 + Phase 1.5 승인** — warm/foreground bottom sheet 진입
- `ReceiveSharingIntent.instance.getMediaStream().listen(...)` 구독을 app shell 단계에 추가
- 폼 dirty(입력 중) 시 스낵바 "새 링크가 들어왔어요" + CTA, 아니면 즉시 bottom sheet
- `SharedIntentService` 재사용, `PendingSharedUrl` 또는 별도 stream provider 도입
- i18n Option B: bottom sheet/snackbar UX 카피는 한글, 운영 exception 은 영문

**C. 검증 통과 + Phase 1.5 이월** — Phase 2 iOS Extension 재평가 세션 준비
- PRD Section 3.3 재검토 질문 3건(Extension UI 범위 / 저장 전략 / OG fetch) 재오픈
- iOS 서명 인프라(`project_release_signing.md`) 선행 작업 목록화

### 3. 문서 / 커밋

- `docs/daily_task_log/YYYY-MM-DD_session39.md`
- CHANGELOG Session 39 섹션
- `project_share_intent.md` memory 갱신 (검증 결과 + Phase 1.5 결정)
- `project_code_review_roadmap.md` Session 39 entry
- PR 머지 후 `origin` 브랜치 삭제

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection** — PR + CI 4 job green 필수
- **TDD RED → GREEN** — 버그 재현 시 예외 없이 테스트 선행
- `.env`, keystore, Firebase service account key 커밋 금지
- Provider Failure 전파: `Error.throwWithStackTrace(failure, StackTrace.current)`
- **i18n Option B** — bottom sheet/스낵바 UX 카피는 한글, 운영 exception/snackbar 는 영문
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion` 으로 확인
- **Aggregate invalidate** — 새 링크 저장 후 list/detail/collection 공급자 cascade invalidate 확인

## 완료 기준

- [ ] 실기기 2앱 이상에서 cold-start 공유 → prefill 동작 확인 (또는 버그 패치 머지)
- [ ] 미구현 시나리오 목록 PRD + memory 업데이트
- [ ] Phase 1.5 진입 또는 이월 결정 기록
- [ ] CHANGELOG + daily log + memory 갱신

## 참조 문서

- **Session 38 로그**: `docs/daily_task_log/2026-04-21_session38.md`
- **Share Intent PRD**: `docs/prds/share-intent.md` (상태: Phase 1 구현)
- **Session 19 URL sanitizer 교훈**: `project_url_launcher_bug_resolved.md`
- **i18n 정책**: `feedback_i18n_policy.md`
- **receive_sharing_intent pub.dev**: https://pub.dev/packages/receive_sharing_intent

## 세션 경계

실기기 검증 + 결과 반영(버그 패치 또는 Phase 1.5 진입 결정)까지. Phase 2 iOS Share Extension 은 별도 세션.
```
