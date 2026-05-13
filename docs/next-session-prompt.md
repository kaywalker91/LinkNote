# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 54 — Track C(실기기 시각 검증) 또는 Track B(Sprint-2 ReadingStats UI integration)

## 미션 한 줄

Session 53 머지로 Sprint-1 follow-up F2(repository_impl unit test gap) closure 완료. Session 54 는 Track C(실기기 시각 검증, 8 세션 누적 deferred) 또는 Track B(Sprint-2 ReadingStats UI integration) 진입 중 사용자 합의 후 단일 트랙.

## 배경

**Session 53 (2026-05-12) 결과**:
- 신규 `test/features/reading_stats/data/repository/reading_stats_repository_impl_test.dart` — 6 케이스(success + HiveError + Exception × recordReadEvent/getReadingStats) all GREEN.
- `docs/harness-followups.md` F2 RESOLVED 마크.
- Session 52 잔여 docs(`tasks/lessons.md`, daily_log, CHANGELOG) 묶어서 단일 실코드 PR 머지.
- 전체 테스트 550 → 556 GREEN, analyze 0, CI 4 job green.

**남은 follow-up (`docs/harness-followups.md` 발췌)**:
- **F1**(low, out-of-scope) — Contract `forbidden_files_codegen_exception` 절. **Track B(Sprint-2) 진입 전 Planner Contract 템플릿 반영 필요** — 미반영 시 동일 부수효과 재발.
- **F3**(low, in-contract) — `_writeQueue` `identical()` cleanup 영원히 false. 동시성 invariant 보존이라 low priority.
- **F4~F9** 잔여 — 모두 low severity, backlog.

## 작업 범위 — 후보 트랙

### Track C — 실기기 시각 검증 (8 세션 연속 deferred) ⭐추천1

- **규모**: 검증 활동 자체는 소(30~60분), 발견 시 fix 사이즈는 가변.
- **의존성**: 실기기 또는 에뮬레이터 연결.
- **범위**: Home/LinkDetail/Collection grid/Search/Bottom Nav + 중앙 FAB/Notifications, light↔dark 토글.
- **가치**: Phase 4 dark mode forest 팔레트(Session 50) + Phase 4.5 alchemist baseline(Session 51) 머지 후 실제 사용자 시각 검증이 한 번도 안 됨. 회귀 위험 누적 상태.
- **PR**: 발견된 회귀 fix 가 있으면 단일 PR, 없으면 검증 리포트만 daily_log 에 기록.

### Track B — Sprint-2 진입 (ReadingStats UI integration)

- **규모**: 중~대
- **의존성**: F1 권고(Contract codegen exception) 반영 필요. Planner Contract 템플릿 사전 정비.
- **범위 후보**:
  - LinkDetail 진입 시 `RecordReadEventUsecase` 호출(durationSeconds 옵션).
  - LinkDetail 또는 Home 카드에 `GetReadingStatsUsecase` 기반 totalReads/lastReadAt 배지 표시.
  - Riverpod provider 통합(읽기는 `FutureProvider`, 쓰기는 fire-and-forget).
- **harness 사용**: Sprint-2 로 정식 진행 권장. Planner 시 F1 반영 + F6(clock regression) AC 포함 여부 결정.

### Track D — Linux golden 재생성

- **규모**: 소
- **의존성**: 없음(GitHub Actions workflow_dispatch).
- **가치**: Phase 4.5 머지 시 CI 가 `--exclude-tags golden` 임시 상태. Linux baseline 생성하면 CI 가 다시 golden 검증 가능.
- **PR**: golden PNG diff 커밋.

### Track E — iOS Share Extension (Phase 2)

- **규모**: 대
- **의존성**: iOS 인증서 / Apple Developer 계정. 미해결.
- **현실성**: 인프라 차단으로 진입 불가일 가능성 높음.

### Track F — ARB 정식 i18n

- **규모**: 대
- **의존성**: Option B 임시 가이드 → ARB 마이그레이션. 기존 한글 카피 전수 추출.

**기본 추천**:
- 우선순위 1: **C (실기기 검증)** — 8 세션 연속 deferred, 누적 회귀 위험. 짧은 검증 사이클로 한 번 끊고 가는 게 위생적.
- 우선순위 2: **B (Sprint-2 진입)** — F1 Contract 권고 반영 후 본 사이클 진입.
- 우선순위 3: **D (Linux golden 재생성)** — CI golden 복원, 소규모.

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote
git checkout main && git pull --ff-only

# Track C 또는 B/D 선택 후 새 브랜치
git checkout -b <feat/...|sprint-2/...>

# 푸시 전 강제 시퀀스 (Session 52~53 학습 — dart format 2회 재발 방지)
dart format lib/ test/
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 556+ GREEN
# 셋 다 통과 후에만 push

