# PRD — 외부 앱에서 링크 바로 저장하기 (Share Intent)

> 문서 버전: 2.1
> 최종 갱신: 2026-07-22
> 상태: **Android Phase A(P0 코드) 구현 완료 · 실기기 검증 대기**
> 적용 플랫폼: Android 우선, iOS 후속
> 기준 라우트: `/links/new?prefill=<encoded-url>`

## 1. 한 줄 정의

사용자가 YouTube, X(트위터), 브라우저 등 외부 앱의 공유 시트에서
**LinkNote를 선택하면 URL을 자동으로 추출하고 링크 추가 화면을 열어,
내용을 확인·수정한 뒤 저장할 수 있게 한다.**

핵심 가치는 “링크 복사 → LinkNote 실행 → 추가 화면 진입 → 붙여넣기”를
“공유 → LinkNote 선택 → 확인 후 저장”으로 단축하는 데 있다.

## 2. 배경과 문제

LinkNote의 핵심 사용 시점은 앱 내부가 아니라 사용자가 외부 콘텐츠를 발견한
순간이다. 현재 사용자가 링크를 직접 복사해 저장하면 앱 전환과 붙여넣기 과정에서
이탈하기 쉽고, 모바일에서는 이 반복 작업의 비용이 특히 크다.

시스템 공유 시트를 진입점으로 제공하면 다음 문제가 해결된다.

- 링크를 복사하거나 기억해 두어야 하는 부담
- LinkNote를 별도로 실행하고 링크 추가 화면을 찾아야 하는 탐색 비용
- YouTube 제목이나 X 공유 문구에 섞인 URL을 사용자가 직접 분리해야 하는 문제
- 링크를 나중에 저장하려다가 잊는 문제

## 3. 목표와 비목표

### 3.1 목표

1. Android 공유 대상 목록에 LinkNote가 안정적으로 노출된다.
2. URL만 공유되거나 문장 안에 URL이 포함된 경우 모두 저장 가능한 URL을 추출한다.
3. 앱이 종료, 백그라운드, 포그라운드 상태일 때 모두 공유 요청을 유실하지 않는다.
4. 기존 작성 내용을 덮어쓰지 않으면서 링크 추가 화면으로 연결한다.
5. 기존 링크 생성 폼과 OG 메타데이터 조회, 태그, 컬렉션, 즐겨찾기 기능을 그대로 재사용한다.
6. 자동 저장하지 않고 사용자가 최종 내용을 확인한 뒤 저장하게 한다.
7. 실패 원인을 사용자가 이해할 수 있는 문구로 안내하고 다시 시도할 수 있게 한다.

### 3.2 비목표

- LinkNote 안의 링크를 다른 앱으로 내보내는 기능
- 공유된 이미지, 동영상 파일 또는 여러 첨부 파일 저장
- URL이 없는 일반 텍스트를 메모로 저장
- 공유 즉시 확인 화면 없이 자동 저장
- 여러 URL을 한 번에 일괄 저장
- Android 1차 완성 범위에서의 iOS Share Extension 구현

## 4. 사용자와 핵심 시나리오

### 4.1 주요 사용자

- YouTube 영상을 보다가 나중에 다시 볼 콘텐츠를 저장하려는 사용자
- X에서 발견한 글이나 외부 기사 링크를 빠르게 보관하려는 사용자
- 모바일 브라우저에서 읽던 페이지를 컬렉션이나 태그와 함께 정리하려는 사용자

### 4.2 대표 시나리오

| ID | 상황 | 기대 결과 |
|---|---|---|
| S1 | YouTube → 공유 → LinkNote | 영상 URL이 채워진 링크 추가 화면이 열린다. |
| S2 | X → 공유 → LinkNote | 트윗 공유 문구에서 첫 번째 유효 URL을 추출한다. |
| S3 | Chrome 등 브라우저 → 공유 → LinkNote | 현재 페이지 URL이 채워진다. |
| S4 | 앱이 완전히 종료된 상태에서 공유 | 앱 부팅과 인증 확인 후 링크 추가 화면으로 이동한다. |
| S5 | 앱이 이미 실행 중인 상태에서 공유 | 안전한 화면이면 링크 추가 화면을 열고, 작성 중이면 사용자의 확인을 기다린다. |
| S6 | URL이 없는 텍스트 공유 | 현재 화면을 유지하고 저장 가능한 URL이 없음을 안내한다. |
| S7 | 로그인하지 않은 상태에서 공유 | 로그인 완료까지 URL을 보관한 뒤 링크 추가 화면을 연다. |

