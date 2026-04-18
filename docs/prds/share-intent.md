# PRD — Share Intent (시스템 공유 인텐트로 링크 받기)

> 상태: **Draft (Session 36, 2026-04-18)** — 본 문서는 Wave 5 P3-A 의 이월 결정에 따라 별도 Wave 진입 전 선결 과제 4건을 정리한 PRD 초안. 실제 구현은 Share Intent Wave 에서 별도 진행.

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

### 3.1 Payload 타입 분기

공유 시트가 전달하는 payload 는 단일 타입이 아니다. 타입별 UX 정책이 필요하다.

| 타입 | 기대 UX | 미해결 질문 |
|------|--------|-----------|
| URL (단순 링크) | 자동 파싱 + `link/add` 폼 prefill (URL/제목/OG 메타) | 자동 저장 vs 폼 띄우고 저장 선택권 |
| Plain text (URL 포함) | 텍스트에서 URL 추출 시도. 추출 성공 → URL 케이스. 실패 → 메모 화면? | 메모 화면 진입을 별도 동선으로 둘지, "URL 없음" 토스트 후 무시할지 |
| Plain text (URL 없음) | 메모로 저장? 무시? | 본 앱이 "북마크" 정체성 — 순수 텍스트 메모를 받는 게 맞는가 |
| Image | 링크 + 썸네일로 저장 / 단독 이미지 노트 | 이미지 단독 노트 도메인 모델이 없음. 추가 시 별도 entity 또는 link.image_url? |
| 멀티 payload (text + image) | URL 우선, 이미지는 첨부 | 첨부 모델 부재 |

### 3.2 앱 상태별 동작

공유 인텐트 수신 시점에 앱이 어떤 상태인가에 따라 UX 가 달라진다.

| 상태 | 동작 옵션 |
|------|---------|
| Cold start (앱이 죽어 있음) | A) 초기 라우트를 `link/add?prefill=...` 로 분기 / B) 스플래시 후 모달 표시 |
| Warm resume (백그라운드에서 복귀) | A) 현재 화면 위로 bottom sheet / B) 강제로 `link/add` 화면 push / C) 토스트 + Inbox 같은 임시 저장소 |
| Foreground (앱 사용 중) | A) bottom sheet (작업 흐름 보존) / B) 풀스크린 push |

**미해결 질문**:
- GoRouter 의 `initialLocation` 을 인텐트 payload 기준으로 동적으로 결정해야 하는데, `main.dart` 에서 channel 호출이 비동기 — 부트 시퀀스가 어떻게 구성돼야 하는가?
- 작업 중 화면(폼 작성 중) 위에 share intent 가 들어왔을 때 사용자 입력을 잃지 않도록 보호하는 UX 는?

### 3.3 iOS Share Extension

iOS 는 단순 채널 호출만으로는 부족하다 — Share Extension 이 별도 binary 로 빌드되어 시스템에 등록된다.

| 항목 | 결정 사항 |
|------|---------|
| Share Extension 추가 여부 | **필요 (iOS 표준 패턴)** — Extension 없이 iOS 공유 시트에 LinkNote 가 노출될 수 없음 |
| App Groups 설정 | 필요 — Extension 이 받은 payload 를 메인 앱에 전달하려면 공유 UserDefaults / shared container 가 필요 |
| Extension UI | A) 풀 SwiftUI 미니 앱 (URL 미리보기 + 저장) / B) 캡처만 + 메인 앱에서 처리 |
| Extension 빌드 환경 | Flutter 의 iOS host 위에 native Swift Extension 추가 — Xcode 프로젝트 수정 필요 |

**미해결 질문**:
- Extension 에서 직접 Supabase 에 저장할 것인가, 아니면 캡처만 하고 메인 앱이 후처리할 것인가? (백그라운드 fetch 신뢰성 검토)
- Extension 에서 OG 메타 fetch 까지 할지 (network entitlement) — 수 초 안에 종료되는 Extension lifetime 제약

### 3.4 패키지 선정

| 옵션 | 장점 | 단점 |
|------|------|------|
| `receive_sharing_intent` (커뮤니티) | Android/iOS 양쪽 추상화. 빠른 PoC | 유지보수 활성도 변동, iOS Share Extension 코드는 직접 작성 / 가이드 의존 |
| 플랫폼 채널 직접 구현 | 완전한 제어, deps 0 | Android `Intent` + iOS Extension 양쪽 native 작성 비용 |
| Hybrid (수신은 패키지, OG 처리는 자체) | 일반적인 절충 | 패키지의 stream/event 형식에 도메인이 결합됨 |

**미해결 질문**:
- `receive_sharing_intent` 의 최신 버전이 Flutter 3.41 / iOS 17+ 와 호환되는지 (Context7 조회 필요)
- Android 13 이상의 photo picker / scoped storage 변경에 패키지가 대응하는지

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

## 7. 결정 로그 (Draft 단계)

| 일자 | 결정 | 사유 |
|------|------|------|
| 2026-04-18 | PRD 를 Draft 로 시작, 4개 선결 과제 명시 | Wave 5 P3-A 구현 차단 — 단일 코드 PR 로 처리 불가 판단 |

---

> **다음 액션**: 본 PRD 의 Open Decision 4건에 대해 사용자/스테이크홀더 합의 → Decided 항목 갱신 → Share Intent Wave 진입.
