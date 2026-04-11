# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 17 — Firebase Android Dart 배선 (Phase 5) + 검증

## 배경 (현재 상태 스냅샷)
- 보안 감사 10/10건 / UI·UX 개선 / Search 보강 / 릴리스 준비 Phase 1 / 빌드 플레이버 분리 / 릴리스 서명 인프라 / analyze 0 issues / 315 tests ALL GREEN — 모두 유지
- **Firebase Android Phase 1~4 완료** (세션 #16):
  - Firebase 프로젝트: `linknote-8994b`
  - Android 앱 3개 등록 + 패키지명 검증 완료
  - `flutterfire configure` 3회 실행 성공 (dev/staging/prod)
  - `lib/firebase_options_{dev,staging,prod}.dart` 생성 완료
  - `android/app/src/{dev,staging,prod}/google-services.json` 생성 완료
  - `firebase.json` 3 flavor buildConfigurations 등록 완료
  - Android Gradle plugin 자동 배선 완료 (`google-services:4.3.15`, `crashlytics:2.8.1`)
- **미커밋 변경사항 (Phase 1~4 산출물 + 이전 릴리스 서명분)**:
  - 신규: `lib/firebase_options_*.dart` x3, `android/app/src/{dev,staging,prod}/google-services.json`, `firebase.json`, `ios/ExportOptions.plist`
  - 수정: `android/settings.gradle.kts`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `ios/Flutter/{Dev,Staging,Prod}-Release.xcconfig`, `ios/Runner.xcodeproj/project.pbxproj`
- iOS Firebase configure / FCM 배선 / Apple Developer Program / Android keystore — 모두 미완료 (의도적 연기)

## 직전 세션(#16) 결정 사항 (유지 필수)
- 아키텍처: **단일 Firebase 프로젝트 + flavor별 앱 3개** (프로젝트 분리 안 함)
- 범위: Crashlytics + Analytics 초기화만, FCM/Messaging dart 배선 제외
- 전략: dev PoC 선행 → staging/prod 확장 (Dart 배선은 3 flavor 동시 진행 OK)
- 테스트 영향: `test/`에서 `bootstrap` import 0건 확인 → boot() 시그니처 확장 안전

## 이번 세션 목표 — Phase 5 (Dart 배선) + 검증

### 수정할 파일 (6개)
1. **`lib/bootstrap.dart`** — `boot()` 시그니처 확장 + Firebase init + Crashlytics 훅
   - `boot(AppEnv env, {required FirebaseOptions firebaseOptions})`
   - `WidgetsFlutterBinding.ensureInitialized()` 직후 `Firebase.initializeApp(options: firebaseOptions)`
   - `FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode)` — 디버그 빌드에서 수집 비활성화
   - `FlutterError.onError` 훅에 `FirebaseCrashlytics.instance.recordFlutterError(details)` **추가** (기존 logger 호출 유지)
   - `PlatformDispatcher.instance.onError` 훅에 `FirebaseCrashlytics.instance.recordError(error, stack, fatal: true)` **추가** (기존 logger 호출 유지)
2. **`lib/main_dev.dart`** — `firebase_options_dev.dart` import 후 `firebaseOptions: DefaultFirebaseOptions.currentPlatform` 전달
3. **`lib/main_staging.dart`** — 동일 패턴 (staging 옵션)
4. **`lib/main_prod.dart`** — 동일 패턴 (prod 옵션)
5. **`lib/main.dart`** — 레거시 기본 엔트리, dev 옵션 전달
6. **`lib/app/router/app_router.dart`** — `observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)]` 추가
   - 알려진 한계: `StatefulShellRoute.indexedStack` 탭 전환은 root observer가 잡지 못함 — 탭별 수동 `logScreenView`는 다음 세션 과제

### 수정하지 않을 것
- `pubspec.yaml` — 의존성 이미 선언됨 (firebase_core / analytics / crashlytics / messaging)
- `android/app/proguard-rules.pro` — firebase_crashlytics 플러그인이 consumer rules 제공
- iOS 관련 파일 전부
- `firebase_options_*.dart` — flutterfire 생성본 그대로 사용 (iOS throw 부분은 iOS configure 시 자동 갱신됨)
- 테스트 파일 — bootstrap import 없음 확인됨

### 검증 절차 (순서 고정)
1. `flutter pub get` (firebase_core 등 resolve 확인)
2. `dart run build_runner build --delete-conflicting-outputs` (app_router 변경 → Riverpod codegen)
3. `flutter analyze --fatal-warnings` → **0 issues 유지**
4. `flutter test` → **315 ALL GREEN 유지**
5. `dart format --set-exit-if-changed lib/ test/` → 클린
6. `flutter build apk --flavor dev -t lib/main_dev.dart --debug` → Gradle plugin + google-services.json이 빌드에 정상 반영되는지 fast feedback
7. **사용자 수동 스모크** (환경 영향 — 진행 여부 세션 중 판단):
   - `flutter run --flavor dev -t lib/main_dev.dart` 실기기/에뮬레이터
   - Firebase 콘솔 Analytics DebugView에서 `first_open` 이벤트 수신 확인
   - (옵션) 강제 크래시 호출 → Crashlytics 대시보드 수신 확인

### 예상 리스크 / 중단 포인트
- **R1 Gradle sync 실패**: `google-services:4.3.15` / `crashlytics:2.8.1`가 Kotlin 2.2 / AGP 8.11과 호환성 문제 발생 가능 → 버전 업데이트 제안 (`4.4.2` / `3.0.2` 등) 후 재시도
- **R2 app_router.g.dart 변경**: Riverpod codegen 결과물도 커밋 대상 포함
- **R3 Analytics observer 주입 위치**: root GoRouter `observers`에 넣어도 shell 전환 이벤트 누락 가능 — 한계로 기록 후 다음 세션에 수동 로깅으로 보완

## 문서·커밋 정책
- **커밋 1**: Firebase Android configure 산출물 + gradle plugin 배선 (세션 #16 자동 생성 분)
  - `feat(firebase): Android flavor별 Firebase configure 완료 (Phase 1-4)`
- **커밋 2**: Dart 배선 (세션 #17 수동 작업 분)
  - `feat(firebase): Android Crashlytics + Analytics Dart 배선 (Phase 5)`
- 커밋 2 후 CHANGELOG `Unreleased` 섹션을 `[1.1.5]` 릴리스 노트로 승격
- `docs/daily_task_log/2026-04-11_session.md` 세션 #17 섹션 추가
- `docs/next_session_prompt.md` 업데이트 (Session 18 프롬프트 — iOS Firebase / FCM / 스모크 테스트 중 사용자 선택)
- `git push`는 **사용자 명시적 승인 후에만** 수행

## 수정하지 않는 것 (불변 원칙)
- 보안 수정 사항 롤백 금지
- 아키텍처 패턴 변경 금지 (Clean Architecture + Riverpod 유지)
- ProGuard/R8 설정 비활성화 금지
- SnackBar 통합 시스템 패턴 변경 금지
- `Error.throwWithStackTrace` 패턴을 다시 `throw`로 되돌리지 말 것
- `Failure sealed class`에서 `implements Exception` 제거 금지
- Firebase 프로젝트 구조 변경 금지 (단일 프로젝트 + flavor별 앱 3개 유지)
- `firebase_options_*.dart` 수동 편집 금지 (flutterfire 재실행으로만 갱신)

## 완료 기준
- `flutter analyze --fatal-warnings` 0 issues 유지
- `flutter test` ALL GREEN 유지 (315+)
- `dart format --set-exit-if-changed lib/ test/` 클린
- `flutter build apk --flavor dev --debug` 성공 (Gradle sync 포함)
- 커밋 2개 작성 + 푸시 (사용자 승인 후)
- 문서 3종 (CHANGELOG, daily_log, next_session_prompt) 업데이트

## 진행 순서 (권장)
1. 먼저 세션 #16 미커밋분을 **커밋 1**로 먼저 기록 (git 히스토리 cleanliness)
2. Phase 5 Dart 배선 구현 (6파일 수정)
3. 검증 1~6단계 순차 실행
4. 실패 시 근본 원인 수정, 통과 후 **커밋 2**
5. 문서 업데이트
6. 사용자에게 push 승인 요청

## 선택적 다음 작업 (Phase 5 완료 후)
- **Option A**: iOS Firebase configure (`flutterfire configure --platforms=ios` × 3 flavor) + Xcode Run Script 배선
- **Option B**: FCM(firebase_messaging) Dart 배선 + 권한 요청 + 토큰 관리
- **Option C**: 탭별 수동 `logScreenView` 구현 (shell route 한계 보완)
- **Option D**: Android keystore 생성 + 릴리스 APK 실빌드 (세션 #15에서 연기된 작업)
- **Option E**: README 포트폴리오 완성 (아키텍처 다이어그램, 시연 GIF)

다음 세션 시작 시 사용자에게 위 옵션 중 선택 요청.
```