## 5. 목표 사용자 흐름

```text
외부 앱에서 공유
  → Android 공유 시트에서 LinkNote 선택
  → 공유 payload 수신
  → 내부 LinkNote 딥링크인지 먼저 분류
  → 웹 URL 추출
      ├─ 실패: 현재 화면 유지 + 오류 안내
      └─ 성공
          → 인증 여부 확인
              ├─ 미인증: URL 임시 보관 → 로그인 → 계속
              └─ 인증됨
                  → 작성 중 화면 여부 확인
                      ├─ 작성 중: "공유한 링크 열기" 액션 제시
                      └─ 안전한 화면: 링크 추가 화면 열기
                          → URL 입력 + 메타데이터 자동 조회
                          → 사용자 확인/수정
                          → 저장
```

### 5.1 앱 상태별 동작

| 앱 상태 | 동작 원칙 | 상세 |
|---|---|---|
| 종료됨 · 로그인됨 | 바로 이어가기 | 부팅 중 payload를 1회 읽고 인증 확인 후 링크 추가 화면으로 이동한다. |
| 종료됨 · 미로그인 | 로그인 후 이어가기 | pending URL을 소비하지 않은 채 로그인 화면으로 이동하고, 인증 성공 후 링크 추가 화면을 연다. |
| 백그라운드/포그라운드 · 로그인됨 · 안전한 화면 | 바로 열기 | warm stream으로 수신해 링크 추가 화면을 push한다. |
| 백그라운드/포그라운드 · 미로그인 | 로그인 후 이어가기 | cold와 동일하게 pending URL을 보관한 뒤 로그인 완료 시 1회만 링크 추가 화면을 연다. cold/warm 경로가 서로 다른 보존 모델을 쓰면 안 된다. |
| 링크/컬렉션 작성 또는 편집 중 | 작업 보호 | 강제 이동하지 않고 “공유한 링크를 받았어요” 스낵바와 `열기` 액션을 표시한다. |
| 저장 가능한 URL 없음 | 이동하지 않음 | 현재 작업을 유지하고 오류 스낵바만 표시한다. |

### 5.2 링크 추가 화면 동작

1. 추출한 URL을 URL 필드에 즉시 표시한다.
2. 화면이 준비되면 기존 OG 조회를 한 번 자동 실행한다. 키보드 완료 액션에 의존하지 않는다.
3. 조회 중에는 상단 진행 표시를 노출한다.
4. 제목, 설명, 썸네일은 **비어 있는 필드에만** 채운다. 이미 값이 있는 필드는 유지한다.
5. 사용자가 조회 중 필드를 수정했다면 늦게 도착한 결과가 수정값을 덮어쓰지 않는다.
6. 조회에 실패하면 URL의 host를 임시 제목으로 사용하고 사용자가 계속 저장할 수 있게 한다.
7. 현재 저장 검증은 `url`과 `title`이 모두 필요하다. 따라서 OG 자동 조회 또는 host fallback 제목 없이 prefill만 되면 저장이 막힐 수 있다.
8. 사용자가 `저장`을 눌렀을 때만 링크를 생성한다.
9. 저장 성공 후 이전 화면으로 돌아가고 성공 메시지를 표시한다.

## 6. Payload 처리 정책

### 6.1 1차 지원 타입

| MIME / 형태 | 처리 | 우선순위 |
|---|---|---|
| `text/plain`의 단일 `http/https` URL | 그대로 사용 | P0 |
| `text/plain`의 제목/문장 + URL | 첫 번째 유효 URL 추출 | P0 |
| scheme 없는 단일 도메인 | 기존 `UrlSanitizer` 규칙으로 `https://` 보완 | P0 |
| 여러 URL이 포함된 텍스트 | 첫 번째 유효 URL만 사용 | P0 |
| URL 없는 일반 텍스트 | 실패 안내 | P0 |
| `linknote://` 내부 딥링크 | 링크 저장과 분리해 기존 내부 라우팅 수행 | P0 |
| 이미지/파일/multi payload | 처리하지 않음 | P2 이후 |

