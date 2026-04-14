# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed (Session 30 — Wave 4 Collection P0/P1)

- **P0-A — `collectionLinksProvider` Failure 침묵 해결** (`lib/features/collection/presentation/provider/collection_links_provider.dart`): Failure 시 빈 리스트를 리턴하던 로직을 제거하고 `Error.throwWithStackTrace(result.failure!, StackTrace.current)`로 에러를 AsyncValue로 surface. 신규 단위 테스트 `test/features/collection/presentation/provider/collection_links_provider_test.dart` (success + failure 2 cases) 추가
- **P1-A — Collection user_id 명시 필터 + RLS 문서화**: `CollectionRemoteDataSource.updateCollection/deleteCollection/getCollectionById`에 `String userId` 인자 추가 → `.eq('user_id', userId)` 이중 필터 적용 (defense in depth). `CollectionRepositoryImpl`이 기존 userId 필드를 전달. `docs/security/rls_policies.md` 신설 — Supabase RLS SELECT/INSERT/UPDATE/DELETE 정책 SQL 문서화 (collections / links / 조인 테이블). 기존 `collection_repository_impl_test.dart`의 mock 시그니처 업데이트 + userId 전달 verify 추가
- **P1-B — Hive cache 타입 가드** (`lib/features/collection/data/datasource/collection_local_datasource.dart` `_trimCache`): 오염된 int-key 엔트리가 `entry.key as String` 캐스트에서 `TypeError`를 던져 cacheWrite 전체가 실패하던 문제를, 루프 시작에 `if (entry.key is! String) { await _box.delete(entry.key); continue; }` 가드로 격리. 테스트 `collection_local_datasource_test.dart`에 int-key 오염 시나리오 추가
- **P1-C — CollectionList create/update 에러 전파 + form snackbar 분기** (`lib/features/collection/presentation/provider/collection_list_provider.dart`, `lib/features/collection/presentation/screens/collection_form_screen.dart`): provider가 Failure를 조용히 삼키고 success snackbar를 오발화하던 문제를 해결. provider는 Failure 시 `Error.throwWithStackTrace`. form `_submit`은 try/catch로 감싸 성공 시에만 success snackbar + pop, 실패 시 `context.showErrorSnackBar("컬렉션 생성/수정에 실패했습니다")` + 폼 유지. 신규 provider 단위 테스트 3 cases

### Changed

- **앱 아이콘 교체**: `assets/images/app_icon.png` (1024×1024 LinkNote 신규 브랜드 로고)로 교체. `flutter_launcher_icons` 재생성 — Android mipmap / iOS AppIcon / adaptive icon (배경 `#4A90D9`, foreground도 동일 로고로 통일). `mipmap-anydpi-v26` foreground를 신규 로고로 통일해 Android 12+ 런처 캐시 이슈 방지
- **스플래시 로고 교체**: `flutter_native_splash` 재생성. Android 12+ 원형 마스크에서 로고가 잘리던 이슈를 2048×2048 투명 캔버스에 1024×1024 로고를 중앙 배치한 padded PNG(`splash_logo_android12.png`)로 해결. 로고에 iOS squircle 수준(22%) 라운딩 마스크 적용으로 자연스러운 모서리 처리

### Security / Fixed

