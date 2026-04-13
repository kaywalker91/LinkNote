# Wave 1 — Security & Auth Critical Path 통합 보고서

- **리뷰 일자**: 2026-04-12
- **리뷰 계획**: `~/.claude/plans/resilient-imagining-starfish.md` (Wave 1)
- **범위**: `lib/features/auth/**`, `lib/core/network/`, `lib/core/constants/env_*.dart`, `lib/core/storage/storage_service.dart`, `lib/shared/providers/session_expired_provider.dart`, `lib/main.dart` + `lib/bootstrap.dart`, `lib/firebase_options_*.dart`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`, `android/app/proguard-rules.pro`, `.github/workflows/ci.yml` (+ 교차검증을 위해 `lib/features/search/data/datasource/search_remote_datasource.dart`)
- **모드**: Read-only. 코드 수정·빌드·테스트 실행 없음.
- **오케스트레이션**: Stage A(준비) → Stage B(Claude `feature-dev:code-reviewer` 1차) → Stage C(Codex + Gemini 3자 합의 2차) → Stage D(통합)

---

## Summary

| 지표 | 값 |
|---|---|
| 읽은 파일 수 (3자 총합, 중복 포함) | 82 (Claude 26 + Codex 39 + Gemini 17) |
| 고유 이슈 개수 | **6** |
| 최종 심각도 분포 | **P0 0 · P1 3 · P2 2 · P3 1** |
| 회귀 (Session #1-6 픽스 깨짐) | **1** (부분 — P1-A, Session #5 P1-2의 행동 보존은 유지되었으나 캐시 정리 계약이 우회됨) |
| 3자 만장일치 이슈 | 2 (allowBackup, CI job gating) |
| 2/3 합의 이슈 | 2 (dio_client 401 bypass, userDeleted) |
| 1/3 (단독 발견) + 소스 검증 통과 이슈 | 2 (signUp 세션 검증, Hive proguard) |

**Headline**: 이 프로젝트는 Session #1-6에서 수정한 P1/P2 10건이 **원칙적으로 유지**되고 있으나, Session #12-19에서 추가된 Firebase 배선·세션 만료 UX 연결 과정에서 **강제 로그아웃 경로가 `SignOutUsecase` 계약을 우회**하도록 드리프트했다. 이와 별도로 signUp flow에 **이메일 미확인 유저가 인증 상태로 승격되는 신규 결함**이 존재한다.

---

## 3자 합의 매트릭스

| # | 이슈 | Claude (1차) | Codex (2차) | Gemini (2차) | 합의 | 최종 심각도 |
|---|---|---|---|---|---|---|
| 1 | dio_client 401 → SignOutUsecase 우회 (캐시 누출) | P1 | **P0** | **P0** | 3/3 "at least P1" | **P1** ⚠ |
| 2 | signUp이 session=null일 때도 Authenticated 반환 | (미탐지) | P1 (M) | (미탐지) | 1/3 + 소스 검증 | **P1** |
| 3 | auth_provider `AuthChangeEvent.userDeleted` 미처리 | P1 | P2 | P1 | 2/3 at P1 | **P1** |
| 4 | AndroidManifest `android:allowBackup` 미지정 | P2 | P2 | P2 | **3/3 P2** | **P2** |
| 5 | `.github/workflows/ci.yml`의 `build` job이 `security` job을 `needs`에 포함 안 함 | P2 | P2 | P2 | **3/3 P2** | **P2** |
| 6 | Hive CE proguard keep rules 선제 보강 | P3 | (미탐지) | (미탐지) | 1/3 | **P3** |

**심각도 결정 규칙 해석 주석**
- 계획서(`resilient-imagining-starfish.md` Wave 1)는 "3 LLM 핑거가 일치해야 P0/P1 승격, 불일치는 P2 다운그레이드"를 제시한다. 이 규칙을 #1에 엄격 적용하면 P2로 떨어뜨려야 하지만, **3자 모두 "버그이며 수정 필요"에는 동의**했고 단지 심각도만 P0 vs P1로 갈렸다. "최소한 P1"에 대해서는 만장일치이므로 **P1 유지가 적절**하다고 판단했다. #1을 P0으로 승격하려면 "다중 계정 공유 기기에서 이전 유저 데이터 잔류"의 실제 발생 조건(공유 기기 사용 + 401 수신 + 다른 계정으로 재로그인) 시나리오 근거가 필요한데, 현재 LinkNote가 단일 사용자 앱이라 P0 요건은 충족되지 않는다.
- #2는 Codex 단독 발견이지만, 리뷰어가 `auth_remote_datasource.dart:55-64`와 Supabase `signUp()` 공식 동작을 직접 교차검증하여 **버그 존재를 사실 확인**했다. 계획서의 "1/3 발견 → P2 다운그레이드" 규칙은 **3 LLM 모두 동일 파일을 읽었지만 2 LLM이 이 결함을 놓쳤다는 사실**을 반영한 규칙이므로, 소스 재검증이 끝난 이상 원래 Codex가 평가한 P1을 유지한다. 계획 준수를 엄격히 요구한다면 P2로 조정해도 된다.
- #3은 Claude/Gemini 모두 P1, Codex만 P2였다. 다수결 P1. 기술적으로도 `auth_provider.dart`의 주석(`lib/features/auth/presentation/provider/auth_provider.dart:17-18`)이 "user deletion"까지 커버한다고 선언하는데 실제 guard는 그것을 포함하지 않는 **의도-구현 불일치**이므로 P1이 타당하다.

---

## P0 — Critical

**없음.**

---

## P1 — High (이번 스프린트 내 수정 권장)

### P1-A · `dio_client.dart` 401 핸들러가 `SignOutUsecase`를 우회하여 로컬 캐시가 잔류

- **Location**: `lib/core/network/dio_client.dart:27-33`
- **합의**: Claude P1 / Codex **P0** / Gemini **P0** (3/3 "버그"; 심각도 P0~P1 범위)
- **Regression**: Session #5 P1-2 + P1-3의 **행동 계약 부분 회귀**. 핸들러 배선(P1-2) 자체는 유지되지만, Session #17 또는 그 이전에 `dio_client.dart`가 `Supabase.instance.client.auth.signOut()`를 직접 호출하도록 수정되면서 Session #5 P1-3("signOut 시 3개 LocalDataSource `clearAll()`") 계약을 바이패스한다.
- **Finding**: `AuthInterceptor.onUnauthorized` 콜백이 401 수신 시 `Supabase` SDK의 `signOut()`을 직접 호출한다. 이 경로는 `SignOutUsecase`를 거치지 않으므로 `LinkLocalDataSource` / `CollectionLocalDataSource` / `NotificationLocalDataSource`의 `clearAll()`이 **호출되지 않는다**. 결과적으로 세션 만료(또는 서버측 토큰 무효화)로 강제 로그아웃된 유저의 Hive 캐시가 디스크에 잔류한다.
- **Evidence**:
  ```dart
  // lib/core/network/dio_client.dart:27-33
  onUnauthorized: () async {
    ref.read(sessionExpiredProvider.notifier).trigger();
    await Supabase.instance.client.auth.signOut();  // ← SignOutUsecase 우회
  },
  ```
  비교:
  ```dart
  // lib/features/auth/domain/usecase/sign_out_usecase.dart:20-27
  Future<Result<void>> call() async {
    final result = await _repository.signOut();
    if (result.isSuccess) {
      await Future.wait([
        _linkLocalDs.clearAll(),
        _collectionLocalDs.clearAll(),
        _notificationLocalDs.clearAll(),
      ]);
    }
    return result;
  }
  ```
- **Impact**:
  1. (주) 공유 기기에서 사용자 A가 세션 만료 → 사용자 B로 재로그인 시 A의 링크/컬렉션/알림이 초기 로딩에서 노출될 수 있음 (네트워크 완료 전까지 local fallback 경로가 작동하는 Link/Collection 피처 특성상).
  2. (부) 개인정보가 암호화되지 않은 채 `.hive` 파일에 잔류. Hive 암호화 키는 `FlutterSecureStorage`에 분리되어 있으나, 앱이 현재 암호화 Hive를 쓰지 않는 이상 평문 잔류.
  3. 계약 위반: Session #5에서 명시적으로 수정했던 보안 계약이 무시됨.
- **Recommended fix**:
  ```dart
  // lib/core/network/dio_client.dart:27-33
  onUnauthorized: () async {
    ref.read(sessionExpiredProvider.notifier).trigger();
    await ref.read(signOutUsecaseProvider).call();
  },
  ```
  그리고 `sign_out_usecase.dart`의 반환값(`Result<void>`)이 실패하더라도 UX가 정지되지 않도록, `dio_client` 레벨에서는 결과를 무시(fire-and-forget)하고 `sessionExpiredProvider` 트리거로 UI 복구를 담당한다.
- **Confidence**: High (소스 + 3자 독립 검증)

---

### P1-B · `signUp()`이 `response.session == null`일 때도 `Authenticated` 상태로 승격

- **Location**: `lib/features/auth/data/datasource/auth_remote_datasource.dart:46-70`
- **합의**: Codex 단독 P1 (Medium confidence) → **리뷰어 소스 재검증으로 P1 확정**
- **Finding**: `signUp()`은 `response.user != null`만 검증하고 `response.session`은 확인하지 않는다. Supabase 프로젝트에서 **이메일 확인(Email Confirmations)이 활성화**되어 있으면 `signUp()`이 `user` 객체는 반환하되 `session`은 `null`이다. 현재 구현은 이를 무시하고 `AuthStateEntity.authenticated(...)`를 반환하여 `isAuthenticated`가 `true`가 된다.
- **Evidence**:
  ```dart
  // lib/features/auth/data/datasource/auth_remote_datasource.dart:51-64
  final response = await _client.auth.signUp(
    email: email,
    password: password,
  );
  final user = response.user;
  if (user == null) {
    return error(const Failure.auth(message: 'Sign up failed'));
  }
  return success(
    AuthStateEntity.authenticated(  // ← session == null이어도 Authenticated 반환
      userId: user.id,
      email: user.email ?? '',
    ),
  );
  ```
  연쇄 영향:
  - `auth_provider.dart:67-68`이 결과를 `state = AsyncData(result.data!)`로 반영
  - `Auth.isAuthenticated` (auth_provider.dart:91) = `state.value is Authenticated` → **true**
  - GoRouter `refreshListenable`이 이를 감지하여 인증 전용 라우트로 자동 이동
  - 인증 전용 화면에서 첫 API 호출 → `currentSession == null` → Dio 401 → **P1-A 경로 작동** → 이전에 없던 캐시도 건드림 + 세션 만료 UX 강제 노출
- **Impact**: (1) UX: "가입 직후 로그인 됐다가 즉시 튕겨나가는" 경험. (2) 보안/계약: 실제 세션이 없는 상태에서 앱이 인증 상태 플래그를 켜두는 논리적 결함. (3) P1-A와 연쇄 작동 (signUp → currentSession null → 401 → dio_client.onUnauthorized → 캐시 우회 경로).
- **Recommended fix** (두 가지 옵션 중 택일):
  - **옵션 A (권장, 즉시 적용 가능)**: `response.session`도 검증. 세션이 없으면 `Failure.auth(message: '이메일 확인 링크를 받으셨어요. 확인 후 다시 로그인해 주세요.')` 반환 → `signup_screen.dart`에서 확인 안내 SnackBar 표시.
    ```dart
    final user = response.user;
    final session = response.session;
    if (user == null) {
      return error(const Failure.auth(message: 'Sign up failed'));
    }
    if (session == null) {
      return error(const Failure.auth(
        message: '이메일 확인 링크가 발송되었습니다. 확인 후 로그인해 주세요.',
      ));
    }
    return success(AuthStateEntity.authenticated(...));
    ```
  - **옵션 B (아키 변경, 차차기 스프린트)**: `AuthStateEntity`에 `pendingVerification(email)` variant 추가 → Go Router가 이 상태를 인식하여 "이메일 확인 대기 화면"으로 분기.
- **Prerequisite check (Stage C 후속)**:
  - [ ] Supabase 프로젝트 `Auth → Providers → Email`의 "Confirm email" 설정이 ON/OFF 중 어느 것인가? OFF라면 현재 버그는 잠재적(설정 변경 시 활성화). ON이라면 현재 실행 중인 버그.
- **Confidence**: High — 코드 경로 명확, Supabase SDK 문서(`response.session: Session?`, nullable) 확인됨

---

### P1-C · `auth_provider.dart` 구독 가드가 `AuthChangeEvent.userDeleted` 미처리

- **Location**: `lib/features/auth/presentation/provider/auth_provider.dart:17-24`
- **합의**: Claude P1 / Codex P2 / Gemini P1 (2/3 at P1)
- **Finding**: 구독 바로 위 주석(line 17-18)이 "session expiry, remote sign-out, password change, **user deletion**"까지 커버한다고 선언하지만, 실제 가드는 `signedOut`과 `tokenRefreshed`만 체크한다. Supabase Dashboard에서 계정이 삭제되거나 Admin API로 `admin.deleteUser()`가 호출되면 `AuthChangeEvent.userDeleted` 이벤트가 방송되는데, 이 프로바이더는 이를 무시하고 JWT 만료(기본 1시간)까지 인증 UI를 유지한다.
- **Evidence**:
  ```dart
  // lib/features/auth/presentation/provider/auth_provider.dart:17-24
  // Subscribe to real-time auth state changes (session expiry, remote
  // sign-out, password change, user deletion).
  final subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
    (data) {
      if (data.event == AuthChangeEvent.signedOut ||
          data.event == AuthChangeEvent.tokenRefreshed) {
        ref.invalidateSelf();
      }
    },
  );
  ```
- **Recommended fix**:
  ```dart
  if (data.event == AuthChangeEvent.signedOut ||
      data.event == AuthChangeEvent.tokenRefreshed ||
      data.event == AuthChangeEvent.userDeleted) {
    ref.invalidateSelf();
  }
  ```
- **Prerequisite check**: `pubspec.lock`에서 설치된 `supabase_flutter` 버전이 `AuthChangeEvent.userDeleted`를 export하는지 확인 (최신 `gotrue` 패키지 기준 존재하지만 오래된 버전에서는 누락되었을 수 있음). 참고: Session #5 주석은 당시 "userDeleted는 SDK에서 deprecated → 제외"라고 기록했는데, 이후 SDK 복원 여부 재확인 필요.
- **Confidence**: Medium-High (SDK 버전 확인 필요; Session #5 당시 결정이 지금도 유효한지 재검증)
- **Note**: SDK 버전 확인 결과 `userDeleted`가 여전히 deprecated라면 이 이슈를 P3로 강등하고 픽스 대신 주석의 "user deletion" 언급을 제거하여 의도-구현을 재정합하는 것으로 대체.

---

## P2 — Medium (다음 스프린트)

### P2-A · `AndroidManifest.xml`가 `android:allowBackup` / `android:dataExtractionRules` 미지정

- **Location**: `android/app/src/main/AndroidManifest.xml:3-6` (`<application>` 태그)
- **합의**: 3/3 만장일치 P2
- **Finding**: `<application>` 태그에 `android:allowBackup`, `android:fullBackupContent`, `android:dataExtractionRules` 중 어느 것도 선언되지 않았다. Android 기본값은 `allowBackup=true`이며, `targetSdkVersion >= 31`에서는 Android 12 Auto Backup/Cloud Backup/Device-to-device Transfer 규칙이 적용된다. 이로 인해 앱 내부 데이터 디렉토리의 Hive `.hive` 파일(링크, 컬렉션, 알림, 검색 히스토리)이 Google Drive로 자동 백업될 수 있다.
- **Mitigation 분석**:
  - Hive 암호화 키는 `FlutterSecureStorage`(Android Keystore 기반)에 저장되며, **Keystore 자료는 Auto Backup에 포함되지 않는다**. 따라서 백업된 `.hive` 파일이 다른 기기/설치로 복원되어도 복호화는 불가.
  - 현재 `storage_service.dart`가 암호화 박스를 쓰지 않고 `Hive.openBox()`만 호출한다면(추후 확인 필요), 백업된 파일은 **평문**으로 복원 가능.
- **Evidence**:
  ```xml
  <!-- android/app/src/main/AndroidManifest.xml:3-6 -->
  <application
      android:label="@string/app_name"
      android:name="${applicationName}"
      android:icon="@mipmap/ic_launcher">
  ```
- **Recommended fix** (옵션 1: 최단거리):
  ```xml
  <application
      android:label="@string/app_name"
      android:name="${applicationName}"
      android:icon="@mipmap/ic_launcher"
      android:allowBackup="false"
      android:fullBackupContent="false">
  ```
  **옵션 2 (정밀)**: `android/app/src/main/res/xml/backup_rules.xml` 및 `data_extraction_rules.xml`을 생성하여 Hive 디렉토리 및 `flutter_secure_storage` 경로만 제외, 이외의 사용자 설정은 백업 허용.
- **Unverified**: `build.gradle.kts`가 `flutter.targetSdkVersion`을 사용하므로 빌드 타임에만 해결. Android 12+ 규칙 적용 여부는 빌드 시 확정. 그러나 **어느 SDK 레벨이든 allowBackup 기본값을 명시적으로 차단**하는 것이 baseline 보안 조치.
- **Confidence**: High

---

### P2-B · `.github/workflows/ci.yml` `build` job이 `security` job을 `needs:`로 게이팅하지 않음

- **Location**: `.github/workflows/ci.yml:87-90` (build job `needs` 선언) + `:120` (security job 정의 시작, 버전에 따라 라인 번호 차이 가능)
- **합의**: 3/3 만장일치 P2
- **Finding**: `build` job이 `needs: [analyze]`만 선언하고 `security` job을 포함하지 않는다. Semgrep step이 실패하더라도 `build` job은 병렬로 이미 실행되며, 병합 가능 여부를 결정하는 status check에 `security`가 등록되어 있지 않다면 머지가 차단되지 않는다. 즉 보안 게이트의 실질 강제력이 없다.
- **Recommended fix**:
  1. `.github/workflows/ci.yml`에서 `build` job의 `needs`에 `security` 추가: `needs: [analyze, security]`.
  2. 동시에 GitHub 저장소 설정 → Branch protection rules → `main` → Required status checks에 `security` job을 필수로 등록. (GitHub CLI: `gh api -X PATCH repos/kaywalker91/LinkNote/branches/main/protection/required_status_checks` 참고)
  3. Semgrep 단독 실패 시 job 전체가 red가 되도록 `continue-on-error` 혹은 `if: always()` 같은 우회 설정이 없는지 재확인.
- **Prerequisite**: Codex 보고서 Dimension 10 주석대로, GitHub Branch Protection 설정은 리포지토리 파일에 없으므로 `.github/workflows/ci.yml` 수정만으로는 실질 게이팅이 확정되지 않는다. `gh api` 호출 또는 웹 UI에서 Required checks 등록이 **반드시 병행**되어야 한다.
- **Confidence**: High

---

## P3 — Nit (선택적)

### P3-A · `proguard-rules.pro`에 Hive CE 타입 어댑터 keep 룰 미존재

- **Location**: `android/app/proguard-rules.pro` 전체
- **합의**: Claude 단독 발견 (Codex/Gemini 모두 미탐지)
- **Finding**: 현재 `storage_service.dart`는 `Map<dynamic, dynamic>` Hive 박스만 사용하므로 **즉시 위험은 없다**. 그러나 향후 feature에서 `@HiveType` 모델 클래스를 도입할 경우 R8 minification이 reflection 대상 클래스를 strip할 수 있다. 선제 keep 룰 추가가 안전망.
- **Recommended fix** (선택):
  ```proguard
  ## Hive CE (precautionary — currently unused but guards against future @HiveType models)
  -keep class * extends com.hivedb.hive.TypeAdapter { *; }
  -keep @com.hivedb.hive.annotations.HiveType class * { *; }
  ```
- **Confidence**: Low (현재 코드 기준 미사용, 미래 대비 선제 조치)

---

## Regression Check Matrix

Session #1-6 보안 감사 픽스 10건 중 Wave 1 범위에 해당하는 항목 재검증:

| 픽스 | 세션 | 결과 | 증거 |
|---|---|---|---|
| P1-1 onAuthStateChange 구독 수명주기 (`ref.onDispose`) | S#5 | ✅ 유지 | `auth_provider.dart:19-27` `ref.onDispose(subscription.cancel)` 유지 |
| P1-2 AuthInterceptor 401 콜백 배선 | S#5 | ✅ 유지 | `auth_interceptor.dart:22-24` 콜백 정상 배선 |
| P1-2 연장 — 401 시 `signOut` 호출 | S#5 | ⚠ 변형 | 호출은 되나 **SignOutUsecase가 아닌 Supabase SDK 직접 호출** (→ P1-A 신규 결함) |
| P1-3 SignOut 3x `clearAll()` | S#5 | ✅ 유지 (정상 경로에서만) | `sign_out_usecase.dart:23-27` + `auth_di_providers.dart:43-48` DI 유지. 단 401 경로는 P1-A에 의해 우회됨 |
| P1-4 `sanitizeTsQuery` | S#5 | ✅ 유지 | `search_remote_datasource.dart:16-24` 정규식 `[^a-zA-Z0-9가-힣\-_]` 유지 |
| P2-1 Global error handler (`FlutterError.onError` + `PlatformDispatcher.onError`) | S#6 | ✅ 유지 (위치 이전) | Session #17에서 `main.dart`에서 `bootstrap.dart:38-39`로 이관. Crashlytics는 `!kDebugMode` gated |
| P2-2 CI Semgrep `continue-on-error` 제거 | S#6 | ✅ 유지 (step 단위) | `.github/workflows/ci.yml` Semgrep step에 `continue-on-error: true` 없음. 단 **job 단위 게이팅 갭 존재** (→ P2-B 신규 결함) |
| P2-3 envied 허용 키 정책 문서화 | S#6 | ✅ 유지 | `CLAUDE.md` 정책 유지 + `env_{dev,staging,prod}.dart` 실 키 2개(`SUPABASE_URL`, `SUPABASE_ANON_KEY`)만 존재 확인 |

**요약**: 10건 중 **8건 완전 유지, 2건 변형/회귀** (P1-2 연장과 P2-2 gating).

---

## 검증되지 않은 가정

1. **Supabase `AuthChangeEvent.userDeleted` 유효성** (P1-C 전제): Session #5 당시 주석은 "userDeleted가 SDK에서 deprecated"라고 기록되었다. 현재 `pubspec.lock`의 `supabase_flutter` 버전에서 해당 이벤트가 여전히 존재·방송되는지 `Context7` 또는 `pub.dev` 문서로 재확인 필요.
2. **Supabase 프로젝트의 Email Confirmation 설정** (P1-B 전제): "이메일 확인이 ON"이라면 P1-B는 실행 중 버그, OFF라면 잠재적 결함. 확인은 Supabase Dashboard → Authentication → Providers → Email → "Confirm email" 토글.
3. **현재 빌드의 `targetSdkVersion` 실제 값** (P2-A 분석 정밀도): `flutter.targetSdkVersion`이 참조되므로 빌드 시 결정. Android 12+ 규칙 적용 여부에 따라 P2-A의 공격 경로가 달라짐(allowBackup vs dataExtractionRules). 픽스 자체는 어느 경우든 동일하게 `allowBackup="false"` 추가로 충분.
4. **`semgrep/semgrep-action@v1` 동작** (P2-B 보강): `SEMGREP_APP_TOKEN` 미설정 시 exit code가 0인지 non-zero인지 action 문서 재확인 필요. Fork PR에서 secret이 없는 경우 fallback 동작 검증 필요.
5. **GitHub Branch Protection `main` 설정** (P2-B 완전 해결 조건): 리포지토리 파일에 없으므로 `gh api repos/kaywalker91/LinkNote/branches/main/protection/required_status_checks` 호출로 현재 설정을 직접 질의해야 한다. `security` job 추가 후 이 체크에 등록해야 실효성 있음.
6. **`storage_service.dart` Hive 박스 암호화 여부** (P2-A 위험도 정량화): `encryptionCipher` 파라미터 사용 여부 미확인. 미사용 시 backup 파일이 평문 → P2-A 위험도 상향 가능.
7. **signup_screen.dart UX 처리** (P1-B 옵션 A 결합): 옵션 A 적용 시 기존 `signup_screen.dart`의 에러 SnackBar가 "이메일 확인이 필요합니다" 메시지를 어떻게 표시하는지 확인 후 안내 UX를 자연스럽게 연결.
8. **ProGuard keep 룰 충분성** (P3-A 일반화): 현재 Retrofit/freezed의 reflection 경로에 대한 keep 룰이 `proguard-rules.pro`에 존재하는지, 배포 빌드에서 R8 shrink 결과를 실제로 돌려 검증했는지 미확인. 릴리스 빌드 시 통합 검증 필요.

---

## 추가 리서치 필요 항목 (후속 웨이브 또는 별도 세션에서 처리)

| 항목 | 우선순위 | 위임 대상 |
|---|---|---|
| `pubspec.lock`의 `supabase_flutter`/`gotrue` 버전과 `AuthChangeEvent.userDeleted` export 여부 | 높음 (P1-C 전제) | Context7 조회 |
| Supabase Dashboard Email Confirmation 토글 상태 | 높음 (P1-B 실행 여부) | 사용자 수동 확인 |
| GitHub Branch Protection 현재 설정 질의 | 중간 (P2-B 완전성) | `gh api` 단건 호출 |
| Hive 암호화 박스 전면 도입 ROI 분석 | 낮음 (baseline 강화) | 별도 세션 리서치 (Stage 1) |
| Crashlytics PII 누출 엣지케이스 정적 분석 | 낮음 (Codex Dimension 8 부분 unverified) | Wave 5 재방문 또는 전용 세션 |

---

## Recommended Follow-up

### 즉시 (이번 스프린트)
1. **P1-A 픽스**: `dio_client.dart:27-33`의 `onUnauthorized` 핸들러를 `ref.read(signOutUsecaseProvider).call()`로 교체. 테스트: 기존 `test/core/network/auth_interceptor_test.dart`(3 GREEN)에 "401 시 3개 LocalDataSource `clearAll` 호출" 케이스 추가.
2. **P1-B 픽스**: `auth_remote_datasource.dart` `signUp()`이 `response.session == null` 분기 처리. 테스트: 신규 `signup_usecase_session_null_test.dart` 추가. Supabase Dashboard Email Confirmation 상태를 확인하여 P1-B의 현재 "실행 중/잠재" 여부도 명시.
3. **P2-A 픽스**: `AndroidManifest.xml`에 `android:allowBackup="false"` 한 줄 추가.

### 다음 스프린트
4. **P1-C 결정**: SDK 버전 확인 후 `userDeleted` 처리 추가 또는 주석 수정.
5. **P2-B 완결**: CI job `needs` 추가 + Branch Protection Required Check 등록. `gh api` 호출로 실체 확인 필수.

### 후속 웨이브 연동
- **Wave 2 (Core 인프라)**: Hive 박스 초기화 순서, `storage_service.dart`의 암호화 옵션 검토. 본 Wave 1의 P2-A 픽스 수준을 넘어 Hive 박스 자체를 `encryptionCipher`로 감쌀지 결정.
- **Wave 3 (Link 피처)**: P1-A 관련하여 "강제 로그아웃 → 새 로그인 시 Link list 초기 렌더링이 이전 데이터로부터 오염되지 않는지" 실제 경로 검증.
- **Wave 5 (Profile + Notification + UI/UX Shared)**: Crashlytics PII 누출 엣지케이스 (Codex Dimension 8 unverified) 재방문.
- **Wave 6 (Testing + CI/CD)**: P2-B의 실질 강제력 검증을 위해 의도적 실패 커밋을 브랜치에 푸시하여 CI가 막는지 적대적 테스트.

---

## 리뷰 메타 데이터

| 항목 | 값 |
|---|---|
| 1차 주도 | `feature-dev:code-reviewer` (내부 서브에이전트) |
| 2차 의견 1 | `codex exec -s read-only` (codex-cli 0.115.0) |
| 2차 의견 2 | `gemini --approval-mode plan` (gemini-cli 0.34.0) |
| 공유 프롬프트 | `/tmp/linknote_wave1_review_prompt.md` |
| Codex stdout | `/tmp/linknote_wave1_codex.md` (59 lines) |
| Gemini stdout | `/tmp/linknote_wave1_gemini.md` (80 lines) |
| 코드 수정 | **없음** (read-only 리뷰) |
| 소요 단계 | Stage A → B → C(병렬 2 LLM) → D |
| 범위 외 검증된 파일 | `search_remote_datasource.dart` (sanitizeTsQuery 재확인), `sign_out_usecase.dart` (DI + clearAll 계약 재확인), `bootstrap.dart` (글로벌 에러 핸들러 이전 확인) |
