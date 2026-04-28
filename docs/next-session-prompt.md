# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 45 — Collection 화면 디자인 토큰 정합성 (Phase 3 잔여)

## 미션 한 줄

Phase 3 디자인 오버홀에서 Home / LinkDetail / LinkAdd / LinkEdit 까지는 forest/amber 톤 + Ln 위젯으로 정렬되었으나 Collection 화면(목록 + 상세)은 여전히 구 토큰을 사용 중. LnIconBtn / AppRadius / AppColors.forest 같은 디자인 토큰을 일괄 적용해 톤·갭·radius 가 다른 화면들과 어긋나지 않도록 정렬한다.

## 배경

**Session 44 (2026-04-25~26, 직전 세션) 결과**:
- PR #25 `4229b10` 머지 — Search 필터 단독 트리거 fix + DateRangePicker 종료일 inclusive
- PR #26 `7ac5693` 머지 — Link list per-row 파싱 fault tolerance (`parseRows` 헬퍼 + appLogger.w)
- PR #27 `0fc1011` 머지 — i18n Home 빈상태/more sheet/삭제 다이얼로그 한글화 + LinkDetail saved date 한글+절대 날짜 병행
- 484 tests GREEN, analyze 0 issues, CI 4 job ALL GREEN
- 신규 헬퍼 `LinkRemoteDataSource.parseRows`, 신규 확장 `DateTimeExtensions.formattedDate()`

