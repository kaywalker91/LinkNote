# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 44 — Search 필터 단독 검색 트리거 fix + HomeScreen 한글화

## 미션 한 줄

Session 43 실기기 검증 중 노출된 Search 필터 단독 적용 시
검색 트리거 안 되는 버그를 fix 하고, Phase 3 디자인 오버홀에서
누락된 HomeScreen 빈 상태 영문 카피를 한글로 통일한다. 두 작업의
변경 도메인이 분리되어 있어 별도 PR 권장 (Stage 1 → Stage 2 순차).

## 배경

**Session 43 (2026-04-25, 직전 세션) 결과**:
- PR #24 `164b60f` 머지: MaterialLocalizations 등록 → DateRangePicker
  회귀 fix. `LinkNoteApp` 에 static const 노출 (`localizationsDelegates`,
  `supportedLocales`, `defaultLocale`)
- 471 tests GREEN (+3), analyze 0 issues, CI 4 job ALL GREEN
- 실기기 (SM A346N): DateRangePicker 빨간 화면 없이 정상 표시 ✅

**Session 43 실기기 검증 중 별도 발견**:
- 날짜 필터 칩 → DateRangePicker 정상 표시되어 날짜 범위 선택 후
  검색 결과가 **갱신되지 않음**
- 위치: `lib/features/search/presentation/provider/search_provider.dart:120`
  ```dart
  void _reSearchIfNeeded() {
    if (state.query.isNotEmpty) {  // ← 검색어 비면 통과
      state = state.copyWith(isSearching: true);
      _debouncer(() => _performSearch(state.query));
    }
  }
  ```
- 영향: `setDateRange` / `toggleTagFilter` / `toggleFavoritesFilter` /
  `clearFilters` 모든 필터 변경 메서드. 검색어 없는 상태에서 필터
  단독 적용 시 결과 갱신 안 됨

