import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthRemoteDatasource _datasource;

  @override
  Future<AuthStateEntity> getSession() => _datasource.getSession();

  @override
  Future<Result<AuthStateEntity>> signIn({
    required String email,
    required String password,
  }) => _datasource.signIn(email: email, password: password);

  @override
  Future<Result<AuthStateEntity>> signUp({
    required String email,
    required String password,
  }) => _datasource.signUp(email: email, password: password);

  @override
  Future<Result<void>> signOut() => _datasource.signOut();
}
