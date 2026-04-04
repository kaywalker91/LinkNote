import 'package:linknote/features/link/data/dto/link_dto.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';

class LinkMapper {
  const LinkMapper._();

  static LinkEntity toEntity(LinkDto dto) {
    return LinkEntity(
      id: dto.id,
      url: dto.url,
      title: dto.title,
      description: dto.description,
      thumbnailUrl: dto.thumbnailUrl,
      collectionId: dto.collectionId,
      collectionName: dto.collections?.name,
      memo: dto.memo,
      isFavorite: dto.isFavorite,
      tags: dto.linkTags.map((lt) => _tagToEntity(lt.tags)).toList(),
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  static TagEntity _tagToEntity(TagDto dto) {
    return TagEntity(
      id: dto.id,
      name: dto.name,
      color: dto.color,
    );
  }

  static Map<String, dynamic> toInsertJson(LinkEntity entity, String userId) {
    return {
      'user_id': userId,
      'url': entity.url,
      'title': entity.title,
      'description': entity.description,
      'thumbnail_url': entity.thumbnailUrl,
      'collection_id': entity.collectionId,
      'memo': entity.memo,
      'is_favorite': entity.isFavorite,
    };
  }

  static Map<String, dynamic> toUpdateJson(LinkEntity entity) {
    return {
      'url': entity.url,
      'title': entity.title,
      'description': entity.description,
      'thumbnail_url': entity.thumbnailUrl,
      'collection_id': entity.collectionId,
      'memo': entity.memo,
      'is_favorite': entity.isFavorite,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
