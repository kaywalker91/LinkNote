# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 51 — 실기기 6 화면 시각 검증 (light↔dark 토글) + 후속 우선순위 결정

## 미션 한 줄

Session 50 머지로 Dark mode forest 팔레트(AppPalette ThemeExtension + Ln 위젯 9개 brightness-aware) 까지 들어갔지만 실기기 시각 검증이 6 세션 연속 스킵된 상태. 우선 Home / LinkDetail / Collection grid / Search / Bottom Nav + 중앙 FAB / Notifications push 흐름을 light↔dark 토글까지 한 번에 확인. 그다음 후속 우선순위(golden_toolkit / Phase 5+ Lock·Globe pill / iOS Share Extension / ARB 정식 i18n) 사용자와 합의 후 단일 트랙 진입.

## 배경

**Session 50 (2026-05-02, 직전 세션) 결과**:
- 신규 `lib/app/theme/app_palette.dart` — `AppPalette extends ThemeExtension<AppPalette>` 22 design 토큰 보유. `factory light()` AppColors byte-identical mirror, `factory dark()` forest-tuned (`bg #141A17`, `ink #E8EDE9`, `forest #3FA37C` 등). `copyWith` + `lerp` 풀 구현.
- `lib/app/theme/app_theme.dart` 재작성 — light/dark 모두 AppPalette 단일 진입점. `extensions: [palette]` 등록. ColorScheme 가 palette 토큰에서 파생.
- `lib/shared/extensions/context_extensions.dart` — `AppPalette get palette` getter, 미등록 시 `AppPalette.light()` fallback (기존 widget 테스트 호환).
- Ln 위젯 9 파일 마이그레이션(`AppColors.X` → `context.palette.X`): ln_link_card / ln_collection_card / ln_top_bar / ln_icon_btn / ln_segmented / ln_brand / ln_tag / ln_thumb / ln_tags.
- `LnTagTone` API breaking change: getter → method `(BuildContext)`.
- `AppColors` 의 사용처 사라진 slate-blue *Dark 8개 제거.
- 신규 회귀 테스트 18개 (`test/app/theme/app_palette_test.dart` 10 + `test/shared/widgets/ln/ln_widgets_dark_test.dart` 8). **518 tests GREEN, analyze 0**, format clean.
- **Visual golden 은 deferred** — `golden_toolkit` 미설치 + CI cross-platform 픽셀 차이 우려. structural 어설션으로 동등한 회귀 보호.
- Stage 1 실기기 검증은 사용자 요청으로 스킵 → Session 51 합쳐서 처리(6 세션 연속).

