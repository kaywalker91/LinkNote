# Wave 1 Fix Plan (Stage 2)

- **세션**: Session 21 (2026-04-12)
- **입력**: `tasks/wave1_fix_research.md`, `docs/code_review/2026-04-12_wave1_security.md`
- **파이프라인 단계**: ai-coding-pipeline Stage 2 (Plan)
- **상태**: 사용자 승인 대기. 승인 후 Session 22에서 Stage 4(구현) 진입.
- **제외**: P3-A (proguard Hive keep rules) — 사용자 결정으로 본 스프린트 미포함.

---

## 0. 사용자 결정 필요 사항 (Session 22 Stage 4 진입 전 최종 확정)

| # | 항목 | Stage 1 검증 결과 | 기본 가안 | 확정 시점 |
|---|---|---|---|---|
| Q1 | `SignOutUsecase.clearAll` 가드 변경 여부 | 현재 `if (result.isSuccess)` 가드 존재. 401 경로에서 서버 실패 시 clearAll 스킵 리스크. | **변경 (가드 제거)**: 401 경로 안전성 보장 | Session 22 P1-A 2단계 진입 직전 |
| Q2 | `failure_ui.dart` AuthFailure 분기 수정 범위 | 현재 AuthFailure는 `this.message`를 무시하고 "다시 로그인해 주세요" 하드코딩. P1-B 픽스의 메시지가 절대 표시되지 않음. | **수정**: `AuthFailure(message: m) when m.isNotEmpty => 그 메시지 사용` | Session 22 P1-B 1단계 진입 직전 |
| Q3 | Branch Protection `enforce_admins` 설정 | 사용자 본인이 owner. 긴급 수정 경로 확보 필요. | **false (admin 우회 허용)** | Session 22 P2-B 2단계 진입 직전 |
| Q4 | Branch Protection `required_pull_request_reviews` | 단독 개발자. | **null (review 강제 해제)** | Session 22 P2-B 2단계 진입 직전 |

---

## 1. 구현 순서 (TDD RED → GREEN → REFACTOR, 의존성 역순)

우선순위는 "단순한 것부터 → 회귀 위험 낮은 순서 → 서로 독립인 것들 먼저"로 배열한다. P1-B가 1단계인 이유: P1-B 픽스가 P1-A의 트리거 조건 중 하나를 제거하므로, P1-B를 먼저 하면 P1-A의 테스트 시나리오가 더 깨끗해진다.

### 1단계 · P1-B · signUp session=null 승격 차단

**수정 대상**:
- `lib/features/auth/data/datasource/auth_remote_datasource.dart` (signUp 분기 추가)
- `lib/core/error/failure_ui.dart` (AuthFailure 메시지 관통) ← Q2 승인 필수
- `test/features/auth/data/datasource/auth_remote_datasource_test.dart` ← **신규 파일** (현재 미존재)

**TDD 사이클**:
1. **RED**: 신규 파일 `test/features/auth/data/datasource/auth_remote_datasource_test.dart` 생성.
   - mocktail로 `SupabaseClient` + `GoTrueClient` + `AuthResponse` fake.
   - 테스트 케이스들:
     - `should return authenticated state when signUp returns user and session`
     - `should return Failure.auth when signUp returns user but session is null` ← **P1-B 신규 RED**
     - `should return Failure.auth when signUp returns user=null`
     - (+ signIn 대응 케이스, 기존 커버리지 보강)
   - `flutter test test/features/auth/data/datasource/auth_remote_datasource_test.dart` → RED 확인 (session null 케이스만 실패).
2. **GREEN**: `auth_remote_datasource.dart:55-64` 수정 — `final session = response.session;` 추가 후 `if (session == null)` 분기:
   ```
   final user = response.user;
   final session = response.session;
   if (user == null) return error(const Failure.auth(message: 'Sign up failed'));
   if (session == null) return error(const Failure.auth(
     message: '이메일 확인 링크가 발송되었습니다. 메일을 확인하고 로그인해 주세요.',
   ));
   return success(AuthStateEntity.authenticated(userId: user.id, email: user.email ?? ''));
   ```
   - 테스트 재실행 → GREEN.
