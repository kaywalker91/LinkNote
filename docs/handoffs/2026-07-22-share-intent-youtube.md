# Handoff — YouTube Share Intent URL 미유입 (Android)

> **작성일**: 2026-07-22  
> **상태**: ✅ **RESOLVED (근본 원인 확정 · 수정 · 실기기 폼 오픈+저장 확인)**  
> **우선순위**: P0 (공유 핵심 가치 경로)  
> **플랫폼**: Android prod 내부테스트 (`app.kaywalker.linknote`)  
> **관련 PRD**: `docs/prds/share-intent.md` (v2.1, Phase A 코드 대부분 완료 · 실기기 DoD 미닫힘)

---

## 🎯 RESOLUTION (2026-07-22)

**근본 원인은 URL 추출이 아니라 `GoRouter` redirect의 부수효과 race였다.** 진단 계측 빌드로 확보한 실기기 payload가 `resolvedUrl`까지 정상임을 보여줬고(플러그인이 URL을 직접 전달, `hasStream:false`, ClipData 가설 A/E 모두 무관), 실패 지점이 라우터 소비 단계임을 확정.

- redirect가 `pendingSharedUrlProvider.consume()`로 상태를 변이 → auth 확정 시 `refreshListenable` 다중 펄스(`listenSelf`+`scheduleMicrotask`+`onAuthStateChange`)로 splash에서 redirect가 여러 번 평가 → 1차 패스가 소비하고 `/links/new` 반환해도 후속 패스가 `null`을 보고 `home`으로 떨어뜨림.
- **수정**: redirect 순수화(소비 제거) + `LinkAddScreen` 도착 시점 소비 이관 + 저장 후 `canPop()?pop():go(home)` + cold-start 폴백 도달성 게이트 + 설정 버전 하드코딩 제거.
- 진단 계측(`debug/`, ShareDebugOverlay 등)은 원인 확정 후 제거. ClipData/EXTRA_TEXT 폴백은 방어로 유지.
- 상세: `CHANGELOG.md` [Unreleased] · PR (fix/share-intent-youtube).

아래 원본 조사 내용은 기록용으로 보존한다.

---

## 1. 한 줄 요약

**로그인된 상태에서 YouTube → 공유 → LinkNote 선택 시 앱은 포그라운드로 오지만, 공유 URL이 링크 추가 폼에 채워지지 않고 링크도 생성되지 않는다.**  
Chrome/X 재현 여부는 미확인. 자동 저장은 제품 비목표(수동 저장)이며, 정상 기대는 **prefill 된 링크 추가 화면 오픈**이다.

---

## 2. 사용자 보고 (재현 조건)

| 항목 | 내용 |
|---|---|
| 계정 상태 | 로그인됨 |
| 소스 앱 | YouTube |
| 동작 | 공유 시트에서 LinkNote 선택 |
| 결과 | LinkNote로 전환됨 |
| 실패 | 공유 URL로 링크 추가 화면/저장 흐름이 이어지지 않음 |
| 재시도 | Phase A(+5) 및 YouTube EXTRA_TEXT 폴백(+6) 업로드 후에도 **동일 증상** |
| 케이블 | 없음 → Play 내부테스트로만 검증 |

**기대 UX (PRD)**  
공유 → (로그인됨) → `/links/new?prefill=<url>` → OG 자동 조회 → 사용자 `저장` → 링크 생성.

**현재 추정 UX**  
공유 → 앱 포그라운드(홈 등) → URL/pending 없음 → 폼 미오픈.

---

## 3. 제품/기술 맥락 (이미 구현된 것)

### 3.1 파이프라인 (의도)

```text
Android ACTION_SEND text/plain
  → receive_sharing_intent (plugin)
  → cold: bootstrap getInitialMedia + PendingSharedUrl + GoRouter splash redirect
     warm: getMediaStream + ShareIntentListener
  → SharePayloadResolver (plugin path → EXTRA_TEXT fallback)
  → /links/new?prefill=...
  → LinkAddScreen seed + parseOgTags(fromShare: true)
  → 사용자 저장
```

### 3.2 Phase A에서 이미 넣은 것 (코드, 대부분 미커밋)

