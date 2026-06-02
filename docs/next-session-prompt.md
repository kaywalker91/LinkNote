# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요. 작성 기준일 2026-06-02 (Session 62 F4+F6a PR #52 squash 머지 직후, main `63598a5`).

---

```
Session 63 — 잔여 cleanup 거의 소진. 신규 기능 또는 인프라/검증 중 단일 트랙 (사용자 합의 선행)

## 미션 한 줄

Session 62에서 Track F4(empty-linkId 검증 선두 재배치) + Track F6a(RecordReadEventUsecase clock 주입 seam)가 PR #52 squash 머지(main `63598a5`)로 완료. F-series 잔여가 사실상 소진(F1/F2/F3/F4/F5/F6a/F9 해소, Track I 폐기)되어, Session 63은 **신규 기능** 또는 **인프라/검증 백로그** 중 사용자 우선순위에 따른 단일 트랙. 임의 트랙 창작 금지.

## 배경 (완료된 트랙 — 재작업 금지)

- **#52 `63598a5` (F4+F6a)**: ① F4 — `record_read_event_usecase.dart`에서 empty-linkId 검증을 timestamp/duration **앞으로** 재배치(most-fundamental-first). 단독 위반 동작 불변, 동시 위반 시 진단성 개선. ② F6a — 같은 usecase에 optional `now` clock seam(`DateTime Function()? now`, default `DateTime.now`, `const` 제거) 추가 → 결정론적 경계 테스트. 프로덕션 무영향(DI가 optional 인자 없이 생성). 테스트 577→580 GREEN.
- **#51 `9b9358b` (F5)**: 데이터 레이어 `on Object catch` fallback 29곳 raw 예외 → `appLogger` 이전 + message sanitize. anti-pattern Category C 가드 추가(A/B/C 셋 다 활성).
- **#50 `e433e66` (explicit_to_json)**: `build.yaml`에 `explicit_to_json: true` → nested toJson 정상 직렬화. 구 Track I 폐기 근거.
- **#49 `ba9e5c0` (F3)**: ReadingStats write-queue 누수 수정 + drain 테스트.
- **#48 `2aecc5f`**: notification/auth provider domain Failure 타입 보존 전파.
- **#46/#47 (Session 59/60)**: 컬렉션 visibility/lockedAt → 링크 read-model 비정규화(`CollectionVisibility` enum + `lockedAt`, CollectionRefDto, select join, migration_59.sql). pill 시각 회귀 golden(`ln_link_card_pills.png`). 정책: locked = 시각 표시 only.

## 작업 범위 — 후보 (Session 62 5-에이전트 감사 기반, 우선순위순)

> ⚠️ 잔여 cleanup이 거의 소진됨. 아래는 감사로 검증된 백로그. **신규 기능/인프라로 전환이 합리적** — 세션 시작 시 사용자 우선순위 합의.

### A. 신규 기능 후보
- **in-app visibility/lock 토글 UI** (M) — read-model(visibility/lockedAt)은 #46/#47로 이미 존재. 토글 신설 시 **link/search/Hive 캐시 invalidate AC 동반 필수**(보류됐던 invalidate 트랙이 이 토글과 함께 부활). 현재 in-app mutation 경로가 없어 stale-cache 트리거 자체가 없는 상태.
- **warm/foreground share bottom sheet** (S~M) — Phase 1 cold-start는 완료. `getMediaStream()` 구독 추가 + dirty-form 시 snackbar degrade.
- **share payload plain-text URL 추출** (S) — UrlSanitizer 3-layer 재사용, 실패 시 toast.
- **Collection 카드 Lock/Globe pill** (M) — `CollectionEntity`에 visibility 필드 추가 선결. Phase 5+.
- **iOS Share Extension (Phase 2)** (L) — PRD 3개 미결(Extension UI/save path/OG-meta) + 네이티브 Swift + App Groups + **릴리스 서명 인프라 선결**.

### B. 인프라/검증 백로그 (별도 세션 성격)
- **Android release keystore + key.properties** — 없으면 release가 debug.keystore 서명. 생성 후 per-flavor SHA-1 3개 GCP 등록.
- **Apple Developer 등록 + Team ID + Xcode 서명** — $99/yr, App ID 3개, `YOUR_TEAM_ID` placeholder 치환.
- **Release 실기기 smoke (40+)** — 위 두 인프라에 blocked.
- **Linux golden baseline 재생성 + CI `--exclude-tags golden` 제거** — macOS↔Linux Skia 0.5~0.7% 차이. 절차는 아래.
- **Phase 1 share-intent 실기기 share-sheet 검증** — APK 빌드됨, 실기기 흐름 + Session 19 "title+URL" 교훈 재확인 미완.
- **iOS Firebase(`GoogleService-Info.plist`) + flutterfire reconfigure** — iOS Crashlytics는 main.dart 주석 처리 상태.

### C. 보류 (설계 선행 — 저가치)
- **F6b** (`received_at` anti-tamper, M) — datasource가 caller timestamp 신뢰 → 사용자 시계 되돌리면 `lastReadAt` 무음 회귀. 스키마 변경 동반. 저가치.
- **F7** (O(n) read-aggregation perf, M) — 같은-Hive-entry 집계는 반쪽 fix(쓰기 여전히 O(n), box open 시 거대 events 디코드). **aggregate 별도 key/box 분리 또는 events 저장 구조 재설계 선행**. 1000+ events/link 전까진 benign → HOLD.

> ⚠️ 감사 오탐 기록: "DateRangePicker 실제 크래시"는 **오탐**(Session 62 검증). `lib/app/app.dart:14`에 `GlobalMaterialLocalizations.delegate` 이미 등록 → `showDateRangePicker` 정상. 재조사 불필요.

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote
git status                                    # wrap 문서(daily log×2 + next-session-prompt)가 main에 로컬 커밋되어 있을 수 있음
git switch main && git pull --ff-only         # 작성 시점 63598a5
flutter --version                             # 작성 시점 3.41.4

git switch -c <feat/...|sprint-N/...|harness/...>   # 이 브랜치에 이전 wrap 문서 커밋이 자연 동봉됨

# 푸시 전 강제 시퀀스
ls .env.dev .env.staging .env.prod            # codegen 필요 시 존재 확인(없으면 envied 실패)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 생성기 영향 있을 때만. SDK 노이즈만 git restore
dart format --set-exit-if-changed lib/ test/
bash tool/check_anti_patterns.sh              # A/B/C PASS
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only --exclude-tags golden   # 580 GREEN (2026-06-02 실측, 로컬 smoke)
git push -u origin <branch>                   # push 는 사용자 승인 후
gh pr create --base main --title "..." --body "..."
```

