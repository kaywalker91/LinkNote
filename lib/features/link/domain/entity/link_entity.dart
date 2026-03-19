import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';

part 'link_entity.freezed.dart';
part 'link_entity.g.dart';

@freezed
abstract class LinkEntity with _$LinkEntity {
  const factory LinkEntity({
    required String id,
    required String url,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    String? thumbnailUrl,
    String? collectionId,
    String? collectionName,
    String? memo,
    @Default([]) List<TagEntity> tags,
    @Default(false) bool isFavorite,
  }) = _LinkEntity;

  factory LinkEntity.fromJson(Map<String, dynamic> json) =>
      _$LinkEntityFromJson(json);
}
