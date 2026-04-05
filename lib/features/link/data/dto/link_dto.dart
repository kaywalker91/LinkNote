import 'package:freezed_annotation/freezed_annotation.dart';

part 'link_dto.freezed.dart';
part 'link_dto.g.dart';

@freezed
abstract class LinkDto with _$LinkDto {
  const factory LinkDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String url,
    required String title,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    String? description,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'collection_id') String? collectionId,
    String? memo,
    @JsonKey(name: 'is_favorite') @Default(false) bool isFavorite,
    @JsonKey(name: 'link_tags') @Default([]) List<LinkTagDto> linkTags,
    CollectionNameDto? collections,
  }) = _LinkDto;

  factory LinkDto.fromJson(Map<String, dynamic> json) =>
      _$LinkDtoFromJson(json);
}

@freezed
abstract class LinkTagDto with _$LinkTagDto {
  const factory LinkTagDto({
    required TagDto tags,
  }) = _LinkTagDto;

  factory LinkTagDto.fromJson(Map<String, dynamic> json) =>
      _$LinkTagDtoFromJson(json);
}

@freezed
abstract class TagDto with _$TagDto {
  const factory TagDto({
    required String id,
    required String name,
    required String color,
  }) = _TagDto;

  factory TagDto.fromJson(Map<String, dynamic> json) => _$TagDtoFromJson(json);
}

@freezed
abstract class CollectionNameDto with _$CollectionNameDto {
  const factory CollectionNameDto({
    required String name,
  }) = _CollectionNameDto;

  factory CollectionNameDto.fromJson(Map<String, dynamic> json) =>
      _$CollectionNameDtoFromJson(json);
}
