# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.5] - 2026-04-11

### Added

- **Firebase Android Phase 5: Dart 배선 완료** — Crashlytics + Analytics 런타임 초기화
  - `lib/bootstrap.dart` — `boot()` 시그니처 확장:
    - `boot(AppEnv env, {required FirebaseOptions firebaseOptions})`
    - `Firebase.initializeApp(options: firebaseOptions)` 호출 (Hive/Supabase 초기화보다 선행)
    - `FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode)` — 디버그 빌드에서 수집 비활성화
    - `FlutterError.onError` 훅에 `recordFlutterError(d)` 추가 (기존 logger 유지, `unawaited` 래핑)
    - `PlatformDispatcher.instance.onError` 훅에 `recordError(error, stack, fatal: true)` 추가
  - `lib/main_{dev,staging,prod}.dart` + `lib/main.dart` — flavor별 `firebase_options_*.dart` import 및 `DefaultFirebaseOptions.currentPlatform` 전달
  - `lib/app/router/app_router.dart` — GoRouter `observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)]` 추가
    - 알려진 한계: `StatefulShellRoute.indexedStack` 탭 전환은 root observer가 잡지 못함 → 탭별 수동 `logScreenView`는 다음 세션 과제
  - 검증:
    - `flutter analyze --fatal-warnings` → 0 issues
    - `flutter test` → 315 ALL GREEN
    - `dart format --set-exit-if-changed lib/ test/` → 클린
    - `flutter build apk --flavor dev -t lib/main_dev.dart --debug` → 성공 (Gradle plugin + google-services.json 정상 반영)
- **Firebase Android configure 완료 (flavor별 3개 앱)** — Crashlytics + Analytics 초기화 준비
  - Firebase 프로젝트 `linknote-8994b` (display name "LinkNote") 생성
  - Android 앱 3개 등록 완료:
    - `app.kaywalker.linknote.dev` (Dev)
    - `app.kaywalker.linknote.staging` (Staging)
    - `app.kaywalker.linknote` (Prod)
  - `flutterfire configure` 3회 실행 → flavor별 설정 파일 생성:
    - `lib/firebase_options_{dev,staging,prod}.dart`
    - `android/app/src/{dev,staging,prod}/google-services.json`
    - `firebase.json` (3 flavor buildConfigurations 등록)
  - Android Gradle plugin 자동 배선 (flutterfire 1차 실행 시):
    - `com.google.gms.google-services:4.3.15`
    - `com.google.firebase.crashlytics:2.8.1`
  - iOS / FCM은 의도적으로 이번 범위에서 제외 (다음 세션)

## [1.1.4] - 2026-04-11

### Fixed

- **CI analyze 완전 클린** — `only_throw_errors` info 5건 제거 (`Error.throwWithStackTrace` 패턴 적용)
  - `throw result.failure!` → `Error.throwWithStackTrace(result.failure!, StackTrace.current)` 치환
  - CI Flutter 3.41.4 환경에서 `Failure implements Exception` 을 인식하지 못해 발생한 info 정리
  - 대상: `collection_list_provider.dart`, `link_detail_provider.dart` (2곳), `link_list_provider.dart`, `profile_provider.dart`
  - 런타임 동작 변경 없음 (analyze 0 issues / 315 tests ALL GREEN 유지)

## [1.1.3] - 2026-04-11

### Fixed

- **[Critical] Android INTERNET 퍼미션 추가** — 릴리스 빌드에서 모든 네트워크 호출이 차단되는 치명적 버그 수정
- **iOS IPHONEOS_DEPLOYMENT_TARGET 통일** — project.pbxproj 13.0 → 15.0 (Podfile과 일치)
- **iOS PRODUCT_BUNDLE_IDENTIFIER 하드코딩 제거** — flavor별 번들 ID가 xcconfig에서 올바르게 적용되도록 수정

### Added

- `ios/ExportOptions.plist` — App Store IPA 내보내기 설정 템플릿
- iOS Release xcconfig에 `DEVELOPMENT_TEAM` 플레이스홀더 추가
- 릴리스 빌드 QA 테스트 플랜 수립 (40+ 테스트 케이스)

## [1.1.2] - 2026-04-11

### Fixed

- `flutter analyze --fatal-warnings` 전체 통과 (31개 → 0개 이슈)
  - `Failure` sealed class에 `implements Exception` 추가 (only_throw_errors 5건)
  - 테스트 `any()` 호출에 타입 인자 추가 (inference_failure 8건 warning)
  - cascade_invocations, discarded_futures, unnecessary_lambdas 등 info 18건 수정
- `app_config.dart` 타입 어노테이션, `dio_client.dart` import 정렬 수정

## [1.1.1] - 2026-04-11

### Fixed

- CI `dart format --set-exit-if-changed` 체크 실패 수정 (34개 테스트 파일 포맷 정리)

## [1.1.0] - 2026-04-11

### Added

- **보안 감사**: P0(3)+P1(4)+P2(3) = 10/10건 전체 수정 완료
  - AuthInterceptor 401 처리, signOut 캐시 정리, 글로벌 에러 핸들러
- **UI/UX 개선 Phase 1**: 에러 메시지 한글화, 세션 만료 UX, 스켈레톤 로더, Pull-to-Refresh
- **UI/UX 개선 Phase 2**: SnackBar 통합 시스템, 빈 상태 일러스트, 테마 전환 애니메이션
- **Search 보강**: 태그/날짜/즐겨찾기 필터, Hive 히스토리 영속화, 자동완성
- **릴리즈 준비 Phase 1**: 앱 아이콘, 스플래시 화면, ProGuard/R8, 메타데이터 통일
- **Testing**: 52개 → 315개 테스트 (Widget 16파일 + CollectionLocalDataSource + Search 등)

### Changed

- Android 패키지명 통일 + iOS 설정 업데이트
- info-level lint 이슈 104개 → 31개로 감소
- `flutter analyze` 0 errors 유지

## [1.0.0] - 2026-04-10

### Added

- **Auth**: Supabase 이메일 회원가입/로그인, 자동 토큰 관리, 세션 검증
- **Link CRUD**: 링크 저장/조회/수정/삭제, OG 태그 자동 파싱, cursor 기반 무한 스크롤
- **Favorites**: 즐겨찾기 토글 (Optimistic update + 실패 시 롤백)
- **Collections**: 컬렉션 CRUD, 링크 수 서브쿼리, 로컬 캐싱
- **Search**: Supabase full-text search (tsvector), debounce 검색, 최근 검색어
- **Offline**: Hive CE 로컬 캐싱, Remote-First/Local-Fallback 패턴
- **Deep Link**: `linknote://` 스킴 (Android intent-filter + iOS CFBundleURLSchemes)
- **UI**: 5탭 네비게이션, Light/Dark 테마 (Material 3), 20+ 공유 위젯
- **Testing**: 60개 테스트 (Unit 16 + Widget 25 + Integration 19)
- **CI/CD**: GitHub Actions 4-job 파이프라인 (analyze, test, build, security)

### Architecture

- Feature-first + Clean Architecture (presentation → domain → data)
- Riverpod 3.x 코드 생성 기반 상태 관리
- `Result<T>` + `Failure` sealed class 타입 안전 에러 처리
- GoRouter 선언적 라우팅 + 인증 가드
