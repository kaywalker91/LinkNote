import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';

class SignOutUsecase {
  const SignOutUsecase(this._repository);

  final IAuthRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}