| 영역 | 내용 | 파일 |
|---|---|---|
| OG 자동 조회 | prefill 시 1회 + 빈 필드 merge + host fallback | `link_add_screen.dart`, `link_form_provider.dart` |
| warm 미로그인 | `WarmShareAction.deferUntilAuthenticated` + `PendingSharedUrl` | `share_intent_listener.dart` |
| scheme | http/https only | `url_sanitizer.dart` |
| 문구 | 한국어 스낵바/검증 | listener, form |
| Analytics | share funnel (raw URL 비수집) | `analytics_service.dart`, bootstrap |
| YouTube 가설 대응 | EXTRA_TEXT MethodChannel 폴백 | `MainActivity.kt`, `android_share_extras.dart`, `share_payload_resolver.dart` |
| 테스트 | share_intent 유닛/위젯 45 green (로컬) | `test/features/share_intent/**` |

### 3.3 내부테스트 빌드

| versionCode | 내용 | 실기기 결과 |
|---|---|---|
| **+5** (`1.1.6+5`) | Phase A (OG/pending/analytics 등), EXTRA_TEXT 폴백 **없음** | YouTube 공유 실패 보고 |
| **+6** (`1.1.6+6`) | + YouTube EXTRA_TEXT/SUBJECT 폴백 + `onNewIntent#setIntent` | **동일 증상** (사용자 확인) |

- AAB 경로: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
- +6 SHA-256 (참고): `05a5e33a9d58355ddc90a9e5c35813b02405f54e539c98efcc46a606870827e7`
- **워킹 트리 미커밋** (main 대비 dirty). 핸드오프 시점 `pubspec`: `1.1.6+6`

---

## 4. 1차 가설과 대응 결과

### 가설 A — YouTube가 EXTRA_STREAM(썸네일) + EXTRA_TEXT(URL)를 함께 보냄

- **근거**: `receive_sharing_intent` Android 플러그인이 `path = filePath ?: text` 로 STREAM을 우선.
  - 패키지: `receive_sharing_intent 1.8.1`
  - 원본: `.../android/.../ReceiveSharingIntentPlugin.kt` → `toJsonObject`
- **대응**: `MainActivity` MethodChannel `app.kaywalker.linknote/share` → `getShareExtras`  
  Dart `SharePayloadResolver`: plugin path에서 URL 실패 시 EXTRA_TEXT/SUBJECT/HTML 폴백.
- **실기기 결과**: **여전히 실패** → 가설 A만으로는 설명 부족, 또는 폴백이 런타임에 동작하지 않음.

### 가설 B — cold start에서 MethodChannel이 boot 시점에 실패

- bootstrap은 `runApp` **이전**에 `SharePayloadResolver().resolveUrl` 호출.
- `AndroidShareExtrasReader`는 예외 시 `null` 반환(삼킴) → pending 미설정 → splash 후 home.
- **미검증**: 내부테스트 release에서 channel 실패 여부 로그 없음.

### 가설 C — warm 경로 이벤트 유실

- `launchMode=singleTop`. plugin `NewIntentListener` + MainActivity `setIntent`는 +6에 추가.
- stream 구독 전 이벤트 / sink null 시 유실 가능.
- **미검증**: cold vs warm 구분 사용자 보고 없음.

### 가설 D — pending 설정됐지만 router가 소비하지 않음

- pending consume 위치: **인증 완료 + (splash | login | signup)** 일 때만  
  (`app_router.dart` redirect).
- cold + 로그인: splash → pending 있으면 `/links/new?prefill=` 이어야 함.
- pending이 null이면 home만. URL 추출 실패와 동일 증상.

### 가설 E — YouTube가 EXTRA_TEXT가 아닌 ClipData / 다른 MIME에 URL을 실음

- 현재 네이티브는 `EXTRA_TEXT` / `EXTRA_SUBJECT` / `EXTRA_HTML_TEXT`만 읽음.
- **ClipData item text/uri 미처리** → 다음 세션 최우선 조사 후보.

### 가설 F — 내부테스트 업데이트 미반영 / 구 빌드

- Play 전파 지연, 테스터 계정 불일치, versionCode 미갱신 UI.
- 사용자에게 +6 업데이트 요청했으나 “동일 증상” 회신 → 가능하나 **코드 버그 가정 유지**.

### 가설 G — 사용자는 “자동 생성”을 기대해 폼 오픈을 못 본 것

