import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:linknote/features/profile/domain/repository/i_profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);
  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Result<UserProfileEntity>> getProfile() =>
      _remoteDataSource.getProfile();

  @override
  Future<Result<UserProfileEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) => _remoteDataSource.updateProfile(
    displayName: displayName,
    avatarUrl: avatarUrl,
  );
}
