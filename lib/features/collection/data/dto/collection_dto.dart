import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';

part 'collection_dto.freezed.dart';
part 'collection_dto.g.dart';

@freezed
abstract class CollectionDto with _$CollectionDto {
  const factory CollectionDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    String? description,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @Default([]) List<LinkCountDto> links,
    @JsonKey(unknownEnumValue: CollectionVisibility.private)
    @Default(CollectionVisibility.private)
    CollectionVisibility visibility,
    @JsonKey(name: 'locked_at') DateTime? lockedAt,
  }) = _CollectionDto;

  factory CollectionDto.fromJson(Map<String, dynamic> json) =>
      _$CollectionDtoFromJson(json);
}

/// Represents the aggregated count result from Supabase `links(count)`.
@freezed
abstract class LinkCountDto with _$LinkCountDto {
  const factory LinkCountDto({
    required int count,
  }) = _LinkCountDto;

  factory LinkCountDto.fromJson(Map<String, dynamic> json) =>
      _$LinkCountDtoFromJson(json);
}
