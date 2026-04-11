import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/profile/data/dto/user_profile_dto.dart';
import 'package:linknote/features/profile/data/mapper/profile_mapper.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._client);
  final SupabaseClient _client;

  Future<Result<UserProfileEntity>> getProfile() async {
    try {
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
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<UserProfileEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
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
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }
}
