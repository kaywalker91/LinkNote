# LinkNote — 개발 워크플로우 & 구현 가이드

> **버전:** v2.1.0
> **최종 수정:** 2026.04
> **목적:** 목업 우선(Mockup-First) 방식 로드맵 + Android MVP → iOS → 배포 단계 전략 + Git / CI/CD / 코드 컨벤션 기준 정의

---

## 1. 개발 원칙

### 1.1 핵심 기준 4가지

1. **완성 가능성 우선** — 완벽한 코드보다 돌아가는 MVP가 먼저다. 2주마다 데모 가능한 상태를 유지한다.
2. **목업 우선 (Mockup-First)** — UI를 먼저 목업 데이터로 완성한 뒤 백엔드를 붙인다. Provider는 처음에 더미 데이터를 반환하고, 백엔드 연동 시 UseCase 호출로 교체한다. 화면이 돌아가는 것을 먼저 확인한 후 실제 데이터로 전환한다.
3. **설명 가능한 구조** — 면접에서 "왜 이렇게 만들었나요?"에 답할 수 있는 의도적 설계를 한다.
4. **점진적 완성** — Phase 2 (UI 완성) → Phase 3 (백엔드 연동) 순서를 지키고, 욕심내서 scope를 벌리지 않는다. 플랫폼 단계는 **Android MVP 완성 → iOS 기능 완성 → 배포 준비** 순서를 준수한다.

### 1.2 해서는 안 되는 것

- UI 미완성 상태에서 백엔드 연동 먼저 착수
- MVP 완성 전에 확장 기능 개발 착수
- 아키텍처 과설계 (e.g., 필요 없는 Use Case 레이어 분리)
- 디자인 픽셀 맞추기에 시간 낭비
- GitHub commit 없이 며칠 이상 작업

---

## 2. 구현 로드맵

### 전체 일정 한눈에 보기

```
Phase 0  [✅ 완료]     프로젝트 세팅, 라우팅, 테마, 디자인 시스템
Phase 1  [✅ 완료]     전체 화면 UI 구현 (목업 데이터)
Phase 2  [✅ 완료]     UI 완성 & 개선 (누락 기능, UX 다듬기)
Phase 3  [✅ 완료]     백엔드 연동 (Supabase Auth + Data Layer + 실 프로젝트 세팅/E2E)
Phase 4  [✅ 완료]     로컬 캐시 & 성능 최적화
Phase 5  [✅ 완료]     테스트 작성 (300+ → 437개 테스트 전체 통과, Wave 1~5 리뷰 반영 포함)
Phase 6  [✅ 완료]     CI/CD & 코드 품질 (GitHub Actions + README bilingual + analyze 0)
Phase 6.5[✅ 완료]     보안 감사 + 코드 리뷰 Wave 1~5 (Session 1~35 누적, 테스트 300+→437)
Phase 7  [🔄 진행 중]  Android MVP 마무리 — Firebase ✅ / FCM / Keystore / Play Store Internal
Phase 8  [⏳ 예정]     iOS 기능 완성 — Firebase iOS / FCM APNs / TestFlight
Phase 9  [⏳ 예정]     배포 준비 — 스토어 리스팅 / 시연 영상 / 정책 문서 / 정식 릴리즈
```

---

### Phase 0 — 기반 세팅 [✅ 완료]

**목표:** 앱 뼈대 완성 + 라우팅 + 디자인 시스템

#### 체크리스트

- [x] Flutter 프로젝트 생성 및 `pubspec.yaml` 기본 의존성 추가
- [x] 폴더 구조 생성 (`app`, `core`, `shared`, `features`)
- [x] `go_router` 라우트 정의 (Splash → Login → Home, 5탭 Shell)
- [x] 인증 가드 설정 (로그인 여부에 따른 redirect)
- [x] 디자인 시스템 (Color, Typography, Spacing, Shadows, Animations 상수)
- [x] Light/Dark 테마 (Material 3)
- [x] 공통 에러 처리 구조 정의 (`Failure` sealed class, `Result<T>` 타입)
- [x] 공통 유틸리티 (Debouncer, DateTimeExtensions 등)
- [x] 네트워크 레이어 기반 (DioClient, Interceptor)
- [x] 로컬 스토리지 기반 (StorageService, Hive CE)

---

### Phase 1 — 전체 화면 UI 구현 (목업 데이터) [✅ 완료]

