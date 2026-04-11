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
      // Email Confirmation이 활성화되면 Supabase는 user는 반환하지만
      // session은 null로 돌려준다. 이 상태에서 Authenticated로 승격하면
      // 이후 모든 API 호출이 401로 떨어지고 dio_client의 401 핸들러가
      // 세션 무효화 경로를 타게 된다. 명시적으로 실패로 변환해 사용자가
      // 이메일 확인 링크를 먼저 처리하도록 유도한다.
      if (response.session == null) {
        return error(
          const Failure.auth(
            message: '이메일 확인 링크가 발송되었습니다. 메일을 확인하고 로그인해 주세요.',
          ),
        );
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
