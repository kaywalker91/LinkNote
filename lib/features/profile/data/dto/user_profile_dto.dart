import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

@freezed
abstract class UserProfileDto with _$UserProfileDto {
  const factory UserProfileDto({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'link_count') @Default(0) int linkCount,
    @JsonKey(name: 'collection_count') @Default(0) int collectionCount,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}