- 제품은 수동 저장. 다만 “이동만 됨” 표현은 **폼 미오픈**에 가깝다.
- 핸드오프 재현 시 **폼 오픈 여부**와 **스낵바 문구**를 분리 확인 필요.

---

## 5. 핵심 코드 맵

| 역할 | 경로 |
|---|---|
| Manifest SEND filter | `android/app/src/main/AndroidManifest.xml` (`text/plain`, singleTop) |
| 네이티브 extras | `android/app/src/main/kotlin/app/kaywalker/linknote/MainActivity.kt` |
| cold read + pending seed | `lib/bootstrap.dart` |
| warm stream listener | `lib/features/share_intent/presentation/widget/share_intent_listener.dart` |
| stream provider | `.../provider/shared_media_stream_provider.dart` |
| pending one-shot | `.../provider/pending_shared_url_provider.dart` |
| URL extract | `.../domain/service/shared_intent_service.dart` |
| path + extras resolve | `.../domain/service/share_payload_resolver.dart` |
| extras reader | `.../data/android_share_extras.dart` |
| sanitizer | `lib/shared/utils/url_sanitizer.dart` |
| router consume | `lib/app/router/app_router.dart` (splash/login redirect) |
| prefill + OG | `lib/features/link/presentation/screens/link_add_screen.dart` |
| PRD | `docs/prds/share-intent.md` |
| 플러그인 원본 | `~/.pub-cache/hosted/pub.dev/receive_sharing_intent-1.8.1/android/.../ReceiveSharingIntentPlugin.kt` |

---

## 6. 다음 세션 권장 작업 순서 (디버그 우선)

> 추측 수정 금지. **실기기 raw payload 확보**가 1순위.

### Step 0 — 재현 메타 확인 (5분)

- [ ] Play 앱 정보에서 versionCode **6** 이상인지 확인
- [ ] cold (강제 종료 후 공유) / warm (백그라운드 유지 후 공유) 각각 1회
- [ ] 증상 세분화:
  - (a) 홈만 열림
  - (b) 폼은 열리는데 URL 빈칸
  - (c) URL 채워지나 저장 실패
  - (d) 스낵바 `공유 내용에서 저장할 링크를 찾지 못했어요.` 여부
- [ ] Chrome / X 동일 재현 여부

### Step 1 — raw intent 가시화 (필수)

내부테스트는 케이블 없이 검증 중이므로 **UI 디버그 패널 또는 1회성 스낵바/다이얼로그** 권장:

네이티브 `getShareExtras` 확장 필드 예시:

```text
action, type, text, subject, htmlText,
hasStream (EXTRA_STREAM != null),
clipItemCount,
clip0Text, clip0Uri,
pluginPath (Dart 쪽 media.first.path),
resolvedUrl, branch (cold|warm)
```

- cold: bootstrap 직후 1회 dialog (dev/staging 또는 Remote Config 플래그)
- warm: ShareIntentListener failure/success 시 동일

또는 USB 가능 시:

```bash
adb logcat | grep -E 'Share|ReceiveSharing|linknote/share'
```

### Step 2 — ClipData / EXTRA_STREAM 동시 처리

`MainActivity.readShareExtras`에 추가:

- `intent.clipData` 각 item의 `text` / `uri`
- STREAM이 있어도 **text 후보를 항상 extras에 포함** (이미 text 필드는 있음 — null인지 확인이 핵심)
- YouTube가 text를 ClipData에만 넣는 경우 폴백

### Step 3 — boot 시점 MethodChannel 타이밍

- `getShareExtras`를 `runApp` 이후 첫 프레임으로 늦추는 경로 검토  
  (pending seed를 post-frame / splash에서 재시도)
- 실패 시 Analytics `share_url_rejected` reason을 세분화:  
  `no_plugin_path` / `channel_error` / `extras_empty` / `sanitize_fail`

### Step 4 — plugin 우회 옵션 (가설 확정 후)

`receive_sharing_intent` 유지보수 리스크 + STREAM 우선 버그:

1. **App-owned platform channel only** for ACTION_SEND text (권장 후보)
2. 플러그인 fork / path+text 동시 전달 패치
3. `receive_sharing_intent` 최신(1.9.x) changelog 확인 후 업그레이드 실험

### Step 5 — 회귀 테스트

