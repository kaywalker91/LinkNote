import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';

abstract interface class IAuthRepository {
  Future<AuthStateEntity> getSession();
  Future<Result<AuthStateEntity>> signIn({
    required String email,
    required String password,
  });
  Future<Result<AuthStateEntity>> signUp({
    required String email,
    required String password,
  });
  Future<Result<void>> signOut();
}
