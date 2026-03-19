import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_entity.freezed.dart';
part 'collection_entity.g.dart';

@freezed
abstract class CollectionEntity with _$CollectionEntity {
  const factory CollectionEntity({
    required String id,
    required String name,
    String? description,
    String? coverImageUrl,
    @Default(0) int linkCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CollectionEntity;

  factory CollectionEntity.fromJson(Map<String, dynamic> json) =>
      _$CollectionEntityFromJson(json);
}