git push -u origin <branch>
gh pr create --base main --title "..." --body "..."
```

## 알려진 인접 이슈 (Session 54 무관, 별도 세션)

- **Phase 4 dark mode 토큰 미세 튜닝** — 실기기 검증(Track C) 후 발견될 수 있음.
- **Supabase RLS / FK 점검** — dashboard 액세스 별도 트랙.
- **`StatefulShellRoute.indexedStack` 탭 전환 `logScreenView`** — `app_router.dart` NOTE 주석, 별도 세션.
- **`CollectionEntity` 모델 확장** (visibility / color / emoji) — Phase 5+ Lock·Globe pill.
- **`shimmer_box.dart` `Theme.of(c).brightness` 직접 검사** — palette 통합 가능.
- **harness deterministic_verifier 에 `dart format --set-exit-if-changed` 추가** — Sprint-2 진입 시 반영.

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection** — PR + CI 4 job green 필수
- **TDD RED → GREEN** — 데이터/도메인/프로바이더 변경은 테스트 선행
- **i18n Option B** — UI 사용자 대면 카피는 한글, snackbar/Exception/Failure.message 는 영문
- **CI dart format atomic 시퀀스** — `dart format && flutter analyze && flutter test` 하나라도 빠지면 푸시 금지 (Session 52 학습, 2회 재발 후 강화)
- **omit_local_variable_types** — 로컬 변수는 `var`
- **`on Exception catch` 만 사용 금지** — 데이터 경계는 `on Object` (Session 28/41/45/52 학습)
- **Freezed nested toJson 주의** — Hive/JSON 직렬화 경계에서 nested 필드 명시 처리 (Session 42)
- **per-row 파싱 fault tolerance** — remote list fetch 는 `parseRows` 패턴 답습 (Session 44)
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion` 으로 확인 (Session 49)
- **`gh pr checks` 모니터링은 `--json` 사용** — awk whitespace split 함정 회피 (Session 45)
- **Docs-only PR 금지** — 문서만 변경한 브랜치는 단독 PR 생성하지 말고 다음 실코드 PR 에 묶기
- **Light 회귀 zero 원칙** — design token 변경 시 `AppPalette.light()` 는 기존 `AppColors` 와 byte-identical 유지 (Session 50)
- **ThemeExtension 패턴** — 디자인 토큰 brightness-aware 분기는 `ThemeExtension<T>` + `context.palette` fallback (Session 50)
- **Harness Path B isolation** — codegen 부수효과는 zero behavioral delta 검증 후 의무 follow-up 등록과 함께 PASS (Session 52). `docs/harness-followups.md` 에 영속.

## 완료 기준

- [ ] 트랙 결정 + 작업 진입
- [ ] flutter analyze 0
- [ ] flutter test all GREEN
- [ ] CI 4 job green + 사용자 머지 (Track C 검증만이면 PR 없을 수 있음)
- [ ] 메모리 갱신:
  - [ ] `project_code_review_roadmap.md` Session 54 entry (선택)
  - [ ] `MEMORY.md` 인덱스 갱신 (선택)
  - [ ] Track별 관련 메모리(`project_harness_pipeline.md` follow-up closure, `project_design_overhaul.md` 등)

## 참조 문서/메모리

- **Session 53 daily log**: `docs/daily_task_log/2026-05-12_session53.md` (작성 예정)
- **Session 52 daily log**: `docs/daily_task_log/2026-05-11_session52.md`
- **Sprint-1 squash commit**: `7aa539d` (PR #35)
- **Harness follow-up registry**: `docs/harness-followups.md` (영속, cross-sprint, F2 RESOLVED)
- **Harness 파이프라인 메모리**: `project_harness_pipeline.md`
- **CI dart format 강화**: `feedback_ci_dart_format.md` + `tasks/lessons.md` 2026-05-11
- **ReadingStats 코드/테스트**: `lib/features/reading_stats/` + `test/features/reading_stats/` (data/repository/ 신규)
- **공유 토큰/Ln 위젯**: `lib/app/theme/app_palette.dart`, `lib/shared/widgets/ln/`

## 세션 경계

트랙 합의 후 단일 흐름. Track C(실기기 검증)는 발견 사항에 따라 후속 결정. Track B(Sprint-2)는 harness 사이클 1개.

## 시작 시 사용자 확인 항목

1. Track 선택 (C/B/D/E/F 또는 사용자 정의)
2. Track B 선택 시: F1 Contract codegen exception 절 반영 시점(이번 sprint 진입 전 vs 진입 후 patch)
3. Track C 선택 시: 실기기 연결 가능 시점
```
