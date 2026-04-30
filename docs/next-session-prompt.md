# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 48 — 4 화면 실기기 톤 일관성 검증 + Phase 4 후보 1개

## 미션 한 줄

Session 45·46·47 머지로 Collection / Search 화면이 forest 토큰으로 정렬되고, Search 결과 카드도 LnLinkCard 로 통일되었지만 실기기 시각 검증이 세 세션 연속 스킵된 상태. 우선 Home / LinkDetail / Collection / Search 4 화면을 실기기에서 한 번에 톤 일관성 확인 후, Phase 4 잔여 후보(LnTabBar 중앙 FAB / Dark mode forest 튜닝) 중 1개를 사용자와 합의해 단일 PR 로 진행한다.

## 배경

**Session 47 (2026-04-30, 직전 세션) 결과**:
- PR #30 `25a63d5` 머지 — Phase 4 진척. Search 결과 카드 `LinkListTile` → `LnLinkCard` 1:1 교체. `lib/shared/utils/highlight_text.dart` 공유 유틸 추출(PR #29 로직 재사용 가능 분리). `LnLinkCard` 에 `highlightText` 파라미터 도입(title 만 강조). `LinkListTile` 및 highlight test orphan 제거.
- 492 tests GREEN(+4 net), analyze 0, CI 통과
- Stage 1 실기기 검증은 사용자 요청으로 스킵 → Session 48 합쳐서 처리

**Session 46 (2026-04-30) 결과**:
- PR #29 `761dfcc` 머지 — Phase 4 진입. Search 헤더 forest 토큰 정렬 + LinkListTile `highlightText` 도입(이후 Session 47 에서 LnLinkCard 로 이전).

