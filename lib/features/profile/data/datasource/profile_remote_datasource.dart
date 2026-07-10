import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/network/supabase_guard.dart';
import 'package:linknote/features/profile/data/dto/user_profile_dto.dart';
import 'package:linknote/features/profile/data/mapper/profile_mapper.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._client);
  final SupabaseClient _client;

  Future<Result<UserProfileEntity>> getProfile() {
    return guardSupabase<UserProfileEntity>(() async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return error(const Failure.auth(message: 'Session expired'));
      }
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return success(ProfileMapper.toEntity(UserProfileDto.fromJson(response)));
    }, label: 'profile remote failure');
  }

  Future<Result<UserProfileEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) {
    return guardSupabase<UserProfileEntity>(() async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return error(const Failure.auth(message: 'Session expired'));
      }
      final json = ProfileMapper.toUpdateJson(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

      await _client.from('profiles').update(json).eq('id', userId);

      return getProfile();
    }, label: 'profile remote failure');
  }
}
