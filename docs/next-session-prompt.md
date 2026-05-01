# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 50 — 5 화면 실기기 톤 일관성 검증 + Phase 4 Dark mode forest 튜닝

## 미션 한 줄

Session 45·46·47·48·49 머지로 Collection list/detail/grid + Search + LnTabBar 4탭/중앙 FAB 까지 forest 토큰으로 정렬됐지만 실기기 시각 검증이 5 세션 연속 스킵된 상태. 우선 Home / LinkDetail / Collection 2열 그리드 / Search / 신규 4탭 nav + 중앙 FAB / AppBar bell → Notifications push 흐름까지 한 번에 톤·동선 일관성 확인. 그다음 Phase 4 잔여 후보 Dark mode forest 팔레트 튜닝(신규 baseline 도입 정책 합의 완료) 단일 PR.

## 배경

**Session 49 (2026-05-01, 직전 세션) 결과**:
- PR #32 `207dd1a` 머지 — Phase 4 Collection 2열 그리드. 신규 `LnCollectionCard`(forest/lilac/slate/amber 4톤 그라디언트 헤더 + folder 아이콘 + name + "링크 N개"), `id` 해시 결정적 톤 분배. CollectionListScreen → `CustomScrollView + SliverGrid`(crossAxisCount=2, gap=12, aspectRatio=0.95). 스켈레톤 그리드 셀 형태 재구성.
- 500 tests GREEN(+5 net), analyze 0, CI 통과, 사용자 수동 머지
- Stage 1 실기기 검증은 사용자 요청으로 스킵 → Session 50 합쳐서 처리
- **디자인 spec 차이 (의도적)**: Lock/Globe pill, emoji, description 카드 노출 모두 미적용. `CollectionEntity` 모델에 필드 없음 — "수치 기준 창작 금지" 정책 확장.