### 6.2 URL 정제 규칙

- 허용 scheme은 `http`, `https`로 제한한다.
- zero-width 문자, BOM, NBSP 등 공유 과정에서 섞일 수 있는 보이지 않는 문자를 제거한다.
- 문장 안 URL 뒤에 붙은 마침표, 쉼표, 닫는 괄호 등은 제거한다.
- 비정상적으로 긴 입력은 거부한다. 현재 기준은 최대 2,048자다.
- query parameter는 링크 동작을 깨뜨릴 수 있으므로 P0에서는 임의로 제거하지 않는다.
- YouTube short URL, X의 `t.co` URL 등 리디렉션 URL도 원형을 보존한다.
- 공유 문구의 URL 앞 텍스트를 P0에서 메모로 자동 저장하지 않는다.
- payload 원문이나 전체 URL을 Analytics 또는 Crashlytics 속성으로 전송하지 않는다.

## 7. 상세 기능 요구사항

### P0 — Android 핵심 흐름 완성

| ID | 요구사항 | 완료 조건 |
|---|---|---|
| FR-01 | 공유 대상 등록 | YouTube, X, 브라우저의 Android 공유 시트에 LinkNote가 표시된다. |
| FR-02 | URL 추출 | URL 단독 및 문장 속 URL에서 동일한 정제 규칙으로 첫 URL을 얻는다. |
| FR-03 | cold-start 처리 | 종료 상태에서 받은 payload를 앱 초기화 중 한 번만 처리한다. |
| FR-04 | warm/foreground 처리 | 실행 중 공유 이벤트를 stream으로 받고 중복 재생하지 않는다. |
| FR-05 | 인증 연속성 | cold/warm 모두 미로그인 상태에서 받은 URL이 로그인 완료 후에도 보존된다. |
| FR-06 | 작성 내용 보호 | 생성/편집 화면에서는 자동 이동하지 않고 사용자 액션을 기다린다. |
| FR-07 | 폼 prefill | `/links/new`에 URL이 표시되고 기존 링크 폼 기능을 사용할 수 있다. |
| FR-08 | 메타데이터 자동 조회 | 공유로 진입했을 때 별도 키보드 액션 없이 OG 조회가 한 번 시작되고, 결과는 빈 필드에만 반영된다. |
| FR-09 | 실패 fallback | OG 조회 실패가 링크 저장 자체를 막지 않는다. host fallback 제목으로 저장 검증을 통과할 수 있다. |
| FR-10 | 수동 확정 저장 | 링크는 사용자가 저장 버튼을 눌렀을 때만 생성된다. |
| FR-11 | 오류 안내 | URL 없음, 파싱 실패, 저장 실패를 구분해 안내한다. |
| FR-12 | 개인정보 보호 계측 | 성공 단계와 실패 코드만 기록하고 URL 원문은 기록하지 않는다. |

### P1 — 저장 품질 개선

| ID | 요구사항 | 정책 |
|---|---|---|
| FR-13 | 중복 링크 감지 | 동일 사용자의 정규화 URL을 조회해 저장 전 경고한다. |
| FR-14 | 중복 처리 선택 | `기존 링크 열기`와 `그래도 저장`을 제공한다. P1에서는 soft warning으로 시작한다. |
| FR-15 | 연속 공유 처리 | 편집 중 새 공유가 연속 도착하면 pending 상태를 명시적으로 관리하고 유실을 알린다. |
| FR-16 | source 분석 | 원문 없이 source domain 범주만 익명 집계해 호환성 우선순위를 판단한다. |

중복 감지는 초기부터 DB unique constraint로 강제하지 않는다. 같은 URL을 다른 맥락으로
다시 저장하려는 사용 사례가 있을 수 있으므로 먼저 경고형 UX로 운영하고 실제 사용
데이터를 본 뒤 정책을 강화한다.