**목표:** 모든 화면을 목업 데이터로 완성 → 앱의 전체 UX 흐름 검증

#### 체크리스트

- [x] 5탭 네비게이션 쉘 (`StatefulShellRoute.indexedStack`)
- [x] Home Screen — 링크 목록, 전체/즐겨찾기 필터, 무한 스크롤, FAB
- [x] Search Screen — debounce 검색, 최근 검색어 표시
- [x] Collections Screen — 컬렉션 목록 + Collection Detail Screen
- [x] Notifications Screen — 알림 목록, 읽음/읽지않음 상태
- [x] Profile Screen + Settings Screen (테마 전환)
- [x] Link Detail Screen — OG 썸네일, 즐겨찾기 토글, 메모, 태그
- [x] Link Add Screen — URL 입력, OG 파싱 시뮬레이션
- [x] Link Edit Screen — 기본 구조
- [x] 공유 위젯 20+ (Skeleton, EmptyState, ErrorState, OfflineBanner, PaginatedListView 등)
- [x] Riverpod Provider 전체 구조 (모든 feature, 목업 데이터 기반)
- [x] Auth Screens (Splash, Login, Signup)
- [x] Domain Layer (Entity, UseCase, Repository 인터페이스) — auth, link, collection

#### 데모 기준

> 앱 실행 → 모든 화면 탐색 → 목업 데이터 정상 표시 → 로딩/에러/빈 상태 확인

---

### Phase 2 — UI 완성 & 개선 [✅ 완료]

**목표:** 누락되거나 미완성인 UI 항목 완료 + UX 다듬기

#### 체크리스트

**링크**

- [x] 링크 삭제 — 확인 다이얼로그 후 Provider에서 목업 삭제 동작
- [x] 링크 편집 화면 — 기존 데이터 바인딩 완성 (`linkDetailProvider`로 기존 데이터 로드 후 폼 초기화)
- [x] 태그 추가/삭제 UI (태그 입력 칩 인터랙션 — TextField + Enter/쉼표로 추가, Chip × 버튼으로 삭제)

**컬렉션**

- [x] Collection Detail Screen — 해당 컬렉션의 링크 목록 표시 (목업, `collectionLinksProvider`)
- [x] 컬렉션 생성 UI (`CollectionFormScreen` — 이름/설명 입력 폼)
- [x] 컬렉션 수정/삭제 UI (Detail 앱바 편집/삭제 메뉴, `ConfirmationDialogWidget` 재사용)

**검색**

- [x] 검색 결과 없음 상태 UI (EmptyStateWidget 연결)

**공통**

- [x] Deep Link 스킴 설정 (`linknote://` — Android `intent-filter`, iOS `CFBundleURLSchemes`)
- [x] 오프라인 배너 동작 완성 (ConnectivityProvider 연결)
- [x] 테스트 계정 자동 로그인 (개발 편의용 — `authProvider`에서 `test@linknote.dev` 자동 인증)

#### 데모 기준

> 모든 화면에서 CRUD 동작이 목업 데이터 기준으로 정상 작동 → 삭제/편집/생성 확인 ✅

---

### Phase 3 — 백엔드 연동 [✅ 완료]

**목표:** 목업 데이터를 실제 Supabase 백엔드로 교체

> **착수 선행 조건 (사용자 직접 수행):**
> 1. Supabase 프로젝트 생성
> 2. `links`, `collections`, `profiles`, `tags`, `link_tags` 테이블 스키마 정의 + RLS 설정
> 3. `.env` 파일에 `SUPABASE_URL`, `SUPABASE_ANON_KEY` 기입
> 4. `dart run build_runner build` 로 `env.g.dart` 갱신

#### 체크리스트

**인증**

- [x] Supabase 프로젝트 생성 및 `.env` 연동 (envied 코드 생성)
- [x] `AuthRemoteDatasource` 실제 구현 (이메일 회원가입/로그인)
- [x] Supabase SDK 자동 토큰 관리 (AuthInterceptor 구현)
- [x] `authProvider` 더미 상태 → 실제 Supabase 세션으로 교체 (UseCase 경유)
- [x] 앱 시작 시 토큰 유효성 검사 흐름 (`CheckSessionUsecase`)

**링크 Data Layer**

