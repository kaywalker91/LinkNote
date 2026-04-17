# Session 1: Security Audit Report

**Date**: 2026-04-11
**Scope**: Authentication, Token Management, Data Storage, Secrets, CI Security
**Files Reviewed**: 14 files
**Method**: 2x parallel code-reviewer agents + manual file analysis

---

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| P0 (Critical) | 3 | **Fixed** (Session 1.5) |
| P1 (High) | 4 | **Fixed** (Session 2) |
| P2 (Medium) | 3 | **Fixed** (Session 3) |
| Total | 10 | |

---

## P0 — Critical (Immediate Fix Required)

### P0-1. `currentUser!` force-unwrap crashes on expired session

**Files**:
- `lib/features/profile/data/datasource/profile_remote_datasource.dart:14, 34`
- `lib/features/link/data/datasource/link_remote_datasource.dart:118`

**Issue**: `_client.auth.currentUser!.id`를 3곳에서 null-check 없이 force-unwrap. Supabase SDK는 세션 만료/원격 취소 시 `currentUser`를 `null`로 설정. `TypeError`는 `Error` 타입이므로 `catch (Exception)` 블록에 잡히지 않음 — **앱 크래시**.

**Fix**:
```dart
final userId = _client.auth.currentUser?.id;
if (userId == null) return error(const Failure.auth(message: 'Session expired'));
```

---

### P0-2. Hive 4개 박스 암호화 미적용 — 사용자 데이터 평문 저장

**File**: `lib/core/storage/storage_service.dart:15-18`

**Issue**: `links`, `collections`, `notifications`, `settings` 박스가 `HiveAesCipher` 없이 `openBox`로 열림. 루팅 기기에서 `/data/data/<package>/` 직접 읽기 가능. iOS에서는 암호화되지 않은 iTunes 백업에 노출.

**Fix**: `FlutterSecureStorage`로 AES 키를 생성/관리하고, `HiveAesCipher`로 박스 암호화.
```dart
Future<void> initHive() async {
  await Hive.initFlutter();
  const secureStorage = FlutterSecureStorage();
  var encodedKey = await secureStorage.read(key: 'hive_encryption_key');
  if (encodedKey == null) {
    final key = Hive.generateSecureKey();
    encodedKey = base64UrlEncode(key);
    await secureStorage.write(key: 'hive_encryption_key', value: encodedKey);
  }
  final encryptionKey = base64Url.decode(encodedKey);
  final cipher = HiveAesCipher(encryptionKey);

  await Hive.openBox<String>('settings', encryptionCipher: cipher);
  await Hive.openBox<Map<dynamic, dynamic>>('links', encryptionCipher: cipher);
  await Hive.openBox<Map<dynamic, dynamic>>('collections', encryptionCipher: cipher);
  await Hive.openBox<Map<dynamic, dynamic>>('notifications', encryptionCipher: cipher);
}
```

---

### P0-3. `secureStorageProvider` 데드코드 — 보안 기능 미연결

**File**: `lib/core/storage/storage_service.dart:7-10`

**Issue**: `FlutterSecureStorage` 프로바이더가 정의되어 있으나 코드베이스 어디에서도 import/사용되지 않음. Hive 암호화 키 관리를 위해 만들어진 것으로 보이나 연결이 완료되지 않음.

**Fix**: P0-2 수정 시 함께 해결. `initHive()`에서 직접 `FlutterSecureStorage()`를 사용하거나, 프로바이더를 통해 주입.

---

## P1 — High (Sprint 내 수정) ✅ Fixed (Session 2, 2026-04-11)

### P1-1. `onAuthStateChange` 미구독 — 세션 만료가 앱에 전파되지 않음 ✅

**File**: `lib/features/auth/presentation/provider/auth_provider.dart:12-19`

**Issue**: `build()`에서 `checkSession()` 1회 호출 후 `keepAlive: true`로 영구 유지. Supabase SDK의 `onAuthStateChange` 이벤트(토큰 갱신, 세션 만료, 원격 취소)를 수신하지 않음. 다른 기기에서 비밀번호 변경 시 앱이 여전히 Authenticated 상태 유지.

**Fix**:
```dart
@override
Future<AuthStateEntity> build() async {
  final subscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.signedOut ||
        data.event == AuthChangeEvent.tokenRefreshed ||
        data.event == AuthChangeEvent.userDeleted) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(subscription.cancel);

  final checkSession = ref.read(checkSessionUsecaseProvider);
  return checkSession();
}
```

---

### P1-2. AuthInterceptor 401 passthrough — 로그인 리다이렉트 없음 ✅

**File**: `lib/core/network/auth_interceptor.dart:15-19`

**Issue**: `onError`에서 401을 감지하지만 `handler.next(err)`로 그대로 전달. 만료된 세션에서 모든 API 호출이 401 실패 → 사용자에게 서버 에러로 표시 → 로그인 화면으로 이동하지 않음.

**Fix**: 401 감지 시 콜백으로 auth 상태 초기화:
```dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor({this.onUnauthorized});
  final VoidCallback? onUnauthorized;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
```

---

### P1-3. signOut 시 로컬 캐시 미삭제 — 이전 사용자 데이터 잔존 ✅

**File**: `lib/features/auth/data/datasource/auth_remote_datasource.dart:72-79`