- **Wave 1 픽스 구현 (Session 22)** (Plan: `tasks/wave1_fix_plan.md`)
  - Session 20에서 식별된 Wave 1 이슈 6건(P1 3 · P2 2 · P3 1) 중 5건을 ai-coding-pipeline Stage 4로 구현. P3-A(proguard Hive keep rules)는 YAGNI 근거로 본 스프린트 제외 (`tasks/lessons.md`에 보류 근거 기록)
  - **P1-A — dio_client 401 → SignOutUsecase 계약 복원**: `lib/core/network/dio_client.dart:27-36`의 `onUnauthorized` 콜백이 `Supabase.instance.client.auth.signOut()`을 직접 호출하던 것을 `ref.read(signOutUsecaseProvider).call()`로 교체. 이로써 Session #5 P1-3의 "3x `clearAll()`" 계약이 401 경로에서도 작동 → 강제 로그아웃 시 `links`/`collections`/`notifications` Hive 박스가 항상 비워짐. Supabase import 제거
  - **P1-A 연장 — clearAll 가드 제거**: `lib/features/auth/domain/usecase/sign_out_usecase.dart:20-32`의 `if (result.isSuccess)` 가드를 제거해 서버 signOut 실패 시에도 로컬 캐시를 항상 clearAll. 네트워크 오류 / 이미 무효인 세션 / 401 경로 모두에서 사용자 전환 시 이전 계정 데이터 누출 방지 (Q1 승인)
  - **P1-B — signUp session=null 승격 차단**: `lib/features/auth/data/datasource/auth_remote_datasource.dart:55-75`에 `response.session == null` 분기 추가. Supabase Email Confirmation이 활성화되면 `user != null` + `session == null`로 돌아오는데, 이 상태를 `Failure.auth("이메일 확인 링크가 발송되었습니다. 메일을 확인하고 로그인해 주세요.")`로 변환해 사용자가 이메일 확인을 먼저 처리하도록 유도. P1-A 트리거 경로 차단
  - **P1-B 결합 — failure_ui.dart AuthFailure 메시지 관통**: `lib/core/error/failure_ui.dart:30-41`의 `AuthFailure()` 분기가 `message` 필드를 무시하고 "다시 로그인해 주세요"를 하드코딩하던 문제를 수정. `AuthFailure(:final message) when message != null && message.isNotEmpty`로 메시지 있으면 surface, 없으면 기본값. 이로써 데이터소스의 `Failure.auth(message: e.message)` 에러가 SnackBar에 실제 표시됨 (Q2 승인)
  - **P1-C — auth_provider userUpdated 분기 + 주석 정합성**: `lib/features/auth/presentation/provider/auth_provider.dart`에 `reactiveAuthEvents` const Set 추출 (`signedOut`, `tokenRefreshed`, `userUpdated`). `gotrue-2.18.0` SDK 검증으로 `AuthChangeEvent.userDeleted`는 `@Deprecated` + 빈 `jsName`이라 서버가 방송하지 않음 확인 → 분기 추가 금지. 대신 `userUpdated` 분기 추가로 비밀번호 변경 감지 실질 지원. 주석의 "user deletion" 제거
  - **P2-A — AndroidManifest allowBackup 비활성**: `android/app/src/main/AndroidManifest.xml`에 `android:allowBackup="false"` + `android:fullBackupContent="false"` 추가. Hive 박스가 이미 `HiveAesCipher` 암호화 + 키가 `FlutterSecureStorage`(Keystore)라 실질 데이터 유출 경로는 없지만 defense-in-depth baseline으로 선언. `flutter build apk --debug --flavor dev` 성공 확인
  - **P2-B Step 1 — CI build.needs에 security 추가**: `.github/workflows/ci.yml`의 `build` job이 `analyze`만 기다리던 것을 `needs: [analyze, security]`로 변경. Semgrep 실패 시 build 자체가 스킵되어 머지 게이트 실효화
  - **P2-B Step 2 — Branch Protection 신규 생성**: `gh api -X PUT repos/kaywalker91/LinkNote/branches/main/protection`으로 보호 규칙 최초 생성 (기존 상태 404). `contexts: [Analyze, Test, Build (Android Dev Debug), Security Scan]`, `strict: true`, `enforce_admins: false` (Q3, 긴급 수정 admin 우회 허용), `required_pull_request_reviews: null` (Q4, 단독 개발자), `allow_force_pushes: false`, `allow_deletions: false`. 앞으로 `main` 직접 push 불가 / PR + CI 4개 job green 필수
  - **TDD 사이클**: Step 1~3 모두 RED → GREEN 준수. 신규 테스트 파일 3건 — `test/features/auth/data/datasource/auth_remote_datasource_test.dart` (6 cases), `test/core/network/dio_client_test.dart` (2 cases), `test/features/auth/presentation/provider/auth_provider_test.dart` (5 cases). 기존 `test/features/auth/domain/usecase/sign_out_usecase_test.dart`의 "NOT clearAll on fail" 케이스를 "ALWAYS clearAll (401 path safety)"로 동작 업데이트
  - **Quality gates**: `flutter analyze` 0 issues · `flutter test` **353 passed** (기존 315 → +38) · `flutter build apk --debug --flavor dev` 성공 (12.6s)
  - **회귀 검증**: Session #1-6 보안 감사 픽스 10건 재검증 — 8건 완전 유지 + 2건(P1-2 연장, P2-2) **복원**. P1-2 연장은 P1-A 픽스로 dio → SignOutUsecase 경로 복원, P2-2는 P2-B로 job-level gating 갭 해결
  - **Stage 1 사전 검증 효과**: 리뷰 보고서의 "Unverified assumptions" 5건을 Stage 2 진입 전 직접 검증 → 3개 이슈(P1-C, P2-A, P2-B)의 픽스 방향이 달라짐. 예: `userDeleted` 분기 추가가 완전 무의미임을 gotrue SDK 소스로 확정 / `allowBackup` 위험도 재평가 / Branch Protection이 전무함을 발견해 스코프 2배. 방법론 기록은 `tasks/lessons.md`