- [x] `LinkRemoteDataSource` (Supabase insert/select/update/delete + 태그 관리)
- [x] `LinkRepositoryImpl` 구현
- [x] `linkListProvider` → `FetchLinksUsecase` 연결
- [x] `linkFormProvider` → `CreateLinkUsecase`/`UpdateLinkUsecase` 연결
- [x] OG 태그 자동 파싱 (`OgTagService` — Dio + html 패키지)
- [x] 즐겨찾기 토글 실제 연동 (Optimistic update + 실패 시 롤백)
- [x] cursor 기반 무한 스크롤 페이지네이션 실제 구현

**컬렉션 Data Layer**

- [x] `CollectionRemoteDataSource` (link_count 서브쿼리 포함)
- [x] `CollectionRepositoryImpl` 구현
- [x] `collectionListProvider` → 실제 UseCase 연결 (CRUD 전체)

**검색 Data Layer**

- [x] `SearchRemoteDataSource` (Supabase full-text search via `tsvector`)
- [x] `searchProvider` → `SearchLinksUsecase` 연결

**실 프로젝트 세팅 (완료)**

- [x] Supabase 프로젝트 세팅 (테이블, RLS, 트리거 — `docs/supabase-setup.md` 참조)
- [x] `.env.dev` / `.env.staging` / `.env.prod` 작성 + `dart run build_runner build`로 `env.g.dart` 생성
- [x] E2E 검증: 회원가입 → 링크 추가 → 목록 → 즐겨찾기 → 컬렉션 → 검색 (Session 15 Collection-Link 실연동 포함)

#### 데모 기준

> 링크 추가 → 썸네일 자동 파싱 → Supabase DB 반영 → 목록 조회 → 즐겨찾기 → 검색으로 찾기 ✅

---

### Phase 4 — 로컬 캐시 & 성능 최적화 [✅ 완료]

**목표:** 오프라인 지원 + 렌더링 성능 개선

#### 체크리스트

**로컬 캐시**

- [x] Hive CE 스키마 정의 (CachedLink, SearchHistory, UserSettings)
- [x] `LinkLocalDataSource` 구현 (R/W)
- [x] Remote 실패 시 Local fallback 흐름 적용
- [x] 즐겨찾기 Optimistic update → 실패 시 롤백

**성능 최적화**

- [x] 링크 리스트 아이템 `const` 위젯화 — 이미 const constructor 적용됨
- [x] `cached_network_image` 썸네일 캐싱 확인 — OgThumbnailWidget에서 사용 중
- [x] Provider watch 범위 최소화 (불필요한 rebuild 제거)
- [x] 오프라인 상태 표시 UI (배너 / 토스트)

#### 데모 기준

> 비행기 모드 → 앱 실행 → 최근 링크 + 즐겨찾기 정상 표시

---

### Phase 5 — 테스트 작성 [✅ 완료]

**목표:** 핵심 레이어 테스트 커버리지 확보

**결과:** 437개 테스트 전체 통과 (300+ 기준선에서 Wave 1~5 리뷰 반영으로 확대, `flutter test` — +437: All tests passed!)

#### 체크리스트

**Unit Test (14개 → 120+)**

- [x] CreateLinkUseCase — 성공 / 실패 케이스
- [x] FetchLinksUseCase — 성공 / 빈 목록 / 실패
- [x] LinkRepositoryImpl — Remote 성공 시 Local 캐시 갱신 확인 (5개 케이스)
- [x] LinkMapper — DTO → Entity 변환 검증
- [x] AuthInterceptor, Debouncer, CollectionLocalDataSource 등 추가 테스트

**Widget Test (19개 → 95+)**

- [x] 로그인 화면 — 빈 폼 submit 시 validation 메시지 (8개 케이스)
- [x] 링크 추가 폼 — 잘못된 URL/제목 입력 validation (6개 케이스)
- [x] 링크 목록 — 로딩 / 데이터 / 에러 / 빈 상태 렌더링 + FAB (5개 케이스)
- [x] Shared Widget 테스트 6파일 (36개) + Feature Screen 테스트 10파일 (58개)

**Integration Test (19개 → 100+)**

- [x] 로그인 → 링크 저장 → 목록 반영 플로우 (10개 케이스)
- [x] 검색 → 결과 표시 → 상세 화면 진입 플로우 (4개 케이스)
- [x] 컬렉션 생성 → 폼 네비게이션 → 빈 이름 validation 플로우 (5개 케이스)
- [x] Collection-Link 실 연동, Search 필터/히스토리/자동완성 등 추가 플로우

#### 데모 기준