**Phase 4 현재 상태** (`project_design_overhaul.md`):
- ✅ Search 헤더 + 매칭 하이라이트 (PR #29, Session 46)
- ✅ Search 결과 카드 → LnLinkCard + highlight_text 공유 유틸 (PR #30, Session 47)
- ✅ LnTabBar 5탭→4탭 + 중앙 FAB (PR #31, Session 48)
- ✅ Collection 2열 그리드 + 그라디언트 카드 (PR #32, Session 49)
- ⏳ Dark mode forest 팔레트 튜닝 (신규 baseline 도입 정책 합의 완료)
- ⏳ Lock/Globe visibility pill — `CollectionEntity` 모델 확장 필요 (Phase 5+)

## 작업 범위

### Stage 1 — 실기기 시각 검증 (필수, 5 화면 + 신규 nav + 그리드)

`flutter run --flavor dev -t lib/main_dev.dart -d <device>` 진입 후:

**Bottom Nav (Session 48 검증, 이번이 첫 실기기)**
- 4탭만 노출: Home / Search / Collections / Profile (Notifications 부재)
- 중앙 FAB: forest, `+` 아이콘, NavigationBar 위 절반 오버랩(`centerDocked`)
- FAB 탭 → `Routes.linkAdd` (LinkAddScreen) 진입
- Collections 탭: shell FAB(centerDocked, `shell_fab`) + collection FAB(endFloat, `collections_fab`) 시각/heroTag 충돌 없음

**Home**
- LnTopBar Wordmark + 내 서랍 + 전체/★즐겨찾기 세그먼트 + LnLinkCard
- AppBar bell 탭 → Notifications 화면 푸시
- 빈 상태 한글 카피

**LinkDetail**
- amber 메모 인용 바 + amberSoft "📝 메모" pill
- AppBar LnIconBtn (favorite=amber/ink3, edit=ink, delete=rose)

**Collection (Session 49 신규 검증)**
- **목록 (2열 그리드)**: 카드 4톤 그라디언트 헤더(forest/lilac/slate/amber, `id` 해시 결정적) + 좌하단 folder 아이콘(white) + 이름(titleM, 2 lines) + "링크 N개"(caption ink3). 그라디언트 톤 분포가 시각적으로 변화 있는지(같은 톤만 4개 깔리지 않는지) 확인
- **카드 비율**: aspectRatio=0.95, gap=12, 좌우 패딩 14
- **상세**: 기존 LnLinkCard 일관성 + 삭제 LnIconBtn rose

**Search**
- 헤더 검색 입력 + LnLinkCard 결과 + 매칭 하이라이트 forestSoft

**Notifications**
- AppBar bell 에서 푸시 후 정상 표시 / 뒤로 가기 → 원래 탭 복귀

검증 결과는 daily log + 메모리 기록.

### Stage 2 — Phase 4 Dark mode forest 팔레트 튜닝

**핵심 파일**:
- `lib/app/theme/app_colors.dart` — *Dark 팔레트 추가/조정 (forest/forestSoft/forestInk/amber/ink/ink3/line/bg/bgAlt/bgSunk 의 dark 변형)
- `lib/app/theme/app_theme.dart` — `ThemeData.dark()` 정렬

**Spec 가이드**:
- 디자인 핸드오프 PRD 다크 토큰 참조 (있으면)
- forest primary 유지, surface/ink 톤만 다크 전환
- amber/rose/lilac/slate accent 는 light 와 동일하게 유지(과채도 회피)

**Golden test baseline 정책 합의 완료**: 신규 baseline 도입 — Dark mode 화면 golden 새로 생성, 향후 회귀 방지

**TDD / 회귀**:
- 위젯 테스트 셀렉터 정합성 사전 점검 (LnLinkCard / LnTopBar / LnIconBtn / LnCollectionCard 다크 톤 fallback)
- golden 1차 baseline 도입은 별도 commit 권장 (시각 검토 분리)

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote

git checkout main && git pull --ff-only

# Stage 1 (실기기 검증) — main 에서 직접
flutter run --flavor dev -t lib/main_dev.dart -d <device>

# Stage 2 (Dark mode 구현) — 새 브랜치
git checkout -b feat/phase4-dark-mode

dart format lib/ test/
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 500+ GREEN

# 푸시 + PR (사용자 명시 승인 필수)
git push -u origin feat/phase4-dark-mode
gh pr create --base main --title "..." --body "..."
```

## 알려진 인접 이슈 (Session 50 무관, 별도 세션)

- **HomeScreen `_showCollectionPicker` snackbar i18n** — Option B 영문 유지 중
- **Phase 2 iOS Share Extension** — Session 38 PoC 후속, 별도 트랙
- **DTO parse 실패 근본 추적** — PR #26 의 `appLogger.w` 가 미래 재발 시 캡처 예정
- **Supabase RLS / FK 점검** — dashboard 액세스 별도 트랙
- **StatefulShellRoute.indexedStack 탭 전환 logScreenView** — `app_router.dart` NOTE 주석 참조, 별도 세션
- **CollectionEntity 모델 확장** (visibility / color / emoji) — Phase 5+ Lock/Globe pill, 사용자 지정 색상 / 이모지

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
- **Docs-only PR 금지** — 문서만 변경한 브랜치는 단독 PR 생성하지 말고 다음 실코드 PR 에 묶기 (Session 46/47/48/49 PR #29/#30/#31/#32 동반 묶음 사례)

## 완료 기준

- [ ] Stage 1 5 화면 + 신규 nav 실기기 시각/동선 검증 결과 기록 (Home / LinkDetail / Collection grid / Search / Bottom Nav / Notifications push)
- [ ] Stage 2 Dark mode forest 팔레트 튜닝 단일 PR
- [ ] golden test baseline 도입 (Dark mode 화면)
- [ ] 위젯/통합 테스트 셀렉터 정합성
- [ ] flutter analyze 0
- [ ] flutter test all GREEN
- [ ] CI 4 job green + 사용자 머지
- [ ] 메모리 갱신:
  - [ ] `project_code_review_roadmap.md` Session 50 entry
  - [ ] `MEMORY.md` 인덱스 갱신
  - [ ] `project_design_overhaul.md` Phase 4 Dark mode 진척 표기

## 참조 문서/메모리

- **Session 49 commit**: `207dd1a` (PR #32)
- **Session 49 daily log**: `docs/daily_task_log/2026-05-01_session49.md`
- **Session 48 commit**: `587cf86` (PR #31)
- **디자인 오버홀 진행 상태**: `project_design_overhaul.md`
- **공유 토큰**:
  - `lib/app/theme/app_colors.dart` — forest / forestSoft / forestInk / amber / ink / ink2 / ink3 / line / bgSunk / bgAlt + *Dark 팔레트
  - `lib/app/theme/app_radius.dart`, `app_spacing.dart`, `app_text_styles.dart`
- **Ln 위젯 라이브러리**: `lib/shared/widgets/ln/`
  - `ln_collection_card.dart` (NEW Session 49) — 4톤 그라디언트 + `toneForId`
  - `ln_link_card.dart`, `ln_top_bar.dart`, `ln_icon_btn.dart`, `ln_segmented.dart`, `ln_thumb.dart`, `ln_tag.dart`, `ln_tags.dart`, `ln_brand.dart`
- **공유 유틸**: `lib/shared/utils/highlight_text.dart`
- **Shell scaffold**: `lib/shared/widgets/app_scaffold_with_nav_bar.dart` (`destinationLabels` 셀렉터 + centerDocked FAB)
- **i18n 정책**: `feedback_i18n_policy.md`
- **디자인 핸드오프**: `/Users/kaywalker/Downloads/design_handoff_linknote/`

## 세션 경계

Stage 1 (5 화면 + nav + grid 실기기 검증) + Stage 2 (Dark mode forest) 단일 흐름. Phase 2 iOS Share Extension / 정식 ARB intl 화 / CollectionEntity 모델 확장 같은 큰 Wave 는 별도 세션.

## 시작 시 사용자 확인 항목

1. 실기기 검증 가능 시점 (Stage 1) — 5 세션 연속 스킵 상태이므로 우선 처리 권장
2. Dark mode 진행 단위 (a. 토큰만 / b. 토큰 + 1 화면 golden / c. 토큰 + 전 화면 golden)
3. Light 모드 영향 범위 — surface/ink 토큰 변경 시 light 회귀 가능성 사전 합의
```
