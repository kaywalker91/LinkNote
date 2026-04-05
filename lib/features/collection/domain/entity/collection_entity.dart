import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_entity.freezed.dart';
part 'collection_entity.g.dart';

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
  }) = _CollectionEntity;

  factory CollectionEntity.fromJson(Map<String, dynamic> json) =>
      _$CollectionEntityFromJson(json);
}
