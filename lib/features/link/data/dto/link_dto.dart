import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';

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
    CollectionRefDto? collections,
  }) = _LinkDto;

  factory LinkDto.fromJson(Map<String, dynamic> json) =>
      _$LinkDtoFromJson(json);
}

@freezed
abstract class LinkTagDto with _$LinkTagDto {
  const factory LinkTagDto({
    // Nullable: Supabase `link_tags(tags(*))` join can return null when the
    // referenced `tags` row is hidden by RLS or deleted. Treating this as
    // required throws a `_TypeError` on parse, which `on Exception` cannot
    // catch (Error vs Exception). Filter null entries in `LinkMapper`.
    TagDto? tags,
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

/// Nested collection reference embedded in a link's `collections(...)` join.
///
/// `visibility`/`lockedAt` are only populated once the SELECT join is widened
/// to `collections(name, visibility, locked_at)`. Until then (or for old
/// cached rows) the keys are absent and resolve to the safe defaults below.
@freezed
abstract class CollectionRefDto with _$CollectionRefDto {
  const factory CollectionRefDto({
    required String name,
    @JsonKey(unknownEnumValue: CollectionVisibility.private)
    @Default(CollectionVisibility.private)
    CollectionVisibility visibility,
    @JsonKey(name: 'locked_at') DateTime? lockedAt,
  }) = _CollectionRefDto;

  factory CollectionRefDto.fromJson(Map<String, dynamic> json) =>
      _$CollectionRefDtoFromJson(json);
}