> `flutter test` 실행 → 437개 테스트 전체 통과 ✅
> 커버리지 측정은 CI에서 `flutter test --coverage` + lcov 필터링으로 자동화 (generated 파일 제외)

---

### Phase 6 — CI/CD & 코드 품질 [✅ 완료]

**목표:** 자동화 파이프라인 완성 + 코드 품질 기준선 확보 + 포트폴리오 수준 README 작성

> 시연 영상, Play Store/App Store 배포, Firebase App Distribution 등 플랫폼별 실배포는 Phase 7~9로 이관했다.

#### 체크리스트

**GitHub Actions**

- [x] `.github/workflows/ci.yml` 작성
- [x] push/PR 시 자동 실행: analyze (`--fatal-warnings`) → test (`--coverage`) → coverage report
- [x] 커버리지 보고: lcov 필터링 (`.g.dart`, `.freezed.dart`, `.gen.dart` 제외), 30% 미만 실패 / 50% 미만 경고
- [x] GitHub Actions CI 실제 실행 검증 (Session 11 — 7개 커밋 push)
- [x] CI dart format 체크 수정 (34개 테스트 파일 포맷 정리 — Session 12)

**코드 품질**

- [x] `analysis_options.yaml` 린트 규칙 조정 (`invalid_annotation_target` 무시, 불필요 규칙 비활성화)
- [x] 타입 안전성 수정 (`Box<Map>` → `Box<Map<String, dynamic>>`)
- [x] `flutter analyze` 0 warnings / 0 errors / info 0 (Session 14 보안감사 완료 시점)
- [x] 보안 감사 10/10 fixes 적용 (Session 13-14)

**문서화 (2026-04-05 완료)**

- [x] `README.md` 작성 (영문 — 프로젝트 소개, 기술 스택, 아키텍처 다이어그램, 실행 방법)
- [x] `README.ko.md` 작성 (한국어 버전)
- [x] 폴더 구조 다이어그램 README 삽입
- [x] 데이터 흐름 다이어그램 README 삽입 (Mermaid)
- [x] `LICENSE` 추가 (MIT)

#### 최종 데모 기준

> GitHub 방문 → README(EN/KO) 확인 → Actions에서 CI 통과 이력 확인 → 아키텍처 다이어그램으로 구조 파악 가능 ✅

---

### Phase 6.5 — 보안 감사 & 코드 리뷰 강화 [✅ 완료]

Phase 6 완료 이후 Phase 7 진입 전에 수행한 품질 보강 단계. 별도 세션(Session 1~35) 에서 누적 진행되었으며, 본 문서의 상위 Phase 6/7 완료 기준을 유지하기 위한 보조 작업이다.

**보안 감사 (Session 1~3 + Firebase 보강)**

- [x] P0/P1/P2 총 10건 처리 — 시크릿 분리, `.gitleaks.toml`/secret-scanning 정책, envied 키 제한
- [x] Firebase Client API Key 보안 정책 — GCP Application/API restriction 화이트리스트, CLAUDE.md에 정식 커밋 근거 문서화

**코드 리뷰 Wave 1~5 (Session 18~34)**

- [x] Wave 1 — 최초 리뷰 (2026-04-12)
- [x] Wave 2 — core 레이어 (2026-04-13)
- [x] Wave 3 — Link feature P1/P2 + 잔여 P3 롤오버 관리
- [x] Wave 4 — Collection feature P2/P3
- [x] Wave 5 — Link 고급 시나리오 (OgTagService Result/redirect/크기 가드, moveToCollection cascade, Wave 3 잔여 cleanup, Share Intent는 별도 Wave로 이관)

**결과물**: `docs/reviews/` (`session*-security-audit.md`, `wave{1~5}-*-review.md`), 테스트 수 300+ → 437개, cascade invalidate 패턴 확립(`feedback_aggregate_invalidate.md`), AsyncNotifier 테스트 가드레일(`feedback_riverpod_async_notifier_inflight.md`)

---

### Phase 7 — Android MVP 마무리 [🔄 진행 중]

**목표:** Android 단독으로 Play Store 내부 테스트 트랙에 올릴 수 있는 수준까지 완성

> iOS 작업은 Phase 8에서 진행한다. Android 에서 기능/품질/배포 파이프라인을 먼저 검증한 뒤 iOS로 이관하는 것이 원칙.

#### 체크리스트

**Firebase Android** (Session 16-17 완료)