### P2 — 플랫폼 및 payload 확장

- iOS Share Extension
- 여러 URL 선택 또는 일괄 저장
- 이미지/스크린샷 첨부
- URL 없는 텍스트를 메모로 저장
- 공유 시트 안에서 앱을 완전히 열지 않는 빠른 저장

## 8. 사용자 문구 초안

| 상황 | 문구 | 액션 |
|---|---|---|
| 편집 중 공유 도착 | `공유한 링크를 받았어요.` | `열기` |
| URL 추출 실패 | `공유 내용에서 저장할 링크를 찾지 못했어요.` | 없음 |
| OG 조회 실패 | `링크 정보를 불러오지 못했어요. URL은 저장할 수 있어요.` | 없음 |
| 저장 성공 | `링크를 저장했어요.` | 없음 |
| 중복 감지(P1) | `이미 저장한 링크예요.` | `기존 링크 열기`, `그래도 저장` |
| 로그인 필요 | 별도 오류 대신 정상 로그인 흐름 사용 | 로그인 완료 후 자동 계속 |

지원 locale이 한국어와 영어이므로 실제 구현 시 문자열을 화면에 직접 쓰지 않고
지역화 리소스로 관리한다. 본 표는 한국어 기준 제품 문구다.

## 9. 현재 구현 현황과 Gap 분석

2026-07-22 `main` 기준 코드 조사 결과다.

### 9.1 이미 구현된 항목

- `AndroidManifest.xml`에 `ACTION_SEND`, `text/plain` intent filter 등록
- `receive_sharing_intent 1.8.1` 도입
- cold start의 `getInitialMedia()` 읽기, native buffer reset, 예외 격리
- `SharedIntentService`와 `UrlSanitizer`를 통한 URL 단독/문장 속 URL 추출
- `http`/`https` scheme allowlist (non-web scheme 거부)
- 내부 `linknote://` 공개 컬렉션 딥링크와 외부 저장 URL 분류
- `PendingSharedUrl` cold/warm 공통 계약 + 로그인 후 one-shot router redirect
- warm/foreground `getMediaStream()` 구독
- `WarmShareAction`: `navigate` / `deferUntilAuthenticated` / `degrade` / `toastFailure`
- 일반 화면에서 `/links/new?prefill=...` push
- 링크/컬렉션 생성·편집 화면에서 스낵바 액션으로 작업 보호
- 링크 추가 화면 URL prefill + OG 자동 1회 조회
- OG 빈 필드 전용 merge + host fallback 제목
- 공유·폼 한국어 UX 문구 (PRD §8)
- share funnel Analytics (`share_intent_received` 등, raw URL 비수집)
- URL 추출, pending, warm decision, OG merge, widget, privacy 단위/위젯 테스트

### 9.2 보강이 필요한 항목

| 우선순위 | Gap | 영향 |
|---|---|---|
| P0 | YouTube/X/브라우저 실기기 검증 결과가 문서화되지 않음 | 앱별 payload 차이에 대한 출시 근거가 부족하다. 결과는 세션 로그 또는 본 PRD 부록에 남겨 DoD를 닫는다. |
| P1 | 중복 URL 조회 및 안내 없음 | 반복 공유로 중복 링크가 쌓일 수 있다. |
| P1 | 여러 URL 또는 연속 공유의 명시적 정책/queue 없음 | 첫 URL 외 데이터 또는 앞선 pending 요청이 유실될 수 있다. |
| P1 | ARB/gen-l10n 기반 다국어 리소스 미도입 | 현재 한국어 hard-code로 일관화. 영어 locale 분리 시 리소스 추출 필요. |
| P2 | iOS Share Extension 없음 | iOS 공유 시트에서 LinkNote를 선택할 수 없다. |

## 10. 구현 설계 방향

### 10.1 기존 파이프라인 유지

```text
Android ACTION_SEND
  → receive_sharing_intent
  → SharedIntentService / UrlSanitizer
  → cold: PendingSharedUrl + GoRouter redirect
     warm: SharedMediaStreamProvider + ShareIntentListener
  → LinkAddScreen(initialUrl)
  → LinkFormProvider + OgTagService
  → CreateLinkUsecase
```

