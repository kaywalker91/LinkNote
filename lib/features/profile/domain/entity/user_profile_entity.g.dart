// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfileEntity _$UserProfileEntityFromJson(Map<String, dynamic> json) =>
    _UserProfileEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      linkCount: (json['linkCount'] as num?)?.toInt() ?? 0,
      collectionCount: (json['collectionCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserProfileEntityToJson(_UserProfileEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'linkCount': instance.linkCount,
      'collectionCount': instance.collectionCount,
    };
