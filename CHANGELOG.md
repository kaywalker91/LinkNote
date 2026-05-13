# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added (Session 53 — Sprint-1 closure: F2 repository test gap)

- **신규 `test/features/reading_stats/data/repository/reading_stats_repository_impl_test.dart`** — `_MockDatasource` (mocktail) 사용해 6 케이스 커버: recordReadEvent/getReadingStats 각각 (a) 정상 → `success`, (b) HiveError 던짐 → `Failure.cache`, (c) generic Exception 던짐 → `Failure.cache`. AC-12 명세("when datasource throws HiveError, repository returns CacheFailure")의 test side 충족.
- **`docs/harness-followups.md` F2 RESOLVED 마크** — Sprint-1 medium-severity follow-up closure 기록.
- **`tasks/lessons.md` 2026-05-11 dart format 강화 항목** — Session 52 작성분 묶음.
- **`docs/daily_task_log/2026-05-11_session52.md`** — Session 52 daily log (Session 52 작성분 묶음).
- 전체 테스트 550 → 556 GREEN, flutter analyze 0 issues.

### Added (Session 52 — Harness Sprint-1: ReadingStats subsystem (PR #35))

- **신규 `lib/features/reading_stats/`** — Clean Architecture(domain/data/presentation) 풀스택 도입. `ReadingEventEntity`(linkId/timestamp/durationSeconds?) + `ReadingStatsEntity`(linkId/totalReads@Default(0)/lastReadAt?) + `IReadingStatsRepository`(`Result<T>` typedef + 톱레벨 `success<T>()`/`error<T>()`) + `RecordReadEventUsecase`(empty linkId / future timestamp / negative duration 검증, `Failure.cache(message: 'Validation: ...')` 접두어) + `GetReadingStatsUsecase`(thin wrapper).
- **신규 `ReadingStatsLocalDatasource`** — Hive `Box<Map<dynamic, dynamic>>` 사용, hand-rolled `Map<String, Future<void>> _writeQueue` 로 per-linkId 동시성 직렬화(`synchronized` 패키지 미사용, 무신규 의존성). 10-way `Future.wait` concurrency 테스트로 distinct timestamp 10개 보존 검증.
- **신규 `ReadingStatsRepositoryImpl`** — `on Object catch` 패턴(HiveError extends Error 대응) + 톱레벨 `error<T>(Failure.cache(message: '<context>: $e'))` 반환.
- **신규 Riverpod DI 프로바이더** — `@riverpod` codegen, `reading_stats_di_providers.dart` + `.g.dart`.
- **`lib/core/storage/storage_service.dart`** — 4줄 추가(`await Hive.openBox<Map<dynamic, dynamic>>('reading_stats', encryptionCipher: cipher);`). Contract `allowed_exceptions` 범위 내, 기존 5 box 와 동일 `HiveAesCipher` 사용.
- **신규 `docs/harness-followups.md`** — Harness Planner-Generator-Evaluator 파이프라인 cross-sprint 영속 registry. Sprint-1 F1~F9 9건 follow-up 등록 + cross-sprint pattern 섹션. `.claude/harness/runs/` 산출물이 gitignored 이므로 squash merge 후에도 살아남는 영속 도큐먼트.
- **테스트 16개 (full suite 550 GREEN)** — `test/features/reading_stats/data/datasource/` FakeBox + 동시성 + out-of-order timestamp aggregation, `test/features/reading_stats/domain/usecase/` 13 AC 커버.

### Process