**Phase 3 디자인 오버홀 누락분 (Session 40 PR #21 후)**:
- HomeScreen 빈 상태 카피가 영문 잔존: `'No links yet'`, `'Add Link'`
  등. Option B 정책상 사용자 대면 카피는 한글이 기본 — 앱 내 일관성
  깨짐

## 작업 범위

### Stage 1 — Search 필터 단독 검색 fix (P1, 별도 PR)

**조사 (먼저)**:
- `SearchLinksUseCase.call(query, filter:)` 가 빈 query + 필터를
  어떻게 처리하는지 확인. Repository / DataSource 까지 빈 query +
  필터만 전달했을 때 의미 있는 결과 (필터 매치) 가 나오는지 검증.
  - 만약 backend (Supabase) 가 빈 query + 필터로 의미 있는 검색을
    못 한다면 → UseCase 또는 Repository 단에서 분기 (예: query 비면
    `getLinks(filter:)` 류 호출)
  - 만약 빈 query + 필터로 정상 동작한다면 → `_reSearchIfNeeded`
    가드만 완화하면 됨

**수정 방향 (조사 결과 기반)**:

옵션 A (가드 완화만으로 충분한 경우):
```dart
void _reSearchIfNeeded() {
  final shouldSearch =
      state.query.isNotEmpty || state.filter.hasActiveFilters;
  if (shouldSearch) {
    state = state.copyWith(isSearching: true);
    _debouncer(() => _performSearch(state.query));
  } else {
    // 쿼리 비고 필터도 없으면 결과 비움
    state = state.copyWith(results: [], isSearching: false);
  }
}
```

옵션 B (UseCase 분기 필요한 경우):
- `SearchLinksUseCase` 또는 별도 `FilterLinksUseCase` 추가
- Repository 에 `searchByFilter(filter:)` 메서드 신규
- 기존 `_performSearch` 가 query/filter 분기

**TDD 사이클 (필수)**:
- RED: `test/features/search/presentation/provider/`
  - `setDateRange triggers search when query is empty but filter active`
  - `toggleFavoritesFilter triggers search when query is empty`
  - `clearFilters with empty query clears results`
- GREEN: 가드 완화 또는 UseCase 분기 적용
- 회귀: 기존 `search_provider_toggle_favorite_test.dart`,
  `search_screen_test.dart` 통과 확인

**주의**:
- search_filter_bar 의 4개 필터 (즐겨찾기/날짜/태그/초기화) 모두
  동일 메커니즘이므로 한 번 수정하면 전부 fix
- `state.filter.hasActiveFilters` getter 가 SearchFilterEntity 에 이미
  있는지 확인 (`search_filter_entity.dart`). 없으면 추가

### Stage 2 — HomeScreen 빈 상태 한글화 (P2, 별도 PR 또는 Stage 1 PR 머지 후)

**대상 파일**: `lib/features/link/presentation/screens/home_screen.dart`
- `'No links yet'` → `'아직 링크가 없어요'` (Phase 3 collection 빈 상태와
  동일 톤)
- `'Add Link'` 또는 `'Add your first link'` 류 → `'첫 링크 추가하기'`
  같은 행동 유도형
- 필요 시 부제(설명) 추가: `'관심 있는 웹페이지를 저장해보세요'` 등
- 다른 잔존 영문 카피도 같이 정리 (단, snackbar / Exception 메시지는
  Option B 에 따라 영문 유지)

**Out of Scope**: AppBar / 메뉴 / 카드 라벨 등은 이미 한글이거나 별도
세션 (Search 화면, LnTabBar) 작업 범위.

**테스트 동기화**:
- `test/features/link/presentation/screens/home_screen_test.dart` 의
  `find.text('No links yet')` 등 셀렉터를 한글로 갱신
- 다른 통합 테스트(`integration_test/login_to_add_link_flow_test` 등)에서
  영문 셀렉터 쓰는 부분 동기화

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote

git checkout main && git pull --ff-only

# Stage 1
git checkout -b fix/search-filter-only-trigger
# - search_provider.dart _reSearchIfNeeded 수정
# - SearchLinksUseCase / Repository 빈 query 처리 검증 (필요 시 분기)
# - search_provider 테스트 RED → GREEN

dart format lib/ test/
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 471+ GREEN

# 실기기 검증
flutter run --flavor dev -t lib/main_dev.dart -d RFCW615RBFT
# → Search 화면, 검색어 비운 상태에서:
#   - 즐겨찾기 칩 탭 → 즐겨찾기 링크만 노출
#   - 날짜 칩 탭 → 범위 선택 → 해당 기간 링크 노출
#   - 태그 칩 탭 → 해당 태그 링크 노출
#   - 초기화 칩 → 결과 비움

# 푸시 + PR (사용자 명시 승인 필수)
git push -u origin fix/search-filter-only-trigger
gh pr create --base main --title "..." --body "..."

# Stage 2 — Stage 1 머지 후
git checkout main && git pull --ff-only
git checkout -b feat/home-screen-i18n
# - home_screen.dart 카피 한글화
# - home_screen_test 셀렉터 동기화
# - integration_test 영문 셀렉터 동기화
# (검증 절차 동일)
```

## 알려진 인접 이슈 (Session 44 무관)

- **Collection 화면 디자인 토큰 정합성** — `LnIconBtn` / `AppRadius` /
  forest 토큰화 별도 PR. 회귀 위험 격리 위해 별도 세션 권장
- **Search 화면 사용자 대면 카피** — Option B 정책상 한글 유지 중.
  정식 ARB 기반 intl 도입 시 일괄 외부화
- **Phase 4+ 디자인 오버홀** — Search 헤더, LnTabBar 라벨, Dark mode
  토글 등 묶음 처리
- **Phase 2 iOS Share Extension** — Session 38 PoC 후속, 별도 트랙
- **Supabase RLS / FK 점검** — Session 41 fix 가 null tags 응답 방어
  처리. dashboard 액세스 별도 트랙

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection** — PR + CI 4 job green 필수
- **TDD RED → GREEN** — 데이터/도메인/프로바이더 변경은 테스트 선행
  (이번 세션은 search_provider 변경이므로 RED 필수)
- **i18n Option B** — UI 사용자 대면 카피는 한글, snackbar / Exception
  / Failure.message 는 영문
- **CI dart format 선행** — 푸시 전 로컬 `dart format`
- **omit_local_variable_types** — 로컬 변수는 `var`
- **on Exception 만 catch 금지** — 데이터 경계는 `on Object` (Session 41
  학습)
- **Freezed nested toJson 주의** — Hive/JSON 직렬화 경계에서 nested
  필드 명시 처리 (Session 42 학습)
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion`
  으로 확인

## 완료 기준

- [ ] Stage 1: search_provider `_reSearchIfNeeded` 가드 완화 (또는
      UseCase 분기) + RED → GREEN 테스트
- [ ] Stage 1: 실기기 — 검색어 없이 4개 필터 단독 동작 확인
- [ ] Stage 1: PR 생성 + CI 4 job green + 사용자 머지
- [ ] Stage 2: HomeScreen 한글화 + 테스트 동기화
- [ ] Stage 2: PR 생성 + CI 4 job green + 사용자 머지
- [ ] flutter analyze 0
- [ ] flutter test all GREEN
- [ ] 메모리 갱신:
  - [ ] `project_code_review_roadmap.md` Session 44 entry
  - [ ] `MEMORY.md` 인덱스 갱신 (Search 필터 버그 후속 항목 제거)

## 참조 문서/메모리

- **Session 43 commit/PR**: `164b60f` (PR #24)
- **Session 43 daily log**: `docs/daily_task_log/2026-04-25_session43.md`
  (Out of Scope 섹션에 Search 필터 버그 상세)
- **i18n 정책**: `feedback_i18n_policy.md`
- **디자인 오버홀 진행 상태**: `project_design_overhaul.md`
- **Search provider 위치**:
  `lib/features/search/presentation/provider/search_provider.dart:120`
- **Search filter entity**: `lib/features/search/domain/entity/`
  `search_filter_entity.dart` (`hasActiveFilters` getter 확인용)

## 세션 경계

Stage 1 (Search 필터 fix) 단일 PR + Stage 2 (HomeScreen i18n) 단일
PR 까지. Collection 디자인 토큰 정합성 / Search 헤더 카피 / LnTabBar /
Dark mode / Phase 2 iOS Share Extension / 정식 ARB 기반 intl 화는
별도 세션.

## 시작 시 사용자 확인 항목

1. Stage 1 (Search 필터 fix) → Stage 2 (HomeScreen i18n) 순차 진행 OK
2. Stage 1 의 옵션 A (가드 완화만) vs 옵션 B (UseCase 분기) 결정은
   조사 결과 후 별도 보고
```
