// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CollectionEntity _$CollectionEntityFromJson(Map<String, dynamic> json) =>
    _CollectionEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      linkCount: (json['linkCount'] as num?)?.toInt() ?? 0,
      visibility:
          $enumDecodeNullable(
            _$CollectionVisibilityEnumMap,
            json['visibility'],
            unknownValue: CollectionVisibility.private,
          ) ??
          CollectionVisibility.private,
      lockedAt: json['lockedAt'] == null
          ? null
          : DateTime.parse(json['lockedAt'] as String),
    );

Map<String, dynamic> _$CollectionEntityToJson(_CollectionEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'linkCount': instance.linkCount,
      'visibility': _$CollectionVisibilityEnumMap[instance.visibility]!,
      'lockedAt': instance.lockedAt?.toIso8601String(),
    };

const _$CollectionVisibilityEnumMap = {
  CollectionVisibility.public: 'public',
  CollectionVisibility.private: 'private',
};
