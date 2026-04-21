# PRD — Share Intent (시스템 공유 인텐트로 링크 받기)

> 상태: **Phase 1 구현 (Session 38, 2026-04-21)** — Android URL-only PoC cold-start prefill 구현 완료. Phase 2 (iOS Share Extension) 및 warm/foreground bottom sheet 는 후속 세션. 상세는 Section 3 각 항목 Decided 마크 및 Section 7 결정 로그 참조.

## 1. 배경 / 동기

LinkNote 의 핵심 사용 동선은 "타 앱에서 본 링크를 한 번에 저장한다" 이다. 현재는 앱을 직접 열어 `link/add` 화면에서 URL 을 붙여넣어야 한다. 시스템 공유 시트(Android: ACTION_SEND, iOS: UIActivityViewController) 를 받아 자동으로 폼을 채우거나, 백그라운드 처리하는 흐름이 필요하다.

Wave 5 리뷰에서 P3-A (Share Intent) 항목은 단순 코드 변경이 아니라 UX/플랫폼 설계 의사결정이 선행돼야 함이 확인되어 별도 PRD 로 이관됐다.

## 2. 사용자 시나리오

| # | 시나리오 | 현재 | 목표 |
|---|---------|------|------|
| S1 | YouTube 영상 → 공유 → LinkNote | 앱을 열고 URL 복붙 | 공유 시트에서 LinkNote 선택 → 자동으로 폼이 열림 |
| S2 | Twitter 트윗 텍스트 → 공유 → LinkNote | 텍스트 안의 URL 수동 추출 | URL 자동 추출, 본문은 메모로 채움 |
| S3 | 사진/스크린샷 → 공유 → LinkNote | 미지원 | 이미지 + URL(있다면) 저장 |

## 3. 선결 과제 (Open Decisions)

별도 Wave 진입 전 본 PRD 에서 합의돼야 할 항목.

### 3.1 Payload 타입 분기 — **Decided (2026-04-21)**

공유 시트가 전달하는 payload 는 단일 타입이 아니다. 타입별 UX 정책이 필요하다.

**결정**: Phase 1 은 **URL payload 만** 처리. 수신한 URL 을 `link/add` 화면으로 전달해 **폼 prefill** 하고, 사용자가 확인 후 저장. 자동 저장(폼 스킵)은 OG 메타 수정 기회가 사라지고 실패 UX 가 모호해 채택하지 않음.

**사유**:
- LinkNote 정체성이 "북마크" 이므로 URL 이 1차 대상. Plain text/image 는 별도 엔티티·화면 도입이 필요해 Phase 3+ 로 이월.
- 폼 prefill 이 OG 메타 수정·태그/컬렉션 선택 여지를 남겨 기존 `link/add` 사용성과 정합.

| 타입 | Phase 1 UX | 비고 |
|------|-----------|------|
| URL (단순 링크) | 자동 파싱 + `link/add` 폼 prefill (URL 만 채움, OG 는 기존 플로우 재사용) | **Phase 1 대상** |
| Plain text (URL 포함) | Phase 3 로 이월 — `UrlSanitizer` 재사용해 URL 추출, 성공 시 URL 케이스로 귀결 | Phase 3 |
| Plain text (URL 없음) | 별도 PRD 필요 (메모 엔티티 모델 부재) — Phase 4+ | 이월 |
| Image | 별도 PRD 필요 (이미지 엔티티 또는 `link.image_url` 확장) | 이월 |
| 멀티 payload (text + image) | 첨부 모델 도입 이후 | 이월 |

### 3.2 앱 상태별 동작 — **Decided (2026-04-21)**

**결정**: Cold start 는 **GoRouter `initialLocation` 동적 분기** 방식. Warm/Foreground 는 작업 흐름 보호를 위해 **bottom sheet** (혹은 스낵 액션) 로 사용자 확인 후 전환. 강제 풀스크린 push 는 입력 손실 위험으로 배제.