3. **failure_ui.dart 수정 (Q2 승인 후)**: `AuthFailure` 분기를 message-aware로 변경:
   ```
   AuthFailure(:final message) when message.isNotEmpty => FailureUi(
     title: '인증 오류',
     message: message,
     icon: Icons.lock_outline_rounded,
     isRetryable: false,
   ),
   AuthFailure() => const FailureUi(
     title: '인증 오류',
     message: '다시 로그인해 주세요.',
     icon: Icons.lock_outline_rounded,
     isRetryable: false,
   ),
   ```
   - **추가 회귀 검증**: 기존 `failure_ui_test.dart` (존재 시) 업데이트, 없으면 작성.
4. **REFACTOR**: 에러 메시지를 `auth_messages.dart` 상수로 분리 검토 (선택, 1건뿐이면 보류).
5. **수동 검증**: Supabase Dashboard에서 Email Confirmation을 **일시적으로 ON**으로 바꾸고 signup_screen에서 가입 시도 → SnackBar에 "이메일 확인 링크가 발송되었습니다..." 표시 확인 → Dashboard 원복 (OFF).

**회귀 방지**:
- 기존 `test/features/auth/presentation/screens/signup_screen_test.dart` GREEN 유지
- 기존 `test/features/auth/data/repository/auth_repository_impl_test.dart` GREEN 유지

---

### 2단계 · P1-A · dio_client 401 → SignOutUsecase

**수정 대상**:
- `lib/core/network/dio_client.dart` (onUnauthorized 콜백 교체)
- `lib/features/auth/domain/usecase/sign_out_usecase.dart` (Q1 승인 시 clearAll 가드 제거)
- `test/core/network/dio_client_test.dart` ← **신규** (또는 `auth_interceptor_test.dart`에 통합)
- `test/features/auth/domain/usecase/sign_out_usecase_test.dart` (가드 제거 시 테스트 업데이트)

**TDD 사이클**:
1. **RED**: `test/core/network/dio_client_test.dart` 신규 생성 (dio_client는 provider 팩토리이므로 ProviderContainer로 테스트).
   - mocktail `SignOutUsecase` 오버라이드 + `signOutUsecaseProvider.overrideWith(...)` 사용.
   - 테스트 케이스: `should invoke SignOutUsecase when 401 received via AuthInterceptor`
   - 구현: `ProviderContainer` 생성 → `dioProvider` 읽기 → 인터셉터의 `onError`에 401 DioException 주입 → mock SignOutUsecase의 `.call()` 호출 횟수 verify.
   - → RED 확인.
2. **GREEN**: `dio_client.dart:27-33` 수정:
   ```
   dio.interceptors.add(
     AuthInterceptor(
       onUnauthorized: () async {
         ref.read(sessionExpiredProvider.notifier).trigger();
         await ref.read(signOutUsecaseProvider).call();  // ← 교체
       },
     ),
   );
   ```
   - `import 'package:supabase_flutter/supabase_flutter.dart';` 제거 검토 (더 이상 직접 사용 안 함).
   - → GREEN.
3. **Q1 분기 처리 (가드 제거 승인 시)**: `sign_out_usecase.dart:20-30` 수정:
   ```
   Future<Result<void>> call() async {
     final result = await _repository.signOut();
     await Future.wait([
       _linkLocalDs.clearAll(),
       _collectionLocalDs.clearAll(),
       _notificationLocalDs.clearAll(),
     ]);                                    // ← if 제거, 항상 실행
     return result;
   }
   ```
   - 기존 `sign_out_usecase_test.dart`의 "should clear local data on success" 테스트를 "should always clear local data regardless of server result"로 업데이트.
   - 신규 테스트: "should clear local data even when server signOut fails" RED → GREEN.
