import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

/// Supabase `onAuthStateChange` 이벤트 중 provider를 invalidate해
/// 세션 상태를 재검증해야 하는 것들.
///
/// - [AuthChangeEvent.signedOut]: 세션 만료 / 원격 로그아웃.
/// - [AuthChangeEvent.tokenRefreshed]: 토큰 rotation으로 세션 정보 갱신.
/// - [AuthChangeEvent.userUpdated]: 비밀번호 변경 등 사용자 메타 변경 시
///   Supabase가 방송하는 이벤트. Session #5 당시 주석에 "password change"
///   의도가 있었으나 실제 분기가 누락되어 있었다.
///
/// `AuthChangeEvent.userDeleted`는 gotrue 2.18 기준 @Deprecated이고
/// jsName이 빈 문자열이라 서버가 방송하지 않으므로 추가하지 않는다.
const reactiveAuthEvents = <AuthChangeEvent>{
  AuthChangeEvent.signedOut,
  AuthChangeEvent.tokenRefreshed,
  AuthChangeEvent.userUpdated,
};

@Riverpod(keepAlive: true)
class Auth extends _$Auth with ChangeNotifier {
  @override
  Future<AuthStateEntity> build() async {
    // Notify GoRouter's refreshListenable whenever auth state changes.
    listenSelf((_, __) => notifyListeners());

    // Subscribe to real-time auth state changes (session expiry, remote
    // sign-out, token rotation, password change via userUpdated event).
    final subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (!reactiveAuthEvents.contains(data.event)) return;
        // Reconcile auth state IN PLACE instead of ref.invalidateSelf().
        // invalidateSelf() recreates this notifier instance, which changes
        // authProvider.notifier's identity. appRouter watches that notifier
        // (as GoRouter.refreshListenable), so recreating it mid sign-out
        // rebuilds the entire GoRouter — swapping refreshListenable and
        // resetting navigation — which freezes the app. Setting state keeps
        // the notifier (and the router) stable while still reacting to remote
        // sign-out, token rotation, and user-metadata updates.
        final session = data.session;
        state = AsyncData(
          session == null
              ? const AuthStateEntity.unauthenticated()
              : AuthStateEntity.authenticated(
                  userId: session.user.id,
                  email: session.user.email ?? '',
                ),
        );
      },
    );
    ref.onDispose(subscription.cancel);

    // Check existing Supabase session.
    final checkSession = ref.read(checkSessionUsecaseProvider);
    final result = await checkSession();
    // The first AsyncLoading -> AsyncData transition is assigned by Riverpod
    // outside the listenSelf cycle, so the initial state can land without
    // notifyListeners ever firing — which leaves GoRouter's refreshListenable
    // asleep and the splash route stuck. Schedule a one-shot tick after the
    // microtask queue drains so the router re-evaluates the redirect for the
    // first rendered frame.
    scheduleMicrotask(notifyListeners);
    return result;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signInUsecaseProvider)
        .call(
          email: email,
          password: password,
        );
    if (result.isSuccess) {
      state = AsyncData(result.data!);
      notifyListeners();
    } else {
      state = AsyncError(result.failure!, StackTrace.current);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signUpUsecaseProvider)
        .call(
          email: email,
          password: password,
        );
    if (result.isSuccess) {
      state = AsyncData(result.data!);
      notifyListeners();
    } else {
      state = AsyncError(result.failure!, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    final result = await ref.read(signOutUsecaseProvider).call();
    if (!result.isFailure) {
      state = const AsyncData(AuthStateEntity.unauthenticated());
      notifyListeners();
    } else {
      state = AsyncError(result.failure!, StackTrace.current);
    }
  }

  bool get isAuthenticated => state.value is Authenticated;
}
