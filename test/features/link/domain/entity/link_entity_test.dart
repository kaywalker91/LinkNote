import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';

void main() {
  // Links are cached locally as `toJson()` maps in a Hive box (no TypeAdapter).
  // Rows written before the visibility/lockedAt fields existed lack those keys,
  // so deserialization must fall back to the safe defaults rather than throw.
  group('LinkEntity.fromJson backward compatibility', () {
    final oldCacheMap = <String, dynamic>{
      'id': '1',
      'url': 'https://flutter.dev',
      'title': 'Old cached link',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'collectionName': 'Dev',
      'tags': <dynamic>[],
      'isFavorite': false,
    };

    test('defaults collectionVisibility to private when key is absent', () {
      final entity = LinkEntity.fromJson(oldCacheMap);

      expect(entity.collectionVisibility, CollectionVisibility.private);
      expect(entity.collectionLockedAt, isNull);
    });

    test('round-trips visibility/lockedAt through toJson/fromJson', () {
      final entity = LinkEntity(
        id: '1',
        url: 'https://flutter.dev',
        title: 'New link',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        collectionName: 'Shared',
        collectionVisibility: CollectionVisibility.public,
        collectionLockedAt: DateTime.utc(2026, 5),
      );

      final restored = LinkEntity.fromJson(entity.toJson());

      expect(restored.collectionVisibility, CollectionVisibility.public);
      expect(restored.collectionLockedAt, DateTime.utc(2026, 5));
    });
  });

  group('LinkEntity.toJson nested serialisation', () {
    test('serialises nested tags as JSON maps so Hive can persist them', () {
      final entity = LinkEntity(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Tagged link',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        tags: const [TagEntity(id: 't1', name: 'dart', color: '#0553B1')],
      );

      final json = entity.toJson();
      final tags = json['tags']! as List<dynamic>;

      // explicit_to_json (build.yaml) must emit nested objects as maps, not
      // raw TagEntity instances that Hive/jsonEncode cannot serialise. Guards
      // the removal of the former link_local_datasource boundary workaround.
      expect(tags.single, isA<Map<String, dynamic>>());
      expect((tags.single as Map<String, dynamic>)['name'], 'dart');

      final restored = LinkEntity.fromJson(json);
      expect(restored.tags.single.name, 'dart');
    });
  });
}