**Issue**: `signOut()`에서 `_client.auth.signOut()`만 호출. 각 LocalDataSource에 `clearAll()` 메서드가 존재하지만 로그아웃 플로우에서 호출되지 않음. 공유 기기에서 다음 사용자가 이전 사용자의 북마크/컬렉션/알림을 볼 수 있음.

**Fix**: `SignOutUsecase`에서 로컬 캐시 정리:
```dart
Future<Result<void>> call() async {
  final result = await _authRepository.signOut();
  if (result.isSuccess) {
    await _linkLocalDs.clearAll();
    await _collectionLocalDs.clearAll();
    await _notificationLocalDs.clearAll();
  }
  return result;
}
```

---

### P1-4. 검색 tsquery 인젝션 가능성 ✅

**File**: `lib/features/search/data/datasource/search_remote_datasource.dart:15-19`

**Issue**: 사용자 입력을 `'$w'`로 감싸 tsquery 구성. 작은따옴표 포함 입력 시 tsquery 파싱 오류(400) 또는 의도치 않은 쿼리 실행 가능. `.textSearch()`는 PostgREST 쿼리 파라미터로 전달되므로 완전한 SQL 인젝션은 아니나, 서비스 거부(DoS)와 예기치 않은 결과 반환 가능.

**Fix**: 입력 sanitize + `plainto_tsquery` 사용:
```dart
final tsQuery = query
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w.replaceAll(RegExp(r"[^a-zA-Z0-9가-힣\-_]"), ''))
    .where((w) => w.isNotEmpty)
    .map((w) => "'$w'")
    .join(' & ');
```

---

## P2 — Medium (다음 스프린트) ✅ Fixed (Session 3, 2026-04-11)

### P2-1. 글로벌 에러 핸들러 부재 — 프로덕션 크래시 관찰 불가 ✅

**File**: `lib/main.dart:8-26`

**Issue**: `runZonedGuarded`, `FlutterError.onError`, `PlatformDispatcher.onError` 모두 없음. Firebase Crashlytics 초기화도 주석 처리됨. 비동기 코드의 미처리 예외가 무관찰 크래시로 이어짐.

**Fix**: `FlutterError.onError` + `PlatformDispatcher.instance.onError` 글로벌 에러 핸들러 추가. 현재 `appLogger`로 로깅, `flutterfire configure` 실행 후 Crashlytics 연동 코드 주석 해제로 즉시 전환 가능.

---

### P2-2. CI Semgrep `continue-on-error: true` — 보안 스캔 실패가 머지 비차단 ✅

**File**: `.github/workflows/ci.yml:131`

**Issue**: Semgrep 보안 스캔이 실패해도 CI가 green 표시. 폴백 시크릿 스캔은 OpenAI 키와 JWT 헤더만 감지 — Firebase, AWS, Stripe 등 다른 시크릿 패턴은 놓침.

**Fix**: `continue-on-error: true` 제거 완료. Semgrep 실패 시 CI가 red로 표시됨.

---

### P2-3. envied XOR 난독화의 한계 — 바이너리에서 키 복구 가능 ✅

**File**: `lib/core/constants/env.g.dart:99-213`

**Issue**: `obfuscate: true`는 XOR 연산으로 문자열을 숨기지만, key 배열과 data 배열이 모두 바이너리에 포함되어 `jadx`/`strings`로 복원 가능. 현재 `supabaseUrl`과 `supabaseAnonKey`만 저장되어 있어 실질적 위험은 낮음(anon key는 설계상 공개용).

**Fix**: `CLAUDE.md`에 envied 보안 정책 문서화 완료. 허용 키 목록(SUPABASE_URL, SUPABASE_ANON_KEY)과 금지 키 목록(SERVICE_ROLE_KEY, SECRET_KEY 등) 명시.

---

## Not a Security Issue (검증 후 제외)

| Item | Verdict |
|------|---------|
| 로그인 화면 비밀번호 최소 길이 미검증 | 서버(Supabase Auth)에서 강제 — 클라이언트 중복 불필요 |
| 클라이언트 인증 시도 레이트 리밋 없음 | Supabase Auth 서버에 내장 — 클라이언트 부담 아님 |
| anon key가 Dio 헤더에 포함 | Supabase 설계 의도 (RLS 전제). Dio가 Supabase 전용이면 안전 |

---

## 수정 우선순위 로드맵

```
즉시 (P0): ✅ Fixed (Session 1.5, 2026-04-11)
  1. currentUser! → null-safe 가드 (3곳)
  2. Hive 암호화 + secureStorage 연결

Sprint 내 (P1): ✅ Fixed (Session 2, 2026-04-11)
  3. onAuthStateChange 구독 + ref.onDispose 정리
  4. AuthInterceptor 401 → onUnauthorized 콜백 + DI 연결
  5. signOut 시 3개 LocalDataSource clearAll 병렬 호출
  6. 검색 입력 sanitizeTsQuery static 메서드 추출

다음 Sprint (P2): ✅ Fixed (Session 3, 2026-04-11)
  7. 글로벌 에러 핸들러 (FlutterError.onError + PlatformDispatcher.onError)
  8. CI Semgrep continue-on-error 제거
  9. envied 정책 문서화 (CLAUDE.md)
```

---

## Review Method

- **Agent A**: Auth/Token flow 전문 code-reviewer (7파일 분석)
- **Agent B**: Storage/Secrets/CI 전문 code-reviewer (7파일 분석)
- **Manual**: 추가 grep 검증 (secureStorage 미사용, currentUser!, onAuthStateChange 부재, 글로벌 에러 핸들러 부재 확인)