4. **REFACTOR**: `dio_client.dart`의 Supabase import 제거 확인. fire-and-forget 형태라 에러 무시하는 것이 맞는지 주석으로 근거 명시.
5. **통합**: 기존 `auth_interceptor_test.dart` 3건 모두 GREEN 유지 확인.

**회귀 방지**:
- Session #5 P1-3 "SignOut 3x clearAll" 계약이 **정상 경로와 401 경로 양쪽에서** 작동하는지 재확인.
- `auth_interceptor_test.dart` 의 기존 3건 변경 없음.

---

### 3단계 · P1-C · auth_provider 주석 정합성 + userUpdated 분기

**수정 대상**:
- `lib/features/auth/presentation/provider/auth_provider.dart` (주석 + 분기)
- `test/features/auth/presentation/provider/auth_provider_test.dart` (존재 확인 후 수정 또는 신규)

**TDD 사이클**:
1. **RED**: `auth_provider_test.dart` 존재 여부 확인.
   - 존재하면: 신규 케이스 추가 `should invalidate on userUpdated event` (Supabase auth stream mock 기반).
   - 미존재: 신규 생성 + 기존 `signedOut`/`tokenRefreshed` 커버리지 + 신규 `userUpdated` 케이스.
   - `flutter test` → RED (userUpdated 분기 아직 없음).
2. **GREEN**: `auth_provider.dart:17-24` 수정:
   ```
   // Subscribe to real-time auth state changes (session expiry, remote
   // sign-out, token refresh, password change emitted as USER_UPDATED).
   final subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
     (data) {
       if (data.event == AuthChangeEvent.signedOut ||
           data.event == AuthChangeEvent.tokenRefreshed ||
           data.event == AuthChangeEvent.userUpdated) {
         ref.invalidateSelf();
       }
     },
   );
   ```
   - 주석에서 "user deletion" 제거됨. `userDeleted`는 @Deprecated no-op이므로 절대 추가하지 않음.
   - → GREEN.
3. **REFACTOR**: 조건식을 `const _reactiveEvents = {...}` Set으로 추출 검토 (선택, 3개뿐이면 보류).

**회귀 방지**:
- 기존 `signedOut`/`tokenRefreshed` 테스트 GREEN 유지.
- `auth_provider`에 의존하는 GoRouter redirect 테스트 (존재 시) GREEN 유지.

---

### 4단계 · P2-A · AndroidManifest allowBackup=false

**수정 대상**:
- `android/app/src/main/AndroidManifest.xml:3-6`

**구현**:
1. `<application>` 태그에 `android:allowBackup="false"` 한 줄 추가.
   ```
   <application
       android:label="@string/app_name"
       android:name="${applicationName}"
       android:icon="@mipmap/ic_launcher"
       android:allowBackup="false">
   ```
2. `flutter build apk --debug --flavor dev -t lib/main_dev.dart` 성공 확인.
3. 수동 smoke test:
   - 앱 실행 → 링크 1건 추가 → 앱 종료/재시작 → 링크 유지 확인 (Hive 데이터는 백업과 무관).
4. **TDD 적용 안 됨**: 빌드 설정 변경이라 unit test 불가. 빌드 성공 + smoke test로 검증.

**회귀 방지**:
- 기존 AndroidManifest 엔트리(permission, intent-filter, queries) 전부 보존.
- Debug/Release 빌드 모두 성공 확인.

---

### 5단계 · P2-B · CI needs + Branch Protection 신규 생성

**수정 대상**:
- `.github/workflows/ci.yml` (build job needs)
- GitHub API (branch protection 신규)

**Step 1 — `.github/workflows/ci.yml` 수정**:
```
build:
  name: Build (Android Dev Debug)
  runs-on: ubuntu-latest
  needs: [analyze, security]   # ← analyze 단독 → analyze + security
  ...
```
- `test` job은 현재 `needs` 없음 (analyze와 병렬 실행). 그대로 유지 (분석 실패해도 테스트는 병렬로 돌려야 CI 신호가 빨리 옴).
- 수정 후 PR로 올려 CI 자체가 통과하는지 확인.