- [x] Firebase 프로젝트 `linknote-8994b` 생성 + Android 앱 3개 등록 (dev/staging/prod)
- [x] `flutterfire configure --platforms=android` × 3 → `lib/firebase_options_{dev,staging,prod}.dart` 생성
- [x] `android/app/src/{dev,staging,prod}/google-services.json` 배치
- [x] Gradle plugin 배선 (google-services 4.3.15, crashlytics 2.8.1)
- [x] Dart 배선: `bootstrap.dart` Firebase init + Crashlytics `FlutterError` / `PlatformDispatcher.onError` 훅 (`unawaited()` 래핑)
- [x] `main_{dev,staging,prod}.dart` flavor별 options 주입, `app_router`에 `FirebaseAnalyticsObserver` 등록
- [x] Debug 빌드 Crashlytics 수집 비활성화 (`setCrashlyticsCollectionEnabled(!kDebugMode)`)
- [x] 검증: `flutter build apk --flavor dev --debug` 성공, 437 tests GREEN, analyze 0

**FCM (Android 우선)**

- [ ] `firebase_messaging` 의존성 추가 + `bootstrap.dart` 초기화
- [ ] `core/notification/fcm_service.dart` — 권한 요청, 토큰 관리, 토픽 구독
- [ ] Android 13+ `POST_NOTIFICATIONS` 런타임 권한 처리
- [ ] 백그라운드 핸들러 (top-level 함수) + 포그라운드 알림 표시
- [ ] 기존 `NotificationScreen`과 연결 (알림 탭 시 딥링크)

**릴리스 서명 + 빌드**

- [x] Android `INTERNET` 권한 추가 (`AndroidManifest.xml`) — Session 14
- [x] Release `signingConfig` **골격**만 작성 (`android/app/build.gradle.kts`) — 실 keystore 미생성, 서명 빌드 검증 미완
- [x] `key.properties.example` 템플릿 제공
- [ ] Upload keystore 생성 (`keytool`) + 백업 정책 문서화 (분실 시 Play Store 재등록 불가)
- [ ] `android/key.properties` (gitignored) 작성 + 실제 `signingConfig` 주입 검증
- [ ] `flutter build apk --flavor prod --release` + `apksigner verify`
- [ ] `flutter build appbundle --flavor prod --release` (AAB)

**스모크 테스트 + Firebase 콘솔 검증**

- [ ] 에뮬레이터/실기기 부팅 + `flutter run --flavor dev -t lib/main_dev.dart`
- [ ] Firebase Analytics DebugView에서 `first_open` / `session_start` 수신 확인
- [ ] 강제 크래시 호출 → Crashlytics 대시보드 수신 확인 (수 분 지연 가능)
- [ ] (옵션) 탭별 수동 `logScreenView` 배선 — `StatefulShellRoute` 탭 전환 관찰용

**Play Store Internal Test 트랙**

- [ ] Play Console 앱 등록 + 내부 테스트 트랙 생성
- [ ] AAB 업로드 + 테스터 그룹 배포
- [ ] (선택) Firebase App Distribution CI 연동 — 현재 `develop` 브랜치를 사용하지 않으므로 `main` 머지 또는 릴리스 태그 트리거로 재정의 필요

#### 데모 기준

> Android 기기에 prod release AAB 설치 → 로그인 → 링크 저장 → 검색 → Firebase 콘솔에서 Analytics 이벤트 및 Crashlytics 수신 확인

---

### Phase 8 — iOS 기능 완성 [⏳ 예정]

**목표:** Android와 동일한 기능 + 품질을 iOS에서 재현, TestFlight 배포 가능 상태까지

> **선행 조건 (사용자 직접 수행):**
> 1. Apple Developer Program 등록 ($99/년)
> 2. Xcode 설치 + macOS 환경
> 3. App Store Connect 접근 권한

#### 체크리스트

**iOS 빌드 인프라** (Session 14 완료, 기록용)

- [x] `ios/Flutter/{Dev,Staging,Prod}-{Debug,Release}.xcconfig` flavor 분리
- [x] `IPHONEOS_DEPLOYMENT_TARGET=15.0` 전체 타겟 통일 (project.pbxproj 3곳)
- [x] Runner 기본 번들 ID `app.kaywalker.linknote` + flavor 오버라이드 (xcconfig)
- [x] `ios/ExportOptions.plist` 템플릿 (`YOUR_TEAM_ID` 플레이스홀더)

