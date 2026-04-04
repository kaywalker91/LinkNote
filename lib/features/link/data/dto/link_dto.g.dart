// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LinkDto _$LinkDtoFromJson(Map<String, dynamic> json) => _LinkDto(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  url: json['url'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  collectionId: json['collection_id'] as String?,
  memo: json['memo'] as String?,
  isFavorite: json['is_favorite'] as bool? ?? false,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  linkTags:
      (json['link_tags'] as List<dynamic>?)
          ?.map((e) => LinkTagDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  collections: json['collections'] == null
      ? null
      : CollectionNameDto.fromJson(json['collections'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LinkDtoToJson(_LinkDto instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'url': instance.url,
  'title': instance.title,
  'description': instance.description,
  'thumbnail_url': instance.thumbnailUrl,
  'collection_id': instance.collectionId,
  'memo': instance.memo,
  'is_favorite': instance.isFavorite,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'link_tags': instance.linkTags,
  'collections': instance.collections,
};

_LinkTagDto _$LinkTagDtoFromJson(Map<String, dynamic> json) =>
    _LinkTagDto(tags: TagDto.fromJson(json['tags'] as Map<String, dynamic>));

Map<String, dynamic> _$LinkTagDtoToJson(_LinkTagDto instance) =>
    <String, dynamic>{'tags': instance.tags};

_TagDto _$TagDtoFromJson(Map<String, dynamic> json) => _TagDto(
  id: json['id'] as String,
  name: json['name'] as String,
  color: json['color'] as String,
);

Map<String, dynamic> _$TagDtoToJson(_TagDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
};

_CollectionNameDto _$CollectionNameDtoFromJson(Map<String, dynamic> json) =>
    _CollectionNameDto(name: json['name'] as String);

Map<String, dynamic> _$CollectionNameDtoToJson(_CollectionNameDto instance) =>
    <String, dynamic>{'name': instance.name};