**Phase 4 현재 상태** (`project_design_overhaul.md`):
- ✅ Search 헤더 + 매칭 하이라이트 (PR #29, Session 46)
- ✅ Search 결과 카드 → LnLinkCard + highlight_text 공유 유틸 (PR #30, Session 47)
- ✅ LnTabBar 5탭→4탭 + 중앙 FAB (PR #31, Session 48)
- ✅ Collection 2열 그리드 + 그라디언트 카드 (PR #32, Session 49)
- ✅ Dark mode forest 팔레트 + AppPalette ThemeExtension (Session 50, PR pending or merged)
- ⏳ visual golden baseline (`golden_toolkit` 도입 후, Phase 4.5)
- ⏳ Lock/Globe visibility pill — `CollectionEntity` 모델 확장 필요 (Phase 5+)

## 작업 범위

### Stage 1 — 실기기 시각 검증 (필수, 6 화면 + light↔dark 토글)

`flutter run --flavor dev -t lib/main_dev.dart -d <device>` 진입 후 light/dark 양쪽 토글하며 검증:

**Bottom Nav + 중앙 FAB**
- 4탭만 노출: Home / Search / Collections / Profile (Notifications 부재)
- 중앙 FAB: forest, `+` 아이콘, NavigationBar 위 절반 오버랩(`centerDocked`)
- FAB 탭 → `Routes.linkAdd` (LinkAddScreen) 진입
- Collections 탭: shell FAB(centerDocked, `shell_fab`) + collection FAB(endFloat, `collections_fab`) 시각/heroTag 충돌 없음

**Home (light + dark)**
- LnTopBar Wordmark + 내 서랍 + 전체/★즐겨찾기 세그먼트 + LnLinkCard
- AppBar bell 탭 → Notifications 화면 푸시
- Dark: bg `#0E1311`, 카드 표면 `#141A17`, 텍스트 `#E8EDE9`, forest `#3FA37C`
- 빈 상태 한글 카피

**LinkDetail (light + dark)**
- amber 메모 인용 바 + amberSoft "📝 메모" pill (dark: amberSoft `#3D2E1A`)
- AppBar LnIconBtn (favorite=amber/ink3, edit=ink, delete=rose)

**Collection (light + dark)**
- **목록 (2열 그리드)**: 카드 4톤 그라디언트 헤더(forest/lilac/slate/amber) — dark 배경 위에서 그라디언트가 어떻게 보이는지 확인. 그라디언트 색상은 light/dark 동일(고정 hex) — 의도된 디자인.
- **상세**: 기존 LnLinkCard 일관성 + 삭제 LnIconBtn rose

**Search (light + dark)**
- 헤더 검색 입력 + LnLinkCard 결과 + 매칭 하이라이트 forestSoft (dark: `#1B3A2D`)

**Notifications (light + dark)**
- AppBar bell 에서 푸시 후 정상 표시 / 뒤로 가기 → 원래 탭 복귀

검증 결과는 daily log + 메모리 기록.

### Stage 2 — 후속 우선순위 결정

Stage 1 검증 후 사용자와 다음 트랙 합의:

| 후보 | 규모 | 의존성 |
|------|------|--------|
| **A) golden_toolkit 도입 + visual baseline** | 중 | Session 50 dark mode 의 후속 |
| **B) Lock/Globe visibility pill** (Phase 5 진입) | 중 | `CollectionEntity` 모델 확장 (visibility/color/emoji 필드) |
| **C) iOS Share Extension** (Phase 2) | 대 | iOS 인증서 / Apple Developer 계정 |
| **D) ARB 정식 i18n** | 대 | Option B 임시 가이드 → ARB 마이그레이션 |
| **E) 잔여 영문 카피 i18n** | 소 | "URL *", OG 추출 snackbar 등 사용자 대면 잔존 |

기본 추천: **A** (Phase 4 후속 자연 흐름) 또는 **E** (소규모 깔끔 마무리). Stage 1 결과에 따라 dark mode 미세 튜닝이 필요하면 그것 우선.

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote

git checkout main && git pull --ff-only

# Stage 1 (실기기 검증) — main 에서 직접
flutter run --flavor dev -t lib/main_dev.dart -d <device>
# light/dark 토글: 시스템 설정 또는 디버그 콘솔에서 brightness 변경

# Stage 2 (후속 작업) — 합의 후 새 브랜치
git checkout -b feat/<chosen-track>

dart format lib/ test/
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 518+ GREEN

