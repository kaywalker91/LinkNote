import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:linknote/features/profile/domain/repository/i_profile_repository.dart';

class GetProfileUsecase {
  const GetProfileUsecase(this._repository);
  final IProfileRepository _repository;

  Future<Result<UserProfileEntity>> call() => _repository.getProfile();
}
