import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/collection/data/dto/collection_dto.dart';
import 'package:linknote/features/collection/data/mapper/collection_mapper.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';

void main() {
  const tDto = CollectionDto(
    id: 'col-1',
    userId: 'user-1',
    name: 'My Collection',
    description: 'A test collection',
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-02T00:00:00.000Z',
    links: [LinkCountDto(count: 3)],
  );

  final tEntity = CollectionEntity(
    id: 'col-1',
    name: 'My Collection',
    description: 'A test collection',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026, 1, 2),
  );

  test(
    'toEntity: maps CollectionDto fields to CollectionEntity correctly',
    () {
      final result = CollectionMapper.toEntity(tDto);

      expect(result.id, tEntity.id);
      expect(result.name, tEntity.name);
      expect(result.description, tEntity.description);
      expect(result.linkCount, 3);
      expect(result.coverImageUrl, isNull);
    },
  );

  test(
    'toEntity: uses 0 for linkCount when links list is empty',
    () {
      final dtoNoLinks = tDto.copyWith(links: []);
      final result = CollectionMapper.toEntity(dtoNoLinks);
      expect(result.linkCount, 0);
    },
  );

  test(
    'toEntity: sums count across multiple LinkCountDto entries',
    () {
      final dtoMulti = tDto.copyWith(
        links: const [LinkCountDto(count: 3), LinkCountDto(count: 2)],
      );
      final result = CollectionMapper.toEntity(dtoMulti);
      expect(result.linkCount, 5);
    },
  );

  test(
    'toEntity: returns 0 when single LinkCountDto has count 0',
    () {
      final dtoZero = tDto.copyWith(links: const [LinkCountDto(count: 0)]);
      final result = CollectionMapper.toEntity(dtoZero);
      expect(result.linkCount, 0);
    },
  );

  test(
    'toInsertJson: includes userId and name, excludes id',
    () {
      final json = CollectionMapper.toInsertJson(tEntity, 'user-123');

      expect(json['user_id'], 'user-123');
      expect(json['name'], tEntity.name);
      expect(json.containsKey('id'), isFalse);
    },
  );

  test(
    'toUpdateJson: includes name and updated_at, excludes id and user_id',
    () {
      final json = CollectionMapper.toUpdateJson(tEntity);

      expect(json['name'], tEntity.name);
      expect(json.containsKey('updated_at'), isTrue);
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('user_id'), isFalse);
    },
  );
}