**Phase 3 잔여 (Session 40 PR #21 후 OOS 로 분리됐던 마지막 항목)**:
- Collection 화면이 forest/amber 디자인 토큰 미적용 상태
- LnIconBtn / AppRadius.* / AppColors.forest|amber|amberSoft 등 공유 토큰 활용 0건
- Home/LinkDetail 의 spacing(AppSpacing.*), 타이포(AppTextStyles.*) 와 시각 차이 발생 → 화면 간 톤 어긋남

## 작업 범위

### Stage 1 — Collection 목록 화면 토큰 정렬

**대상 파일**:
- `lib/features/collection/presentation/screens/collection_list_screen.dart` (또는 home 통합 형태일 경우 그 위치)
- `lib/features/collection/presentation/widgets/collection_*.dart` (카드/타일/빈상태)

**기대 변화**:
- AppBar 액션 → `LnIconBtn` 변경 (Home/LinkDetail 와 동일 hit-target)
- 카드/타일 radius → `AppRadius.lg` (예: 16) 통일
- primary 컬러 사용처 → `AppColors.forest`
- 빈 상태 → `EmptyStateWidget` + 한글 카피 (`'아직 컬렉션이 없어요'` 류)
- spacing 정수 → `AppSpacing.*` 매핑

### Stage 2 — Collection 상세 화면 토큰 정렬

**대상 파일**:
- `lib/features/collection/presentation/screens/collection_detail_screen.dart`

**기대 변화**:
- 헤더/액션 → LnIconBtn / Material 3 IconButton 정합성
- 컬렉션 메타 영역 → AppTextStyles.titleM / bodySmall + ink/ink2/ink3 컬러 토큰
- 안에 들어있는 링크 카드 → `LnLinkCard` (또는 변형) 사용
- 빈 상태 → `'이 컬렉션에 저장된 링크가 없어요'` 류

### TDD / 회귀

- Collection 화면 위젯 테스트가 있는지 먼저 확인 (`test/features/collection/presentation/screens/`).
- 기존 셀렉터(영문/구토큰)가 있다면 새 토큰·한글 카피로 셀렉터 동기화.
- golden test 가 있다면 디자인 변경 후 baseline 갱신 필요할 수 있음.

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote

git checkout main && git pull --ff-only

git checkout -b feat/collection-design-tokens

# Stage 1 → Stage 2 순차 작업
# - 각 단계마다 dart format / flutter analyze / flutter test 통과 확인

dart format lib/ test/
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 484+ GREEN

# 실기기 검증
flutter run --flavor dev -t lib/main_dev.dart -d RFCW615RBFT
# → Collection 목록 / 상세 화면 톤·radius·spacing 이 Home / LinkDetail 과 일관되는지 시각 확인
# → 빈 상태 한글 카피 노출 확인

# 푸시 + PR (사용자 명시 승인 필수)
git push -u origin feat/collection-design-tokens
gh pr create --base main --title "..." --body "..."
```

## 알려진 인접 이슈 (Session 45 무관, 별도 세션)

- **Search 헤더 / LnTabBar 라벨 / Dark mode 토글** — Phase 4+ 묶음
- **HomeScreen `_showCollectionPicker` snackbar i18n** — Option B 대로 영문 유지 중. ARB 기반 정식 intl 도입 시 일괄 외부화
- **Phase 2 iOS Share Extension** — Session 38 PoC 후속, 별도 트랙
- **DTO parse 실패 근본 추적** — Session 44 PR #26 의 `appLogger.w` 가 미래 재발 시 캡처 예정
- **Supabase RLS / FK 점검** — dashboard 액세스 별도 트랙

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection** — PR + CI 4 job green 필수
- **TDD RED → GREEN** — 데이터/도메인/프로바이더 변경은 테스트 선행
- **i18n Option B** — UI 사용자 대면 카피는 한글, snackbar / Exception / Failure.message 는 영문
- **CI dart format 선행** — 푸시 전 로컬 `dart format`
- **omit_local_variable_types** — 로컬 변수는 `var`
- **on Exception 만 catch 금지** — 데이터 경계는 `on Object` (Session 28 / 41 학습)
- **Freezed nested toJson 주의** — Hive/JSON 직렬화 경계에서 nested 필드 명시 처리 (Session 42)
- **per-row 파싱 fault tolerance** — remote list fetch 는 `parseRows` 패턴 답습 (Session 44 학습)
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion` 으로 확인

## 완료 기준

- [ ] Stage 1 Collection 목록 화면 디자인 토큰 적용 + 한글 카피
- [ ] Stage 2 Collection 상세 화면 디자인 토큰 적용 + 한글 카피
- [ ] 위젯 테스트 셀렉터 동기화
- [ ] 실기기 — Home / LinkDetail 과 시각 일관성 확인
- [ ] PR 생성 + CI 4 job green + 사용자 머지
- [ ] flutter analyze 0
- [ ] flutter test all GREEN
- [ ] 메모리 갱신:
  - [ ] `project_code_review_roadmap.md` Session 45 entry
  - [ ] `MEMORY.md` 인덱스 갱신
  - [ ] `project_design_overhaul.md` Phase 3 잔여 항목 완료 표기

## 참조 문서/메모리

- **Session 44 commits**: `4229b10` (PR #25) / `7ac5693` (PR #26) / `0fc1011` (PR #27)
- **Session 44 daily log**: `docs/daily_task_log/2026-04-26_session44.md`
- **디자인 오버홀 진행 상태**: `project_design_overhaul.md`
- **공유 토큰**:
  - `lib/app/theme/app_colors.dart` — forest / amber / ink / ink2 / ink3 / line / bgAlt
  - `lib/app/theme/app_radius.dart` — sm / md / lg / xl / full
  - `lib/app/theme/app_spacing.dart` — xs / sm / md / lg / xl / xxl / screenPadding
  - `lib/app/theme/app_text_styles.dart` — titleM / bodyMedium / bodySmall / label
- **Ln 위젯 라이브러리**: `lib/shared/widgets/ln/`
- **i18n 정책**: `feedback_i18n_policy.md`

## 세션 경계

Stage 1 + Stage 2 단일 PR. Search 헤더 / LnTabBar / Dark mode / Phase 2 iOS Share Extension / 정식 ARB intl 화는 별도 세션.

## 시작 시 사용자 확인 항목

1. Collection 화면(목록 + 상세) 단일 PR 묶음 진행 OK
2. golden test baseline 변경 발생 시 갱신 방침 (PR 에 같이 포함 vs 별도 정리)
```
