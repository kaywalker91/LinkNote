# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요. 작성 기준일 2026-05-28 (Session 60 + 후속 #48·#49·#50 머지 후, main `ba9e5c0`). Codex(gpt-5.5)/agy 교차 리뷰로 stale 항목 정정 반영.

---

```
Session 61 — Track F5 (Failure.message sanitization + grep-feasible Cat C) / Track F7 (ReadingStats perf gate, 보류) 중 단일 트랙

## 미션 한 줄

Session 60 Track L-a/L-b 가 PR #47(`31febc9`) 머지 후, 후속 #50/#48/#49 가 추가 머지되어 현재 main 은 `ba9e5c0`. 이 후속 3건이 구 Track I 와 F3 를 이미 해소(아래 "완료" 참조). Session 61 은 사용자 합의 후 단일 트랙 — 실재 잔여 결함인 **F5** 를 1순위로 권장.

## 배경 (완료된 트랙 — 재작업 금지)

- **#50 `e433e66` (explicit_to_json)**: 루트 `build.yaml:12` 에 `explicit_to_json: true` 추가 → `LinkEntity.tags`/`LinkDto.linkTags·collections`/`CollectionDto.links` 의 `.g.dart` toJson 이 nested `.toJson()` 재귀 방출로 갱신. `LinkLocalDataSource` 의 수동 boundary workaround 제거. **→ 구 Track I 의 "실위반 baseline" 소멸.**
- **#49 `ba9e5c0` (F3)**: ReadingStats write-queue 누수 수정 — tracked future identity 정합(`reading_stats_local_datasource.dart:45`) + drain 테스트(`pendingWriteCount`). **→ F3 해소(잔여 목록에서 제거).** (F3 는 "dead code" 가 아니라 활성 직렬화 큐의 메모리 누수였음 — 구 표기 정정)
- **#48 `2aecc5f` (Failure 타입 전파)**: notification_list/auth provider 가 raw Exception/String 대신 domain `Failure` 를 `Error.throwWithStackTrace(result.failure!)` / `AsyncError(result.failure!)` 로 전파. **F5 의 message sanitization 과는 별개 이슈 — F5 는 여전히 열림.**
- **Track I — 폐기 (재제안 금지)**: 후보였던 "freezed nested toJson `explicitToJson` 누락 grep 검출"은 #50 커밋이 *"생성물의 primitive 필드(`'id': instance.id`)와 nested object 를 grep 으로 구별 불가 → 스크립트 검출 infeasible, build 설정 자체가 가드레일"* 이라고 명시. 전제(실위반)와 메커니즘(grep)이 모두 부정됨. (grep-feasible 한 다른 Cat C 후보는 Track F5 참조.)
- **Session 60 (PR #47)**: Track L-a — `test/shared/widgets/ln/golden/ln_cards_golden_test.dart` 에 public(Globe)/locked(Lock)×light/dark 4 시나리오 + 새 golden `ln_link_card_pills.png`(Linux CI 재생성). base 픽스처가 private+unlocked 라 pill 미렌더였던 갭 마감. Track L-b — `.gitignore` 에 `test/**/failures/**/*.*`.
- **Session 59 (PR #46)**: 컬렉션 visibility/lockedAt → 링크 read-model 비정규화. `CollectionVisibility{public,private}` enum + `lockedAt`, CollectionRefDto + LinkEntity flat 필드, `link`/`search` select join `collections(name, visibility, locked_at)`, migration_59.sql. `toInsertJson`/`toUpdateJson` 의도적 미변경(AC-5, PostgREST 400 회피). 정책: locked = 시각 표시 only(접근 제어 아님). 하위호환: 키 누락→private/null, 미지 enum→private.
- **Session 58 (PR #43~45)**: Track D(Linux golden baseline 재생성 + CI golden 게이트 복원), Track H(다크 모드 화면 검증).

## golden 재생성 절차 (실증, Session 60)

`regenerate-goldens.yml`(workflow_dispatch)은 **artifact 업로드만, 브랜치 커밋 안 함**:
1. feature 브랜치 push
2. `gh workflow run regenerate-goldens.yml --ref <branch>`
3. `gh run download <run-id> -n goldens-ci-linux -D /tmp/golden-$(date +%s)`
4. 기존 PNG `cmp -s` 로 byte 무변경 확인 후 신규만 `test/shared/widgets/ln/golden/goldens/ci/` 복사 → 커밋
- ⚠️ macOS 로컬 `--update-goldens` 금지 (역방향 Skia diff).

## 작업 범위 — 후보 트랙

### Track F5 — Failure.message raw `$e` sanitization (+ grep-feasible Cat C 가드) ★1순위
- 규모: 중(범위 결정에 따라 5~25파일). 의존: 없음.
- 실태(검증 2026-05-28): `reading_stats_repository_impl.dart:24,37` + notification/auth/link/collection/search/profile 데이터소스 **~25곳**이 `Failure.X(message: e.toString())` / `'...: $e'` 로 raw exception 임베드. `failure_ui.dart` 가 대부분 고정 메시지로 매핑하나 `UnknownFailure(:message)` 경로는 UI 노출 가능 → minor info-leak(HiveError 의 box 이름/key path 등).
- **범위 결정 필요(AC)**: ReadingStats 한정 vs 전 25곳 일반화. 일반화 시 5+파일 → elegance gate 적용.
- **Cat C 가드 번들**: toJson 과 달리 `Failure(message: e.toString())` 는 **grep 검출 가능** → `tool/check_anti_patterns.sh`(현재 Cat A/B 만 실행, `:95`)에 Category C(sanitize 안 된 raw-$e Failure 메시지 FAIL) 추가하여 회귀 차단. 실해소 1건과 묶으면 "script 단독 PR 금지" 규칙 자연 충족.
- 해소 패턴: `_sanitize(e.toString())` helper 또는 exception type 별 고정 메시지 카탈로그.

### Track F7 — O(n) read-aggregation perf gate (보류 — 설계 재정의 선행)
- 규모: 소~중. 의존: Sprint-1 datasource 변경(`forbidden_files` 정책 재확인).
- 전제(유효): Hive entry 가 `{events}` 만 저장(`reading_stats_local_datasource.dart:80`)하고 `getStats` 가 매번 events 전체 walk(`:93-116`). `ReadingStatsEntity.lastReadAt` 는 이미 존재(entity:14).
- **⚠️ 설계 재정의 필요 (Codex 리뷰)**: 초안의 `{events, totalReads, lastReadAt}` 같은-entry 저장은 **반쪽 fix**. `_box`(일반 Box) 기준 `getStats` 의 실비용은 Dart 루프(`DateTime.parse × n`)라 집계 캐시로 루프는 제거되나, **쓰기 경로(`_doRecord`)가 매번 events 전체를 다시 `put` → O(n)·무한증가**, **박스 open 시 거대 events 리스트 디코드**는 그대로 남음. 성능이 목표면 **aggregate 를 별도 key/box 로 분리**하거나 events 저장 구조 자체를 재설계해야 perf 목표가 명확해짐.
- 구현 시 보존: out-of-order event 의 `max(timestamp)` semantics(테스트 `reading_stats_local_datasource_test.dart:126` 가 고정). legacy `{events}`-only 데이터 backfill + 안전성 unit test 명시.
- 검증: 500+ events/link 시뮬레이션 + Hive read/write 시간 측정.
- 현실성: 1000+ events/link 도달 전까진 benign. **보류 권장.**

### Track F4 — usecase 검증 순서 정리 (cosmetic, low)
- `record_read_event_usecase.dart:15-16` 검증 순서 [future timestamp → negative duration → empty linkId]. 셋 다 동시 위반 입력은 첫 매칭만 반환. empty linkId 선두 재배치 제안. 단독 가치 낮음 — F5 곁다리로만.

### (보류/speculative) visibility-toggle 캐시 invalidate 트랙
- in-app visibility/lock mutation 경로가 없어 stale-cache 트리거 자체가 없음. in-app toggle UI 가 생기는 별도 트랙에서 link/search/Hive 캐시 invalidate AC 와 함께 부활.

**기본 추천**:
- 우선순위 1: **Track F5** — 실재 잔여 결함, minor 보안성, grep-feasible Cat C 가드와 번들 가능
- 우선순위 2: **Track F7** — 보류(설계 재정의 선행, 현 규모 benign)

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote
git status                                    # clean 먼저 (dirty 면 정리 후 switch)
git switch main && git pull --ff-only         # 작성 시점 ba9e5c0
flutter --version                             # 작성 시점 3.41.4

# Track 선택 후 새 브랜치
git switch -c <feat/...|sprint-N/...|harness/...>

# 푸시 전 강제 시퀀스
ls .env.dev .env.staging .env.prod            # (clean 체크아웃이면) 존재 확인 — 없으면 envied codegen 실패. 기존 머신 재개면 보통 존재
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 산출물 커밋. SDK 노이즈(.g.dart/pubspec.lock)만 git restore
dart format --set-exit-if-changed lib/ test/  # clean
bash tool/check_anti_patterns.sh              # PASS (현재 Cat A/B; F5 트랙이면 Cat C 추가)
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only --exclude-tags golden   # 572+ GREEN floor(#48·#49·#50 으로 증가; 정확 수치는 로컬 실행 확인)
# 넷 다 통과 후에만 push

git push -u origin <branch>
gh pr create --base main --title "..." --body "..."
```

> ⚠️ CI parity: 로컬은 `--exclude-tags golden` smoke 만, CI Test job 은 `flutter test --coverage` 라 **golden 포함**. golden 변경 시 반드시 PR CI 로 최종 확인.

## 알려진 인접 이슈 (별도 세션)

- **dev/staging Supabase URL DNS 실패** — 실기기 빌드 시 반복 (`jzcduhgatmbobevxjdhy.supabase.co` lookup 실패).
- **Supabase RLS / FK 점검** — visibility=private non-owner read 차단 여부(Track L D2 연관), dashboard 별도 트랙
- **`StatefulShellRoute.indexedStack` 탭 전환 `logScreenView`** — `app_router.dart` NOTE 주석, 별도 세션
- **잔여 F-series**: F4(ordering cosmetic → **Track F4**) / F5(Failure.message raw $e → **Track F5 로 승격**) / F6(clock regression, 연기). (F3=#49 해소, F9=Session 60 L-b 해소)
```