**Firebase iOS**

- [ ] Firebase 콘솔에서 iOS 앱 3개 등록 (`app.kaywalker.linknote.dev` / `.staging` / 기본)
- [ ] `flutterfire configure --platforms=ios` × 3 → `ios/Runner/GoogleService-Info-*.plist` 생성
- [ ] `firebase_options_{dev,staging,prod}.dart` iOS 섹션 갱신 (수동 편집 금지, flutterfire 재실행으로만)
- [ ] Xcode Run Script Phase 추가 (Crashlytics dSYM 업로드)
- [ ] `pod install` + Podfile 의존성 해결

**iOS FCM (APNs)**

- [ ] Apple Developer에서 APNs 인증 키(.p8) 생성 + Firebase 콘솔 업로드
- [ ] Xcode Capabilities: Push Notifications + Background Modes (Remote notifications)
- [ ] iOS 권한 요청 플로우 (`UNUserNotificationCenter.requestAuthorization`)
- [ ] 백그라운드/포그라운드 알림 동작 검증 (실기기 필수)

**iOS 스모크 테스트 + 품질 검증**

- [ ] Simulator에서 dev flavor 실행 + Firebase Analytics DebugView 확인
- [ ] 실기기에서 prod 빌드 테스트 (로그인 → 링크 CRUD → 검색 → 컬렉션)
- [ ] `flutter test` 437+ GREEN 유지 (iOS 플랫폼 채널 mock 확인)
- [ ] Info.plist 권한 설명 문자열 점검 (카메라/포토 등 사용 시)

**TestFlight 준비**

- [ ] App Store Connect 앱 등록 + Bundle ID 승인
- [ ] 코드 사이닝 (automatic signing 또는 fastlane `match`)
- [ ] `flutter build ipa --flavor prod --release` → `ExportOptions.plist` 실제 Team ID 채워 넣기
- [ ] TestFlight 업로드 + 내부 테스터 배포

#### 데모 기준

> iOS 기기에서 TestFlight 설치 → 로그인 → 링크 CRUD → 검색 → 컬렉션 → Crashlytics 수신 확인

---

### Phase 9 — 배포 준비 [⏳ 예정]

**목표:** Play Store / App Store 정식 배포를 위한 비-기술 준비물 및 정식 릴리즈

#### 체크리스트

**스토어 리스팅 자산**

