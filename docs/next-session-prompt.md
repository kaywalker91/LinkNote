# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 46 — 실기기 시각 검증 + Phase 4 디자인 오버홀 진입

## 미션 한 줄

Session 45 PR #28 로 Collection 목록/상세가 forest/amber 토큰으로 정렬되었으나 실기기 시각 검증이 별도 트랙으로 미뤄졌다. 우선 Home / LinkDetail / Collection 톤 일관성을 실기기에서 확인 후, Phase 4 디자인 오버홀의 다음 후보 (Search 헤더 / LnTabBar / Dark mode 중 1개) 를 사용자와 합의해 단일 PR 로 진행한다.

## 배경

**Session 45 (2026-04-28, 직전 세션) 결과**:
- PR #28 `d49b292` 머지 — Collection list/detail 디자인 토큰 정렬 (LnTopBar, LnIconBtn, LnLinkCard, AppColors.forest/ink, AppRadius.lg, AppTextStyles, "링크 N개" 한글)
- 484 tests GREEN, analyze 0 issues, CI 4 job ALL GREEN
- `on Exception` → `on Object` 일관성 정렬 (Session 28/41 학습 답습)
- 실기기 시각 검증은 사용자 사정으로 본 세션 스킵

**Phase 3 디자인 오버홀 종결** — Home(PR #19) + LinkDetail(PR #20) + LinkEdit/Add/Collection i18n(PR #21) + DateRangePicker localizations(PR #24) + HomeScreen 빈상태 + LinkDetail saved date(PR #27) + Collection 토큰(PR #28)

**Phase 4+ 후보 (`project_design_overhaul.md` OOS 표)**:
- Search debounce 300ms · blink caret · forest-soft 매칭 하이라이트
- LinkAdd share-sheet bottom-sheet variant (현 full-screen 폼 유지)
- LnTabBar 중앙 FAB 교체 (라우터 branch 재구성 수반)
- Dark mode forest 팔레트 튜닝
- Collection 디자인 (2열 그리드/그라디언트/Lock·Globe pill — 별도 Wave)

## 작업 범위

### Stage 1 — 실기기 시각 검증 (필수)

`flutter run --flavor dev -t lib/main_dev.dart -d <device>` 로 실기기 진입 후:
- Home → Collection 탭 진입 시 톤 일관성 (forest 액센트, ink 컬러, AppRadius.lg, AppSpacing 갭) 확인
- Collection 목록 → 상세 진입 시 LnTopBar 뒤로 화살표/편집/삭제(rose) 동작
- Collection 상세 → LnLinkCard 탭 시 외부 브라우저 launch + 길게 눌러 LinkDetail 진입 동작
- 빈 상태 한글 카피 ('아직 컬렉션이 없어요' / '이 컬렉션에 링크가 없어요') 노출
- Home / LinkDetail 와 시각 어긋남 없는지 사용자 OK

검증 결과 메모리/daily log 에 기록.

### Stage 2 — Phase 4 후보 1개 선정 + 구현

세션 시작 시 사용자에게 AskUserQuestion 으로 Phase 4 후보 중 1개 선택 받아 단일 PR 로 진행.

**후보별 작업 시 참고**:
- **Search 헤더**: `lib/features/search/presentation/screens/search_screen.dart`, `widgets/search_filter_bar.dart`. forest-soft 매칭 하이라이트는 `RichText` + `TextSpan` 으로 분할. debounce 300ms 는 이미 있을 가능성 높음 — 확인 후 적용.
- **LnTabBar 중앙 FAB**: `lib/shared/widgets/app_scaffold_with_nav_bar.dart` 와 `lib/app/router/app_router.dart` 의 `StatefulShellRoute.indexedStack`. Notifications 탭을 AppBar bell 로 이동시키거나 5탭 → 4탭 + 중앙 FAB. **라우터 변경은 회귀 위험** — RED 테스트 우선.
- **Dark mode**: `lib/app/theme/app_colors.dart` 의 `*Dark` 팔레트 + `app_theme.dart` 의 `ThemeData.dark()` 정의. forest primary 만 적용된 상태에서 surface/ink 계열까지 forest-tone 으로 정렬.

### TDD / 회귀

- 라우터 변경 (LnTabBar) 는 위젯 테스트 우선 (`test/app/app_router_test.dart` 같은 위치).
- Search 하이라이트는 `RichText` 자식 검증.
- Dark mode 는 visual 검증 위주 — golden 테스트 baseline 갱신 정책 사용자와 합의.

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote

git checkout main && git pull --ff-only

git checkout -b feat/<phase4-topic>      # 사용자 합의 후 결정

# Stage 1 (실기기 검증) — main 에서 직접
flutter run --flavor dev -t lib/main_dev.dart -d <device>

# Stage 2 (구현) — 새 브랜치
dart format lib/ test/
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 484+ GREEN

# 푸시 + PR (사용자 명시 승인 필수)
git push -u origin feat/<phase4-topic>
gh pr create --base main --title "..." --body "..."
```

## 알려진 인접 이슈 (Session 46 무관, 별도 세션)

- **HomeScreen `_showCollectionPicker` snackbar i18n** — Option B 대로 영문 유지 중. ARB 기반 정식 intl 도입 시 일괄 외부화
- **Phase 2 iOS Share Extension** — Session 38 PoC 후속, 별도 트랙
- **DTO parse 실패 근본 추적** — PR #26 의 `appLogger.w` 가 미래 재발 시 캡처 예정
- **Supabase RLS / FK 점검** — dashboard 액세스 별도 트랙
- **Collection 디자인 (2열 그리드/그라디언트/Lock·Globe pill)** — 별도 Wave (Phase 4+ 후보지만 작업량 큼)

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
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion` 으로 확인
- **`gh pr checks` 모니터링은 `--json` 사용** — awk whitespace split 함정 회피 (Session 45 학습)

## 완료 기준

- [ ] Stage 1 실기기 시각 검증 결과 기록
- [ ] Stage 2 Phase 4 후보 1개 선정 + 단일 PR
- [ ] 위젯/통합 테스트 셀렉터 정합성
- [ ] flutter analyze 0
- [ ] flutter test all GREEN
- [ ] CI 4 job green + 사용자 머지
- [ ] 메모리 갱신:
  - [ ] `project_code_review_roadmap.md` Session 46 entry
  - [ ] `MEMORY.md` 인덱스 갱신
  - [ ] `project_design_overhaul.md` Phase 4 진입 표기

## 참조 문서/메모리

- **Session 45 commit**: `d49b292` (PR #28)
- **Session 45 daily log**: `docs/daily_task_log/2026-04-28_session45.md`
- **디자인 오버홀 진행 상태**: `project_design_overhaul.md`
- **공유 토큰**:
  - `lib/app/theme/app_colors.dart` — forest / amber / ink / ink2 / ink3 / line / bgAlt
  - `lib/app/theme/app_radius.dart` — sm / md / lg / xl / full
  - `lib/app/theme/app_spacing.dart` — xs / sm / md / lg / xl / xxl / screenPadding
  - `lib/app/theme/app_text_styles.dart` — heading1~3 / titleL / titleM / bodyMedium / bodySmall / label
- **Ln 위젯 라이브러리**: `lib/shared/widgets/ln/`
- **i18n 정책**: `feedback_i18n_policy.md`

## 세션 경계

Stage 1 (실기기 검증) + Stage 2 (Phase 4 후보 1개) 단일 흐름. Phase 2 iOS Share Extension / 정식 ARB intl 화 / Collection 2열 그리드 같은 큰 Wave 는 별도 세션.

## 시작 시 사용자 확인 항목

1. 실기기 검증 가능 시점 (Stage 1)
2. Phase 4 후보 중 진행할 1개 (Search 헤더 / LnTabBar / Dark mode 등)
3. golden test baseline 정책 (Dark mode 선택 시 특히 관련)
```
