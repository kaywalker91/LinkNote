# LinkNote Lessons Learned

프로젝트 로컬 교훈. `~/.claude/rules/continuous-improvement.md` 규칙에 따라 기록.

---

## 2026-05-21 — Harness Planner Self-Validation 강화는 Round-1 에서 즉시 ROI 회수된다

**무엇을 배웠나**: Session 57 의 Track B+ 사전 작업으로 글로벌 `~/.claude/agents/harness-planner.md` Self-Validation 에 F-Sprint2-4 (verified_canonical_evidence ERROR) + F-Sprint2-3 (silent-fallback widget test WARN) 두 jq 게이트를 신설. Sprint-3 Planner Round-1 에서 게이트가 4 prescriptive_test_snippets 의 evidence schema 를 실제 검증 (13 override refs / 4 evidence objects / {file, line, exact_match} 3 필드 의무) 했고, Sprint-2 의 3 라운드 family-arg over-specification 회귀가 0 라운드로 차단됐다. Mode A 도 2 라운드만에 confirm (Sprint-2 의 3 라운드보다 짧음 — wording-only revisions). Generator 가 canonical 2-arg `(ref, linkId) async => ...` 형식을 첫 시도에 정확히 채택.

**근본 원인**: 메타-패턴 회귀 (family-arg / silent-fallback) 는 사람 리뷰어가 매 sprint 마다 같은 실수를 재확인해야 하는 비용이 컸다. Self-Validation jq 게이트로 변환 가능한 패턴은 Planner 가 contract 확정 전에 자동 reject 되어 사이클 비용이 사라진다.

**예방 규칙**:
- 메타-패턴 (3+ sprint 누적된 동일 카테고리 결함) 발견 시 글로벌 agent Self-Validation 강화로 영구화. ERROR/WARN 2 단계 적용 (mechanical 회귀는 ERROR, 컨텍스트 판단 필요한 회귀는 WARN).
- 글로벌 agent 변경은 Phase 1 사전 작업으로 분리. Sprint 실행 sprint Contract 작성 시점부터 게이트 효과 발휘.
- jq 게이트는 8 sanity 케이스 (positive 4 + negative 4) 로 검증 후 적용. negative 가 실제로 reject 되는지 확인 필수.

---

## 2026-05-21 — Harness 사이클의 stream idle timeout 은 부분 진행을 디스크로 보존한다

**무엇을 배웠나**: Sprint-3 Planner 2회 stream idle timeout 발생 (Round-1: 22min/69 tool uses, Round-2: 10min/600s watchdog). 둘 다 핵심 산출물 (spec.md, contracts, impact-map, response.md) 은 timeout 직전에 이미 디스크에 저장됨. SendMessage 재개 또는 Orchestrator 직접 검증 (jq Self-Validation 재실행) 으로 다음 phase 진입 가능.

**근본 원인**: Sub-agent 가 파일 기반 도구 (Write/Edit) 를 사용하면 핵심 산출물은 자동 영속화됨. timeout 은 stream 차원의 idle 감지로, 작업 자체 손실은 아님. 다만 final report (transcript-only) 는 timeout 시 잃을 수 있음.

**예방 규칙**:
- Sub-agent 호출 후 timeout 발생 시 (a) 디스크 상태 확인 → (b) 핵심 산출물 존재하면 Orchestrator 가 mechanical 검증 (jq, grep, test 실행) 으로 직접 보완 → (c) 부족한 부분만 SendMessage 로 finalize. 전체 재실행은 비용 큼.
- Final report 가 transcript-only 인 정보는 별도 영속화 (예: handoff/sprint-N-handoff.md 파일) 로 보존. Sprint-3 hand-off 는 12KB 로 전체 산출 보존됨.
- 글로벌 agent 시간이 30 분 넘는 작업은 분할 가능성 검토. Tier 2-3 작업은 시퀀스 길이 늘리지 말고 sprint 분할.

---

## 2026-05-14 — 누적 lesson 의 회귀는 grep script + CI step 으로 영구 차단