- [ ] 앱 아이콘 최종본 (1024×1024) + 플랫폼별 사이즈 (flutter_launcher_icons)
- [ ] 스크린샷: Android (phone/7" tablet/10" tablet) + iOS (6.7"/6.5"/5.5" + iPad 12.9"/11")
- [ ] 짧은 설명 / 긴 설명 (KO + EN)
- [ ] 프로모션 이미지 / 기능 그래픽 (Play Store feature graphic 1024×500)
- [ ] 카테고리 (생산성), 연령 등급 (Play Content Rating, App Store Age Rating 4+)

**정책/약관 문서**

- [ ] 개인정보 처리방침 (Supabase 데이터 수집, Firebase Analytics, Crashlytics 명시)
- [ ] 이용약관
- [ ] GitHub Pages 또는 도메인에 호스팅 + 스토어 등록 필드 입력

**시연 영상/GIF**

- [ ] 핵심 유저 플로우 녹화 (링크 저장 → 검색 → 컬렉션 → 딥링크)
- [ ] 30초 프로모 영상 (App Preview용) + 60초 긴 버전
- [ ] README + 스토어 리스팅에 GIF/영상 삽입

**정식 배포**

- [ ] Play Store 프로덕션 트랙 배포 (단계 롤아웃 20% → 50% → 100%)
- [ ] App Store 심사 제출 + 리뷰 피드백 대응
- [ ] GitHub Releases에 AAB/IPA 첨부 + 버전 태그 (`v1.0.0`)
- [ ] `CHANGELOG.md` 릴리즈 노트 작성

**모니터링**

- [ ] Crashlytics 대시보드 주시 (첫 72h 집중)
- [ ] Firebase Analytics 핵심 이벤트 정의 + 대시보드 구성 (DAU, 링크 저장 수, 리텐션)
- [ ] 사용자 피드백 수집 경로 (이메일, GitHub Issues, In-app 링크)

#### 최종 데모 기준

> Play Store + App Store 공식 페이지 링크가 README에 노출되고 실사용자가 설치 가능 → 첫 주 Crashlytics crash-free sessions 99%+ 유지

---

## 3. 목업 우선 전략

### 3.1 개발 흐름

```
목업(Mockup) 단계
Provider에서 Future.delayed() + 더미 데이터 반환
        ↓
UI 완성 확인
모든 화면 탐색, 상태 전환, 에러/빈 상태 표시 검증
        ↓
백엔드 연동
Provider 내부의 더미 데이터를 UseCase 호출로 교체
        ↓
실제 데이터 검증
Supabase DB와 화면 동기화 확인
```

### 3.2 Provider 교체 패턴

백엔드 연동 시 Provider 내부만 교체하고, 화면(Screen)과 위젯은 그대로 유지한다.

```dart
// Before — Phase 1, 2 (목업)
@riverpod
class LinkListNotifier extends _$LinkListNotifier {
  Future<List<LinkEntity>> build() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockLinks(); // 더미 데이터
  }
}

// After — Phase 3 (백엔드 연동)
@riverpod
class LinkListNotifier extends _$LinkListNotifier {
  Future<List<LinkEntity>> build() async {
    final result = await ref.read(fetchLinksUseCaseProvider).execute(
      const FetchLinksParams(page: 1),
    );
    return result.fold((failure) => throw failure, (links) => links);
  }
}
```

### 3.3 목업 우선의 장점

- **빠른 UX 검증**: 백엔드 없이도 전체 앱 흐름을 데모할 수 있다
- **병렬 개발**: UI와 백엔드 API를 동시에 설계할 수 있다
- **명확한 인터페이스**: Provider가 반환해야 할 데이터 구조를 UI를 통해 먼저 확정한다
- **포트폴리오 활용**: 백엔드 연동 전에도 앱 동작 영상을 찍을 수 있다

---

## 4. Git 브랜치 전략

### 4.1 브랜치 구조

```
main          — 단일 통합 브랜치 (릴리즈 태그 + PR 머지 대상, Branch Protection)
feature/*     — 기능 개발
fix/*         — 버그 수정
chore/*       — 설정 변경, 리팩토링
```

> **운영 방식** (2026-04 기준): `develop`은 사용하지 않는다. `feature/*`·`fix/*`·`chore/*` 브랜치에서 `main`으로 PR을 올리고, Branch Protection(`main` 전용 + CI 4 job green 필수) 하에서 머지한다.

### 4.2 브랜치 네이밍 예시

```
feature/auth-login
feature/link-crud
feature/search-debounce
feature/collection-share
feature/deep-link-cold-start
fix/link-thumbnail-parse-error
chore/add-github-actions-ci
```

### 4.3 PR 규칙

- PR 단위: 기능 하나 단위로 작게 유지
- PR 제목 형식: `[feat] 링크 저장 기능 구현`
- PR 생성 시 CI 자동 실행 확인
- self-review 후 merge

---

## 5. 커밋 컨벤션

### 5.1 형식

```
<type>: <subject>

<body> (선택)
```

### 5.2 Type 목록

| Type | 의미 |
|------|------|
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `refactor` | 리팩토링 (기능 변경 없음) |
| `test` | 테스트 코드 추가/수정 |
| `chore` | 빌드, 설정, 의존성 변경 |
| `docs` | 문서 수정 |
| `style` | 코드 포맷, 세미콜론 등 (로직 변경 없음) |

### 5.3 예시

```
feat: URL OG 태그 자동 파싱 구현

- dio를 사용해 URL HEAD 요청 후 og:title, og:description, og:image 추출
- 파싱 실패 시 URL 도메인을 기본 제목으로 fallback 처리
```

```
fix: Cold Start 딥링크 미처리 버그 수정

앱 초기화 완료 전 딥링크 수신 시 화면 이동이 무시되는 문제를
큐 시스템 도입으로 해결
```

---

## 6. 코드 컨벤션

### 6.1 파일 네이밍

```
// 스크린
link_list_screen.dart
link_detail_screen.dart

// 위젯
link_card_widget.dart
tag_chip_widget.dart

// Provider
link_list_provider.dart
save_link_notifier.dart

// UseCase
fetch_links_use_case.dart
create_link_use_case.dart
```

### 6.2 Provider 선언 위치

- Provider는 해당 feature의 `presentation/provider/` 디렉토리에 위치
- 전역 DI provider는 `app/di/` 디렉토리에 위치

### 6.3 린트 설정

`analysis_options.yaml`:

```yaml
include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_widgets: true
    avoid_print: true
```

---

## 7. 면접 대비 Q&A

### Q. 왜 목업 우선 방식을 선택했나요?

> "UI를 먼저 완성하면 백엔드 API 설계 전에 화면에서 필요한 데이터 구조를 확정할 수 있습니다. Provider가 반환할 타입을 Entity로 먼저 정의하고, 더미 데이터로 전체 UX를 검증한 뒤 백엔드를 붙이는 방식으로 진행했습니다. 덕분에 백엔드 연동 시 UI 코드를 거의 건드리지 않고 Provider 내부만 교체할 수 있었습니다."

### Q. 왜 이 폴더 구조를 선택했나요?

> "기능이 늘어날 것을 고려해 Feature-first 구조를 선택했습니다. 기능 단위로 응집도를 높이고, 각 기능 내부는 data / domain / presentation으로 분리해 책임을 명확히 했습니다. 순수 레이어드 아키텍처보다 실무에서 유지보수하기 쉬운 형태라고 판단했습니다."

### Q. 왜 Riverpod을 썼나요?

> "의존성 주입과 테스트가 편하고, AsyncNotifier로 비동기 상태를 로딩/성공/실패로 명확하게 표현할 수 있어서 서비스 앱 구조에 적합하다고 판단했습니다. UI는 provider를 구독만 하고, 상태 변경은 notifier에서만 일어나도록 단방향 흐름을 유지했습니다."

### Q. 오프라인은 어떻게 처리했나요?

> "최근 조회 링크와 즐겨찾기를 Hive CE에 로컬 캐싱했습니다. 네트워크 실패 시 Local DataSource를 fallback으로 사용하고, 오프라인 상태임을 UI에 표시했습니다. 즐겨찾기 토글은 Optimistic update를 적용해 반응성을 높이고, 실패 시 롤백 처리했습니다."

### Q. 테스트는 어디까지 했나요?

> "UseCase와 Repository 레이어는 mocktail로 의존성을 mock해 단위 테스트를 작성했습니다. 로그인 validation, 리스트 렌더링은 위젯 테스트로, 핵심 사용자 플로우 3개는 integration test로 검증했습니다."

### Q. 이 프로젝트에서 가장 어려웠던 점은?

> "두 가지가 있었습니다. 첫째는 링크 저장 흐름에서 Remote/Local 상태를 일관되게 유지하는 부분이었습니다. Optimistic update 적용 후 실패 시 롤백 로직을 안정적으로 처리하는 데 공을 들였습니다. 둘째는 Cold Start 딥링크 처리였습니다. 앱 초기화 완료 전 딥링크가 수신될 때 화면 이동이 무시되는 문제를 큐 시스템으로 해결했습니다."

### Q. CI/CD는 어떻게 구성했나요?

> "GitHub Actions로 `main`에 올리는 모든 PR에서 flutter analyze / flutter test / build APK 4-job을 자동 실행합니다. Branch Protection으로 머지 전 green을 강제하고, 릴리스 자동 배포(Firebase App Distribution 등)는 Phase 7에서 `main` 머지 또는 릴리스 태그 트리거로 이어갈 예정입니다."

---

## 8. README 구성 가이드

> **현황:** 루트 `README.md` (영문) + `README.ko.md` (한국어) 2026-04-05 완료. Mermaid 아키텍처/데이터 흐름 다이어그램 포함. Phase 9에서 시연 GIF 및 스토어 링크만 추가하면 완성.

포함 항목:

```
# LinkNote

[앱 시연 GIF]

## 소개
한 줄 설명

## 기술 스택
Flutter | Riverpod | go_router | Supabase | Hive CE | GitHub Actions

## 아키텍처
Feature-first + Clean Architecture 설명 + 폴더 구조 트리

## 주요 기능
- 링크 저장 (OG 자동 파싱)
- 태그/컬렉션 관리
- 오프라인 지원
- 딥링크 연동
- ...

## 데이터 흐름 다이어그램
[Mermaid 또는 이미지]

## CI/CD
GitHub Actions 파이프라인 설명 + badge

## 실행 방법
flutter pub get
flutter run

## 구현 포인트
(이력서 기재 내용과 동일하게)
```

---

*Workflow v2.1 — LinkNote Side Project (Mockup-First → Android MVP → iOS → Deployment)*
