// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CollectionEntity _$CollectionEntityFromJson(Map<String, dynamic> json) =>
    _CollectionEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      linkCount: (json['linkCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CollectionEntityToJson(_CollectionEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'linkCount': instance.linkCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
