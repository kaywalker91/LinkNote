import 'package:flutter/foundation.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth with ChangeNotifier {
  @override
  Future<AuthStateEntity> build() async {
    // Notify GoRouter's refreshListenable whenever auth state changes.
    listenSelf((_, next) => notifyListeners());

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
    ref.onDispose(subscription.cancel);

    // Check existing Supabase session.
    final checkSession = ref.read(checkSessionUsecaseProvider);
    return checkSession();
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
      state = AsyncError(
        result.failure?.message ?? 'Sign in failed',
        StackTrace.current,
      );
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
      state = AsyncError(
        result.failure?.message ?? 'Sign up failed',
        StackTrace.current,
      );
    }
  }

  Future<void> signOut() async {
    final result = await ref.read(signOutUsecaseProvider).call();
    if (!result.isFailure) {
      state = const AsyncData(AuthStateEntity.unauthenticated());
      notifyListeners();
    } else {
      state = AsyncError(
        result.failure?.message ?? 'Sign out failed',
        StackTrace.current,
      );
    }
  }

  bool get isAuthenticated => state.value is Authenticated;
}