**Step 2 — Branch Protection 신규 생성 (gh api)**:

**사전 확인**:
```
gh auth status
gh api repos/kaywalker91/LinkNote/branches/main/protection  # 여전히 404인지 확인
```

**생성 명령** (heredoc으로 JSON body 전달):
```
gh api -X PUT repos/kaywalker91/LinkNote/branches/main/protection \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Analyze",
      "Test",
      "Build (Android Dev Debug)",
      "Security Scan"
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```
- `contexts` 값은 ci.yml의 각 job의 `name:` 필드와 **정확히 일치**해야 함 (대소문자 구분).
- 응답 정상 JSON 확인 → 설정 적용.

**Step 3 — 수동 검증** (세션 후반):
1. feature branch에 일부러 analyze 실패 커밋 push → PR 생성 → CI가 red → 머지 버튼 비활성화 확인.
2. analyze 수정 commit push → CI green → 머지 가능 확인.
3. main 직접 push 시도 → 거부됨 확인.

**회귀 방지**:
- 기존 CI 워크플로우의 green state 유지.
- `enforce_admins: false`로 긴급 수정 시 admin 우회 경로 확보.
- `main` 보호 활성화 후 첫 PR에서 예상치 못한 required check 이름 mismatch 발생 시 즉시 contexts 배열 업데이트.

---

## 2. 전체 수정 파일 목록

### 2.1 Source (Write)

- `lib/core/network/dio_client.dart` — P1-A
- `lib/features/auth/data/datasource/auth_remote_datasource.dart` — P1-B
- `lib/features/auth/presentation/provider/auth_provider.dart` — P1-C
- `lib/core/error/failure_ui.dart` — P1-B 결합 (AuthFailure 메시지 관통, Q2 승인 시)
- `lib/features/auth/domain/usecase/sign_out_usecase.dart` — P1-A 결합 (clearAll 가드 제거, Q1 승인 시)
- `android/app/src/main/AndroidManifest.xml` — P2-A
- `.github/workflows/ci.yml` — P2-B Step 1

### 2.2 Test (Write)

- `test/features/auth/data/datasource/auth_remote_datasource_test.dart` — **신규** (P1-B RED)
- `test/core/network/dio_client_test.dart` — **신규** (P1-A RED)
- `test/features/auth/domain/usecase/sign_out_usecase_test.dart` — **업데이트 (존재 확인 후 변경 혹은 신규)** (Q1 승인 시)
- `test/features/auth/presentation/provider/auth_provider_test.dart` — **업데이트 또는 신규** (P1-C RED)

### 2.3 External State (Write)

- GitHub Branch Protection on `kaywalker91/LinkNote` `main` (P2-B Step 2, `gh api -X PUT`)

### 2.4 Docs (Write)

- `CHANGELOG.md` — Wave 1 픽스 6건 요약 (세션 마무리 시)
- `docs/daily_task_log/2026-04-12_session.md` — Session 21/22 연속 기록
- `docs/next_session_prompt.md` — Session 23 프롬프트 갱신
- `tasks/lessons.md` — P3-A 보류 근거 한 줄 + Stage 1 사전 확인이 플랜 품질을 바꾼 사례 1건

---

## 3. 아키텍처 영향 분석

