import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<AuthStateEntity> getSession() async {
    final session = _client.auth.currentSession;
    if (session == null) return const AuthStateEntity.unauthenticated();
    return AuthStateEntity.authenticated(
      userId: session.user.id,
      email: session.user.email ?? '',
    );
  }

  Future<Result<AuthStateEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return error(const Failure.auth(message: 'Sign in failed'));
      }
      return success(
        AuthStateEntity.authenticated(
          userId: user.id,
          email: user.email ?? '',
        ),
      );
    } on AuthException catch (e) {
      return error(Failure.auth(message: e.message));
    } on Exception catch (e) {
      return error(Failure.server(message: e.toString()));
    }
  }

  Future<Result<AuthStateEntity>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return error(const Failure.auth(message: 'Sign up failed'));
      }
      return success(
        AuthStateEntity.authenticated(
          userId: user.id,
          email: user.email ?? '',
        ),
      );
    } on AuthException catch (e) {
      return error(Failure.auth(message: e.message));
    } on Exception catch (e) {
      return error(Failure.server(message: e.toString()));
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return success(null);
    } on Exception catch (e) {
      return error(Failure.server(message: e.toString()));
    }
  }
}
