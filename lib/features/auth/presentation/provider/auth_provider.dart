import 'package:flutter/foundation.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth with ChangeNotifier {
  @override
  Future<AuthStateEntity> build() async {
    // Notify GoRouter's refreshListenable whenever auth state changes.
    listenSelf((_, next) => notifyListeners());

    // TODO(linknote): Replace with real Supabase auth when backend is ready.
    // final client = Supabase.instance.client;
    // final subscription = client.auth.onAuthStateChange.listen((_) {
    //   notifyListeners();
    // });
    // ref.onDispose(subscription.cancel);
    // final session = client.auth.currentSession;
    // if (session == null) return const AuthStateEntity.unauthenticated();
    // return AuthStateEntity.authenticated(
    //   userId: session.user.id,
    //   email: session.user.email ?? '',
    // );
    return const AuthStateEntity.unauthenticated();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      final user = response.user;
      if (user == null) {
        state = AsyncError('Sign in failed', StackTrace.current);
        return;
      }
      state = AsyncData(
        AuthStateEntity.authenticated(
          userId: user.id,
          email: user.email ?? '',
        ),
      );
      notifyListeners();
    } on AuthException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await Supabase.instance.client.auth
          .signUp(email: email, password: password);
      final user = response.user;
      if (user == null) {
        state = AsyncError('Sign up failed', StackTrace.current);
        return;
      }
      state = AsyncData(
        AuthStateEntity.authenticated(
          userId: user.id,
          email: user.email ?? '',
        ),
      );
      notifyListeners();
    } on AuthException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AsyncData(AuthStateEntity.unauthenticated());
    notifyListeners();
  }

  bool get isAuthenticated => state.value is Authenticated;
}