- **레이어 경계**: 변화 없음. 모두 기존 Clean Architecture 경계 내에서 작동.
- **신규 의존성**: `dio_client` (core/network) → `signOutUsecaseProvider` (features/auth/presentation/provider) 방향 의존 발생. core가 feature를 참조하는 형태지만, Riverpod DI를 통한 간접 참조라 정식 import 체인은 아님. **계약상 문제없음** (Session #5에서 이미 `dio_client`가 `sessionExpiredProvider`를 참조하는 동일 패턴 존재).
- **GoRouter redirect**: `auth_provider.isAuthenticated` 기반 redirect가 있음. P1-B/P1-C 모두 이 플래그를 더 정확하게 만드는 방향이므로 redirect 로직 변경 불필요.
- **DI 그래프**: 변화 없음. `signOutUsecaseProvider`는 이미 완성되어 있음.

---

## 4. 회귀 방지 체크리스트 (Session 22 종료 시점에 실행)

### 4.1 Session #1-6 보안 감사 픽스 10건 재검증

`tasks/wave1_fix_research.md` 섹션 6의 Regression Check Matrix 재실행:

1. P1-1 `onAuthStateChange` `ref.onDispose` — `auth_provider.dart` 변경에도 유지 확인
2. P1-2 AuthInterceptor 401 콜백 — 변경 없음
3. **P1-2 연장 "401 → clearAll"** — **P1-A 픽스로 복원** (재검증 대상 중 가장 중요)
4. P1-3 SignOut 3x clearAll — 정상 경로 유지 + (Q1 승인 시) 가드 제거로 더 강건해짐
5. P1-4 sanitizeTsQuery — 범위 외, 재확인 불필요
6. P2-1 Global error handler — 범위 외
7. **P2-2 CI Semgrep gating** — **P2-B 픽스로 job-level gating 복원**
8. P2-3 envied 허용 키 — 범위 외

### 4.2 Quality gates

- [ ] `flutter analyze` — 0 issues 유지
- [ ] `flutter test` — 315+ GREEN 유지 (신규 테스트 추가 후 증가)
- [ ] `flutter build apk --debug --flavor dev -t lib/main_dev.dart` 성공
- [ ] CI 워크플로우 모든 job green
- [ ] Branch protection 신규 적용 후 의도적 실패 PR 테스트 통과

### 4.3 수동 smoke test

- [ ] 앱 실행 → 로그인 → 링크 추가 → 앱 재시작 → 링크 유지
- [ ] 로그아웃 → 다른 계정 로그인 → 이전 계정 링크가 UI에 보이지 않음 (P1-A 효과)
- [ ] (옵션) Supabase Dashboard에서 Email Confirmation 일시 ON → signup → SnackBar 메시지 확인 → OFF 원복 (P1-B 효과)

---

## 5. 블로커 → Stage 1 복귀 조건

다음 상황 발생 시 Stage 4를 즉시 중단하고 Stage 1 재진입:

- [ ] TDD RED 테스트가 예상과 다른 방식으로 실패 (e.g., import 오류, mocktail 설정 실패) → 테스트 환경 문제 Stage 1 재확인
- [ ] `signOutUsecaseProvider`가 `dio_client`에서 `ref.read()` 호출 시 **순환 의존** 발생 (dio ← signOut ← localDataSource ← Hive ← ... 체인 확인 필요)
- [ ] `gh api` branch protection `PUT` 요청이 `status_checks.contexts` mismatch로 실패 → ci.yml job name과 contexts 배열 재매칭
- [ ] `failure_ui.dart` 수정 후 기존 UI 테스트 다수 깨짐 → 롤백 후 재설계
- [ ] Q1(가드 제거)이 예상치 못한 테스트 다수 깨뜨림 → P1-A만 적용하고 Q1은 후속 세션으로 분리

---

## 6. 참고 (Research 문서)

전체 사실 배경과 검증 결과는 `tasks/wave1_fix_research.md`를 참조:
- 섹션 0: 사전 확인 결과 5건 (`userDeleted` deprecated, Email Confirmation OFF, main 보호 없음, Hive 암호화 확인, semgrep 부분 확인)
- 섹션 1~5: 이슈별 영향 분석 + 엣지 케이스
- 섹션 6: Regression Check Matrix

Session 22 Stage 4 진입 시 이 플랜의 1단계부터 순차 실행. 각 단계 진입 직전 해당 단계의 Q(Q1/Q2/Q3/Q4)가 있으면 사용자에게 최종 확정 질의 후 진행.
