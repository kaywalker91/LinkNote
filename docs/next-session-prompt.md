# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 56 — Track B+ (Sprint-3 진입, harness 강화 후 Home 카드 미니 배지) / Track D (Linux golden) / 후속 다크 모드 검증

## 미션 한 줄

Session 55 머지로 Phase 4 dark mode forest 완성(11 화면 palette 마이그레이션, 갤럭시 A34 Home 회귀 해소, F-Sprint2-5 RESOLVED). Session 56 은 Track B+ (Sprint-3 정식 사이클 — Home 카드 미니 배지 + harness 강화) 또는 Track D (Linux golden 재생성) 또는 추가 다크 모드 화면 실기기 시각 검증 중 사용자 합의 후 단일 트랙.

## 배경

**Session 55 (2026-05-14) 결과**:
- PR 머지 (`fix/dark-mode-screen-palette-migration`). 11 코드 파일, 46 use site `AppColors.<X>` → `context.palette.<X>` 치환.
- 갤럭시 A34 다크 모드 Home 회귀 해소 검증 완료. `palette.bgAlt` = `#0E1311` 다크 forest tone 정상.
- 562 tests GREEN 유지, analyze 0, format clean.
- 의도된 잔여 5 site 보존 (semantic / data hex / top-level brand 마커).
- `AppPalette.light()` byte-identical 보장 → 라이트 회귀 zero.
- F-Sprint2-5 (live_verification badge dark-mode 실기기 검증) RESOLVED.

**남은 follow-up (`docs/harness-followups.md`)**:
- **F-Sprint2-1**(low) — AC-2 wording에 zero-stats data-branch fallback 공식화.
- **F-Sprint2-2**(low) — Impact Map downstream_test_files transitive scan 강화.
- **F-Sprint2-3**(med) — silent-fallback FutureProvider + async-throw widget test 금지 가이드를 Contract 템플릿에 명시.
- **F-Sprint2-4**(med, harness_tune) — Planner `verified_canonical_evidence` 의무화 (Sprint-3 진입 전 글로벌 agent 강화 권고).

**Sprint-1 잔여**: F3 (`_writeQueue identical()` dead code, low) / F4~F9 backlog.

**Session 55 잔여 시각 검증** (옵션):
- Search / Collection Detail / Login / Edit 등 11 화면 일부는 갤럭시 A34 직접 검증 미수행 (mechanical 패턴이라 회귀 위험 매우 낮으나 보수적 확인 가능).

## 작업 범위 — 후보 트랙

### Track B+ — Sprint-3 진입 (Home 카드 미니 배지 + harness 강화) ⭐추천1

- **규모**: 중~대
- **의존성**: F-Sprint2-3/F-Sprint2-4 Contract 템플릿 반영 권고 (Sprint-3 Planner 호출 전)
- **범위 후보**:
  - LnLinkCard 에 mini ReadingStatsBadge (totalReads 만 압축 표시, lastReadAt 생략)
  - N+1 Hive read 방지 — batch API `GetReadingStatsForMany(List<String> linkIds)` 도입 검토 (F7 연동)
  - Riverpod provider 그래프 확장
- **harness 강화 사전 작업 (F-Sprint2-4)**:
  - 글로벌 `~/.claude/agents/harness-planner.md` Self-Validation에 prescriptive code snippet ↔ corpus literal match grep 검증 추가
  - 모든 `overrideWith` snippet 에 `verified_canonical_evidence` (파일:line 인용) 필드 의무화
- **harness 사용**: Sprint-3 정식 사이클 (Planner → Mode A → Generator → Mode B simplified)

### Track D — Linux golden 재생성

- **규모**: 소
- **의존성**: 없음 (GitHub Actions workflow_dispatch)
- **가치**: Phase 4.5 머지(`61e5c5b`) 시 CI 가 `--exclude-tags golden` 임시 상태. Linux baseline 생성하면 CI 가 다시 golden 검증 가능.
- **PR**: golden PNG diff 커밋

