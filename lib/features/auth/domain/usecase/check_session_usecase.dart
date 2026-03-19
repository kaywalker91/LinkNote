import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';

class CheckSessionUsecase {
  const CheckSessionUsecase(this._repository);

  final IAuthRepository _repository;

  Future<AuthStateEntity> call() => _repository.getSession();
}
