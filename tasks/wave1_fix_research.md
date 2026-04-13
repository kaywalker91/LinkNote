# Wave 1 Fix Research (Stage 1)

- **세션**: Session 21 (2026-04-12)
- **입력**: `docs/code_review/2026-04-12_wave1_security.md` (6 이슈)
- **파이프라인 단계**: ai-coding-pipeline Stage 1 (Research)
- **상태**: 코드 변경 없음. `tasks/wave1_fix_plan.md` 작성을 위한 사실 정리.
- **범위 외**: P3-A (proguard Hive keep rules) — 사용자 결정에 따라 본 스프린트 제외. `tasks/lessons.md` 한 줄 기록으로 종료.

---

## 0. 사전 확인 결과 (Wave 1 보고서 "Unverified assumptions" 직접 검증)

Wave 1 보고서가 제기한 8개의 unverified assumption 중 5개를 Session 21에서 직접 검증했다. 결과가 일부 이슈의 픽스 방향과 우선순위를 바꾼다.

### 0.1 Supabase `AuthChangeEvent.userDeleted` export 여부 → **Deprecated, 방송 불가 (no-op)**

- **Source**: `~/.pub-cache/hosted/pub.dev/gotrue-2.18.0/lib/src/constants.dart:39-53`
- **Fact**:
  ```dart
  enum AuthChangeEvent {
    initialSession('INITIAL_SESSION'),
    passwordRecovery('PASSWORD_RECOVERY'),
    signedIn('SIGNED_IN'),
    signedOut('SIGNED_OUT'),
    tokenRefreshed('TOKEN_REFRESHED'),
    userUpdated('USER_UPDATED'),

    @Deprecated('Was never in use and might be removed in the future.')
    userDeleted(''),                 // ← jsName이 빈 문자열
    mfaChallengeVerified('MFA_CHALLENGE_VERIFIED');
    ...
  }
  ```