### Track H — 다크 모드 추가 화면 실기기 검증 (Session 55 후속)

- **규모**: 소
- **의존성**: 실기기 또는 에뮬레이터 연결
- **범위**: Search / Collection Detail / Login / Edit / Form / Skeleton 다크 모드 시각 회귀 zero 확인
- **PR**: 발견된 회귀 fix 가 있으면 단일 PR, 없으면 검증 리포트만 daily_log 에 기록

### Track E — iOS Share Extension (Phase 2)

- **규모**: 대
- **의존성**: iOS 인증서 / Apple Developer 계정. 미해결
- **현실성**: 인프라 차단 가능성 높음

### Track F — ARB 정식 i18n

- **규모**: 대
- **의존성**: Option B 임시 가이드 → ARB 마이그레이션. 기존 한글 카피 전수 추출

### Track G — 메모리 갱신 (Session 55 closure 항목)

- **규모**: 소
- **의존성**: 없음
- **현실성**: Docs-only PR 금지 규칙. **Track B+/D/H 의 실코드 PR 에 묶기**. 갱신 항목:
  - `feedback_theme_extension_pattern.md` — Session 55 closure (screen-level 마이그레이션 완료, Phase 4 dark mode forest 100% 적용)
  - `project_design_overhaul.md` — Phase 4 closure entry
  - `docs/harness-followups.md` F-Sprint2-5 — RESOLVED 마크

**기본 추천**:
- 우선순위 1: **B+ (Sprint-3 진입)** — F-Sprint2-4 harness 강화 후 본 사이클. KL-1/F-Sprint2-3 학습 반영
- 우선순위 2: **D (Linux golden 재생성)** — CI golden 복원, 소규모
- 우선순위 3: **H (다크 모드 잔여 화면 검증)** — Session 55 보수적 follow-up

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote
git checkout main && git pull --ff-only

# Track B+/D/H 선택 후 새 브랜치
git checkout -b <sprint-3/...|harness/...|verify/...>

# 푸시 전 강제 시퀀스 (Session 52~55 학습)
dart format lib/ test/
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 562+ GREEN
# 셋 다 통과 후에만 push