실기기 fixture 확보 후 unit에 고정:

- pluginPath = cache jpg, extras.text = YouTube title+URL → resolve OK (이미 있음)
- extras 전부 null, ClipData text only → 추가
- cold: channel delay 시뮬레이션

### Step 6 — 검증 매트릭스 (PRD §13.2)

YouTube / X / Chrome × 종료·백그라운드·포그라운드·편집 중.  
결과를 본 문서 또는 `docs/daily_task_log/`에 표로 남기고 PRD DoD 닫기.

---

## 7. 하지 말 것

- iOS Share Extension (Phase C) — 이번 버그와 무관
- 중복 soft warning (P1) — URL 유입 전 범위 확대 금지
- “자동 저장”으로 제품 정책 변경 — PRD 비목표. 폼 prefill 수정이 목표
- raw URL을 Crashlytics/Analytics 속성에 넣기 — privacy AC 위반. **로컬 디버그 UI / 비식별 reason code만**

---

## 8. 워킹 트리 상태 (핸드오프 시점)

**브랜치**: `main` (origin 대비 앞/뒤 없음, **로컬 수정 다수 미커밋**)

### 수정됨 (M)

- `CHANGELOG.md`, `docs/prds/share-intent.md`, `pubspec.yaml` (`1.1.6+6`)
- `android/.../MainActivity.kt`
- `lib/bootstrap.dart`
- `lib/core/services/analytics_service.dart`
- `lib/features/link/presentation/provider/link_form_provider.dart`
- `lib/features/link/presentation/screens/link_add_screen.dart`
- `lib/features/share_intent/**` (listener, pending, shared_intent_service)
- `lib/shared/utils/url_sanitizer.dart`
- 관련 tests

### 신규 (??)

- `lib/features/share_intent/data/android_share_extras.dart`
- `lib/features/share_intent/domain/service/share_payload_resolver.dart`
- `test/core/services/analytics_service_share_test.dart`
- `test/features/share_intent/domain/service/share_payload_resolver_test.dart`

### 권장 커밋 전략

1. **옵션 A**: Phase A + YouTube 폴백을 하나의 WIP 커밋으로 보존 후 디버그 브랜치  
2. **옵션 B**: 디버그 계측만 먼저 커밋하지 말고, raw payload 확보 후 근본 수정과 함께 커밋  
3. **git push는 사용자 명시 승인 후에만**

---

## 9. 로컬 검증 상태 (개발 머신)

| 검사 | 결과 |
|---|---|
| `flutter test test/features/share_intent/` | ✅ 45 passed (핸드오프 직전 기준) |
| Phase A 관련 유닛/위젯 | ✅ green (이전 세션) |
| `flutter analyze` (share_intent/bootstrap) | ✅ clean |
| YouTube 실기기 | 🔴 fail (+5, +6) |
| Chrome/X 실기기 | ❓ 미실행 |

---

## 10. 다음 세션 시작 프롬프트 (복붙용)

```text
docs/handoffs/2026-07-22-share-intent-youtube.md 핸드오프 이어서.

목표: Android YouTube 공유 시 LinkNote로 URL prefill → 링크 추가 화면이 열리게 한다.
제약: 자동 저장 금지. raw payload 증거 없이 추측 수정 금지.
우선: (1) versionCode 6 설치 확인 (2) cold/warm 재현 분류 (3) getShareExtras + ClipData + plugin path를 UI/로그로 노출 (4) 원인 확정 후 최소 수정 (5) +7 내부테스트 재배포.

관련 파일: MainActivity.kt, bootstrap.dart, share_payload_resolver.dart, share_intent_listener.dart, app_router.dart, docs/prds/share-intent.md
```

---

## 11. 결정/메모

| 일자 | 메모 |
|---|---|
| 2026-07-22 | Phase A 코드 구현 + 단위테스트. 실기기 DoD 미완. |
| 2026-07-22 | YouTube 실기기 실패 → EXTRA_STREAM 가설로 +6 폴백. 재실패. |
| 2026-07-22 | 핸드오프. **다음 액션 = raw intent 계측**, ClipData·boot channel 타이밍 조사. |

---

*이 문서가 다음 세션의 단일 진실 공급원(SSOT)이다. 수정 시 상단 상태·버전·재현 결과를 갱신할 것.*
