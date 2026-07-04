# In-App Update System — Design (LinkNote / Android)

> 3-모델(grok · codex · agy) 병렬 설계 + 통합. 첫 Google Play 출시 전 kill-switch
> 확보를 목표로 한다. 결론은 세 모델 만장일치.

## 1. 결정: 하이브리드 (Remote Config = 정책 · Play In-App Update = 설치 UX)

| 메커니즘 | 역할 | 도입 시점 |
| --- | --- | --- |
| **Firebase Remote Config** | 버전 게이트(강제/권장 판정)의 **단일 권위** | **V1 (지금)** |
| **Google Play In-App Update** | 매끄러운 인앱 다운로드 설치 UX | V1.5 (프로덕션 유저 확보 후) |

### 왜 Remote Config가 게이트인가
- Play In-App Update는 "이 유저가 **지금 실제로 받을 수 있는** 버전"만 감지 → 내부/클로즈드
  트랙에서 거의 동작하지 않고, 프로덕션 전파 지연(최대 24–48h)에 종속. **긴급
  kill-switch로 부적합.**
- Remote Config는 트랙·설치 경로와 무관하게 `min_supported_version_code` 한 값으로 **새
  빌드 없이 즉시** 강제 업데이트를 걸 수 있다. 이미 Firebase를 쓰고 있어 인프라 추가 0.
- **핵심**: 이 게이트는 **프로덕션 출시 전에 앱에 심어져 있어야** 나중에 kill-switch가
  작동한다. 그래서 첫 출시 전에 미리 구축한다.

## 2. 아키텍처 (Clean Architecture Lite, 프로젝트 컨벤션 준수)

추가 패키지: `firebase_remote_config`, `package_info_plus`. (`url_launcher` 재사용)

```
lib/features/app_update/
├── app_update_constants.dart              # RC 키 + 기본 스토어 URL
├── domain/
│   ├── entity/update_policy.dart          # freezed sealed: upToDate | optional | forced
│   ├── repository/i_app_update_repository.dart
│   └── usecase/check_update_policy_usecase.dart   # → Result<UpdatePolicy>
├── data/
│   ├── datasource/remote_config_update_datasource.dart
│   ├── datasource/package_info_datasource.dart
│   └── repository/app_update_repository_impl.dart
└── presentation/
    ├── provider/app_update_di_providers.dart      # @riverpod DI 배선
    ├── provider/app_update_provider.dart          # @Riverpod(keepAlive) AsyncNotifier
    ├── provider/update_dismissal_provider.dart     # "나중에" 로컬 영속(Hive settings)
    ├── widget/update_gate.dart                    # 강제=child 대체 · 권장=배너
    └── screen/force_update_screen.dart
```

### 트리거 & 통합 (라우터 비침습 설계)
- **콜드 스타트**: `UpdateGate`가 첫 프레임에 `appUpdateProvider`를 watch → `build()`에서
  RC best-effort fetch + versionCode 비교.
- **웜 리줌**: `UpdateGate`(WidgetsBindingObserver)가 `resumed`에서 `recheck()` 호출.
  RC의 `minimumFetchInterval`이 네트워크 스로틀을 담당하므로 별도 수동 스로틀 불필요.
- **강제 UI**: `MaterialApp.router`의 `builder` 안에서 `UpdateGate`가 `forced`일 때
  `child`를 통째로 `ForceUpdateScreen`으로 **대체**한다. GoRouter redirect를 쓰지 않는
  이유 → auth↔router refreshListenable 메커니즘이 민감해 최근 로그아웃 멈춤 버그의 원인이
  됐기 때문(격리가 목적). redirect 방식은 향후 대안으로만 남긴다.
- **권장 UI**: 기존 `_scaffoldMessengerKey`로 `MaterialBanner` 노출(비차단). ShareIntent
  스낵바와 동일 인프라 재사용.
- **에러 처리**: `Result<UpdatePolicy>`. fetch 실패는 **앱을 막지 않는다**. RC 플러그인이
  마지막 activate 값/기본값을 캐시하므로 오프라인에서도 이전 정책이 유지된다.

## 3. UX 흐름
- **권장(현재 < latest)**: "새 버전 사용 가능" MaterialBanner + [업데이트][나중에]. "나중에"는
  해당 `latestVersionCode`를 Hive `settings`에 저장 → **더 높은 버전에서만** 재노출. 매번 안 뜸.
- **강제(현재 < minSupported)**: 전체화면 차단, 뒤로가기 봉쇄(`PopScope(canPop:false)`).
  "보안·안정성을 위한 필수 업데이트" + [Play 스토어에서 업데이트]. 설치 후 재실행 시 재검사로 해제.

## 4. Remote Config 스키마 (제어판)

| 키 | 타입 | 기본값 | 용도 |
| --- | --- | --- | --- |
| `android_updates_enabled` | bool | `false` | 마스터 스위치(꺼짐이면 전부 no-op) |
| `android_min_supported_version_code` | int | `0` | 이 미만 → 강제 |
| `android_latest_version_code` | int | `0` | 이 미만 → 권장 |
| `android_update_message_required` | string | `""` | 강제 문구(옵션) |
| `android_update_message_optional` | string | `""` | 권장 문구(옵션) |
| `android_play_store_url` | string | `""` | 스토어 URL 오버라이드(옵션) |

> **불변 규칙**: `versionName`("1.1.6") 문자열 비교 금지. 반드시 `buildNumber`(=Android
> `versionCode`, `1.1.6+2`의 `2`)를 **int로 비교**. 기본값이 모두 0/false이므로 신규 설치는
> 첫 fetch 이전에 절대 강제되지 않는다.

**강제 거는 절차(빌드 없이)**: 패치 빌드가 대상 유저에게 배포 완료된 뒤 → 콘솔에서
`android_min_supported_version_code`를 패치 버전코드로 올리고 `android_updates_enabled=true`
publish. 롤백은 값을 내리면 즉시 해제.

## 5. 주의점
- Play 스테이지드 롤아웃 %와 RC `latest`가 어긋나면 유저 혼란 → 실제 받을 수 있는 버전으로만 설정.
- RC 스로틀: 시간당 과다 fetch 차단. 중앙 1곳(`UpdateGate`)에서만, `minimumFetchInterval`
  (prod 1h / dev 0)로 관리.
- Play In-App Update는 Internal App Sharing + prod 서명 빌드로만 테스트 가능(V1.5).

## 6. 단계
- **V1 (지금)**: RC 게이트 + `ForceUpdateScreen`(스토어 딥링크) + 권장 배너 + 로컬 dismiss.
  플러그인 없음, 저위험.
- **V1.5**: `in_app_update` 추가, `isProd && !kDebugMode` 게이팅으로 Flexible(권장)/
  Immediate(강제) 인앱 다운로드.
- **Later**: analytics 이벤트, RC 실시간 리스너, FCM 긴급 넛지, iOS.

## 부록: 모델별 특이 기여
- **grok**: 기존 인프라 재사용(ShareIntentListener·암호화 Hive settings·messengerKey 배너),
  V1.5 `isProd && !kDebugMode` 게이팅.
- **codex**: RC 스키마 정교화(마스터 스위치·문구 분리·스토어 URL·쿨다운), 강제화면 재시도 버튼,
  롤백 절차.
- **agy**: freezed `UpdateStatus` 상태 모델, V1 공수 ~1일 추정, 재노출 쿨다운.