현재 feature-first 구조와 테스트 seam이 이미 마련돼 있으므로 플랫폼 채널을 새로
작성하거나 별도의 저장 화면을 만들지 않는다. 기존 흐름을 확장하는 것이 원칙이다.

### 10.2 P0 변경 지점

1. `LinkAddScreen` / `LinkFormProvider`
   - 공유 URL을 provider에 주입한 뒤 OG 조회를 정확히 한 번 자동 호출한다.
   - 위젯 dispose 또는 URL 교체 시 진행 중 조회를 취소한다.
   - OG 성공/실패 merge 규칙을 통일한다: **비어 있는 필드만 채운다.**
     `og.title`이 있어도 사용자가 이미 입력한 title/description/thumbnail은 유지한다.
   - OG 실패 또는 메타 부재 시 host fallback 제목을 넣어 저장 검증(`title` 필수)을 통과 가능하게 한다.

2. `PendingSharedUrl` / 라우터
   - cold와 warm 모두 동일한 pending 계약을 사용한다.
   - warm + 미로그인 시에도 `PendingSharedUrl`에 seed하고, 인증 가드에 의해
     `/links/new` push가 무효화돼도 URL이 남도록 한다.
   - 인증이 끝나기 전에는 consume하지 않는다.
   - 링크 추가 화면 이동이 확정된 시점에 한 번만 consume한다.

3. `SharedIntentService` / `UrlSanitizer`
   - 최종 추출 결과의 scheme을 `http/https`로 제한한다.
   - direct URL, 문장 속 URL, scheme 없는 URL이 동일한 검증 계약을 거치게 한다.
   - `ftp://`, `file://`, `javascript:` 등 non-web scheme은 추출 실패로 처리한다.

4. `ShareIntentListener`
   - 현재 인증 상태를 포함해 `navigate`, `deferUntilAuthenticated`,
     `degrade`, `toastFailure`를 결정한다. (`WarmShareAction` 확장 필요)
   - `deferUntilAuthenticated`는 pending seed만 하고 화면을 강제 이동하지 않는다.
   - 공유 스낵바·OG 실패·저장 성공 등 관련 문구를 지역화 리소스로 옮긴다.
   - 연속 이벤트와 중복 replay에 대한 방어 테스트를 추가한다.

5. Analytics
   - 기존 `AnalyticsService`를 확장한다.
   - 이벤트에는 성공 여부, 앱 상태, payload 분류, 실패 코드만 보낸다.
   - raw URL, title, query string은 보내지 않는다.

### 10.3 P1 중복 감지 방향

- 1차 정규화는 scheme/host 대소문자, 기본 port, fragment 정도만 처리한다.
- query parameter는 보존한다. 추적 parameter 제거는 오탐 가능성이 있어 별도 결정한다.
- 저장 전 사용자 소유 링크에서 정규화 URL을 조회한다.
- 발견되면 기존 링크 제목을 포함한 경고를 보여준다.
- 초기 정책은 soft warning이며 사용자가 중복 저장을 선택할 수 있다.
- 조회량이 커질 때 비고유 `normalized_url` column/index 도입을 별도 migration으로 검토한다.

## 11. Analytics 및 성공 지표

### 11.1 이벤트 초안

| 이벤트 | 시점 | 허용 속성 예시 |
|---|---|---|
| `share_intent_received` | payload 수신 | `app_state`, `payload_type` |
| `share_url_extracted` | URL 추출 성공 | `app_state`, `source_category` |
| `share_url_rejected` | 추출 실패 | `reason_code` |
| `share_add_form_opened` | prefill 폼 표시 | `entry_state` |
| `share_metadata_result` | OG 조회 완료 | `success`, `failure_code` |
| `share_save_result` | 저장 완료/실패 | `success`, `failure_code` |
| `share_flow_abandoned` | 저장 없이 종료 | `stage` |

`source_category`는 `youtube`, `x`, `browser/other` 수준의 범주만 허용하며
전체 host 또는 URL은 수집하지 않는다.

### 11.2 초기 성공 지표 제안

