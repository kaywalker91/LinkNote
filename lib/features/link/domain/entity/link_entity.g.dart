// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LinkEntity _$LinkEntityFromJson(Map<String, dynamic> json) => _LinkEntity(
  id: json['id'] as String,
  url: json['url'] as String,
  title: json['title'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  description: json['description'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  collectionId: json['collectionId'] as String?,
  collectionName: json['collectionName'] as String?,
  memo: json['memo'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => TagEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isFavorite: json['isFavorite'] as bool? ?? false,
);

Map<String, dynamic> _$LinkEntityToJson(_LinkEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'memo': instance.memo,
      'tags': instance.tags,
      'isFavorite': instance.isFavorite,
    };