> ⚠️ CI parity: 로컬은 `--exclude-tags golden` smoke만, CI Test job은 golden 포함. golden 변경 시 PR CI로 최종 확인. (#52는 4-job 전부 green 확인됨)

## golden 재생성 절차 (실증, Session 60)

`regenerate-goldens.yml`(workflow_dispatch)은 artifact 업로드만, 브랜치 커밋 안 함:
1. feature 브랜치 push
2. `gh workflow run regenerate-goldens.yml --ref <branch>`
3. `gh run download <run-id> -n goldens-ci-linux -D /tmp/golden-...`
4. 기존 PNG `cmp -s` byte 무변경 확인 후 신규만 `test/shared/widgets/ln/golden/goldens/ci/` 복사 → 커밋
- ⚠️ macOS 로컬 `--update-goldens` 금지 (역방향 Skia diff).

## 미커밋/대기 항목

- **wrap 문서 3건**(`docs/daily_task_log/2026-06-02_session.md`, `2026-05-28_session.md`, `docs/next-session-prompt.md`)이 main에 로컬 커밋됨(또는 working tree). **푸시 보류** 상태 — 다음 코드 PR에 동봉(docs-only-PR 금지).

## 알려진 인접 이슈 (별도 세션)

- **dev/staging Supabase URL DNS 실패** — 실기기 빌드 시 반복(`jzcduhgatmbobevxjdhy.supabase.co` lookup 실패). 환경/Supabase 설정 문제 추정(앱코드 아님).
- **Supabase RLS / FK 점검** — visibility=private non-owner read 차단 여부. dashboard 액세스 필요.
- **`StatefulShellRoute.indexedStack` 탭 전환 `logScreenView`** — `app_router.dart` NOTE 주석, 별도 세션.
```