- 지원 앱 payload URL 추출 성공률 98% 이상
- 링크 추가 화면 도달 대비 저장 완료율 85% 이상
- 공유 처리로 인한 crash-free session 저하 없음
- 편집 중 공유 수신으로 기존 입력이 유실되는 재현 사례 0건

수치는 출시 후 4주 데이터를 기준으로 재조정한다. Android 공유 시트 노출 자체는
앱이 측정할 수 없으므로 `share_intent_received`를 funnel 시작점으로 본다.

## 12. 수용 기준 (Acceptance Criteria)

### AC-01 Android 공유 대상

**Given** LinkNote가 설치되어 있고 1차 지원 앱에서 웹 콘텐츠를 보고 있을 때

**When** 사용자가 공유 시트를 열면

**Then** LinkNote가 `text/plain` 공유 대상으로 표시된다.

### AC-02 종료 상태

**Given** 앱이 종료되어 있고 로그인 세션이 유효할 때

**When** YouTube 또는 X에서 LinkNote로 URL을 공유하면

**Then** 앱 초기화 후 URL이 채워진 링크 추가 화면이 한 번만 열린다.

### AC-03 비로그인 상태

**Given** 로그인 세션이 없을 때

**When** 외부 앱에서 URL을 공유하고 로그인을 완료하면

**Then** 공유 URL이 유실되지 않고 링크 추가 화면이 열린다.

### AC-04 warm/foreground 상태

**Given** 사용자가 홈, 검색, 컬렉션 목록 또는 프로필 화면에 있을 때

**When** 새 URL을 공유하면

**Then** 현재 탭 상태를 보존한 채 링크 추가 화면이 push된다.

### AC-05 작성 내용 보호

**Given** 사용자가 링크 또는 컬렉션 폼을 편집 중일 때

**When** 새 URL을 공유하면

**Then** 자동으로 이동하지 않고 스낵바를 표시하며 기존 입력을 유지한다.

### AC-06 문장 속 URL

**Given** `제목 - https://example.com/path` 형태의 payload일 때

**When** LinkNote가 payload를 처리하면

**Then** `https://example.com/path`만 URL 필드에 채운다.

### AC-07 URL 없음

**Given** 저장 가능한 URL이 없는 텍스트 payload일 때

**When** LinkNote가 payload를 처리하면

**Then** 화면 이동 없이 오류 안내를 표시한다.

### AC-08 메타데이터

**Given** 공유 URL로 링크 추가 화면이 열릴 때

**When** 폼 초기화가 완료되면

**Then** OG 조회가 자동으로 한 번 실행되고, 성공 결과는 **비어 있던 필드에만** 반영된다.
사용자가 조회 중에 수정한 필드는 유지된다.

### AC-08b 메타데이터와 사용자 수정

**Given** OG 조회가 진행 중이고 사용자가 제목을 직접 입력했을 때

**When** OG 결과가 나중에 도착하면

**Then** 사용자가 입력한 제목은 덮어쓰지 않는다.

### AC-09 메타데이터 실패

**Given** 네트워크 또는 대상 페이지 문제로 OG 조회가 실패할 때

**When** 사용자가 폼을 확인하면

**Then** URL과 host 기반 fallback 제목이 채워져 있어 바로 저장을 시도할 수 있고,
필요하면 제목을 수정한 뒤 저장할 수 있다.

### AC-10 수동 저장

**Given** 공유 URL이 폼에 채워졌을 때

**When** 사용자가 저장하지 않고 뒤로 가면

**Then** 링크가 생성되지 않는다.

### AC-11 개인정보

**Given** 공유 흐름에서 오류 또는 Analytics 이벤트가 발생할 때

**When** 로그와 이벤트 속성을 검사하면

**Then** raw URL, query string, 공유 원문이 포함되지 않는다.

### AC-12 중복 링크 (P1)

**Given** 동일 사용자가 이미 같은 정규화 URL을 저장했을 때

**When** 다시 저장을 시도하면

**Then** 기존 링크 열기 또는 중복 저장을 선택할 수 있다.

## 13. 테스트 및 검증 계획