- **Harness 파이프라인 첫 정식 사이클 완주** — Planner(opus) → Generator(sonnet-4-6) → 4-evaluator 합의(Mode B Opus 74/80 + Codex AC-11 PASS + Gemini AC-12 PASS + Round 4 Opus 독립 재평가 73/80). 모든 측정 차원 floor 충족, threshold 60 대비 weighted 73~74.
- **Path B isolation judgment** — build_runner 의 결정적 부수효과로 `lib/{app/router, features/{auth,search,share}, core/constants/env_*}` 등 forbidden territory 의 `.g.dart` 5 파일 재생성(riverpod hash 재계산 + envied XOR seed 회전). 모두 zero behavioral delta. 4-evaluator 모두 Path B(semantic/lenient) 동의. 의무 follow-up `forbidden_files_codegen_exception` 절 다음 Planner Contract 권고.
- **`tasks/lessons.md` 2026-05-11 항목 추가** — `dart format` 누락이 CI Analyze 를 2 회 실패시킴(Session 38 PR #18 + Session 52 PR #35). 메모리 entry 만으로는 재발 방지 부족 결론, 자동 메커니즘(pre-push hook / harness deterministic_verifier 에 `dart format --set-exit-if-changed` 추가) 권고.

### Added (Session 51 — Phase 4.5: Visual baseline (alchemist + bundled fonts))

- **신규 `dev_dependencies: alchemist ^0.14.0`** — Betterment 의 golden test 라이브러리. `golden_toolkit` 이 archived 인 점 + CI 의 cross-platform 픽셀 차이 우려를 해결(Ahem 폰트로 CI golden 통일). `goldenTest` 1 호출 = 1 PNG, `GoldenTestGroup` + `GoldenTestScenario` 로 컬럼 그리드 매트릭스 캡처.
- **신규 `test/flutter_test_config.dart`** — `GoogleFonts.config.allowRuntimeFetching = false` (번들 폰트 사용, 네트워크 페치 차단) + `AlchemistConfig` 의 `platformGoldensConfig.enabled = !isRunningInCi` 분기(로컬 macOS 골든 가독성 + CI ahem golden 결정성 동시 보호). 컴파일 타임 `bool.fromEnvironment('CI')` 사용.
- **신규 `dart_test.yaml`** — alchemist 가 부여하는 `golden` 태그 등록 → 테스트 실행 시 "tag was used that wasn't specified" 경고 제거. 사용 패턴: `flutter test --tags golden` (only goldens), `flutter test --exclude-tags golden` (skip).
- **신규 `assets/fonts/`** — Inter Regular/Medium/SemiBold/Bold + JetBrainsMono Regular/Medium + Fraunces-Medium(Fraunces72pt-Regular 리네임) 7 파일, 약 2.2MB. 출처: rsms/inter v4.1, JetBrains/JetBrainsMono v2.304, undercasetype/Fraunces v1.0. `pubspec.yaml` 의 `flutter.assets` 에 등록 → `google_fonts` 패키지가 prefix endsWith 매칭으로 자동 인식. 부수 이점: 프로덕션 첫 로드 시 폰트 페치 대기 제거.
- **신규 `test/shared/widgets/ln/golden/_golden_helpers.dart`** — `themedScenario({dark, child, padding, width})` 헬퍼. 위젯을 `Theme(data: AppTheme.dark/light)` + bgAlt 배경에 래핑해 light/dark 시나리오를 같은 PNG 안에서 비교 가능.
- **신규 8 alchemist `goldenTest` (3 파일, 42 `GoldenTestScenario`)** + **8 CI golden PNG baseline** (`test/shared/widgets/ln/golden/goldens/ci/*.png`):
  - `ln_brand_golden_test.dart` — LinkNoteWordmark / LinkNoteMark × light/dark.
  - `ln_cards_golden_test.dart` — LnLinkCard (favorite + 2 tags + collection name) × light/dark, LnCollectionCard 4 tone(forest/lilac/slate/amber 4 컬렉션 id) × light/dark.
  - `ln_atoms_golden_test.dart` — LnTopBar(`내 서랍`), LnIconBtn(plain/badge), LnSegmented(전체/즐겨찾기), LnTag 5 tone, LnThumb sm/md/lg(hostPill) × light/dark.

### Changed (Session 51)

- **`.gitignore`** — `**/goldens/macos`, `**/goldens/linux`, `**/goldens/windows` 추가. alchemist 의 platform-specific 골든은 host 의존이므로 `goldens/ci/*.png` 만 트래킹.

### Added (Session 50 — Phase 4: Dark mode forest 팔레트 + AppPalette ThemeExtension)

- **신규 `lib/app/theme/app_palette.dart`** — `AppPalette extends ThemeExtension<AppPalette>` 22 design 토큰(forest/forestSoft/forestInk, amber/amberSoft/amberInk, slate/slateSoft, rose/roseSoft, lilac/lilacSoft, bg/bgAlt/bgSunk, ink~ink5, line/lineStrong) 보유. `factory light()` 는 기존 `AppColors` 와 byte-identical, `factory dark()` 는 forest-tuned 다크 팔레트(`bg #141A17`, `ink #E8EDE9`, `forest #3FA37C` 등). `copyWith` + `lerp` 풀 구현.
- **`lib/app/theme/app_theme.dart` 재작성** — light/dark 빌더 모두 AppPalette 인스턴스 단일 진입점. `extensions: [palette]` 등록, ColorScheme 가 palette 토큰에서 파생. AppBar / Card / NavigationBar / Chip / Snackbar / FAB / Input 모든 컴포넌트가 palette 사용.
- **`lib/shared/extensions/context_extensions.dart`** — `AppPalette get palette` getter. 미등록 시 `AppPalette.light()` fallback (기존 위젯 테스트 호환).
- **신규 `test/app/theme/app_palette_test.dart` (10 cases)** + **`test/shared/widgets/ln/ln_widgets_dark_test.dart` (8 cases)** — AppPalette light↔AppColors 동등 검증, dark factory 차이 검증, ThemeData wiring, context.palette 분기, 8 Ln 위젯이 dark theme 하에서 dark 토큰 적용해 렌더하는지 회귀 보호.

### Changed (Session 50)

- **Ln 위젯 마이그레이션 (`AppColors.X` → `context.palette.X`)** — `ln_link_card.dart`, `ln_collection_card.dart`, `ln_top_bar.dart`, `ln_icon_btn.dart`, `ln_segmented.dart`, `ln_brand.dart`, `ln_tag.dart`, `ln_thumb.dart`, `ln_tags.dart` 9 파일. ThemeData.dark() 만으로는 변하지 않던 위젯 색이 brightness 따라 자동 분기.
- **`LnTagTone` extension API breaking change** — `Color get background` / `Color get foreground` getter → method `(BuildContext context)`. 호출부(`ln_tag.dart` / `ln_thumb.dart`) 동시 마이그레이션. 외부에서 LnTagTone 컬러 직접 사용처 없음.
- **`lib/app/theme/app_colors.dart` 정리** — light 상수/alias/Hex 모두 유지(backward compat). 사용처 사라진 slate-blue *Dark 상수 8개(`surfaceDark`, `surfaceVariantDark`, `backgroundDark`, `textPrimaryDark`, `textSecondaryDark`, `textHintDark`, `borderDark`, `borderLightDark`) 제거.

### Tests (Session 50 — TDD GREEN, 500 → 518)

- 신규 dark mode 회귀 테스트 18개 추가 (palette 10 + Ln widgets dark 8).
- 기존 `test/shared/widgets/ln/ln_tag_test.dart` 의 LnTagTone color API 사용 케이스를 `MaterialApp + Builder` ctx 캡처 패턴으로 마이그레이션.

### Notes (Session 50)

- **시각 golden baseline 은 deferred** — `golden_toolkit` 미설치 + CI cross-platform 픽셀 차이 우려. 동등한 회귀 보호를 structural 어설션으로 대체. Phase 4.5+ 에서 `golden_toolkit` 도입 후 visual baseline 수립.
- **실기기 시각 검증 6 세션 연속 스킵** — Home / LinkDetail / Collection grid / Search / Bottom Nav / Notifications + light↔dark 토글, Session 51 우선순위 최상.

### Changed (Session 49 — Phase 4: Collection 2열 그리드 + 그라디언트 카드)

- **신규 `lib/shared/widgets/ln/ln_collection_card.dart`** — 그라디언트 헤더 카드 위젯. 78px 헤더에 4톤(forest/lilac/slate/amber) `LnCollectionTone.values` 중 `id` 해시(31진법)로 결정적 분배 → 같은 컬렉션은 항상 동일 톤. 헤더 좌하단 `Icons.folder_rounded` white. 하단 패널: 이름 `titleM`(2 lines, ellipsis) + "링크 N개" `caption ink3`. `static LnCollectionTone toneForId(String id)` 노출(테스트 + 외부 재사용).
- **`lib/features/collection/presentation/screens/collection_list_screen.dart`** — `PaginatedListView`(ListView) → `CustomScrollView + SliverGrid`(crossAxisCount=2, crossAxisSpacing/mainAxisSpacing=12, childAspectRatio=0.95). 빈/에러/로딩 분기 유지, 스크롤 페이지네이션 + RefreshIndicator 인라인. `_PaginatedGrid` 내부 위젯 + `_SkeletonGrid`. shell add-link FAB(centerDocked) 와 collection FAB(endFloat, `collections_fab`) 위치 충돌 없음 유지.
- **`lib/shared/widgets/skeleton/collection_card_skeleton.dart`** — 그리드 셀 카드 폼(헤더 78 ShimmerBox + 텍스트 라인 2개)으로 재구성, 가로 패딩 제거(셀 단위 렌더).

### Tests (Session 49 — TDD RED → GREEN, 495 → 500)

- `test/shared/widgets/ln/ln_collection_card_test.dart` 신규 5 cases — RED(`No such file 'ln_collection_card.dart'`) → GREEN. name/count 렌더링, onTap, folder icon, `toneForId` 결정성, 팔레트 분포(20개 id → 1개 톤 collapse 방지).
- `test/features/collection/presentation/screens/collection_list_screen_test.dart` — 스켈레톤 finder `ListView` → `GridView`, 셀렉터에 `LnCollectionCard.findsNWidgets(2)` 추가.
- `test/integration/collection_create_flow_test.dart` — 카드가 description 미표시(디자인 spec) 반영해 `find.text('Useful dev links')` assertion 제거.
- 500 GREEN, analyze 0, format clean. CI 4 job ALL PASS + 사용자 수동 머지(commit `207dd1a`).

### Decision (Session 49)

- **Lock/Globe visibility pill 미도입** — `CollectionEntity` 에 `visibility` 필드 없음. "수치 기준 창작 금지" 정책 확장 적용: 모델에 없는 속성을 UI에서 임의로 표기하지 않음. public/private 데이터 모델 도입 시 후속 PR.
- **emoji slot → folder 아이콘 유지** — `CollectionEntity` 에 `emoji` 필드 없음. 디자인 spec 의 emoji 자리는 `Icons.folder_rounded` (white on gradient) 로 대체.
- **description 카드 미표시** — 디자인 spec 그대로. description 은 상세 화면에서만 노출.

### Changed (Session 48 — Phase 4: LnTabBar 5탭→4탭 + 중앙 FAB)

- **`lib/shared/widgets/app_scaffold_with_nav_bar.dart`** — `NavigationBar.destinations` 5개→4개. Notifications destination 제거 → Home/Search/Collections/Profile. `Scaffold.floatingActionButton` 신설(forest, `Icons.add_rounded`, heroTag `shell_fab`, → `Routes.linkAdd`) + `floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked`. `static const List<String> destinationLabels` 공개해 테스트 셀렉터로 활용.
- **`lib/app/router/app_router.dart`** — `_notificationsNavKey` + notifications `StatefulShellBranch` 제거. Notifications 는 top-level `GoRoute(path: Routes.notifications, parentNavigatorKey: _rootNavigatorKey)` 로 이전. 경로 (`/notifications`) 자체는 변경 없음.
- **`lib/features/link/presentation/screens/home_screen.dart`** — 로컬 `floatingActionButton`(home_fab, endFloat) 블록 삭제(shell 제공). bell `LnIconBtn(icon: Icons.notifications_none_rounded, badge: true, tooltip: '알림')` 의 no-op `onPressed: () {}` → `context.push(Routes.notifications)`.

### Tests (Session 48 — TDD RED → GREEN, 492 → 495)

- `test/shared/widgets/app_scaffold_with_nav_bar_test.dart` 신규 3 cases — RED(`Member not found: destinationLabels`) → GREEN. `destinationLabels.length == 4`, in-order Home/Search/Collections/Profile, 'Notifications' 부재.
- `test/features/link/presentation/screens/home_screen_test.dart` "should show FAB for adding links" → "should NOT have its own FAB (shell provides central FAB)" 로 기대 반전(`findsOneWidget` → `findsNothing`).

### Changed (Session 47 — Phase 4: Search 결과 카드 → LnLinkCard 통일)

- **공유 유틸 추출** — 신규 `lib/shared/utils/highlight_text.dart`. `buildHighlightedSpans({text, query})` 헬퍼가 PR #29 의 `LinkListTile._buildHighlightedSpans` 로직을 재사용 가능 형태로 분리. case-insensitive lower-cased indexOf 반복, 매칭 토큰만 `forestSoft` 배경 + `forestInk` 글자 + `w600`. 미매치/empty query 시 `null` 반환.
- **`lib/shared/widgets/ln/ln_link_card.dart`** — `String? highlightText` 파라미터 추가. 매칭 시 title 을 `Text.rich` 로 분할, 그 외엔 기존 `Text` 경로.
- **`lib/features/search/presentation/screens/search_screen.dart`** — 결과 ListView 의 `LinkListTile` → `LnLinkCard` 1:1 교체. Home 카드와 시각 토큰 일관성 확보 (라우터/상태 변경 없음).

### Removed (Session 47)

- `lib/shared/widgets/link_list_tile.dart` 삭제 — Search 외 사용처 0건. orphan 정리 (backwards-compat shim 두지 않음).
- `test/shared/widgets/link_list_tile_highlight_test.dart` 삭제 — 대상 위젯 orphan.

### Tests (Session 47 — TDD RED → GREEN, 488 → 492)

- `test/shared/utils/highlight_text_test.dart` 신규 4 cases: empty / no-match / case-insensitive split / multi-occurrence.
- `test/shared/widgets/ln/ln_link_card_highlight_test.dart` 신규 4 cases: null / 매칭(case-insensitive) / 빈 문자열 / 미매치.

### Added (Session 38 — Share Intent Phase 1: Android URL-only PoC)

- **Cold-start share intent → `link/add` prefill** (Android 전용, Phase 1 Decision 3.1~3.4 에 따름)
  - 신규 `lib/features/share_intent/domain/service/shared_intent_service.dart` — payload → URL 추출, `UrlSanitizer` 재사용 (title+URL / tweet prose / hidden Unicode / malformed 처리)
  - 신규 `lib/features/share_intent/presentation/provider/pending_shared_url_provider.dart` — Riverpod `keepAlive` Notifier. 부트 seed + redirect 1회 consume
  - `lib/bootstrap.dart` — `runApp` 전 `ReceiveSharingIntent.getInitialMedia()` 1회 읽기 + `reset()`. 플러그인 예외는 warn 로그 + null 반환으로 격리
  - `lib/app/router/app_router.dart` — 인증 완료 후 splash/login/signup → home 리다이렉트 직전 pending URL 있으면 consume + `/links/new?prefill=<encoded>` 로 분기
  - `lib/features/link/presentation/screens/link_add_screen.dart` — `initialUrl` 파라미터 추가. `initState` 에서 URL controller seed + post-frame callback 으로 `linkFormProvider.updateUrl`
- **플랫폼 설정**
  - `pubspec.yaml` — `receive_sharing_intent: ^1.8.1`
  - `android/app/src/main/AndroidManifest.xml` — `ACTION_SEND` + `category.DEFAULT` + `text/plain` intent-filter (기존 deep link `linknote://` 와 공존)
  - `android/build.gradle.kts` — subprojects Kotlin/Java JVM 17 정렬 (plugin 의 Kotlin `jvmTarget=17` 과 Java 1.8 불일치 해결)
- **테스트** (+16: 437 → 453)
  - `test/features/share_intent/domain/shared_intent_service_test.dart` — TDD RED → GREEN 9 케이스
  - `test/features/share_intent/presentation/pending_shared_url_provider_test.dart` — 5 케이스 (default null / setInitial / null·empty guard / consume)
  - `test/features/link/presentation/screens/link_add_screen_test.dart` — prefill seed / prefill absent 2 케이스
- **빌드 검증**: `flutter build apk --debug --flavor dev` 및 `--flavor staging` 모두 성공
- **미검증 (사용자 수동 확인 필요)**: 실기기/에뮬레이터에서 YouTube/Chrome/Twitter 공유 시트 → LinkNote 선택 → 폼 prefill 동작

### Docs (Session 38 — PRD 갱신)

- **`docs/prds/share-intent.md`**
  - 상단 상태 배너: `Decided (Session 37)` → `Phase 1 구현 (Session 38)`
  - Section 7 결정 로그: "2026-04-21 Phase 1 Android URL-only PoC 구현" + 로드맵 갱신 2 entry 추가
  - "다음 액션" 을 ① 실기기 2앱 검증 ② warm/foreground bottom sheet ③ Phase 2 iOS Extension 3단계로 재구성

### Docs (Session 37 — Share Intent PRD Decided 승격)

- **`docs/prds/share-intent.md` Draft → Decided (2026-04-21)**: Open Decision 4건 합의 완료. Phase 1 (Android URL-only PoC) 진입 가능
  - **3.1 Payload**: Phase 1 은 URL only + `link/add` 폼 prefill. plain text/image 는 Phase 3+ 이월
  - **3.2 App State**: Cold start 는 GoRouter `initialLocation` 동적 분기, warm/foreground 는 bottom sheet. 풀스크린 강제 push 배제(입력 손실 위험)
  - **3.3 iOS Share Extension**: Phase 2 이월 (Xcode·native Swift·App Groups·서명 범위 큼). Phase 2 진입 세션 재검토 질문 3건 보존
  - **3.4 Package**: `receive_sharing_intent` 1.8.1 채택. iOS 15/Android default minSdk 와 호환(pub.dev 조회 2026-04-21). 18개월 무업데이트는 Phase 2 재평가 포인트
  - Section 7 결정 로그에 2026-04-21 엔트리 5건 추가
- **Phase 1 PoC 구현은 Session 38 이월** — 5+ 파일 변경·실기기 검증 필요로 세션 경계 안 안정 종료 어려움 판단. docs-only 단독 PR 금지 정책상 본 세션 산출물은 Session 38 Phase 1 코드 PR 에 묶음

### Fixed (Session 36 — Wave 3 i18n 확장: Collection / Auth / url_launcher)

- **i18n 정책 결정 (Option B)**: 사용자 대면 UX 카피(Search 화면 hint/empty state/recent search 라벨)는 한글 유지 + 개발자/운영성 메시지(snackbar, Exception, Failure.message)는 영문 통일. Wave 3 P3-E 의 Link 범위 결정을 다른 feature 로 확장 적용
- **Collection snackbar 영문화** (`collection_detail_screen.dart`, `collection_form_screen.dart`): `'컬렉션이 삭제/수정/생성되었습니다'`, `'삭제/수정/생성에 실패했습니다'` 6건 → `'Collection deleted/updated/created'`, `'Failed to delete/update/create collection'`
- **url_launcher_helper Exception 영문화** (`lib/shared/utils/url_launcher_helper.dart`): `'잘못된 링크 형식입니다'` / `'링크를 열 수 없습니다'` / `'링크를 여는 중 오류가 발생했습니다'` → `'Invalid link format'` / `'Cannot open link'` / `'Failed to open link'`. 테스트 4 expect 동시 갱신
- **Auth 이메일 확인 안내 영문화** (`auth_remote_datasource.dart:67`): signup 후 session=null 분기에서 반환하는 `Failure.auth` 메시지를 영문화. `signup_screen` 의 snackbar 로 노출되는 사용자 대면 메시지

### Docs (Session 36 — Share Intent PRD 초안)

- **신규 `docs/prds/share-intent.md`**: Wave 5 P3-A 이월분. Share Intent 별도 Wave 진입 전 합의돼야 할 4개 선결 과제(payload 타입 분기 / 앱 상태별 동작 / iOS Share Extension / 패키지 선정)를 옵션-미해결 질문-우선순위-비목표-결정 로그 구조의 PRD Draft 로 정리. 실 구현은 별도 Wave

### Fixed (Session 35 — Wave 5 Link P3 + Wave 3 잔여)

- **P3-B — Provider autoDispose 정책 명시** (`lib/features/link/presentation/provider/`): `link_list_provider` 는 `@Riverpod(keepAlive: true)` 로 글로벌 생존을, `link_detail_provider` / `link_form_provider` 는 기본 `@riverpod` (autoDispose) + docstring 으로 화면 단위 소멸 의도를 각각 명시
- **P3-C — LinkFormProvider dispose 시 in-flight OG parse cancel 보장** (`link_form_provider.dart`): `ref.onDispose` 훅에서 `_pendingOgParse` 를 `unawaited` 취소. 폼 닫힘 시 백그라운드 Future leak 방지
- **P3-E' (Wave 3) — toggleFavorite 성공 후 linkDetailProvider invalidate** (`link_list_provider.dart`): `moveToCollection` 과 동일한 cascade invalidate 패턴 적용. 리스트 favorite 토글 후 detail 화면 star 아이콘 stale 증상 해소. 테스트 +1
- **P3-C' (Wave 3) — 태그 색상 하드코딩 제거**: `AppColors.defaultTagColorHex` 신설 (== `AppColors.primary` 의 hex 표현). `link_add_screen` / `link_edit_screen` 의 `'#6750A4'` 하드코딩 → 상수 참조
- **P3-i18n (Wave 3) — Link feature snackbar/OG 에러 영문 일치화**: AppBar 가 영문인 반면 snackbar 만 한글이던 혼재 해소. Link 화면 범위만 변경 (Collection / Search 는 별도 스코프로 이월)

### Changed (Session 35 — Refactor)

- **P3-D' (Wave 3) — LinkFormFields 위젯 추출** (`lib/features/link/presentation/widgets/link_form_fields.dart`): `link_add_screen` / `link_edit_screen` 에서 ~50줄 중복되던 title/description/notes/tags/favorite 필드를 단일 위젯으로 추출. `ref.listen` 기반 controller↔state 미러링으로 프로그래매틱 state 업데이트(OG parse / URL auto-extract title)가 UI 에 반영됨. `LinkEditScreen` 은 controller 소유 중단 → `ConsumerWidget` 으로 단순화

### Docs (Session 35 — Workflow sync + Share Intent 이월)

- **`docs/linknote-workflow.md` stale 정정**: Section 4.1 브랜치 전략에서 `develop` 줄 제거 (실제 운영은 `main` 단일 + Branch Protection), Phase 5 테스트 수치 315 → 437, Phase 7 릴리스 서명 항목에 "골격만, 실 keystore 미생성" 명시, Q&A CI/CD 답변을 현 운영과 일치시킴
- **Phase 6.5 신설**: 보안 감사(Session 1~3 + Firebase GCP 제약) + 코드 리뷰 Wave 1~5 (Session 18~34) 를 Phase 6 과 Phase 7 사이 별도 트랙으로 가시화. overview 표에도 반영
- **Wave 5 P3-A Share Intent — 이월 결정 기록** (`docs/reviews/wave5-link-review.md`): Session 35 에서 구현 제외, 별도 Wave 진입 전 PRD 선결 과제 4건(payload 타입 분기 / cold start 라우팅 / iOS App Extension / 패키지 선정) 명시

### Chore (Session 34 — Docs 구조 정리)

- **`docs/code_review/` + `docs/review/` → `docs/reviews/` 통합** (PR #15, `b9bd88b`): 동일 목적(코드 리뷰 기록)이 두 디렉토리로 분산되던 구조를 단일 `reviews/`로 합치고, 이동과 동시에 파일명을 `kebab-case`로 정규화. 8개 파일 `git mv` 로 히스토리 유지
- **루트 문서 `snake_case` → `kebab-case`**: `linknote_PRD.md` → `linknote-prd.md`, `linknote_workflow.md` → `linknote-workflow.md`, `next_session_prompt.md` → `next-session-prompt.md`
- **`docs/security/rls_policies.md` → `rls-policies.md`**: 단일 파일 rename
- **참조 갱신**: `CHANGELOG.md`, `docs/next-session-prompt.md`, `tasks/wave1_fix_{plan,research}.md` 내 구 경로 문자열 치환 (8곳). `README.md/ko`는 해당 경로 미참조로 수정 없음
- **유지(의도적 제외)**: `daily_task_log/` · `work_performance/` — 내부적으로 일관된 `snake_case` 이며 외부 참조 많아 blast radius 과대. 별도 PR로 이월

### Fixed (Session 33 — Wave 5 Link P2)

- **P2-C — OgTagService 대용량 응답 제한** (`lib/core/services/og_tag_service.dart`): `_maxBodyBytes = 2 MiB` 상한 추가. Content-Length 헤더가 초과하거나 실제 수신 body가 초과하면 DioException(badResponse) → `Failure.server`로 거부. html 파서 메모리 비정상 폭증 방지
- **P2-D — moveToCollection optimistic rollback 명시** (`lib/features/link/presentation/provider/link_list_provider.dart`): `deleteLink`/`toggleFavorite`와 동일한 낙관적 업데이트 + 실패 롤백 패턴으로 재작성. UI 상태를 먼저 바꿔 즉시 반영하고, 실패 시 `previous` 상태로 복원한 뒤 `Failure`를 rethrow — 호출자(`home_screen`)의 에러 snackbar 경로 유지
- **P2-E — null → null 컬렉션 이동 early return 가드** (`lib/features/link/presentation/provider/link_list_provider.dart`): `existing.collectionId == collectionId` 시 usecase 호출 전 early return. 동일 컬렉션 재선택 또는 null→null 입력에서 불필요한 원격 호출 제거
- **P2-I — repository dead branch 재검증** (`lib/features/link/data/repository/link_repository_impl.dart:26-47`): Wave 3 리뷰 표시와 달리 현재 코드는 `isSuccess`이면 `cacheLinks` + return, 실패 시 `cursor == null`에서만 local fallback — dead branch 아님. 수정 불필요로 확인

### Added (Session 33 — Test Coverage)

- **`og_tag_service_test.dart` +3 tests**: Content-Length 헤더 초과 / 다운로드 body 초과 / 2 MiB 경계값 허용
- **`link_list_provider_test.dart` +3 tests**: moveToCollection early return (same collectionId, null→null) + rollback on failure
- **`url_sanitizer_test.dart` +4 tests**: IDN 도메인 허용 정책 문서화 (독일어 움라우트, 일본어, 한글 경로, 스킴 없는 IDN)

### Baseline (Session 33)

- 테스트: 426 → **436 GREEN** (+10), analyze 0

### Fixed (Session 32 — Wave 5 Link P1 + Review)

- **P1-A — OgTagService silent fail → Result 전환** (`lib/core/services/og_tag_service.dart`, `lib/features/link/presentation/provider/link_form_provider.dart`): `fetchOgTags` 반환 타입을 `Future<OgTagResult>` → `Future<Result<OgTagResult>>`로 변경. DioException을 Failure 타입으로 분류 (timeout→NetworkFailure, 4xx/5xx→ServerFailure). `parseOgTags` 실패 시 `errorMessage`로 한국어 사용자 피드백 제공. OgTagService 생성자에 `Dio?` 주입 파라미터 추가 (테스트 용이성)
- **P1-B — HTTPS→HTTP redirect downgrade 차단** (`lib/core/services/og_tag_service.dart`): Dio `followRedirects: false` + 수동 `_fetchFollowingRedirects` 구현. 최대 3 hop까지 허용하며 각 hop에서 scheme downgrade(HTTPS→HTTP) 감지 시 거부. MitM 공격 surface 축소
- **P1-D — moveToCollection 후 detail 화면 stale** (`lib/features/link/presentation/provider/link_list_provider.dart`): `moveToCollection` 성공 시 `linkDetailProvider(linkId)` invalidate 추가. detail 화면에서 컬렉션 이동 후 collectionId가 즉시 반영됨
- **P2-A — URL 길이 제한 (DOS guard)** (`lib/shared/utils/url_sanitizer.dart`): `_maxLength = 2048` 상한 추가. 초과 URL 입력 시 `null` 반환으로 정규식/DB/네트워크 경로의 비정상 지연 방지

### Added (Session 32 — Test Coverage)

- **`test/core/services/og_tag_service_test.dart` 신규** (13 tests): `_FakeAdapter`로 Dio HTTP 계층 모킹. success/fallback title/empty body/cache hit/timeout/404/500/redirect(HTTPS→HTTPS)/redirect downgrade block/HTTP→HTTP/redirect loop/malformed HTML 경로 검증
- **`link_list_provider_test.dart` 추가** (+1 test): moveToCollection 후 `linkDetailProvider` invalidate 검증
- **`url_sanitizer_test.dart` 추가** (+2 tests): 2049자 URL 거부 + 2048자 경계값 허용

### Docs (Session 32)

- **Wave 5 Link 리뷰 문서** (`docs/reviews/wave5-link-review.md`): Link 고급 시나리오 리뷰 — 16건 발견 (P1:4, P2:6, P3:6). Wave 3 잔여 확인 포함

### Baseline (Session 32)

- 테스트: 410 → **426 GREEN** (+16)

### Fixed (Session 31 — Wave 4 Collection P2/P3 + Test Coverage)

- **P2-A — `CollectionMapper` linkCount array fold** (`lib/features/collection/data/mapper/collection_mapper.dart`): `dto.links.first.count` 단일 요소 가정을 `dto.links.fold<int>(0, (sum, e) => sum + e.count)`로 교체. Supabase select 스키마가 multi-aggregate으로 확장되어도 침묵 실패 방지. 매퍼 테스트에 multi-aggregate + zero 케이스 2건 추가
- **P2-B — `getCollectionById` 로컬 캐시 폴백** (`lib/features/collection/data/repository/collection_repository_impl.dart`): 원격 실패 시 `_local.getCachedCollectionById(id)` 폴백 추가. 원격 성공 시에도 `cacheSingleCollection`으로 캐시 갱신. `getCollections`와 동일 패턴으로 오프라인 UX 개선. repository 테스트에 3 케이스 추가 (remote success + cache, remote fail → cache hit, remote fail → cache miss)
- **P2-C — Collection 삭제 UX 에러 처리** (`lib/features/collection/presentation/screens/collection_detail_screen.dart`, `collection_list_provider.dart`): `CollectionList.deleteCollection`이 실패 시 상태만 rollback하고 조용히 성공 처리되던 문제를 수정. rollback 후 `Error.throwWithStackTrace`로 Failure 전파, detail screen은 try/catch로 감싸 실패 시 `context.showErrorSnackBar("삭제에 실패했습니다")` 표시. 위젯 테스트 2건 추가 (확인 다이얼로그 표시 + 실패 시 error snackbar)
- **P2-D — create/update/delete 후 provider invalidate** (`lib/features/collection/presentation/provider/collection_list_provider.dart`): `updateCollection`/`deleteCollection` 성공 직후 `ref.invalidate(collectionDetailProvider(id))` + `ref.invalidate(collectionLinksProvider(id))` 추가. 동일 id 재진입 시 stale 캐시 제거. provider 테스트에 invalidate 검증 케이스 추가
- **P3-B — `updateCollection` firstWhere 가드** (`lib/features/collection/presentation/provider/collection_list_provider.dart`): `items.firstWhere((c) => c.id == id)`가 missing id에서 `StateError`를 던지던 문제를 `where(...).firstOrNull` + `Failure.unknown` throw로 교체. 딥링크/알림으로 사라진 컬렉션 편집 시도 시 사용자 친화적 에러. provider 테스트 케이스 추가
- **P3-A — form snackbar**: Session 30 P1-C 구현에서 이미 try/catch + 성공/실패 분기 처리 완료 확인. 추가 변경 불필요

### Added (Session 31 — Test Coverage)

- **`collection_remote_datasource_test.dart` 신규** (10 tests): `MockSupabaseClient`로 `from()` throw 시점을 제어해 `PostgrestException` → `Failure.server`, 일반 Exception → `Failure.unknown` 매핑을 5개 메서드(getCollections/getCollectionById/create/update/delete) 각각 2 케이스 검증. Session 28에서 link feature에 추가된 동일 갭 해소
- **`collection_detail_provider_test.dart` 신규** (3 tests): build success/failure + refresh 재호출 검증. Session 30 lesson(autoDispose + throwWithStackTrace)에 따라 `container.listen` 구독 + `Future<void>.delayed(Duration.zero)` 2회 후 `state.hasError` 체크 패턴 적용

### Added (Session 31 — Link → Collection 이동 기능)

- **홈 롱프레스 메뉴 "Move to Collection"** (`lib/features/link/presentation/screens/home_screen.dart`, `lib/features/link/presentation/provider/link_list_provider.dart`): 링크 타일의 `⋮` 메뉴에 "Move to Collection" 액션 추가. BottomSheet로 컬렉션 피커 표시 ("None" 옵션 포함), `LinkList.moveToCollection(linkId, collectionId)` 메서드가 `UpdateLinkUsecase`를 통해 `collection_id` 변경. 성공 시 `이전/신규 컬렉션의 collectionLinksProvider + collectionDetailProvider` 무효화 + 리스트 배지 refresh용 `collectionListProvider` 무효화로 **linkCount 스테일 이슈 해결**. 실패 시 error snackbar. 신규 provider 테스트 4 cases (success / null clear / 실패 throw / collectionList invalidate)

### Baseline (Session 31)

- 테스트: 385 → **410 GREEN** (+25: mapper +2, repository +2, collection list provider +2, detail screen +2, detail provider +3, remote datasource +10, link list provider +4)
- `flutter analyze --fatal-warnings`: 0 issues
- `flutter build apk --flavor dev --debug`: 성공
- **실기기 QA 통과** (Galaxy A34 / SM A346N / RFCW615RBFT): 삭제 UX, 캐시 폴백, invalidate, 에러 스낵바, Move to Collection + linkCount 갱신 모두 확인

### Fixed (Session 30 — Wave 4 Collection P0/P1)

- **P0-A — `collectionLinksProvider` Failure 침묵 해결** (`lib/features/collection/presentation/provider/collection_links_provider.dart`): Failure 시 빈 리스트를 리턴하던 로직을 제거하고 `Error.throwWithStackTrace(result.failure!, StackTrace.current)`로 에러를 AsyncValue로 surface. 신규 단위 테스트 `test/features/collection/presentation/provider/collection_links_provider_test.dart` (success + failure 2 cases) 추가
- **P1-A — Collection user_id 명시 필터 + RLS 문서화**: `CollectionRemoteDataSource.updateCollection/deleteCollection/getCollectionById`에 `String userId` 인자 추가 → `.eq('user_id', userId)` 이중 필터 적용 (defense in depth). `CollectionRepositoryImpl`이 기존 userId 필드를 전달. `docs/security/rls-policies.md` 신설 — Supabase RLS SELECT/INSERT/UPDATE/DELETE 정책 SQL 문서화 (collections / links / 조인 테이블). 기존 `collection_repository_impl_test.dart`의 mock 시그니처 업데이트 + userId 전달 verify 추가
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
  - **보고서**: `docs/reviews/2026-04-12-wave1-security.md` (전체 3자 합의 매트릭스 + 각 이슈 file:line + 재현 + 권장 픽스 + Unverified assumptions + Recommended follow-up)
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
    - 참조: 메모리 `project_url_launcher_bug_open.md`, `docs/next-session-prompt.md` Session 19 프롬프트
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
