import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/app_update/domain/entity/update_policy.dart';
import 'package:linknote/features/app_update/domain/repository/i_app_update_repository.dart';

class CheckUpdatePolicyUsecase {
  const CheckUpdatePolicyUsecase(this._repository);
  final IAppUpdateRepository _repository;

  Future<Result<UpdatePolicy>> call() => _repository.getUpdatePolicy();
}