### 13.1 자동 테스트

| 레이어 | 필수 케이스 |
|---|---|
| Domain unit | URL 단독, YouTube식 제목+URL, X식 문장+URL, hidden Unicode, trailing punctuation, non-http scheme, malformed URL, URL 없음, 복수 URL |
| Provider unit | pending set/consume, 인증 전 유지, 화면 전환 후 1회 consume, 연속 이벤트 정책 |
| Decision unit | cold/warm/foreground × 로그인 여부 × 편집 여부 action matrix |
| Widget | prefill 표시, OG 자동 호출 1회, 편집 중 스낵바, 오류 문구, 사용자 수정값 보존 |
| Router | 로그인 전 공유 → 로그인 후 `/links/new`, 내부 딥링크와 외부 URL 우선순위 |
| Integration | 공유 payload 모사 → 폼 → 저장 성공 → 목록 갱신 |
| Privacy regression | Analytics/로그 event parameter에 URL 원문이 없음을 검증 |

### 13.2 실기기 검증표

최소 다음 조합을 Android 실기기에서 기록한다.

| Source | 앱 종료 | 백그라운드 | 포그라운드 | 편집 중 |
|---|---:|---:|---:|---:|
| YouTube | 필수 | 필수 | 필수 | 필수 |
| X | 필수 | 필수 | 필수 | 필수 |
| Chrome 또는 기본 브라우저 | 필수 | 필수 | 필수 | 선택 |

각 케이스에서 확인할 항목은 공유 대상 노출, URL 정확성, 중복 이벤트 여부,
메타데이터 조회, 뒤로 가기, 저장 성공이다. 로그인/비로그인 케이스를 최소 한 번씩
포함하고, 프로젝트의 minSdk 근접 기기와 최신 targetSdk 기기에서 각각 확인한다.

## 14. 단계별 실행 계획

### Phase A — Android P0 완성

1. 현행 테스트에 미로그인 warm share, OG 자동 조회, OG 빈 필드 전용 merge RED 케이스 추가
2. pending 공유 모델을 cold/warm 동일 계약으로 통일하고 router consume 시점을 고정
3. 공유 진입 시 OG 자동 조회, 빈 필드 전용 merge, host fallback 제목 처리
4. `UrlSanitizer` scheme allowlist (`http`/`https` only) 정리
5. 공유·폼 UX 문구 지역화 (listener + OG/저장 메시지)
6. Analytics 이벤트와 URL 비수집 회귀 테스트 추가
7. 전체 analyze/test 및 Android dev/staging 빌드 검증
8. YouTube/X/브라우저 실기기 매트릭스 기록
   - 기록 위치: `docs/daily_task_log/` 세션 로그 또는 본 PRD 부록
   - 미기록이 있으면 Android P0 DoD를 닫지 않는다

### Phase B — P1 중복 및 연속 공유

1. URL 정규화 정책 단위 테스트 작성
2. 사용자 소유 링크 중복 조회 계약 추가
3. soft warning dialog와 기존 링크 열기 구현
4. 연속 공유 pending 정책 구현 및 테스트
5. 사용 데이터 확인 후 index/migration 필요성 판단

### Phase C — iOS URL-only

1. 현재 `receive_sharing_intent` 버전과 대체 패키지 유지보수 상태 재평가
2. Share Extension UI 범위 결정
3. App Groups, entitlement, signing 구성
4. Extension capture → 메인 앱 pending handoff 구현
5. iOS cold/warm, 로그인, 편집 중 시나리오 검증

### Phase D — payload 확장

이미지, URL 없는 텍스트, multi payload는 링크 엔티티와 저장 UX 변경이 필요하므로
별도 PRD로 진행한다.

## 15. 위험과 대응

