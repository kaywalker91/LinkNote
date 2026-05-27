// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CollectionDto _$CollectionDtoFromJson(Map<String, dynamic> json) =>
    _CollectionDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      links:
          (json['links'] as List<dynamic>?)
              ?.map((e) => LinkCountDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      visibility:
          $enumDecodeNullable(
            _$CollectionVisibilityEnumMap,
            json['visibility'],
            unknownValue: CollectionVisibility.private,
          ) ??
          CollectionVisibility.private,
      lockedAt: json['locked_at'] == null
          ? null
          : DateTime.parse(json['locked_at'] as String),
    );

Map<String, dynamic> _$CollectionDtoToJson(_CollectionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'description': instance.description,
      'cover_image_url': instance.coverImageUrl,
      'links': instance.links.map((e) => e.toJson()).toList(),
      'visibility': _$CollectionVisibilityEnumMap[instance.visibility]!,
      'locked_at': instance.lockedAt?.toIso8601String(),
    };

const _$CollectionVisibilityEnumMap = {
  CollectionVisibility.public: 'public',
  CollectionVisibility.private: 'private',
};

_LinkCountDto _$LinkCountDtoFromJson(Map<String, dynamic> json) =>
    _LinkCountDto(count: (json['count'] as num).toInt());

Map<String, dynamic> _$LinkCountDtoToJson(_LinkCountDto instance) =>
    <String, dynamic>{'count': instance.count};