# 푸시 + PR (사용자 명시 승인 필수)
git push -u origin feat/<chosen-track>
gh pr create --base main --title "..." --body "..."
```

## 알려진 인접 이슈 (Session 51 무관, 별도 세션)

- **HomeScreen `_showCollectionPicker` snackbar i18n** — Option B 영문 유지 중
- **Phase 2 iOS Share Extension** — Session 38 PoC 후속, 별도 트랙
- **DTO parse 실패 근본 추적** — PR #26 의 `appLogger.w` 가 미래 재발 시 캡처 예정
- **Supabase RLS / FK 점검** — dashboard 액세스 별도 트랙
- **StatefulShellRoute.indexedStack 탭 전환 logScreenView** — `app_router.dart` NOTE 주석 참조, 별도 세션
- **CollectionEntity 모델 확장** (visibility / color / emoji) — Phase 5+ Lock/Globe pill, 사용자 지정 색상 / 이모지
- **`shimmer_box.dart` 의 `Theme.of(c).brightness` 직접 검사** — palette 통합 가능, Session 50 마이그레이션에서 의도적 미포함

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection** — PR + CI 4 job green 필수
- **TDD RED → GREEN** — 데이터/도메인/프로바이더 변경은 테스트 선행
- **i18n Option B** — UI 사용자 대면 카피는 한글, snackbar / Exception / Failure.message 는 영문
- **CI dart format 선행** — 푸시 전 로컬 `dart format`
- **omit_local_variable_types** — 로컬 변수는 `var`
- **`on Exception catch` 만 사용 금지** — 데이터 경계는 `on Object` (Session 28/41/45 학습)
- **Freezed nested toJson 주의** — Hive/JSON 직렬화 경계에서 nested 필드 명시 처리 (Session 42)
- **per-row 파싱 fault tolerance** — remote list fetch 는 `parseRows` 패턴 답습 (Session 44 학습)
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion` 으로 확인. 모델에 없는 속성을 UI에서 임의로 표기하지 않음 (Session 49 확장)
- **`gh pr checks` 모니터링은 `--json` 사용** — awk whitespace split 함정 회피 (Session 45 학습)
- **Docs-only PR 금지** — 문서만 변경한 브랜치는 단독 PR 생성하지 말고 다음 실코드 PR 에 묶기
- **Light 회귀 zero 원칙** — design token 변경 시 `AppPalette.light()` 는 기존 `AppColors` 와 byte-identical 유지 (Session 50 학습)
- **ThemeExtension 패턴** — 디자인 토큰 brightness-aware 분기는 `ThemeExtension<T>` + `context.palette` fallback. ColorScheme 6슬롯 강제 매핑 / AppColors.bgDark 별도 상수는 안티패턴 (Session 50 학습)

## 완료 기준

- [ ] Stage 1 6 화면 + nav 실기기 light↔dark 검증 결과 기록
- [ ] Stage 2 후속 트랙 합의 및 작업 진입
- [ ] flutter analyze 0
- [ ] flutter test all GREEN
- [ ] CI 4 job green + 사용자 머지
- [ ] 메모리 갱신:
  - [ ] `project_code_review_roadmap.md` Session 51 entry
  - [ ] `MEMORY.md` 인덱스 갱신
  - [ ] `project_design_overhaul.md` Phase 4 진척 표기

## 참조 문서/메모리

- **Session 50 daily log**: `docs/daily_task_log/2026-05-02_session50.md`
- **Session 49 commit**: `207dd1a` (PR #32)
- **디자인 오버홀 진행 상태**: `project_design_overhaul.md`
- **공유 토큰**:
  - `lib/app/theme/app_palette.dart` (NEW Session 50) — 22 design 토큰, light/dark factory
  - `lib/app/theme/app_colors.dart` — light 상수 backward compat 유지
  - `lib/app/theme/app_radius.dart`, `app_spacing.dart`, `app_text_styles.dart`
- **Ln 위젯 라이브러리** (Session 50 부터 brightness-aware): `lib/shared/widgets/ln/`
  - 모두 `context.palette` 기반
- **공유 유틸**: `lib/shared/utils/highlight_text.dart`
- **Shell scaffold**: `lib/shared/widgets/app_scaffold_with_nav_bar.dart` (`destinationLabels` 셀렉터 + centerDocked FAB)
- **i18n 정책**: `feedback_i18n_policy.md`
- **ThemeExtension 패턴 lesson**: `feedback_theme_extension_pattern.md`
- **디자인 핸드오프**: `/Users/kaywalker/Downloads/design_handoff_linknote/` (현재 비어 있음)

## 세션 경계

Stage 1 (6 화면 + nav 실기기 light↔dark 검증) + Stage 2 (후속 트랙 합의 후 진입) 단일 흐름. golden_toolkit / iOS Share Extension / ARB intl / Phase 5 같은 큰 Wave 는 합의된 1개만 이번 세션 진입.

## 시작 시 사용자 확인 항목

1. 실기기 검증 가능 시점 (Stage 1) — 6 세션 연속 스킵 상태이므로 우선 처리 권장
2. Stage 2 후속 트랙 — A(golden_toolkit) / B(Phase 5 Lock·Globe) / C(iOS Share Ext) / D(ARB intl) / E(잔여 영문 카피) 중 우선순위
3. Dark mode 토큰 미세 튜닝 필요 발견 시 — Stage 2 후속 작업과 별도 단일 PR vs 묶음
```
