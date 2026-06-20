import 'package:linknote/features/collection/data/dto/collection_dto.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';

class CollectionMapper {
  const CollectionMapper._();

  static CollectionEntity toEntity(CollectionDto dto) {
    final linkCount = dto.links.fold<int>(0, (sum, e) => sum + e.count);
    return CollectionEntity(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      coverImageUrl: dto.coverImageUrl,
      linkCount: linkCount,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
      visibility: dto.visibility,
      lockedAt: dto.lockedAt,
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

  /// Focused PATCH payload for the in-app visibility/lock toggle. Deliberately
  /// excludes name/description so a toggle never clobbers user-edited text
  /// (and the name/desc edit path never clobbers visibility — see [toUpdateJson]).
  static Map<String, dynamic> toVisibilityUpdateJson(
    CollectionVisibility visibility,
    DateTime? lockedAt,
  ) {
    return {
      'visibility': visibility.name,
      'locked_at': lockedAt?.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