**사유**:
- `initialLocation` 을 부트 시퀀스에서 인텐트 payload 기준으로 계산하면 스플래시 후 모달 대비 사용자 인지 경로가 단축되고, 표준 Flutter/Deep-link 패턴에 부합.
- 풀스크린 강제 push 는 링크 작성·메모 입력 중인 사용자의 기존 작업을 덮어써 체감 피해가 크다는 판단.

| 상태 | Phase 1 동작 |
|------|-------------|
| Cold start (앱이 죽어 있음) | 부트 시 payload 확인 → `initialLocation = /link/add?prefill=<encoded-url>` 로 분기. payload 없으면 기본 home. |
| Warm resume (백그라운드 복귀) | Phase 1 범위 검토 — cold-start 우선. warm 처리는 Phase 1 후반/2 에서 bottom sheet 채택. |
| Foreground (앱 사용 중) | 동일. 현재 화면 위 bottom sheet / 스낵바 "새 링크 저장" 액션. 풀스크린 push 금지. |

**구현 노트**:
- 부트 시퀀스: `main.dart` → `receive_sharing_intent` 초기 getter (비동기) → `runApp` 전에 payload 확정 → GoRouter 에 전달.
- Warm/foreground 스트림 구독은 app shell 단계에서 구독, 도착 시 bottom sheet 표시.
- 작업 중 입력 보호: 폼 dirty 상태일 때 "새 링크가 들어왔어요" 스낵바로 대체, 사용자가 수락 시에만 이동.

### 3.3 iOS Share Extension — **Decided (2026-04-21): Phase 2 이월**

**결정**: Phase 1 에서는 **iOS Share Extension 작업 일체 보류**. Phase 2 진입 시점에 Extension UI 범위 / Extension vs 메인 앱 저장 / App Groups / entitlement 을 재결정한다.

**사유**:
- Phase 1 목표는 Android URL-only PoC 로 공유 인텐트 기본 흐름 검증. iOS Extension 은 Xcode 프로젝트 수정·native Swift·App Groups·서명까지 범위가 급증해 한 세션 경계 안에 안정적 종료가 어려움.
- Phase 1 에서 검증한 payload → GoRouter 분기 → `link/add` prefill 체계를 iOS 에서도 그대로 재사용할 수 있어 선행 가치가 크다.

**Phase 2 재검토 질문** (Phase 2 진입 세션에서 다시 연다):
- Extension UI 는 풀 SwiftUI 미니 앱 vs 캡처만 (메인 앱 후처리)?
- Extension 이 직접 Supabase 저장 vs 캡처 → App Group 저장 → 메인 앱 fetch?
- Extension OG 메타 fetch 여부 (network entitlement + lifetime 제약)?

### 3.4 패키지 선정 — **Decided (2026-04-21)**

**결정**: **`receive_sharing_intent` 1.8.1** 채택.

**호환성 확인** (pub.dev 조회, 2026-04-21):
- 버전: 1.8.1 (verified publisher `kasem.dev`)
- 최신 배포: 18개월 전 — 활성도 주의 (위험은 Phase 2 재평가 포인트)
- 플랫폼 제약: Android SDK 19+ (Kotlin 1.9.22), iOS 12.0+ (Swift 5.0)
- LinkNote 타겟: iOS 15.0 (Podfile/pbxproj), Android `flutter.*SdkVersion` — 모두 충족

**사유**:
- Phase 1 Android 만이라도 패키지가 ACTION_SEND 인텐트 필터 + Kotlin 브리지 + Dart 스트림을 일체 제공 → PoC 속도 확보.
- Phase 2 iOS Share Extension 진입 시 동일 패키지가 Extension 템플릿과 App Group 브리지를 제공해 재사용성 높음.
- "18개월 무업데이트" 는 리스크지만, Phase 2 진입 시점에 대체 수단(플랫폼 채널 직접 / fork) 을 다시 평가하는 것으로 위험을 지연.

**미채택 이유**:
- Hybrid (Android 직접 채널 + iOS 만 패키지) — Phase 2 에서야 가치가 발생하는 구조이고, Phase 1 에서 부트 시퀀스·스트림 구독을 우리가 직접 만들어야 해 코드량이 더 큼.
- 완전 자체 구현 — 일정 대비 이득 부족, Phase 1 범위를 벗어남.