**무엇을 배웠나**: Session 56 stocktake 에서 메모리 lessons (15건) 중 일부가 코드베이스에 잔존 위반으로 누적되고 있음을 발견. `on Exception catch` 가 Session 28 + 41 의 두 sweep 이후에도 34곳까지 다시 자라 있었다. 추가로 `parseRows` per-row tolerance 패턴(PR #26)이 Link 한 feature 에만 적용되어 Collection/Notification 은 같은 함정이 그대로 남아 있었다. 메모리 만으론 회귀 방지 부족.

**근본 원인**: 메모리는 "원리" 를 기록하지만 코드베이스의 "현재 잔존 위반" 을 추적하지 않는다. 새 코드가 들어올 때 패턴 위반 여부를 검토하는 책임이 인간 리뷰어에게 100% 의존하면 누적되는 것이 자연스럽다.

**해결책**: `tool/check_anti_patterns.sh` 를 만들어 grep 기반 카테고리별 게이트 추가. PR #39 에서 `.github/workflows/ci.yml` 의 analyze job 에 step 으로 연동.
- Category A (FAIL): `AppColors` whitelist — 의도된 5 site 외에는 차단
- Category B: `on Exception catch` — PR #39 시점 WARN(34건 카운트) → PR #40 의 sweep 후 ENFORCE=1 FAIL
- 향후 카테고리 추가 시 `check_xxx()` 함수 + main 호출 추가만으로 확장 가능

**예방 규칙**:
- 메모리 lesson 이 누적되면 grep 으로 잔존 위반을 정량 측정 가능한지 먼저 확인. 가능하면 script + CI step 으로 영구화.
- 신규 lesson 도입 시점에 같은 PR 안에서 script category 추가 가능한지 평가 (해당 lesson 이 mechanical 패턴이면 가능, semantic judgment 필요하면 불가능).
- WARN → ENFORCE 2단계 승격 패턴: 잔존 위반 sweep 직후 같은 PR 에서 ENFORCE=1 로 flip. WARN 단계 길게 두지 말 것 (몇 PR 못 가서 카운트 증가).

---

## 2026-05-14 — 메모리 stale 판정은 grep 결과만 보면 오판한다

**무엇을 배웠나**: Session 56 stocktake 중 두 메모리가 "stale" 처럼 보였으나 검증 결과 둘 다 유효했다.
- `feedback_ci_dart_format` 의 "강화 권고: pre-push hook 자동화" — 실제로는 `.github/workflows/ci.yml:32-33` 에 dart format step 이 이미 적용된 상태. CI 강화는 이미 일부 달성됨.
- `feedback_riverpod_async_notifier_inflight` — `grep AsyncNotifier lib --include='*.dart' | grep -v '.g.dart'` 가 0건 반환. 코드베이스에 패턴이 없는 것으로 잘못 결론. 실제로는 riverpod_generator 가 `.g.dart` 안에 출력하고, source code 는 `class X extends _$X` 패턴으로 작성됨. 사용처 8 generated provider 존재.

**근본 원인**: 메모리 검증을 grep 한 번으로 끝내면 (a) 다른 곳에서 이미 해결된 것을 못 알아채거나 (b) generator/codegen 출력 형태로 존재하는 패턴을 놓친다.

**예방 규칙**:
- 메모리 stale 판정 전 최소 2가지 그렙 변형 시도: `.g.dart` 포함 + `.g.dart` 제외, source 패턴(`extends _\$`) + 키워드.
- 메모리에 "강화 권고", "TODO", "후속" 같은 동작성 문구가 있으면 그 동작이 다른 PR 에서 이미 수행됐는지 git log 또는 파일 mtime 으로 확인.
- 메모리 갱신 시 stale 한 권고는 "RESOLVED in PR #X (date)" 로 명시. 갱신 시점의 사실로 덮어쓰면 다음 검증자가 같은 시간 낭비를 한다.

---

## 2026-05-14 — 안정화 sprint 는 risk profile 분리해 3+ PR 분할

**무엇을 배웠나**: Session 56 의 Stabilization Sprint 를 단일 PR 로 묶지 않고 risk profile 기준 3 PR 로 분할 (#39 인프라 + #40 semantic + #41 behavior). 각 PR 머지 후 다음 PR 의 baseline 이 명확했고, 회귀 추적·롤백 용이성이 확보됐다. PR 1 의 anti-pattern script 가 PR 2 의 sweep 결과를 ENFORCE 하는 layered 구조까지 가능.

**예방 규칙**:
- 안정화 / 리팩터링 sprint 는 변경의 risk profile 로 PR 을 나눈다: 인프라(CI/script) / semantic(catch type, error mapping) / behavior(데이터 흐름).
- 같은 PR 안에 risk profile 이 다른 변경을 묶지 말 것 — 회귀 발생 시 어느 변경이 원인인지 추적 비용 큼.
- PR 간 의존성 (`addBlockedBy`) 을 TaskCreate 단계에서 명시. 사용자가 수동 머지하는 환경에서도 머지 순서 보장.

---

## 2026-04-12 — Stage 1 사전 검증이 플랜 방향을 바꾼다

**무엇을 배웠나**: Wave 1 보안 리뷰가 도출한 6개 이슈에 대해 Stage 1(Research) 진입 전, 보고서의 "Unverified assumptions" 5건을 코드/SDK 소스/`gh api`로 직접 검증했더니 **3개 이슈의 픽스 방향이 달라졌다.**

**구체 사례**:
1. **P1-C (userDeleted 이벤트 미처리)**: 사전 검증으로 `gotrue-2.18.0/lib/src/constants.dart`에서 `userDeleted('')`가 `@Deprecated` + 빈 `jsName`임을 확인. 추가 분기를 넣는 것이 **완전 무의미**(영원히 false)임을 알아냄. 대신 `userUpdated` 분기 추가 + 주석 정합성 수정으로 방향 전환.
2. **P2-A (AndroidManifest allowBackup)**: `storage_service.dart`가 이미 `HiveAesCipher`로 모든 박스를 암호화하고 있음을 확인. 위험도가 "실질 데이터 유출"에서 "defense-in-depth baseline"으로 재평가되어 플랜의 긴급도가 조정됨.
3. **P2-B (CI gating)**: 보고서는 "`security` job을 required checks에 등록해야 실효성 있음"이라고 기술했으나, `gh api`로 확인해보니 `main`에 **보호 규칙 자체가 전무** (404). 원 픽스 범위의 2배 규모 작업으로 재스코핑됨.

**근본 원인**: 리뷰 보고서가 "Unverified"로 명시한 가정을 검증 없이 Stage 2로 넘어갔다면, Stage 4(구현) 중에 "코드 추가했는데 동작 안 함", "픽스했는데 실질 강제력 없음" 같은 블로커 발생 후 Stage 1 복귀 필요.

**예방 규칙**:
- 코드 리뷰 보고서를 입력으로 받는 Stage 1 세션은 **Unverified assumptions를 맨 먼저 검증**한다. 검증 전에 리서치.md를 쓰지 않는다.
- 검증 가능한 가정(SDK enum, `gh api`, 파일 존재 여부, 설정 값)은 즉시 확인. 사용자 확인이 필요한 가정(Dashboard 설정, 권한)은 AskUserQuestion으로 묶음 질의.
- 검증 결과는 리서치.md의 맨 앞 섹션 "사전 확인 결과"로 박아 후속 단계 전체가 그 결과를 참조하게 한다.

---

## 2026-04-12 — P3-A proguard Hive keep rules: YAGNI, 보류

**무엇을 배웠나**: Wave 1 리뷰의 P3-A(선제 Hive keep rules)는 현재 `Map<dynamic, dynamic>` 박스만 사용하는 구조에서 **즉시 위험이 없다.** 미래에 `@HiveType` 모델 클래스 도입 시에만 R8 minification 위험이 생긴다.

**결정**: 본 스프린트에서 제외. 향후 `@HiveType` 도입 PR에서 함께 추가한다. 선제 추가는 YAGNI 위반.

**예방 규칙**:
- "미래 방어" 목적 픽스는 **트리거 조건이 코드에 실제로 등장하는 시점**까지 보류한다.
- Wave 1의 P3는 원칙적으로 지금 수정하지 않는 방향이 기본값. "Low confidence, 현재 코드 기준 미사용" 표기가 있으면 더욱 그렇다.

---

## 2026-04-12 — `failure_ui.dart` 하드코딩이 datasource 메시지를 삼키고 있었다

**무엇을 배웠나**: Wave 1 P1-B 플랜 작성 중 `lib/core/error/failure_ui.dart:30-35`의 `AuthFailure()` 분기가 **패턴의 message 필드를 완전히 무시하고** "다시 로그인해 주세요"를 하드코딩하는 것을 발견.

**영향**: `auth_remote_datasource.dart`의 `Failure.auth(message: e.message)` 호출들(signIn/signUp/signOut 전부)이 만든 정교한 Supabase 에러 메시지(e.g., "Invalid login credentials", "User already registered")가 전부 한 문자열로 덮어써지고 있었다. P1-B 픽스의 "이메일 확인 링크가 발송되었습니다" 메시지도 사용자에게 보이지 않을 것.

**근본 원인**: 친화적 한국어 UX와 raw Supabase 에러 메시지 사이의 트레이드오프 결정이 **message 필드 자체를 drop하는 방식**으로 이뤄졌음. 디버깅 어려움 + UX 정보 손실.

**예방 규칙**:
- `failure_ui.dart`의 각 `XxxFailure` 분기는 `message`를 반드시 surface하거나, 최소한 `isNotEmpty`일 때는 관통시킨다.
- 데이터소스에서 `Failure.auth(message: e.message)`를 호출하는 모든 경로는 해당 메시지가 UI에 **실제로 도달하는지** 수동 확인한다.
- 보안/리뷰 세션에서 "에러 처리 일관성"은 독립 dimension으로 추가 검토 가치 있음.

---

## 2026-05-11 — `dart format` 누락이 CI Analyze를 두 번째 떨어뜨림 (2회 재발)

**무엇을 배웠나**: PR #35 (harness Sprint-1 ReadingStats) 푸시 직후 CI **Analyze 잡이 `dart format --set-exit-if-changed` 단계에서 실패**. 원인은 신규 테스트 파일 2개가 dart format 결과와 다르게 작성됨. 동일한 실패 모드가 **Session 38 PR #18에서도 발생**했고 (`feedback_ci_dart_format.md`로 메모리에 기록되어 있었음) 그럼에도 이번에 다시 재현됨.

**구체 사례 (이번 PR #35)**:
- `test/features/reading_stats/data/datasource/reading_stats_local_datasource_test.dart` — 함수 시그니처 multi-param wrap 누락
- `test/features/reading_stats/domain/usecase/record_read_event_usecase_test.dart` — `test('...', () async {})` 인자 정렬 누락
- 로컬 `flutter analyze`는 통과 (analyze는 format 비검사) → 푸시 후 CI에서만 노출
- 4-evaluator harness 검증 단계 모두 통과시킨 코드여도 format 갭이 별개 layer에서 잔존

**근본 원인**: 메모리에 lesson은 있었으나 푸시 전 체크리스트에 **자동 강제 단계가 없음**. 인간/에이전트 모두 "analyze 통과 = format 통과"로 잘못 일반화하기 쉬움.

**예방 규칙 (강화)**:
1. **푸시 전 강제 시퀀스**: `dart format lib/ test/ && flutter analyze && flutter test` 를 **하나의 atomic 명령**으로 실행. 하나라도 빠지면 푸시 금지.
2. **Pre-push hook 도입 검토** (별도 작업): `.git/hooks/pre-push` 또는 husky 패턴으로 `dart format --set-exit-if-changed` 자동 실행 → 로컬에서 차단.
3. **Harness 파이프라인 게이트 추가 검토**: Generator Hand-off에 "`dart format --set-exit-if-changed lib/ test/` exit 0" 결정적 검증 항목 추가. 현재 harness deterministic_verifier에 `flutter analyze`는 있지만 `dart format`는 없음 → 같은 사각지대.
4. **메모리 → 자동화 승격**: lesson을 단순 메모리로만 두지 말고 **실행 시점에 강제되는 메커니즘**(hook / CI 사전 step / 에이전트 체크리스트 슬롯)으로 승격해야 재발 방지 효과 발생. "기록만 한 lesson"은 2번째 발생에 무력함.

**Action items 백로그**:
- [ ] `.git/hooks/pre-push` 추가 또는 `lefthook`/`pre-commit` 도입
- [ ] Harness Generator Hand-off 검증 항목에 `dart format` 추가 (`docs/harness-followups.md` cross-sprint patterns 섹션에 등록 검토)
- [ ] `feedback_ci_dart_format.md` 메모리 항목 갱신 — "강제 자동화 필요" 표기 추가
