# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요. 작성 기준일 2026-06-20 (Session 64 RLS/문서 PR 직전, main `e0cc432` = #54 visibility 토글 squash 머지 직후).

---

```
Session 65 — F-series 소진. 신규 기능 또는 인프라/검증 중 단일 트랙 (사용자 합의 선행)

## 미션 한 줄

F-series 잔여가 소진됐고 Session 63(in-app visibility/lock 토글)·Session 64(visibility RLS 의미 명문화)까지 완료. Session 65는 **신규 기능** 또는 **인프라/검증 백로그** 중 사용자 우선순위에 따른 단일 트랙. 임의 트랙 창작 금지.

## 배경 (완료된 트랙 — 재작업 금지)

- **Session 64 (RLS + Collection pill PR)**: ① `scripts/migration_63_visibility_rls.sql` 신설 + `docs/security/rls-policies.md`에 "visibility 컬럼과 RLS" 섹션 추가. 결정: 컬렉션은 **strictly owner-only** 유지 → `private`는 이미 강제됨(비소유자는 visibility 무관 read 불가), `public`은 **백엔드 무효과**(pill·토글 표시용)로 의도된 설계. `public` 비소유자 read 허용은 공유/공개 뷰 기능 구현 시 별도 결정. ⚠️ 라이브 DB enable 검증은 대시보드 액세스 blocked. ② `LnCollectionCard`에 visibility/lock pill 추가(LnLinkCard 패턴·색 토큰 재사용, Globe=public·Lock=lockedAt). no-pill 시 `_CountRow`가 bare caption 렌더 → 기존 `ln_collection_card.png` golden byte-불변 확인, 신규 `ln_collection_card_pills.png` baseline은 CI Linux regen. pill = 시각 마커 only. 604→608 GREEN. 직전 wrap 문서 동봉.
- **#54 `e0cc432` (Session 63, visibility 토글)**: CollectionDetail 화면 in-app visibility/lock `SwitchListTile` 2개 + 전용 변경 경로(Option B — `toVisibilityUpdateJson`/`updateCollectionVisibility` usecase·repo·datasource). optimistic update + 실패 시 rollback·rethrow, 무변경 no-op. 토글 시 link/search/Hive 캐시 invalidate AC 동반(보류됐던 invalidate 트랙 부활·해소). 정책: lock = 시각 마커 only(접근 제어는 RLS). 580→604 GREEN.
- **#53 `821b516` (golden 전략 전환)**: `_TolerantGoldenFileComparator`(로컬 ≤1.5% Skia 노이즈 허용, 실측 max 0.88%; CI `CI=true`는 pixel-exact 유지) 도입 → **로컬 full suite가 `--exclude-tags golden` 없이 통과**. per-developer real-font 플랫폼 골든은 폐기(gitignore·드리프트), tracked `ci/` baseline만 비교. (구 "Linux golden baseline 재생성" 백로그 항목 해소.)
- **#52 `63598a5` (F4+F6a)**: record_read_event_usecase empty-linkId 검증 선두 재배치 + optional `now` clock seam.
- **#51 `9b9358b` (F5)**: 데이터 레이어 `on Object catch` raw 예외 → `appLogger` 이전 + sanitize. anti-pattern Category C 가드.
- **#50 `e433e66`**: `build.yaml` `explicit_to_json: true`. 구 Track I 폐기 근거.
- **#46/#47 (Session 59/60)**: 컬렉션 visibility/lockedAt → 링크 read-model 비정규화(`CollectionVisibility` enum, CollectionRefDto, select join, migration_59.sql). pill golden.

## 작업 범위 — 후보 (우선순위순)

> ⚠️ 잔여 cleanup 소진. 아래는 감사로 검증된 백로그. **신규 기능/인프라로 전환이 합리적** — 세션 시작 시 사용자 우선순위 합의.

### A. 신규 기능 후보
- **warm/foreground share bottom sheet** (S~M) — Phase 1 cold-start 완료. `getMediaStream()` 구독 추가 + dirty-form 시 snackbar degrade.
- **share payload plain-text URL 추출** (S) — UrlSanitizer 3-layer 재사용, 실패 시 toast.
- **public/공유 뷰 + visibility-aware RLS** (M~L) — Session 64에서 의도적으로 보류한 트랙. SELECT 정책 `OR visibility='public'` + 클라이언트 공개 read 경로 + 공유 UI. **데이터 노출 신설**이므로 설계·보안 AC 선행 필수.
- **iOS Share Extension (Phase 2)** (L) — PRD 3개 미결 + 네이티브 Swift + App Groups + **릴리스 서명 인프라 선결**.

### B. 인프라/검증 백로그 (별도 세션 성격)
- **Supabase RLS 라이브 enable 검증** — migration_63 SQL은 작성됨. 대시보드에서 `collections`/`links` RLS enabled + owner-only SELECT 적용 여부 확인 + 비소유자 세션 empty-result 테스트. **대시보드 액세스 blocked**.
- **Android release keystore + key.properties** — 없으면 release가 debug.keystore 서명. 생성 후 per-flavor SHA-1 3개 GCP 등록.
- **Apple Developer 등록 + Team ID + Xcode 서명** — $99/yr, App ID 3개, `YOUR_TEAM_ID` 치환.
- **Release 실기기 smoke (40+)** — 위 두 인프라에 blocked.
- **Phase 1 share-intent 실기기 share-sheet 검증** — APK 빌드됨, 실기기 흐름 + Session 19 "title+URL" 교훈 재확인 미완.
- **iOS Firebase(`GoogleService-Info.plist`) + flutterfire reconfigure** — iOS Crashlytics는 main.dart 주석 처리 상태.

### C. 보류 (설계 선행 — 저가치)
- **F6b** (`received_at` anti-tamper, M) — datasource가 caller timestamp 신뢰 → 사용자 시계 되돌리면 `lastReadAt` 무음 회귀. 스키마 변경 동반. 저가치.
- **F7** (O(n) read-aggregation perf, M) — aggregate 별도 key/box 분리 또는 events 저장 구조 재설계 선행. 1000+ events/link 전까진 benign → HOLD.

> ⚠️ 감사 오탐 기록: "DateRangePicker 실제 크래시"는 **오탐**(Session 62 검증). `lib/app/app.dart:14`에 `GlobalMaterialLocalizations.delegate` 이미 등록 → `showDateRangePicker` 정상. 재조사 불필요.

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote
git status
git switch main && git pull --ff-only         # 작성 시점 e0cc432
flutter --version                             # 작성 시점 3.41.4

git switch -c <feat/...|sprint-N/...|harness/...>   # 이 브랜치에 이전 wrap 문서 커밋이 자연 동봉됨

# 푸시 전 강제 시퀀스
ls .env.dev .env.staging .env.prod            # codegen 필요 시 존재 확인(없으면 envied 실패)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 생성기 영향 있을 때만. SDK 노이즈만 git restore
dart format --set-exit-if-changed lib/ test/
bash tool/check_anti_patterns.sh              # A/B/C PASS
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 608 GREEN (2026-06-20 실측, 골든 포함 — #53 이후 --exclude-tags golden 불필요)
git push -u origin <branch>                   # push 는 사용자 승인 후
gh pr create --base main --title "..." --body "..."
```

