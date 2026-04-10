import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';

abstract interface class IProfileRepository {
  Future<Result<UserProfileEntity>> getProfile();
  Future<Result<UserProfileEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
  });
}