git push -u origin <branch>
gh pr create --base main --title "..." --body "..."
```

## 알려진 인접 이슈 (Session 56 무관, 별도 세션)

- **dev/staging Supabase URL DNS 실패** — Session 55 실기기 빌드 시 반복 (`jzcduhgatmbobevxjdhy.supabase.co` 호스트 lookup 실패). 로컬 Hive 무관이지만 인증/동기화 필요 검증 시 prod flavor 또는 dev Supabase 재설정 필요.
- **Phase 4 dark mode 토큰 미세 튜닝** — Session 55 추가 화면 실기기 검증 시 발견될 수 있음
- **Supabase RLS / FK 점검** — dashboard 액세스 별도 트랙
- **`StatefulShellRoute.indexedStack` 탭 전환 `logScreenView`** — `app_router.dart` NOTE 주석, 별도 세션
- **`CollectionEntity` 모델 확장** (visibility / color / emoji) — Phase 5+ Lock·Globe pill
- **`shimmer_box.dart` `Theme.of(c).brightness` 직접 검사** — palette 통합 가능
- **harness deterministic_verifier 에 `dart format --set-exit-if-changed` 추가** — Sprint-3 진입 시 반영

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection** — PR + CI 4 job green 필수
- **TDD RED → GREEN** — 데이터/도메인/프로바이더 변경은 테스트 선행
- **i18n Option B** — UI 사용자 대면 카피는 한글, snackbar/Exception/Failure.message 는 영문
- **CI dart format atomic 시퀀스** — `dart format && flutter analyze && flutter test` 하나라도 빠지면 푸시 금지
- **omit_local_variable_types** — 로컬 변수는 `var`
- **`on Exception catch` 만 사용 금지** — 데이터 경계는 `on Object`
- **Freezed nested toJson 주의** — Hive/JSON 직렬화 경계에서 nested 필드 명시 처리
- **per-row 파싱 fault tolerance** — remote list fetch 는 `parseRows` 패턴 답습
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion` 으로 확인
- **`gh pr checks` 모니터링은 `--json` 사용** — awk whitespace split 함정 회피
- **Docs-only PR 금지** — 문서만 변경한 브랜치는 단독 PR 생성하지 말고 다음 실코드 PR 에 묶기
- **Light 회귀 zero 원칙** — design token 변경 시 `AppPalette.light()` 는 기존 `AppColors` 와 byte-identical 유지
- **ThemeExtension 패턴** — 디자인 토큰 brightness-aware 분기는 `ThemeExtension<T>` + `context.palette` fallback. **Screen-level 마이그레이션도 동시 진행** (Session 55 교훈 — 토큰만 도입하고 screen `AppColors.X` 직접 사용 유지 시 다크 모드 부분 적용 회귀)
- **Harness Path B isolation** — codegen 부수효과 + KL substitution 은 zero behavioral delta 검증 후 의무 follow-up 등록과 함께 PASS. `docs/harness-followups.md` 에 영속
- **Family-arg over-specification 회피 (F-Sprint2-4)** — Planner Contract prescriptive code snippet 의 `overrideWith` 패턴은 반드시 `target shape + lambda signature` 전체를 corpus literal match grep 으로 검증. `verified_canonical_evidence` 필드 의무화 권고
- **Silent-fallback ↔ error branch 모순 회피 (F-Sprint2-3)** — provider 가 Failure 를 swallow하면 widget error branch 는 production-unreachable. async-throw widget test prescriptive snippet 금지
- **Impact Map transitive test scan (F-Sprint2-2)** — Planner Impact Map 단계에서 changed screen widget 의 모든 mount caller test 파일 scan 필수

## 완료 기준

- [ ] 트랙 결정 + 작업 진입
- [ ] flutter analyze 0
- [ ] flutter test all GREEN (562+)
- [ ] CI 4 job green + 사용자 머지
- [ ] 메모리 갱신:
  - [ ] Track 별 관련 메모리 (`feedback_theme_extension_pattern.md` closure, `project_design_overhaul.md`, `project_harness_pipeline.md` follow-up 등)
  - [ ] `MEMORY.md` 인덱스 갱신 (선택)

## 참조 문서/메모리

- **Session 55 daily log**: `docs/daily_task_log/2026-05-14_session55.md`
- **Session 54 daily log**: `docs/daily_task_log/2026-05-13_session54.md`
- **Harness follow-up registry**: `docs/harness-followups.md` (영속, F1+F2 RESOLVED, F-Sprint2-1~5 + F-Sprint2-5 RESOLVED)
- **Harness 파이프라인 메모리**: `project_harness_pipeline.md`
- **공유 토큰/Ln 위젯**: `lib/app/theme/app_palette.dart`, `lib/shared/widgets/ln/`, `lib/shared/extensions/context_extensions.dart`

## 세션 경계

트랙 합의 후 단일 흐름. Track B+(Sprint-3)는 harness 강화 + Planner→Generator→Evaluator 1 사이클. Track D 는 workflow_dispatch + golden PNG 커밋. Track H 는 발견 사항에 따라 후속 결정.

## 시작 시 사용자 확인 항목

1. Track 선택 (B+/D/H/E/F 또는 사용자 정의)
2. Track B+ 선택 시: F-Sprint2-4 글로벌 Planner `verified_canonical_evidence` 의무화 시점 (Sprint-3 진입 전 vs 진입 후 patch)
3. Track G(메모리 갱신) 묶음 처리 — Track B+/D/H 중 어디에 합칠지
```