| 위험 | 영향 | 대응 |
|---|---|---|
| 외부 앱마다 payload 형식이 다름 | 특정 앱에서 URL 추출 실패 | 앱별 실기기 fixture를 수집하고 공통 sanitizer 회귀 테스트에 추가 |
| plugin 유지보수 정체 | 최신 OS에서 수신 실패 가능 | Android 자체 platform channel 또는 유지되는 fork를 Phase C 전에 재평가 |
| cold/warm 이벤트 중복 처리 | 폼이 두 번 열림 | initial buffer reset, one-shot consume, 동일 lifecycle replay 테스트 |
| 인증 redirect 중 payload 유실 | 사용자가 공유를 다시 해야 함 | 인증 완료 전 pending 미소비, 로그인 후 이어가기 통합 테스트 |
| OG 조회 지연이 사용자 입력을 덮음 | 편집 내용 유실 | 요청 취소 및 빈 필드만 채우는 정책 유지 |
| raw URL 로깅 | 개인정보 노출 | reason code 기반 계측과 URL 비수집 테스트 |
| 중복 판정 오탐 | 저장 의도 차단 | P1은 경고만 제공하고 강제 unique 제약은 보류 |

## 16. Definition of Done

Android P0는 다음 조건을 모두 만족할 때 완료로 본다.

- FR-01~FR-12 및 AC-01~AC-11(AC-08b 포함) 충족
- cold/warm × 로그인/미로그인 모두 pending 유실 없음
- 공유 prefill 진입 시 OG 자동 조회 1회 + 빈 필드 전용 merge
- `flutter analyze` 0 issue
- 관련 단위/widget/router/integration 테스트 green
- dev/staging Android 빌드 성공
- YouTube, X, 브라우저 실기기 검증표가 문서에 기록됨
- 비로그인, 편집 중, URL 없음 시나리오에서 payload 또는 입력 유실 없음
- 공유 관련 Crashlytics/Analytics에 URL 원문이 포함되지 않음
- PRD §9 구현 현황과 CHANGELOG가 실제 코드와 일치

## 17. 결정 로그

| 일자 | 결정 | 이유 |
|---|---|---|
| 2026-04-21 | Android URL-only + 링크 폼 prefill을 Phase 1로 채택 | 북마크 핵심 흐름을 가장 작은 범위로 검증하기 위해서다. |
| 2026-04-21 | 자동 저장 대신 사용자 확인 후 저장 | 메타데이터, 태그, 컬렉션 수정 기회와 실패 복구 경로를 보존한다. |
| 2026-04-21 | `receive_sharing_intent 1.8.1` 채택 | Android PoC와 향후 iOS 확장의 초기 구현 비용을 줄인다. |
| 2026-04-21 | iOS Share Extension을 후속 Phase로 분리 | native extension, App Groups, signing 범위를 Android 검증과 분리한다. |
| 2026-06-20 | warm/foreground stream과 편집 화면 보호 구현 | 실행 중 공유 유실 및 기존 입력 덮어쓰기를 방지한다. |
| 2026-07-22 | PRD 2.0으로 현행화 | 이미 구현된 Android 기반과 남은 제품 완성도 작업을 분리하고 수용 기준을 명확히 한다. |
| 2026-07-22 | 중복 감지는 P1 soft warning으로 결정 | 중복 저장 의도를 차단하지 않으면서 데이터 품질을 개선한다. |
| 2026-07-22 | 코드 대조 후 Gap 보완 | OG 빈 필드 merge, warm 미로그인 pending 통일, scheme allowlist, 실기기 기록 위치를 문서에 명시한다. |
| 2026-07-22 | Phase A 코드 구현 완료 | OG 자동 조회, warm 미로그인 pending, scheme allowlist, 한국어 문구, Analytics funnel. 실기기 매트릭스는 수동 검증 대기. |

## 18. 관련 자료

- Android 수신 설정: `android/app/src/main/AndroidManifest.xml`
- 부트 처리: `lib/bootstrap.dart`
- 공유 payload 분류: `lib/features/share_intent/domain/service/shared_intent_service.dart`
- warm/foreground 처리: `lib/features/share_intent/presentation/widget/share_intent_listener.dart`
- URL 정제: `lib/shared/utils/url_sanitizer.dart`
- 링크 추가 화면: `lib/features/link/presentation/screens/link_add_screen.dart`
- 기존 구현 기록: `docs/daily_task_log/2026-04-21_session38.md`
- Android 공식 문서: https://developer.android.com/training/sharing/receive
- iOS App Extension Guide: https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/
