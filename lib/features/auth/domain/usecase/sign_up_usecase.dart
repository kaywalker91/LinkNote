import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';

class SignUpUsecase {
  const SignUpUsecase(this._repository);

  final IAuthRepository _repository;

  Future<Result<AuthStateEntity>> call({
    required String email,
    required String password,
  }) => _repository.signUp(email: email, password: password);
}