- **의미**: `userDeleted`는 enum 멤버로 존재하지만 **`jsName`이 `''`이라 Supabase 서버가 절대 방송하지 않는다.** Session #5 당시의 "deprecated" 기록은 현재도 유효.
- **추가 발견**: `userUpdated('USER_UPDATED')`는 실제로 방송되며, Supabase 공식 문서 기준 **비밀번호 변경 시 emit**된다.
- **→ P1-C 픽스 방향 확정**:
  - `userDeleted` 분기 추가는 **무의미** (영원히 false).
  - 진짜 불일치 원인은 `auth_provider.dart:17-18` 주석이 "user deletion"을 선언했다는 것 → 주석에서 그 문구 제거.
  - 덤으로 `userUpdated` 분기를 추가해 비밀번호 변경 감지를 실질 지원 (Session #5 당시 "password change" 주석 의도를 실제로 구현).

### 0.2 Supabase 프로젝트 Email Confirmation 설정 → **OFF (사용자 확인 완료)**

- **Source**: 사용자가 Supabase Dashboard → Authentication → Providers → Email → "Confirm email" 토글 상태 직접 확인.
- **Fact**: 현재 OFF.
- **→ P1-B 긴급도 재평가**: 현재 실행 중 버그는 아님 (response.session이 항상 non-null로 반환). **Dashboard에서 ON으로 바꾸는 순간 잠재 결함이 즉시 실행 중 버그로 바뀐다.** 코드 픽스는 여전히 필요 (future-proof / defense-in-depth). 본 스프린트 포함 대상.

### 0.3 GitHub Branch Protection `main` 현재 설정 → **보호 없음 (404)**

- **Command**: `gh api repos/kaywalker91/LinkNote/branches/main/protection`
- **Response**: `{"message":"Branch not protected","status":"404"}`
- **Fact**: `main` 브랜치에 **어떤 보호 규칙도 존재하지 않는다.** 직접 push 가능, required status checks 없음, PR 강제 없음.
- **→ P2-B 재평가**: Wave 1 보고서는 "`security` job을 required checks에 등록해야 실효성 있음"이라고 기술했으나, **실제로는 required checks 설정 자체가 전무.** 픽스가 두 단계 필수:
  1. `.github/workflows/ci.yml`: `build.needs`에 `security` 추가.
  2. `gh api -X PUT repos/kaywalker91/LinkNote/branches/main/protection`: 보호 규칙을 **신규 생성**하고 `Analyze`, `Test`, `Build (Android Dev Debug)`, `Security Scan` 4개를 required status checks로 등록.
- **→ 사용자 결정 확정**: 본 스프린트에 두 단계 모두 포함 (Session 21 AskUserQuestion 응답).
- **워크플로우 변화 경고**: 앞으로 `main` 직접 push 불가, PR + CI 통과 필수.

### 0.4 `storage_service.dart` Hive 박스 암호화 여부 → **암호화되어 있음** ✅

- **Source**: `lib/core/storage/storage_service.dart:6-29`
- **Fact**: 모든 박스(`settings`, `links`, `collections`, `notifications`)가 `HiveAesCipher(encryptionKey)`로 암호화되어 열린다.
  ```dart
  final cipher = HiveAesCipher(encryptionKey);
  await Hive.openBox<String>('settings', encryptionCipher: cipher);
  await Hive.openBox<Map<dynamic, dynamic>>('links', encryptionCipher: cipher);
  await Hive.openBox<Map<dynamic, dynamic>>('collections', encryptionCipher: cipher);
  await Hive.openBox<Map<dynamic, dynamic>>('notifications', encryptionCipher: cipher);
  ```
- 키는 `FlutterSecureStorage`(Android Keystore-backed) 에 저장되며, Keystore 자료는 **Android Auto Backup 대상이 아니다**.
- **→ P2-A 위험도 재평가**:
  - 현재 allowBackup 기본값이 true이더라도 **백업된 `.hive` 파일은 복호화 키가 없어 무용지물**.
  - 공격 경로: "다른 기기로 복원 후 앱 데이터 읽기"는 차단됨 (Keystore 재생성 시 키 일치 불가).
  - 남은 위험: 루팅된 기기에서 앱 프로세스 메모리 덤프, 또는 백업 파일 자체 유출 후 미래 취약점 악용 — 둘 다 **이론적**.
  - **결론**: 실질 공격면 거의 없음. defense-in-depth 목적으로 P2 유지하되 "위험 완화됨" 근거 기술.

### 0.5 `semgrep/semgrep-action@v1` 동작 (P2-B 보강) → **부분 확인**

- **Source**: `.github/workflows/ci.yml:129-137` 직접 읽기.
- **Fact**:
  - `continue-on-error` 없음 → step 단위는 정상 fail.
  - Fork PR에서 `SEMGREP_APP_TOKEN` 미주입 시 action 동작은 action 문서 재확인 필요.
- **추가 맥락**: LinkNote는 단일 owner 리포지토리. public fork PR 시나리오가 실무에 없음. **영향 낮음**, 구현 세션에서 한 번 더 확인.

---

## 1. P1-A · `dio_client.dart` 401 핸들러가 `SignOutUsecase`를 우회

### 1.1 영향 파일 (Read)

- `lib/core/network/dio_client.dart:27-33` — 바이패스 호출 지점
- `lib/core/network/auth_interceptor.dart:20-26` — 401 콜백 트리거 지점
- `lib/features/auth/domain/usecase/sign_out_usecase.dart:20-30` — 호출되어야 할 계약
- `lib/features/auth/presentation/provider/auth_di_providers.dart:41-49` — `signOutUsecaseProvider` DI 확인
- `lib/shared/providers/session_expired_provider.dart` — 기존 세션 만료 UX 연결 지점

### 1.2 영향 파일 (Write)

- `lib/core/network/dio_client.dart` — `onUnauthorized` 콜백 교체
- `lib/features/auth/domain/usecase/sign_out_usecase.dart` — **조건부**: `clearAll` 가드 제거 검토 (Stage 2 잔여 질문)

### 1.3 Dependencies

- `signOutUsecaseProvider`가 이미 `auth_di_providers.dart:41-49`에 정의되어 있고 `LinkLocalDataSource` / `CollectionLocalDataSource` / `NotificationLocalDataSource` 3개를 주입받음 → **추가 DI 불필요.**
- `dio_client.dart`는 이미 `Ref` 파라미터를 받으므로 `ref.read(signOutUsecaseProvider).call()` 호출 가능.

### 1.4 Side effects

- **정상 경로(수동 로그아웃)**: `AuthProvider.signOut()` → `SignOutUsecase.call()` → clearAll. **변화 없음.**
- **401 경로**: 이전에는 Supabase SDK 직접 호출로 clearAll 스킵. 픽스 후 clearAll 호출 → Session #5 P1-3 계약 복원.
- **잠재 문제**: SignOutUsecase의 `if (result.isSuccess)` 가드 (sign_out_usecase.dart:22) 때문에 **서버 signOut이 실패하면 clearAll이 돌지 않는다.** 401 경로에서는 세션이 이미 무효라 signOut 실패 가능성이 낮지만, 네트워크 오류 시 clearAll이 스킵되는 엣지가 남는다.

### 1.5 Edge cases

- **멱등성**: 짧은 시간 안에 여러 401이 오면 `onUnauthorized`가 여러 번 호출될 수 있다. Supabase `signOut()`은 이미 signedOut 상태에서 no-op이므로 안전. `clearAll()`도 멱등 (빈 박스 clear → 효과 없음).
- **생성 시점**: `dio_client`가 생성되기 전의 401은 인터셉터 자체가 없어 발생 불가능.
- **`sessionExpiredProvider.trigger()` 순서**: 현재 trigger가 signOut보다 먼저 호출됨. 픽스 후에도 순서 유지하여 UX 상태 플리커를 방지.
- **signOut 실패 시 UX**: `dio_client`의 `onUnauthorized`는 `fire-and-forget` 형태이므로 usecase의 `Result<void>`를 무시. UI는 `sessionExpiredProvider`로 복구.

### 1.6 회귀 방지 포인트

- `test/core/network/auth_interceptor_test.dart`의 기존 3건 (callback 호출, 403 제외, null callback) 모두 **GREEN 유지**.
- 새 테스트는 `dio_client` 레벨에서 ProviderContainer + mock SignOutUsecase로 검증 (auth_interceptor는 콜백을 받기만 하므로 401 → usecase 호출 검증은 dio 생성 함수 레벨에서 해야 함).

---

## 2. P1-B · `signUp()`이 `response.session == null`일 때도 `Authenticated` 상태로 승격

### 2.1 영향 파일 (Read)

- `lib/features/auth/data/datasource/auth_remote_datasource.dart:46-70` — 결함 지점
- `lib/features/auth/presentation/screens/signup_screen.dart:38-44` — 에러 처리 UX
- `lib/core/error/failure_ui.dart` — `failureUiFromError` 매핑 확인

### 2.2 영향 파일 (Write)

- `lib/features/auth/data/datasource/auth_remote_datasource.dart` — `signUp()` 메서드에 session null 분기 추가

### 2.3 Dependencies

- `signup_screen.dart`는 이미 `failureUiFromError` → `showErrorSnackBar(ui.message)` 체인이 작동하므로, `Failure.auth(message: ...)`를 반환하면 그 메시지가 SnackBar에 그대로 표시된다. **UI 변경 불필요.**
- `failure_ui.dart`가 `Failure.auth`의 `message`를 어떻게 다루는지 Stage 2 작성 전에 한 번 더 확인할 필요 있음 (기본 매핑이 있으면 오버라이드 방식 조정).

### 2.4 Side effects

- **Email Confirmation = OFF (현재)**: `response.session`이 항상 non-null → 기존 행동 유지 (변화 없음).
- **Email Confirmation = ON (미래)**: "이메일 확인 링크가 발송되었습니다. 확인 후 로그인해 주세요." SnackBar 표시 + Authenticated 상태 미승격 → GoRouter 리디렉션 없음 → 사용자가 signup_screen에 머무름.
- P1-A와의 연쇄 차단: signUp → currentSession null → 401 → dio_client.onUnauthorized → 캐시 clearAll 경로가 **애초에 발생하지 않음.** (P1-B가 P1-A의 트리거 조건 중 하나를 제거)

### 2.5 Edge cases

- **이미 존재하는 이메일로 signUp**: Supabase가 `AuthException` 발생 → 기존 catch 경로 (`Failure.auth(message: e.message)`). **영향 없음.**
- **비밀번호 정책 위반**: `AuthException` 경로. **영향 없음.**
- **`response.user == null` + `response.session == null`**: 현재 코드에 이미 `user == null` 분기가 있음 (line 56-58). 순서상 user null 검사가 먼저 실행되어야 하고, 그 다음에 session null 검사가 실행되도록 배치.
- **다국어화**: 메시지는 한국어 ("이메일 확인 링크가 발송되었습니다..."). 본 앱이 한국어 사용자 대상임을 전제. i18n 체계가 있으면 상수화 고려, 없으면 인라인.

### 2.6 회귀 방지 포인트

- 기존 `auth_remote_datasource_test.dart`가 존재하는지 Stage 2에서 확인 후, 없으면 신규 생성.
- `signIn()` 경로는 이 픽스와 무관 → 회귀 가능성 없음.

---

## 3. P1-C · `auth_provider.dart` 구독 가드가 실제 Supabase 이벤트와 불일치

### 3.1 영향 파일 (Read)

- `lib/features/auth/presentation/provider/auth_provider.dart:17-27`
- (참고만) `~/.pub-cache/hosted/pub.dev/gotrue-2.18.0/lib/src/constants.dart:39-53`

### 3.2 영향 파일 (Write)

- `lib/features/auth/presentation/provider/auth_provider.dart` — 주석 + 분기 조건 수정

### 3.3 픽스 방향 (사전 확인 #0.1 결과 반영)

- **주석 수정**: line 17-18의 "password change, **user deletion**"을 "password change (via userUpdated event)"로 교체. "user deletion" 제거.
- **분기 추가**: `AuthChangeEvent.signedOut || tokenRefreshed`에 `|| AuthChangeEvent.userUpdated` 추가. **`userDeleted` 추가는 금지** (영원히 false).

### 3.4 Side effects

- `userUpdated` 이벤트는 Supabase에서 **비밀번호 변경 시 emit**. 현재 LinkNote에 프로필 편집/비밀번호 변경 화면은 없지만, 관리자가 Supabase Dashboard에서 사용자 이메일/메타데이터를 변경할 때도 emit.
- `invalidateSelf()`가 호출되면 `build()` 재실행 → `checkSessionUsecase()` 재호출 → 현재 세션이 여전히 유효하면 동일한 `Authenticated` 상태 반환, 무효하면 `Unauthenticated`로 전환.
- **과도한 invalidate 우려**: 현재 앱에 자체 userUpdate 트리거가 없으므로 실무상 추가 invalidate는 거의 발생하지 않음. 미래에 프로필 편집 화면이 추가되면 재검토.

### 3.5 Edge cases

- **구독 재시작 중 이벤트 유실**: `ref.onDispose(subscription.cancel)`가 이미 배선되어 있어 provider dispose 시 정상 정리.
- **동시 다중 이벤트**: 같은 틱에 `tokenRefreshed + userUpdated`가 같이 오면 `invalidateSelf`가 두 번 호출될 수 있음. Riverpod이 내부적으로 dedupe하므로 실 영향 없음.

### 3.6 회귀 방지 포인트

- 기존 `auth_provider_test.dart`가 `signedOut`/`tokenRefreshed` 분기를 커버하는지 확인.
- 신규 테스트: `userUpdated` 이벤트 수신 → `invalidateSelf` 호출 검증 (Supabase stream mock 필요).

---

## 4. P2-A · `AndroidManifest.xml` `android:allowBackup` 미지정

### 4.1 영향 파일 (Write)

- `android/app/src/main/AndroidManifest.xml:3-6` — `<application>` 태그

### 4.2 Dependencies

- 없음. Gradle 빌드에 영향 없음.

### 4.3 위험도 재평가 (사전 확인 #0.4 결과 반영)

- Hive 박스 전부 `HiveAesCipher`로 암호화되어 있고 키가 `FlutterSecureStorage`(Keystore)에 있음.
- Android Auto Backup은 Keystore 자료를 **백업하지 않는다.** → 백업된 `.hive` 파일은 다른 기기/설치에서 복호화 불가 → **실질 데이터 유출 경로 차단.**
- 본 픽스의 목적은 **defense-in-depth**: (1) 미래에 새 암호화되지 않은 저장소가 추가될 가능성 차단, (2) 보안 baseline을 명시적으로 선언, (3) Android 12+ `dataExtractionRules` 지침 준수.

### 4.4 픽스 옵션

- **옵션 A (권장, 1줄)**: `<application>` 태그에 `android:allowBackup="false"` 추가.
- **옵션 B (과공학)**: `res/xml/backup_rules.xml` + `data_extraction_rules.xml` 생성해 Hive 디렉토리 제외, 그 외 사용자 설정은 백업 허용. 현재 Hive 외의 사용자 설정이 거의 없으므로 ROI 없음.

### 4.5 Side effects

- **사용자 기기 이전 시**: 앱 데이터 백업이 복원되지 않음. Supabase가 원격 저장소이므로 로그인 재수행으로 자동 복원. **사용자 영향 미미.**
- **앱 재설치**: 로컬 캐시 리셋됨. 기존 동작과 동일 (Hive 암호화 키가 Keystore에 남아있어도 앱 제거 시 동반 삭제).

### 4.6 회귀 방지 포인트

- `flutter build apk --debug --flavor dev` 성공 확인.
- 기존 smoke test (앱 실행 → 링크 추가 → 앱 재시작 후 링크 유지) 통과 확인.

---

## 5. P2-B · CI + Branch Protection

### 5.1 영향 파일 (Write)

- `.github/workflows/ci.yml:86-118` — `build` job `needs` 수정
- `.github/workflows/ci.yml:38-84` — `test` job `needs` 검토 (현재 needs 없음, 병렬 실행)

### 5.2 영향 외부 상태

- **GitHub API**: `gh api -X PUT repos/kaywalker91/LinkNote/branches/main/protection` 로 보호 규칙 **신규 생성**.

### 5.3 Dependencies

- `gh` CLI 인증 상태 확인 필요 (`gh auth status`).
- 사용자가 리포지토리 owner 권한 보유 확인.

### 5.4 픽스 스펙

**Step 1 — ci.yml 수정**:
```
jobs:
  analyze: (변화 없음)
  test:    (변화 없음, 현재 needs 없음 유지)
  build:
    needs: [analyze, security]   # ← security 추가
  security: (변화 없음)
```

**Step 2 — Branch Protection (gh api)**:
- Endpoint: `PUT repos/kaywalker91/LinkNote/branches/main/protection`
- Required status checks: 4개 (`Analyze`, `Test`, `Build (Android Dev Debug)`, `Security Scan`) — job의 `name` 필드 기준
- `strict: true` (branch must be up to date before merging)
- `enforce_admins: false` (개인 프로젝트, 긴급 수정 시 admin 우회 허용)
- `required_pull_request_reviews: null` (단독 개발자, review 강제 해제)
- `restrictions: null`
- `allow_force_pushes: false`
- `allow_deletions: false`

### 5.5 Side effects

- **개발자 워크플로우 변화**: `main` 직접 push **불가**. 앞으로 모든 변경은 feature branch → PR → CI 통과 → 머지.
- **긴급 수정 경로**: `enforce_admins: false` 덕분에 admin(사용자 본인)이 우회 가능. 단 남용 시 의미 상실.
- **`gh` 명령 실패 시**: JSON body format 오류 가능성 → Session 22 구현 시 `--input` flag + stdin heredoc으로 안전하게 전달.

### 5.6 Edge cases

- **리포지토리 owner가 아닌 경우**: `gh` 호출이 403. 사용자 본인이 `kaywalker91/LinkNote` owner이므로 해당 없음.
- **이미 보호 규칙이 존재하는 경우**: `PUT`은 전체 덮어쓰기 → 기존 설정 무시. 현재 404이므로 해당 없음.
- **Semgrep step이 fork PR에서 silent-skip하는 경우**: 단일 owner 리포라 실무 영향 없음. (사전 확인 #0.5)

### 5.7 회귀 방지 포인트

- 수동 검증 (Session 22 후반): 의도적 실패 커밋을 feature branch → PR로 올려 CI가 머지를 차단하는지 확인.
- 기존 CI 통과 커밋은 영향 없음 (green PR은 계속 머지 가능).

---

## 6. 회귀 방지 체크리스트 (Session #1-6 보안 감사 픽스 재검증)

Wave 1 보고서의 `Regression Check Matrix`를 Session 22 구현 완료 시점에 재실행해야 한다.

| 픽스 | 세션 | Session 21 예상 결과 | 재검증 방법 |
|---|---|---|---|
| P1-1 onAuthStateChange `ref.onDispose` | S#5 | ✅ 유지 | `auth_provider.dart:27` 확인 |
| P1-2 AuthInterceptor 401 콜백 배선 | S#5 | ✅ 유지 | `auth_interceptor.dart:22-24` 확인 |
| P1-2 연장: 401 시 clearAll | S#5 | **✅ 복원 (P1-A 픽스 후)** | dio_client → SignOutUsecase 경로 재확인 |
| P1-3 SignOut 3x clearAll | S#5 | ✅ 유지 | `sign_out_usecase.dart:23-27` 확인 |
| P1-4 sanitizeTsQuery | S#5 | ✅ 유지 | `search_remote_datasource.dart:16-24` 확인 |
| P2-1 Global error handler | S#6 | ✅ 유지 | `bootstrap.dart:38-39` 확인 |
| P2-2 CI Semgrep continue-on-error 제거 | S#6 | ✅ 유지 + **gating 갭 해결 (P2-B 픽스 후)** | ci.yml step 단위 확인 + build.needs 확인 |
| P2-3 envied 허용 키 정책 | S#6 | ✅ 유지 | `env_*.dart` 키 2개만 존재 확인 |

**구현 후 추가 검증**:
- `flutter analyze` 0 issues 유지
- 전체 테스트 315+ GREEN 유지 (Session 20 기준)
- Session 22 종료 전 위 매트릭스 전체 재확인

---

## 7. 블로커 / Stage 2 진입 전 잔여 질문

다음 항목은 `tasks/wave1_fix_plan.md` 섹션 0에 명시되어 Session 22 Stage 4 진입 전 최종 확정된다:

1. **SignOutUsecase `clearAll` 가드 변경 여부** — 401 경로에서도 항상 clearAll 실행 (권장) vs 서버 성공 시에만 (현 상태).
2. **`failure_ui.dart`의 `Failure.auth` 메시지 매핑** — Stage 2 작성 전 파일 1건 추가 확인 필요.
3. **`test/features/auth/data/datasource/auth_remote_datasource_test.dart` 파일 존재 여부** — 없으면 신규 생성, 있으면 기존 그룹에 case 추가.