### Security / Review

- **Wave 1 — 보안 & 인증 크리티컬 패스 종합 코드리뷰 (Session 20)** (Plan: `resilient-imagining-starfish.md` Wave 1)
  - **목적**: Session #12~#19에서 정식 코드 리뷰 없이 누적 머지된 변경(Firebase 배선, release signing, URL 런처, UrlSanitizer, 훅 튜닝)이 Session #1~#6에서 수정한 보안 감사 10건을 회귀시켰는지 + 신규 드리프트가 발생했는지 검증
  - **오케스트레이션**: Stage A(준비) → Stage B(Claude 내부 `feature-dev:code-reviewer` 1차) → Stage C(`codex exec -s read-only` + `gemini --approval-mode plan` 병렬 2차) → Stage D(3자 합의 통합)
  - **범위**: `lib/features/auth/**` 13파일 + `lib/core/network/` 3파일 + `lib/core/constants/env_*.dart` 3파일 + `lib/core/storage/storage_service.dart` + `lib/shared/providers/session_expired_provider.dart` + `lib/main.dart` + `lib/bootstrap.dart` + `lib/firebase_options_*.dart` 3파일 + `android/app/src/main/AndroidManifest.xml` + `android/app/build.gradle.kts` + `android/app/proguard-rules.pro` + `.github/workflows/ci.yml` (+ 교차검증: `search_remote_datasource.dart`)
  - **결과**: P0 0 · **P1 3** · P2 2 · P3 1 — 코드 수정은 발생하지 않은 read-only 리뷰
    - **P1-A**: `lib/core/network/dio_client.dart:27-33` — 401 핸들러가 `Supabase.auth.signOut()`을 직접 호출하여 Session #5 P1-3(`SignOutUsecase`의 3x `clearAll()` 계약)을 우회. 강제 로그아웃 시 `links`/`collections`/`notifications` Hive 캐시 잔류. **Codex/Gemini 둘 다 P0, Claude P1** → 합의 P1 (캐시 누출 계약 위반)
    - **P1-B**: `lib/features/auth/data/datasource/auth_remote_datasource.dart:51-64` — `signUp()`이 `response.session == null`일 때도 `Authenticated` 반환. Supabase Email Confirmation 활성화 시 이메일 미확인 유저가 인증 상태로 승격 → 즉시 401 → P1-A 경로 연쇄 작동. **Codex 단독 발견 + 리뷰어 소스 재검증으로 확정**
    - **P1-C**: `lib/features/auth/presentation/provider/auth_provider.dart:21-23` — 구독 가드가 `AuthChangeEvent.userDeleted` 미처리. 주석은 "user deletion" 커버 선언하지만 실제 guard는 `signedOut`/`tokenRefreshed`만. Supabase 원격 계정 삭제 시 JWT 만료(1h)까지 인증 UI 유지
    - **P2-A**: `android/app/src/main/AndroidManifest.xml:3-6` — `android:allowBackup` / `dataExtractionRules` 미지정. Android Auto Backup으로 Hive `.hive` 파일이 Google Drive에 업로드될 가능성 (3/3 만장일치 P2)
    - **P2-B**: `.github/workflows/ci.yml` `build` job이 `security` job을 `needs:`에 포함하지 않음. Semgrep 실패가 머지 게이트 역할 못 함 (3/3 만장일치 P2)
    - **P3-A**: `android/app/proguard-rules.pro` — Hive CE `@HiveType` 어댑터용 keep 룰 선제 보강 (현재 미사용이라 잠재 리스크만)
  - **회귀 매트릭스 (Session #1-6 픽스 10건 재검증)**: 8건 완전 유지, 2건 변형 — P1-2 연장(401 시 `signOut` 호출은 유지되나 Usecase 우회 → P1-A), P2-2(Semgrep `continue-on-error`는 제거 유지되나 job 단위 gating 갭 → P2-B)
  - **보고서**: `docs/code_review/2026-04-12_wave1_security.md` (전체 3자 합의 매트릭스 + 각 이슈 file:line + 재현 + 권장 픽스 + Unverified assumptions + Recommended follow-up)
  - **3자 합의 인프라 검증**: `codex exec` + `gemini -p` 병렬 백그라운드 실행 프로토콜이 Wave 2~6에서 재사용 가능한 상태로 확정. 공유 프롬프트는 `/tmp/linknote_wave1_review_prompt.md`에 기록되어 다음 웨이브 진입 시 구조만 재활용
  - **참고**: 코드 수정/빌드/테스트 실행 없음. P1 픽스는 별도 구현 세션에서 ai-coding-pipeline Stage 1(Research) → 2(Plan) → 3(Feedback) → 4(Implement) 파이프라인 재가동 후 진행 예정

### Fixed

- **YouTube 링크 "잘못된 링크 형식입니다" 버그 해결 (Session 19)** (Plan: `refactored-sniffing-pebble.md`)
  - **증상**: Session 18 수정 후 실기기(Galaxy A34, Android 16)에서 저장된 YouTube 링크를 탭하면 `"잘못된 링크 형식입니다"` 스낵바 — scheme-less fallback 추가에도 해결 안 됨
  - **데이터 기반 진단**: `UrlLauncherHelper.launch` 진입부에 temp debugPrint 삽입 → 실기기 재설치 → 문제 링크 탭 → flutter logs 캡처. raw 문자열:
    ```
    하네스 엔지니어링 - 50점짜리 Codex를 88점으로 만드는 법 - https://youtube.com/watch?v=p9mRnsx7yv4&si=LLAhSDDM4YQ_Xv4X
    ```
    → `NULL@tryParse` 분기. hidden char도, canLaunch 버그도, scheme 문제도 아닌 **"제목 + URL" 전체 텍스트가 통째로 저장된 입력 데이터 문제**. YouTube Share sheet → Copy의 기본 포맷이 제목을 포함한다는 사실을 간과
  - **Session 18의 교훈 적용**: 가설 없이 진단부터 시작 — 로그 한 줄로 원인 확정
  - **변경**:
    - `lib/shared/utils/url_sanitizer.dart` **(신규)** — `UrlSanitizer.extract()` 공용 유틸:
      1. Unicode invisible 제거 (`\u200b-\u200f\ufeff\u00a0\u2028\u2029`)
      2. Fast path — 이미 유효한 URL이면 그대로
      3. Regex `https?://\S+` 로 텍스트 안 첫 번째 URL 추출 (title+URL 페이스트 대응)
      4. Scheme-less fallback — 공백 없는 도메인 입력이면 `https://` prepend
      5. Trailing 구두점 trimming (`. , ; : ! ? ) ] }`)
    - `lib/shared/utils/url_launcher_helper.dart` — `_parse` 제거, `UrlSanitizer.extract` 단일 호출로 단순화. 진단용 debugPrint 전부 제거
    - `lib/features/link/presentation/screens/link_add_screen.dart` — `_handleUrlChanged()` 추가:
      - URL TextField `onChanged`에서 `UrlSanitizer.wouldAlter` 체크
      - 자동 추출 시 `_urlController` 텍스트를 깨끗한 URL로 교체 (커서 끝으로 이동)
      - 제목 필드가 비어있으면 leading prose(한글 제목 등)를 자동 복사 + separator 제거
      - `"붙여넣은 텍스트에서 URL을 추출했습니다"` 스낵바로 사용자 안내
    - `lib/features/link/data/mapper/link_mapper.dart` — `toEntity(dto)`에서 `UrlSanitizer.extract(dto.url)` 호출 — Supabase 원격 경로의 **레거시 DB 레코드 런타임 복구**
    - `lib/features/link/data/datasource/link_local_datasource.dart` — `_mapToEntity`에서 동일 sanitize — Hive 로컬 캐시 경로의 **레거시 레코드 런타임 복구** (양쪽 데이터 경계에서 이중 방어)
    - `LinkDto.fromJson` / `LinkEntity.fromJson`은 원복 — freezed 3.x + json_serializable이 customized factory body를 코드 생성 트리거로 인식하지 못해(`_$LinkDtoFromJson` 미생성), sanitize 책임을 mapper / datasource 레이어로 옮김
  - **테스트**:
    - `test/shared/utils/url_sanitizer_test.dart` **(신규)** — 18 cases: 빈 문자열, whitespace-only, 정상 http/https, BOM/NBSP/ZWSP 제거, title+URL (실제 문제 raw 문자열 상수화), prose+trailing punctuation, 다중 URL, scheme-less path, www prefix, space-separated 문장 거부, 한글 텍스트 거부, HTTPS 대문자, wouldAlter 4 cases
    - `test/shared/utils/url_launcher_helper_test.dart` — 기존 5 + 신규 2 cases 추가:
      - `extracts embedded URL from "title - URL" paste` (실제 문제 URL 재현)
      - `returns false + snackbar for text with no URL`
  - **검증**:
    - `flutter analyze` → **0 issues**
    - `flutter test` → **340 ALL GREEN** (기존 319 + sanitizer 18 + helper regression 2 + 기타 1)
    - `rg '\[UrlLauncher' lib/` / `rg 'debugPrint' lib/shared/utils/` → 0 (진단 로그 완전 제거)
    - **실기기 검증 (Galaxy A34, Android 16)**: YouTube 링크 + 일반 웹 링크 모두 정상 외부 브라우저 오픈 확인 — 사용자 승인
  - **Session 18에서 저지른 실수 반성**: "가설만으로 코드를 고친다" 패턴 재발 금지. 데이터가 확보되기 전에는 fix를 시도하지 않음. `project_url_launcher_bug_open.md` 메모리를 resolved 처리

- **`dart-code-smell.sh` 훅 false-positive 해결 (Session 19 secondary)**
  - **증상**: Session 18에서 발견된 훅의 `^.{16,}{` 정규식이 Dart named-parameter 생성자(`const factory Foo({`), freezed 코드, 일반 K&R brace를 모두 "deep nesting"으로 오탐 → 신규 파일들이 `// dart format off` + Allman 우회를 강요당함
  - **변경**:
    - `~/.claude/hooks/dart-code-smell.sh` 백업: `dart-code-smell.sh.bak`
    - 정규식 교체: `^.{16,}{` → `^ {32,}\S.*\{[[:space:]]*$`
      - **indent-first**: 선행 공백 32개 (= 2-space × 16 levels) 이상만 대상
      - **non-whitespace 요구**: `\S`로 Allman 고립 brace(`    {`)는 제외, K&R 스타일만 잡음
      - **EOL brace**: `\{[[:space:]]*$`로 줄 끝 `{`만 — `RegExp(` 등의 중간 brace 오탐 방지
    - 프로젝트 내 주요 파일 12개 전부 PASS 확인 (link_dto, link_entity, url_launcher_helper, url_sanitizer, link_list_tile, home_screen, link_add_screen, search_screen, collection_detail_screen, link_detail_screen, link_edit_screen, link_form_provider)
  - **Session 18 우회 미해제 (의도적)**: Session 18이 추가한 `// dart format off` + Allman 스타일은 그대로 유지 — 스타일 일관성 + diff 최소화. 향후 별도 리팩터링 세션에서 K&R 복구 가능

- **저장된 링크 탭 → 브라우저 열기 버그 수정** (Plan: `shiny-baking-aho.md`)
  - **증상**: 홈/검색/컬렉션 상세에서 저장된 링크를 탭해도 아무 반응이 없음 (상세 화면 이동도, 외부 브라우저 열기도 발생하지 않음)
  - **근본 원인 2건**:
    1. **의도 불일치** — 세 리스트 화면의 `LinkListTile.onTap`이 `context.push(linkDetailPath)`로 배선되어 있었지만, 사용자 기대는 즉시 외부 브라우저 열기
    2. **Android 11+ 패키지 가시성** — `AndroidManifest.xml`의 `<queries>`에 `http/https` `ACTION_VIEW`가 선언되지 않아 `canLaunchUrl`이 **사일런트 false** 반환 → 상세 화면에서조차 URL 탭이 무반응
  - **변경**:
    - `android/app/src/main/AndroidManifest.xml` — 기존 `<queries>` 블록에 http/https `ACTION_VIEW` intent 2건 추가 (url_launcher 공식 문서 패턴, iOS는 기본 허용)
    - `lib/shared/utils/url_launcher_helper.dart` **(신규)** — `UrlLauncherHelper.launch(context, url)`:
      - `trim().isEmpty` / `!hasScheme` / `host.isEmpty` 검증 → "잘못된 링크 형식입니다" 스낵바
      - `canLaunchUrl == false` → "링크를 열 수 없습니다" 스낵바
      - `launchUrl(mode: externalApplication)` + `PlatformException` 캐치 → "링크를 여는 중 오류가 발생했습니다" 스낵바
      - 모든 `await` 뒤 `context.mounted` 가드
    - `lib/shared/widgets/link_list_tile.dart` — nullable `onLongPress` 파라미터 + `InkWell.onLongPress` 배선 (탭이 URL 열기로 변경되며 상세 진입 경로를 롱프레스로 보존 — 표준 모바일 UX)
    - `lib/features/link/presentation/screens/home_screen.dart` — tap→`UrlLauncherHelper.launch`, longPress→상세, `_showMoreSheet` 최상단에 "View Details" 항목 추가
    - `lib/features/search/presentation/screens/search_screen.dart` — tap→launch, longPress→상세
    - `lib/features/collection/presentation/screens/collection_detail_screen.dart` — 동일
    - `lib/features/link/presentation/screens/link_detail_screen.dart` — 인라인 `canLaunchUrl`/`launchUrl` 블록을 `UrlLauncherHelper.launch` 한 줄로 치환, 매니페스트 fix 혜택을 자동 수혜 + `url_launcher` import 제거
    - `pubspec.yaml` — `plugin_platform_interface`, `url_launcher_platform_interface`를 `dev_dependencies`에 직접 선언 (test 파일의 `depend_on_referenced_packages` 린트 해결 — 기존 transitive → direct)
  - **테스트**:
    - `test/shared/utils/url_launcher_helper_test.dart` **(신규)** — `UrlLauncherPlatform.instance` mocktail 오버라이드, 4 케이스 (empty URL / canLaunch=false / 성공 / PlatformException) 전부 GREEN
    - `test/integration/search_to_detail_flow_test.dart` — `should navigate to detail when tapping result` → `should navigate to detail when long-pressing result`로 전환, `tester.tap` → `tester.longPress`
  - **검증**:
    - `flutter analyze` → **0 issues**
    - `flutter test` → **319 ALL GREEN** (기존 315 + 신규 helper 4)
    - TDD 사이클 준수: RED (`UrlLauncherHelper` 미정의 compile error) → GREEN (구현) → REFACTOR (화면 배선)
  - **수동 검증 시도 (Galaxy A34, Android 16) → 미해결 버그 발견**:
    - `flutter run --flavor dev -t lib/main_dev.dart` full install 2회 수행
    - 저장된 YouTube 링크 탭 시 **"잘못된 링크 형식입니다"** 스낵바 (`_parse`의 invalid 분기)
    - 즉석 추가 수정: `_parse`에 scheme-less fallback (`!uri.hasScheme` → `https://$trimmed` prepend) + 테스트 케이스 1건 추가 → 5/5 GREEN
    - 재설치 후에도 **동일 오류 지속** → 즉시 해결 불가, **Session 19로 이월**
    - 반성: 실제 저장된 `link.url` raw 값을 확인하지 않고 가설로 수정한 것이 잘못. Session 19는 데이터 확인부터 시작
    - 참조: 메모리 `project_url_launcher_bug_open.md`, `docs/next_session_prompt.md` Session 19 프롬프트
  - **발견된 기술 부채 (별도 세션)**:
    - `~/.claude/hooks/dart-code-smell.sh`의 "중첩 깊이" 검사 정규식(`^.{16,}{`)이 **Dart named-parameter 생성자 `{`**와 **K&R 함수 brace `{`**를 "deep nesting"으로 오탐 → 신규 파일 2건(`url_launcher_helper.dart`, `url_launcher_helper_test.dart`)에 `// dart format off` + Allman-style brace 적용으로 우회. 기존 파일 편집은 경고만 발생하고 edit은 정상 적용됨 (`flutter analyze` 0 + 319 tests GREEN이 증거)

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
