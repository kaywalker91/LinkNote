import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/data/dto/link_dto.dart';
import 'package:linknote/features/link/data/mapper/link_mapper.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';

void main() {
  // ---------------------------------------------------------------------------
  // toEntity
  // ---------------------------------------------------------------------------
  group('LinkMapper.toEntity', () {
    test('should convert LinkDto to LinkEntity with all fields', () {
      // Arrange
      const dto = LinkDto(
        id: 'dto-id',
        userId: 'user-1',
        url: 'https://example.com',
        title: 'Test Title',
        description: 'Some description',
        thumbnailUrl: 'https://example.com/thumb.png',
        collectionId: 'col-1',
        memo: 'My memo',
        isFavorite: true,
        createdAt: '2026-01-15T10:30:00.000Z',
        updatedAt: '2026-01-16T12:00:00.000Z',
        linkTags: [
          LinkTagDto(
            tags: TagDto(id: 'tag-1', name: 'flutter', color: '#42A5F5'),
          ),
          LinkTagDto(
            tags: TagDto(id: 'tag-2', name: 'dart', color: '#66BB6A'),
          ),
        ],
        collections: CollectionNameDto(name: 'Dev Resources'),
      );

      // Act
      final entity = LinkMapper.toEntity(dto);

      // Assert
      expect(entity.id, 'dto-id');
      expect(entity.url, 'https://example.com');
      expect(entity.title, 'Test Title');
      expect(entity.description, 'Some description');
      expect(entity.thumbnailUrl, 'https://example.com/thumb.png');
      expect(entity.collectionId, 'col-1');
      expect(entity.collectionName, 'Dev Resources');
      expect(entity.memo, 'My memo');
      expect(entity.isFavorite, isTrue);
      expect(entity.createdAt, DateTime.utc(2026, 1, 15, 10, 30));
      expect(entity.updatedAt, DateTime.utc(2026, 1, 16, 12));
      expect(entity.tags, hasLength(2));
      expect(
        entity.tags[0],
        const TagEntity(id: 'tag-1', name: 'flutter', color: '#42A5F5'),
      );
      expect(
        entity.tags[1],
        const TagEntity(id: 'tag-2', name: 'dart', color: '#66BB6A'),
      );
    });

    test('should handle nullable fields as null', () {
      // Arrange
      const dto = LinkDto(
        id: 'dto-id',
        userId: 'user-1',
        url: 'https://example.com',
        title: 'Minimal',
        createdAt: '2026-01-01T00:00:00.000Z',
        updatedAt: '2026-01-01T00:00:00.000Z',
      );

      // Act
      final entity = LinkMapper.toEntity(dto);

      // Assert
      expect(entity.description, isNull);
      expect(entity.thumbnailUrl, isNull);
      expect(entity.collectionId, isNull);
      expect(entity.collectionName, isNull);
      expect(entity.memo, isNull);
      expect(entity.isFavorite, isFalse);
      expect(entity.tags, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // toInsertJson
  // ---------------------------------------------------------------------------
  group('LinkMapper.toInsertJson', () {
    test('should produce correct JSON with user_id', () {
      // Arrange
      final entity = LinkEntity(
        id: 'ignored-id',
        url: 'https://example.com',
        title: 'Insert Test',
        description: 'desc',
        thumbnailUrl: 'https://example.com/thumb.png',
        collectionId: 'col-1',
        memo: 'memo',
        isFavorite: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      // Act
      final json = LinkMapper.toInsertJson(entity, 'user-123');

      // Assert
      expect(json['user_id'], 'user-123');
      expect(json['url'], 'https://example.com');
      expect(json['title'], 'Insert Test');
      expect(json['description'], 'desc');
      expect(json['thumbnail_url'], 'https://example.com/thumb.png');
      expect(json['collection_id'], 'col-1');
      expect(json['memo'], 'memo');
      expect(json['is_favorite'], isTrue);
      // id should NOT be in insert JSON
      expect(json.containsKey('id'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // toUpdateJson
  // ---------------------------------------------------------------------------
  group('LinkMapper.toUpdateJson', () {
    test('should produce correct JSON with updated_at', () {
      // Arrange
      final entity = LinkEntity(
        id: 'link-1',
        url: 'https://updated.com',
        title: 'Updated Title',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      // Act
      final json = LinkMapper.toUpdateJson(entity);

      // Assert
      expect(json['url'], 'https://updated.com');
      expect(json['title'], 'Updated Title');
      expect(json.containsKey('updated_at'), isTrue);
      // updated_at should be a valid ISO 8601 string
      expect(
        () => DateTime.parse(json['updated_at'] as String),
        returnsNormally,
      );
      // Should NOT contain id or user_id
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('user_id'), isFalse);
    });
  });
}
