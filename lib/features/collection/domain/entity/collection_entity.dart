import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_entity.freezed.dart';
part 'collection_entity.g.dart';

enum CollectionVisibility {
  @JsonValue('public')
  public,
  @JsonValue('private')
  private,
}

@freezed
abstract class CollectionEntity with _$CollectionEntity {
  const factory CollectionEntity({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    String? coverImageUrl,
    @Default(0) int linkCount,
    @JsonKey(unknownEnumValue: CollectionVisibility.private)
    @Default(CollectionVisibility.private)
    CollectionVisibility visibility,
    DateTime? lockedAt,
  }) = _CollectionEntity;

  factory CollectionEntity.fromJson(Map<String, dynamic> json) =>
      _$CollectionEntityFromJson(json);
}
