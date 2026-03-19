import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';

class SignInUsecase {
  const SignInUsecase(this._repository);

  final IAuthRepository _repository;

  Future<Result<AuthStateEntity>> call({
    required String email,
    required String password,
  }) =>
      _repository.signIn(email: email, password: password);
}