> ⚠️ CI parity: #53 이후 로컬도 골든 포함 통과(로컬 ≤1.5% tolerance). CI(`CI=true`)는 pixel-exact 회귀 게이트 유지. golden 변경 시 PR CI로 최종 확인.

## golden 재생성 절차 (실증, Session 60 — 여전히 유효)

`regenerate-goldens.yml`(workflow_dispatch)은 artifact 업로드만, 브랜치 커밋 안 함:
1. feature 브랜치 push
2. `gh workflow run regenerate-goldens.yml --ref <branch>`
3. `gh run download <run-id> -n goldens-ci-linux -D /tmp/golden-...`
4. 기존 PNG `cmp -s` byte 무변경 확인 후 신규만 `test/shared/widgets/ln/golden/goldens/ci/` 복사 → 커밋
- ⚠️ macOS 로컬 `--update-goldens` 금지 (역방향 Skia diff). 로컬은 #53 tolerance 로 비교만.

## 미커밋/대기 항목

- 없음. Session 64 RLS PR이 직전 wrap 문서를 동봉해 머지되면 클린.

## 알려진 인접 이슈 (별도 세션)

- **dev/staging Supabase URL DNS 실패** — 실기기 빌드 시 반복(`jzcduhgatmbobevxjdhy.supabase.co` lookup 실패). 환경/Supabase 설정 문제 추정(앱코드 아님).
- **Supabase RLS 라이브 enable 검증** — migration_63 SQL·rls-policies.md 작성 완료. 실DB 적용·검증은 대시보드 액세스 필요(blocked). private는 owner-only RLS가 enable 되어 있다는 전제 하에 강제됨.
- **`StatefulShellRoute.indexedStack` 탭 전환 `logScreenView`** — `app_router.dart` NOTE 주석, 별도 세션.
```
