import 'package:flutter/foundation.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth with ChangeNotifier {
  @override
  Future<AuthStateEntity> build() async {
    // Notify GoRouter's refreshListenable whenever auth state changes.
    listenSelf((_, next) => notifyListeners());

    // Check existing Supabase session.
    final checkSession = ref.read(checkSessionUsecaseProvider);
    return checkSession();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final Result<AuthStateEntity> result = await ref
        .read(signInUsecaseProvider)
        .call(
          email: email,
          password: password,
        );
    if (result.isSuccess) {
      state = AsyncData(result.data as AuthStateEntity);
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
    final Result<AuthStateEntity> result = await ref
        .read(signUpUsecaseProvider)
        .call(
          email: email,
          password: password,
        );
    if (result.isSuccess) {
      state = AsyncData(result.data as AuthStateEntity);
      notifyListeners();
    } else {
      state = AsyncError(
        result.failure?.message ?? 'Sign up failed',
        StackTrace.current,
      );
    }
  }

  Future<void> signOut() async {
    final Result<void> result = await ref.read(signOutUsecaseProvider).call();
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
