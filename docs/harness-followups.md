# Harness Follow-ups

Planner-Generator-Evaluator harness run에서 누적된 관찰사항 및 다음 sprint/planner를 위한 권고. 각 항목은 `severity`, `scope`, `source`, `next_action_hint`로 분류한다.

원본 evaluator JSON: `.claude/harness/runs/<run-id>/sprints/<n>/eval/*.json` (gitignored). 이 문서는 main에 영속되어 cross-sprint 학습을 유지하기 위해 존재.

---

## Run 20260502-045500 — Sprint-1 (ReadingStats)

**Verdict**: PASS (4-evaluator convergence — Mode B Opus 74/80 + Round 4 Opus 73/80 + Codex AC-11 PASS + Gemini AC-12 PASS, threshold 60)
**Isolation judgment**: Path B (semantic / lenient with mandatory follow-ups)
**Commit**: `a996f5a` (rebased onto branch `harness/20260502-045500/sprint-1`)

### F1 — Contract codegen exception clause (Planner template gap)

- **severity**: low
- **scope**: out_of_scope
- **source**: 4-evaluator consensus
- **next_action_hint**: Next Planner Contract — add default clause

build_runner의 결정적 부수효과로 `lib/app/router/app_router.g.dart`, `lib/features/{auth,search,share}/.../*_provider.g.dart`, `lib/core/constants/env_{dev,staging,prod}.g.dart` 4개 파일이 forbidden territory에서 재생성됨. 모두 zero-behavioral-delta (riverpod hash 재계산 + envied XOR seed 회전). Contract `forbidden_files`가 이 패턴을 literal-enumerate하지 않아 Path A/B 판단 분기 발생.

**권고 Contract 추가절**:
```json
"forbidden_files_codegen_exception": ["**/*.g.dart", "**/*.freezed.dart"]
```

**Alternative** (Generator-side mitigation): `dart run build_runner build --build-filter='lib/features/<feature>/**' --delete-conflicting-outputs` — 다만 riverpod_generator hash propagation 때문에 완전 격리는 어려움. Contract exception 절이 더 안정적.

### F2 — AC-12 repository_impl unit test absent (test coverage gap) — RESOLVED

- **severity**: medium
- **scope**: in_current_contract
- **source**: Round 4 evaluator inspection
- **resolved**: Session 53 (2026-05-12, branch `feat/reading-stats-repo-tests`) — `test/features/reading_stats/data/repository/reading_stats_repository_impl_test.dart` 신규(6 tests, all GREEN). mocktail `_MockDatasource`로 HiveError + generic Exception + 정상 케이스 커버.

Contract AC-12 명세는 "Test: when datasource throws HiveError, repository returns CacheFailure"를 요구. 구현은 정확 (`on Object catch` + 톱레벨 `error<T>(Failure.cache(...))`)하지만 `test/features/reading_stats/data/repository/` 디렉토리 자체가 없음. mocktail `MockReadingStatsLocalDatasource`로 HiveError 던지는 테스트 30줄이면 갭 종료.

### F3 — _writeQueue eviction dead code (handoff 자진 신고)

- **severity**: low
- **scope**: in_current_contract
- **source**: handoff Known Limitations + Round 4 confirm
- **next_action_hint**: Sprint-2 backlog

`reading_stats_local_datasource.dart:35-42` — `next.whenComplete(...)`를 `_writeQueue[linkId]`에 저장. 따라서 line 37 `identical(_writeQueue[linkId], next)`는 영원히 false → 큐 엔트리 evict 안 됨. 동시성 invariant는 보존(prev→next chain serialize 정상)이지만 unique linkId당 메모리 단조 증가. 단일 세션 datasource에는 benign.

**Fix hint**: `_writeQueue[linkId] = next;` 로 변경하고 cleanup callback은 별도 `next.whenComplete(() { ... })` 리스너로 분리. 또는 per-linkId int counter로 reference count.

### F4 — AC-4 + AC-13 ordering inversion (cosmetic)

- **severity**: low
- **scope**: in_current_contract
- **source**: Mode B evaluator inspection
- **next_action_hint**: backlog

`record_read_event_usecase.dart:16-35` 검증 순서가 [future timestamp → negative duration → empty linkId]. 셋 다 동시 위반인 입력은 첫 매칭만 반환. 테스트 미커버, cosmetic. 제안: empty linkId 선두로 재배치.

### F5 — Failure.message가 raw $e를 embed (minor security)

- **severity**: low
- **scope**: in_current_contract
- **source**: Round 4 evaluator inspection
- **next_action_hint**: UI 노출 전 sanitization

`reading_stats_repository_impl.dart:24,37` — `Failure.cache(message: 'recordReadEvent: $e')`. HiveError 메시지에 box 이름/key path가 포함될 수 있어 추후 UI 배너에서 누출 가능. `_sanitize(e.toString())` helper 또는 exception type 별 고정 메시지 카탈로그 도입.

### F6 — Clock regression / time-travel attack (의도적 연기)

- **severity**: low
- **scope**: out_of_scope
- **source**: spec-redteam.md missing_edge_cases[1] + Mode B confirm
- **next_action_hint**: Sprint-2

Datasource가 `event.timestamp`를 그대로 신뢰. 사용자가 시계를 되돌리면 `lastReadAt = max(timestamps)`가 silent regress. 해결: `received_at` 필드 추가, 또는 monotonic clock 사용. Sprint-1은 도메인+데이터 레이어만이므로 명시 연기.

### F7 — O(n) read-aggregation per linkId (성능 천장)

- **severity**: low
- **scope**: out_of_scope
- **source**: spec-redteam.md spec_gaming_paths[0]
- **next_action_hint**: backlog

`getStats`가 events 리스트 전체 walk → totalReads + max(lastReadAt). UI 컨슈머가 없는 동안 acceptable, ~500 events/link 이하 한계. Sprint-2에서 stored aggregate 또는 paginated read 도입.

### F8 — AC-1 entity-level empty linkId 허용 (의도)

- **severity**: low
- **scope**: in_current_contract
- **source**: Mode B
- **next_action_hint**: 정책 명시

`ReadingEventEntity` freezed factory가 empty linkId 허용. Usecase 레이어(AC-4)에서만 거부. Clean Architecture 원칙(Entity는 값, Usecase는 정책)에 부합 → 의도된 설계. 다음 Planner Contract에 명시.

### F9 — .gitignore root-level addition (out-of-scope-benign)

- **severity**: low
- **scope**: out_of_scope
- **source**: Round 4 evaluator inspection

`.gitignore`에 `.claude/harness/runs/` 관련 3줄 추가. Contract `forbidden_files`에 명시 안 됨, harness 위생 변경으로 분류. Path B 수락. 차후 Contract에 project-meta 파일(`.gitignore`, `.claude/**`) 명시 허용 추가 권장.

---

## Cross-sprint patterns (재발 방지용)

- **Codegen 부수효과 (F1)**: build_runner를 표준 명령으로 쓰는 한 모든 sprint에서 재발 가능. Contract 템플릿 default로 박을 것.
- **Test parity gap (F2)**: AC가 "Test: ..."를 명시했는데 dir조차 없는 경우 — Generator Hand-off 체크리스트에 "AC가 명시한 모든 test path 존재 여부" 자동 검증 추가 검토.
- **Mode A→B revision drift**: Mode A round-1에서 Contract 결함(존재 안 하는 Result.failure/ValidationFailure 등) 발견 시 — 다음 sprint도 동일 패턴 가능. Planner가 Contract 작성 시 실제 코드 API 첫 grep 강제.
