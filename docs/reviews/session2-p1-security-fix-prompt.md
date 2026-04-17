# Session 2 보안 감사 P1 수정

## Context
보안 코드리뷰 Session 1에서 P0 3건 수정 완료 (Session 1.5).
전체 리포트: `docs/code_review/session1_security_audit.md`
현재 테스트: 289 tests ALL GREEN
이번 세션: P1 (High) 4건 수정.

## P1 수정 항목 (4건)

### P1-1. `onAuthStateChange` 미구독 → 실시간 세션 감지

세션 만료/비밀번호 변경/원격 로그아웃이 앱에 전파되지 않음. `build()`에서 1회 `checkSession()` 후 `keepAlive: true`로 영구 유지.

**수정 대상:**
- `lib/features/auth/presentation/provider/auth_provider.dart:12-19` (build 메서드)

**수정 방법:** `onAuthStateChange` 스트림 구독 + `ref.onDispose`로 정리:
```dart
@override
Future<AuthStateEntity> build() async {
  listenSelf((_, next) => notifyListeners());

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

**주의:**
- `supabase_flutter` import 필요 (Supabase.instance, AuthChangeEvent)
- `tokenRefreshed` 시 invalidate하면 새 토큰으로 세션 재확인 가능
- Supabase `onAuthStateChange` API를 Context7로 확인할 것

---

### P1-2. AuthInterceptor 401 → 로그인 리다이렉트

`onError`에서 401을 감지하지만 `handler.next(err)`로 그대로 전달. 만료된 세션에서 사용자가 로그인 화면으로 이동하지 않음.

**수정 대상:**
- `lib/core/network/auth_interceptor.dart:15-19`

**수정 방법:** 콜백 패턴으로 401 감지 시 auth 상태 초기화:
```dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor({this.onUnauthorized});
  final VoidCallback? onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
```

**주의:**
- `AuthInterceptor`를 생성하는 DI 코드에서 `onUnauthorized` 콜백 연결 필요
- 콜백에서 `authProvider`를 invalidate하거나 signOut 호출
- DI 파일 확인: `grep -r "AuthInterceptor" lib/` 로 생성 위치 파악

---

### P1-3. signOut 시 로컬 캐시 미삭제 → clearAll 호출

로그아웃 후 이전 사용자의 links/collections/notifications 캐시가 남아있음. 각 LocalDataSource에 `clearAll()` 메서드 존재하지만 미호출.

**수정 대상:**
- `lib/features/auth/domain/usecase/sign_out_usecase.dart` (현재 9줄, repository.signOut()만 호출)

**수정 방법:** SignOutUsecase에 3개 LocalDataSource 주입 + clearAll 호출:
```dart
class SignOutUsecase {
  const SignOutUsecase(
    this._repository,
    this._linkLocalDs,
    this._collectionLocalDs,
    this._notificationLocalDs,
  );

  final IAuthRepository _repository;
  final LinkLocalDataSource _linkLocalDs;
  final CollectionLocalDataSource _collectionLocalDs;
  final NotificationLocalDataSource _notificationLocalDs;

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
}
```

**주의:**
- `SignOutUsecase`를 생성하는 DI 프로바이더 수정 필요
- `auth_di_providers.dart`에서 3개 LocalDataSource를 ref.read로 주입
- 기존 `clearAll()` 동작 확인: `link_local_datasource.dart:108`, `collection_local_datasource.dart:83`, `notification_local_datasource.dart:82`

---

### P1-4. 검색 tsquery 인젝션 → 입력 sanitize

사용자 입력에 작은따옴표(`'`) 포함 시 tsquery 파싱 오류(400) 발생. DoS 가능성.

**수정 대상:**
- `lib/features/search/data/datasource/search_remote_datasource.dart:15-19`

**수정 방법:** 특수문자 제거 후 tsquery 구성:
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

## 수정 규칙

1. **TDD**: 각 P1 수정 전 실패 테스트 작성 → 수정 → 통과 확인
   - P1-1: auth_provider_test에 "onAuthStateChange signedOut 시 상태 갱신" 테스트
   - P1-2: auth_interceptor_test에 "401 시 onUnauthorized 콜백 호출" 테스트
   - P1-3: sign_out_usecase_test에 "signOut 성공 시 3개 clearAll 호출" 테스트
   - P1-4: search_remote_datasource_test에 "특수문자 포함 쿼리 sanitize" 테스트
2. **기존 테스트 289개 ALL GREEN 유지** — `flutter test` 전체 통과 확인
3. **flutter analyze 0 errors 유지**
4. **수정 범위 엄수** — P1 4건만 수정. P2는 이 세션에서 수정하지 않음
5. **Context7 조회** — Supabase `onAuthStateChange` API, `AuthChangeEvent` enum 최신 문서 확인 후 구현