**Phase 4 현재 상태** (`project_design_overhaul.md`):
- ✅ Search 헤더 + 매칭 하이라이트 (PR #29, Session 46)
- ✅ Search 결과 카드 → LnLinkCard + highlight_text 공유 유틸 (PR #30, Session 47)
- ⏳ LnTabBar 중앙 FAB (라우터 branch 재구성 수반 — 회귀 위험 있음)
- ⏳ Dark mode forest 팔레트 튜닝 (golden test baseline 정책 확인 필요)
- ⏳ Collection 디자인 (2열 그리드/그라디언트/Lock·Globe pill — 별도 Wave)

## 작업 범위

### Stage 1 — 실기기 시각 검증 (필수, 4 화면 일괄)

`flutter run --flavor dev -t lib/main_dev.dart -d <device>` 진입 후:

**Home**
- LnTopBar Wordmark + 내 서랍 + 전체/★즐겨찾기 세그먼트
- LnLinkCard + forest FAB 동작
- 빈 상태 한글 카피 ('저장된 링크가 없어요' / '+ 버튼을 눌러 첫 링크를 저장해 보세요')

**LinkDetail**
- amber 메모 인용 바 + amberSoft "📝 메모" pill
- AppBar LnIconBtn (favorite=amber/ink3, edit=ink, delete=rose)
- "N일 전 저장 · YYYY.MM.DD" 한글+절대 날짜 병행

**Collection**
- 목록: LnTopBar(large) + 폴더 아이콘 박스 forestSoft + "링크 N개" 카피
- 상세: LnLinkCard 일관성 + 삭제 LnIconBtn rose

**Search (Session 47 신규 검증)**
- 헤더 검색 입력 (`bgSunk` pill + `Icons.search` ink3 + forest cursor + `LnIconBtn(close_rounded)`)
- 결과 카드가 Home/Collection 과 동일한 `LnLinkCard` 시각 (host pill + title + tag + folder caption + favorite star)
- 텍스트 입력 시 결과 title 의 매칭 토큰이 **forestSoft 배경 + forestInk 글자 + 굵기 w600** 으로 강조되는지
- 빈 검색 / 매칭 0건 / 한글 매칭(case-insensitive 영문) / URL host 매칭(LnLinkCard host 라인은 강조 안 됨 — 의도)
- 최근 검색 칩 / 전체 삭제 / 필터 단독 트리거 (Session 44 fix 회귀 없음)

검증 결과는 daily log + 메모리에 기록. 4 화면 톤 일관성 OK 받으면 Stage 2 진행.

### Stage 2 — Phase 4 후보 1개 선정 + 구현

세션 시작 시 사용자에게 `AskUserQuestion` 으로 후보 선택. **회귀 위험 순서**:
1. **Dark mode forest 튜닝** — `app_colors.dart *Dark` 팔레트 + `app_theme.dart ThemeData.dark()`. golden test baseline 정책 사전 합의 필요
2. **LnTabBar 중앙 FAB** — Notifications 탭 → AppBar bell, 5탭 → 4탭 + 중앙 FAB. `lib/shared/widgets/app_scaffold_with_nav_bar.dart` + `lib/app/router/app_router.dart` `StatefulShellRoute.indexedStack`. **라우터 변경 회귀 위험 큼 — RED 테스트 우선**

**후보별 핵심 파일**:
- Dark mode: `lib/app/theme/app_colors.dart` *Dark 팔레트 + `lib/app/theme/app_theme.dart` ThemeData.dark()
- LnTabBar: `lib/shared/widgets/app_scaffold_with_nav_bar.dart` + `lib/app/router/app_router.dart`

### TDD / 회귀

- **라우터 변경 (LnTabBar)**: `test/app/app_router_test.dart` 같은 위치에 RED 테스트 우선
- **Dark mode**: golden test baseline 갱신 정책 사용자와 합의 (도입 / 보류 / baseline 신규)

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote

git checkout main && git pull --ff-only

# Stage 1 (실기기 검증) — main 에서 직접
flutter run --flavor dev -t lib/main_dev.dart -d <device>

# Stage 2 (구현) — 새 브랜치
git checkout -b feat/<phase4-topic>      # 사용자 합의 후 결정

dart format lib/ test/
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 492+ GREEN

# 푸시 + PR (사용자 명시 승인 필수)
git push -u origin feat/<phase4-topic>
gh pr create --base main --title "..." --body "..."
```

## 알려진 인접 이슈 (Session 48 무관, 별도 세션)

- **HomeScreen `_showCollectionPicker` snackbar i18n** — Option B 대로 영문 유지 중. 정식 ARB intl 도입 시 일괄 외부화
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
- **Docs-only PR 금지** — 문서만 변경한 브랜치는 단독 PR 생성하지 말고 다음 실코드 PR 에 묶기 (Session 46/47 PR #29/#30 동반 묶음 사례)

## 완료 기준

- [ ] Stage 1 4 화면 실기기 시각 검증 결과 기록 (Home / LinkDetail / Collection / Search)
- [ ] Stage 2 Phase 4 후보 1개 선정 + 단일 PR
- [ ] 위젯/통합 테스트 셀렉터 정합성
- [ ] flutter analyze 0
- [ ] flutter test all GREEN
- [ ] CI 4 job green + 사용자 머지
- [ ] 메모리 갱신:
  - [ ] `project_code_review_roadmap.md` Session 48 entry
  - [ ] `MEMORY.md` 인덱스 갱신
  - [ ] `project_design_overhaul.md` Phase 4 진척 표기

## 참조 문서/메모리

- **Session 47 commit**: `25a63d5` (PR #30)
- **Session 47 daily log**: `docs/daily_task_log/2026-04-30_session47.md`
- **Session 46 commit**: `761dfcc` (PR #29)
- **디자인 오버홀 진행 상태**: `project_design_overhaul.md`
- **공유 토큰**:
  - `lib/app/theme/app_colors.dart` — forest / forestSoft / forestInk / amber / ink / ink2 / ink3 / line / bgSunk / bgAlt
  - `lib/app/theme/app_radius.dart` — sm / md / lg / xl / full
  - `lib/app/theme/app_spacing.dart` — xs / sm / md / lg / xl / xxl / screenPadding
  - `lib/app/theme/app_text_styles.dart` — heading1~3 / titleL / titleM / bodyMedium / bodySmall / label
- **Ln 위젯 라이브러리**: `lib/shared/widgets/ln/`
- **공유 유틸**: `lib/shared/utils/highlight_text.dart` (Session 47 추출)
- **i18n 정책**: `feedback_i18n_policy.md`

## 세션 경계

Stage 1 (4 화면 실기기 검증) + Stage 2 (Phase 4 후보 1개) 단일 흐름. Phase 2 iOS Share Extension / 정식 ARB intl 화 / Collection 2열 그리드 같은 큰 Wave 는 별도 세션.

## 시작 시 사용자 확인 항목

1. 실기기 검증 가능 시점 (Stage 1) — 세 세션 연속 스킵 상태이므로 우선 처리 권장
2. Phase 4 후보 중 진행할 1개 (Dark mode / LnTabBar)
3. golden test baseline 정책 (Dark mode 선택 시 특히 관련)
```
