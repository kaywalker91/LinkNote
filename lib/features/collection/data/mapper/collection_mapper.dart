import 'package:linknote/features/collection/data/dto/collection_dto.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';

class CollectionMapper {
  const CollectionMapper._();

  static CollectionEntity toEntity(CollectionDto dto) {
    final linkCount = dto.links.isNotEmpty ? dto.links.first.count : 0;
    return CollectionEntity(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      coverImageUrl: dto.coverImageUrl,
      linkCount: linkCount,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  static Map<String, dynamic> toInsertJson(
    CollectionEntity entity,
    String userId,
  ) {
    return {
      'user_id': userId,
      'name': entity.name,
      'description': entity.description,
      'cover_image_url': entity.coverImageUrl,
    };
  }

  static Map<String, dynamic> toUpdateJson(CollectionEntity entity) {
    return {
      'name': entity.name,
      'description': entity.description,
      'cover_image_url': entity.coverImageUrl,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