## 4. 우선순위 (제안)

PRD 합의 후 별도 Wave 진입 시 다음 순서를 권장:

1. **Phase 1 — Android 만**: ACTION_SEND (URL only) 수신 → cold start 시 `link/add` 분기 → 폼 prefill. 패키지 vs 자체 결정 후 PoC.
2. **Phase 2 — iOS Share Extension**: native 코드 작성 + App Groups + URL only 수신.
3. **Phase 3 — Plain text URL 추출**: 기존 `UrlSanitizer` 재사용 가능 (Wave 5 P2 IDN 정책 적용된 상태).
4. **Phase 4 — Image / multi-payload**: 도메인 모델 확장 필요. 별도 PRD 권장.

## 5. 비목표 (Non-goals)

- 시스템 공유 시트로 **내보내기** (LinkNote → 타 앱) 는 본 PRD 범위 외 (별도 기능).
- 다른 사용자에게 link 공유 (협업) — 컬렉션 공유는 별도 로드맵.
- 알림 → 직접 link 저장 등 비공유 경로.

## 6. 참조

- Wave 5 Link 리뷰 (P3-A Deferred 결정): `docs/reviews/wave5-link-review.md`
- `UrlSanitizer` (Wave 5 P2 IDN 정책): `lib/shared/utils/url_sanitizer.dart`
- Android `ACTION_SEND` 공식 문서: https://developer.android.com/training/sharing/receive
- iOS App Extension Programming Guide: https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/

## 7. 결정 로그

| 일자 | 결정 | 사유 |
|------|------|------|
| 2026-04-18 | PRD 를 Draft 로 시작, 4개 선결 과제 명시 | Wave 5 P3-A 구현 차단 — 단일 코드 PR 로 처리 불가 판단 |
| 2026-04-21 | 3.1 Payload — **Phase 1 은 URL only + 폼 prefill** | 북마크 정체성 우선, plain text/image 는 엔티티 모델 도입 필요로 이월 |
| 2026-04-21 | 3.2 App State — **Cold start 는 GoRouter initialLocation 동적 분기**, warm/foreground 는 bottom sheet | 표준 Flutter/deep-link 패턴, 풀스크린 강제 push 는 입력 손실 위험 |
| 2026-04-21 | 3.3 iOS Share Extension — **Phase 2 이월** | Xcode·native Swift·App Groups 범위가 크다. Phase 1 은 Android 만 |
| 2026-04-21 | 3.4 Package — **`receive_sharing_intent` 1.8.1 채택** | iOS 15 / Android default minSdk 와 호환, PoC 속도·Phase 2 iOS Extension 재사용 |
| 2026-04-21 | PRD 상태 **Draft → Decided** 승격, Phase 1 진입 가능 | 4건 합의 완료 (Session 37) |
| 2026-04-21 | **Phase 1 Android URL-only PoC 구현** (Session 38) | `SharedIntentService` (UrlSanitizer 재사용) + `PendingSharedUrl` provider + AndroidManifest ACTION_SEND text/plain intent-filter + bootstrap cold-start read + GoRouter redirect 분기 + `LinkAddScreen(initialUrl:)` prefill. 453 tests GREEN, Android dev/staging debug APK 빌드 성공. **실기기 공유 시트 검증은 사용자 수동 확인 필요**. Plugin 통합 부수효과로 Gradle subprojects JVM 17 정렬 적용. |
| 2026-04-21 | 로드맵 갱신 — Phase 1 잔여 + Phase 2 재평가 | warm/foreground bottom sheet, URL 이 아닌 payload 예외 처리, 실기기 multi-app 검증 후 iOS Share Extension 진입 |

---

> **다음 액션**: ① 실기기 2앱 이상 (YouTube/Chrome/Twitter) 에서 공유 시트 → LinkNote → 폼 prefill 확인. ② Phase 1 후반: warm/foreground 스트림 구독 + bottom sheet UX. ③ Phase 2: iOS Share Extension (App Groups / entitlement / SwiftUI vs 캡처-전용 재결정).
