# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 18 — Firebase 마무리 / FCM / 스모크 테스트 / Keystore 중 사용자 선택

## 배경 (현재 상태 스냅샷)
- 보안 감사 10/10건 / UI·UX 개선 / Search 보강 / 릴리스 준비 Phase 1 / 빌드 플레이버 분리 / 릴리스 서명 인프라 / analyze 0 issues / 315 tests ALL GREEN — 모두 유지
- **Firebase Android Phase 1~5 완료** (세션 #16 configure + 세션 #17 Dart 배선):
  - Firebase 프로젝트: `linknote-8994b`
  - Android 앱 3개 등록 + flutterfire configure 완료 (dev/staging/prod)
  - `lib/firebase_options_*.dart`, `android/app/src/*/google-services.json`, `firebase.json` 모두 생성
  - Gradle plugin 자동 배선 (google-services 4.3.15 / crashlytics 2.8.1)
  - **Dart 배선 완료**: `bootstrap.dart` Firebase init + Crashlytics 훅, `main_*.dart` 4종 flavor 옵션 주입, `app_router.dart` FirebaseAnalyticsObserver 등록
  - 검증: analyze 0 / test 315 GREEN / format 클린 / `flutter build apk --flavor dev --debug` 성공
- **origin/main 동기화 완료** (세션 #17 말미 push 수행):
  - `6d7fe85` fix(release) — Android INTERNET / iOS 타겟 / 번들 ID / ExportOptions
  - `c422012` feat(firebase) — Android configure + Gradle plugin 배선
  - `8400c9c` docs — 세션 #16 요약
  - `8a4a680` docs — 세션 #16 커밋 해시 반영 + Session 17 프롬프트 재정비
  - `0f441b8` feat(firebase) — Dart Phase 5 배선 + CHANGELOG [1.1.5] + daily_log #17 + next_session_prompt (Session 17 통합 커밋)
- iOS Firebase configure / FCM 배선 / Apple Developer Program / Android keystore — 모두 미완료

## 세션 #17 결정 사항 (유지 필수)
- 아키텍처: **단일 Firebase 프로젝트 + flavor별 앱 3개** 유지
- FlutterError / PlatformDispatcher 훅에 Crashlytics 호출은 **`unawaited()` 래핑** (sync 핸들러 내부)
- Debug 빌드에서 Crashlytics 수집 비활성화 (`setCrashlyticsCollectionEnabled(!kDebugMode)`)
- Analytics observer는 root GoRouter에만 등록 — StatefulShellRoute 탭 전환 한계는 주석으로 기록됨 (Option C 과제)

## 이번 세션 목표 — 사용자에게 선택 요청 후 진행

### Option A: iOS Firebase configure + Xcode Run Script 배선
- **범위**: iOS 3 flavor (`flutterfire configure --platforms=ios` × 3) + Xcode Run Script Phase 추가 (Crashlytics dSYM 업로드)
- **전제**: 사용자가 Firebase 콘솔에서 iOS 앱 3개 등록 필요 (번들 ID: `app.kaywalker.linknote.dev` / `.staging` / 기본)
- **산출물**: `ios/Runner/GoogleService-Info-*.plist` 3개, `lib/firebase_options_*.dart` iOS 섹션 갱신
- **리스크**: Apple Developer Program 미완료 상태면 실기기 테스트 제한, Simulator로 대체 가능

### Option B: FCM (firebase_messaging) Dart 배선
- **범위**: `bootstrap.dart`에 FCM 권한 요청 + 토큰 관리, 백그라운드 핸들러, 포그라운드 알림 표시
- **전제**: Android만 진행 가능 (iOS APNs는 Apple Developer Program 필요)
- **산출물**: `lib/core/notification/fcm_service.dart` 신규 + `NotificationScreen`과 연동 고려
- **리스크**: Android 13+ POST_NOTIFICATIONS 런타임 권한 처리 필요

### Option C: 탭별 수동 logScreenView (Analytics 보완)
- **범위**: `AppScaffoldWithNavBar` 또는 각 탭 진입 시 `FirebaseAnalytics.instance.logScreenView()` 수동 호출
- **전제**: Riverpod Observer 또는 route listener 패턴 중 선택
- **산출물**: `lib/core/analytics/screen_logger.dart` 또는 shell 레벨 observer
- **리스크**: StatefulShellRoute의 `currentIndex` 감지 타이밍 이슈 (탭 최초 진입 vs 재방문 구분 필요)

### Option D: Android keystore 생성 + 릴리스 APK 실빌드
- **범위**: `keytool` upload keystore 생성 + `android/key.properties` 작성 + release `signingConfig` 주입 검증 + `flutter build apk --flavor prod --release` 실행
- **전제**: 사용자 로컬에서 keystore 생성 + secrets 관리 정책 결정 (gitignore 유지)
- **산출물**: signed release APK + 서명 검증 (`apksigner verify`)
- **리스크**: keystore 분실 시 Play Store 재등록 불가 — 백업 정책 명확히

### Option E: 수동 스모크 테스트 + Firebase 콘솔 검증
- **범위**: `flutter run --flavor dev -t lib/main_dev.dart` 실기기/에뮬레이터 실행 → Firebase Analytics DebugView에서 `first_open` / `session_start` 수신 확인 → (옵션) 강제 크래시 호출 → Crashlytics 대시보드 수신 확인
- **전제**: 사용자가 Firebase 콘솔 접근 가능 + 실기기 또는 에뮬레이터 부팅
- **산출물**: 세션 로그에 검증 스크린샷 또는 이벤트 수신 확인 기록
- **리스크**: Crashlytics는 초기 수신까지 수 분 지연 가능

### Option F: README 포트폴리오 완성
- **범위**: 루트 `README.md`를 포트폴리오 수준으로 재작성 (아키텍처 다이어그램, 기술 스택, 빌드 가이드, 시연 GIF 자리)
- **산출물**: README.md + `docs/images/architecture.svg` (선택)

## 수정하지 않는 것 (불변 원칙)
- 보안 수정 사항 롤백 금지
- 아키텍처 패턴 변경 금지 (Clean Architecture + Riverpod 유지)
- ProGuard/R8 설정 비활성화 금지
- SnackBar 통합 시스템 패턴 변경 금지
- `Error.throwWithStackTrace` 패턴 되돌리기 금지
- `Failure sealed class`에서 `implements Exception` 제거 금지
- Firebase 프로젝트 구조 변경 금지
- `firebase_options_*.dart` 수동 편집 금지 (flutterfire 재실행으로만 갱신)
- `bootstrap.dart`의 `unawaited()` 래핑 제거 금지 (discarded_futures 린트 회피 목적)

## 완료 기준 (Option 공통)
- `flutter analyze --fatal-warnings` 0 issues 유지
- `flutter test` 315+ ALL GREEN 유지
- `dart format --set-exit-if-changed lib/ test/` 클린
- 문서 3종 업데이트 (CHANGELOG, daily_log, next_session_prompt)
- Push는 사용자 명시적 승인 후에만 수행

## 진행 순서 (권장)
1. 사용자에게 Option A~F 중 선택 요청
2. 선택된 Option에 대해 ai-coding-pipeline Stage 1 (Research) → Stage 2 (Plan) → Stage 3 (Feedback) 진행
3. 사용자 승인 후 Stage 4 (Implement) 진행
4. 검증 파이프라인 실행
5. 문서 업데이트 + 커밋
6. Push 승인 요청
```
