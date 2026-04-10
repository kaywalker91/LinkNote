import 'package:linknote/features/profile/data/dto/user_profile_dto.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';

class ProfileMapper {
  const ProfileMapper._();

  static UserProfileEntity toEntity(UserProfileDto dto) {
    return UserProfileEntity(
      id: dto.id,
      email: dto.email,
      displayName: dto.displayName,
      avatarUrl: dto.avatarUrl,
      linkCount: dto.linkCount,
      collectionCount: dto.collectionCount,
    );
  }

  static Map<String, dynamic> toUpdateJson({
    String? displayName,
    String? avatarUrl,
  }) {
    final json = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (displayName != null) json['display_name'] = displayName;
    if (avatarUrl != null) json['avatar_url'] = avatarUrl;
    return json;
  }
}
