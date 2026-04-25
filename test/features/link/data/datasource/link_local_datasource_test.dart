import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/data/datasource/link_local_datasource.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockBox extends Mock implements Box<Map<dynamic, dynamic>> {}

void main() {
  late LinkLocalDataSource sut;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    sut = LinkLocalDataSource(mockBox);
  });

  final tLinkMap1 = <dynamic, dynamic>{
    'id': 'link-1',
    'url': 'https://example.com',
    'title': 'First Link',
    'createdAt': '2026-01-02T00:00:00.000',
    'updatedAt': '2026-01-02T00:00:00.000',
    'isFavorite': false,
    'tags': <dynamic>[],
  };

  final tLinkMap2 = <dynamic, dynamic>{
    'id': 'link-2',
    'url': 'https://example2.com',
    'title': 'Second Link',
    'createdAt': '2026-01-01T00:00:00.000',
    'updatedAt': '2026-01-01T00:00:00.000',
    'isFavorite': true,
    'tags': <dynamic>[],
  };

  final tLinkMap3 = <dynamic, dynamic>{
    'id': 'link-3',
    'url': 'https://example3.com',
    'title': 'Third Link',
    'createdAt': '2026-01-03T00:00:00.000',
    'updatedAt': '2026-01-03T00:00:00.000',
    'isFavorite': false,
    'tags': <dynamic>[],
  };

  // ---------------------------------------------------------------------------
  // getCachedLinks
  // ---------------------------------------------------------------------------
  group('getCachedLinks', () {
    test('should return cached links sorted by createdAt descending', () {
      // Arrange
      when(() => mockBox.isEmpty).thenReturn(false);
      when(() => mockBox.values).thenReturn([tLinkMap1, tLinkMap2, tLinkMap3]);

      // Act
      final result = sut.getCachedLinks();

      // Assert
      expect(result.isSuccess, isTrue);
      final items = result.data!.items;
      expect(items, hasLength(3));
      expect(items[0].id, 'link-3'); // 2026-01-03
      expect(items[1].id, 'link-1'); // 2026-01-02
      expect(items[2].id, 'link-2'); // 2026-01-01
    });

    test('should return only favorites when favoritesOnly is true', () {
      // Arrange
      when(() => mockBox.isEmpty).thenReturn(false);
      when(() => mockBox.values).thenReturn([tLinkMap1, tLinkMap2, tLinkMap3]);

      // Act
      final result = sut.getCachedLinks(favoritesOnly: true);

      // Assert
      expect(result.isSuccess, isTrue);
      final items = result.data!.items;
      expect(items, hasLength(1));
      expect(items[0].id, 'link-2');
      expect(items[0].isFavorite, isTrue);
    });

    test('should return CacheFailure when box is empty', () {
      // Arrange
      when(() => mockBox.isEmpty).thenReturn(true);

      // Act
      final result = sut.getCachedLinks();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<CacheFailure>());
    });

    test('should return only links matching collectionId', () {
      // Arrange
      final tLinkWithCollection = <dynamic, dynamic>{
        'id': 'link-4',
        'url': 'https://example4.com',
        'title': 'Collection Link',
        'createdAt': '2026-01-04T00:00:00.000',
        'updatedAt': '2026-01-04T00:00:00.000',
        'isFavorite': false,
        'collectionId': 'col-1',
        'tags': <dynamic>[],
      };
      when(() => mockBox.isEmpty).thenReturn(false);
      when(() => mockBox.values).thenReturn([
        tLinkMap1,
        tLinkMap2,
        tLinkWithCollection,
      ]);

      // Act
      final result = sut.getCachedLinks(collectionId: 'col-1');

      // Assert
      expect(result.isSuccess, isTrue);
      final items = result.data!.items;
      expect(items, hasLength(1));
      expect(items[0].id, 'link-4');
      expect(items[0].collectionId, 'col-1');
    });

    test('should skip unparseable entries gracefully', () {
      // Arrange
      final badMap = <dynamic, dynamic>{'invalid': 'data'};
      when(() => mockBox.isEmpty).thenReturn(false);
      when(() => mockBox.values).thenReturn([tLinkMap1, badMap]);

      // Act
      final result = sut.getCachedLinks();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.items, hasLength(1));
      expect(result.data!.items[0].id, 'link-1');
    });
  });

  // ---------------------------------------------------------------------------
  // getCachedLinkById
  // ---------------------------------------------------------------------------
  group('getCachedLinkById', () {
    test('should return link when found in cache', () {
      // Arrange
      when(() => mockBox.get('link-1')).thenReturn(tLinkMap1);

      // Act
      final result = sut.getCachedLinkById('link-1');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.id, 'link-1');
      expect(result.data!.url, 'https://example.com');
    });

    test('should return CacheFailure when id not found', () {
      // Arrange
      when(() => mockBox.get(any<dynamic>())).thenReturn(null);

      // Act
      final result = sut.getCachedLinkById('nonexistent');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<CacheFailure>());
    });

    test('should return CacheFailure when stored data is unparseable', () {
      // Arrange
      final badMap = <dynamic, dynamic>{'invalid': 'data'};
      when(() => mockBox.get('bad-link')).thenReturn(badMap);

      // Act
      final result = sut.getCachedLinkById('bad-link');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<CacheFailure>());
    });
  });

  // ---------------------------------------------------------------------------
  // cacheLinks
  // ---------------------------------------------------------------------------
  group('cacheLinks', () {
    test('should putAll links to box', () async {
      // Arrange
      final tLinks = [
        LinkEntity(
          id: 'link-1',
          url: 'https://example.com',
          title: 'Test',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];
      when(() => mockBox.putAll(any())).thenAnswer((_) async {});
      when(() => mockBox.length).thenReturn(1);

      // Act
      await sut.cacheLinks(tLinks);

      // Assert
      verify(
        () => mockBox.putAll(
          any(
            that: isA<Map<String, Map<String, dynamic>>>().having(
              (m) => m.containsKey('link-1'),
              'has link-1',
              isTrue,
            ),
          ),
        ),
      ).called(1);
    });

    test('should silently handle exceptions', () async {
      // Arrange
      final tLinks = [
        LinkEntity(
          id: 'link-1',
          url: 'https://example.com',
          title: 'Test',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];
      when(() => mockBox.putAll(any())).thenThrow(Exception('Hive error'));

      // Act & Assert — should not throw
      await sut.cacheLinks(tLinks);
    });

    test(
      'should serialize nested tags as List<Map> so Hive can store them',
      () async {
        // Regression: LinkEntity.toJson() leaves nested TagEntity instances
        // as-is (`'tags': instance.tags`). Hive then throws
        // `HiveError: Cannot write, unknown type: _TagEntity`.
        final tLinks = [
          LinkEntity(
            id: 'link-1',
            url: 'https://example.com',
            title: 'Test',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
            tags: const [
              TagEntity(id: 'tag-1', name: 'Flutter', color: '#FF0000'),
              TagEntity(id: 'tag-2', name: 'Dart', color: '#0000FF'),
            ],
          ),
        ];
        Map<String, Map<String, dynamic>>? captured;
        when(() => mockBox.putAll(any())).thenAnswer((invocation) async {
          captured =
              invocation.positionalArguments.first
                  as Map<String, Map<String, dynamic>>;
        });
        when(() => mockBox.length).thenReturn(1);

        // Act
        await sut.cacheLinks(tLinks);

        // Assert — every nested tag must be a plain Map, not a TagEntity.
        expect(captured, isNotNull);
        final stored = captured!['link-1'];
        expect(stored, isNotNull);
        final tags = stored!['tags'];
        expect(tags, isA<List<dynamic>>());
        for (final tag in tags as List<dynamic>) {
          expect(
            tag,
            isA<Map<String, dynamic>>(),
            reason:
                'Hive cannot serialize TagEntity instances; '
                'nested tags must be Map<String, dynamic>',
          );
        }
        expect((tags.first as Map<String, dynamic>)['id'], 'tag-1');
        expect((tags.first as Map<String, dynamic>)['name'], 'Flutter');
      },
    );
  });

  // ---------------------------------------------------------------------------
  // cacheSingleLink
  // ---------------------------------------------------------------------------
  group('cacheSingleLink', () {
    test('should put single link to box', () async {
      // Arrange
      final tLink = LinkEntity(
        id: 'link-1',
        url: 'https://example.com',
        title: 'Test',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      when(
        () => mockBox.put(any<dynamic>(), any<Map<dynamic, dynamic>>()),
      ).thenAnswer((_) async {});
      when(() => mockBox.length).thenReturn(1);

      // Act
      await sut.cacheSingleLink(tLink);

      // Assert
      verify(() => mockBox.put('link-1', any())).called(1);
    });

    test(
      'should serialize nested tags as List<Map> when caching one',
      () async {
        // Same regression as cacheLinks — but via the single-link write path.
        final tLink = LinkEntity(
          id: 'link-1',
          url: 'https://example.com',
          title: 'Test',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          tags: const [
            TagEntity(id: 'tag-1', name: 'Flutter', color: '#FF0000'),
          ],
        );
        Map<String, dynamic>? captured;
        when(
          () => mockBox.put(any<dynamic>(), any<Map<dynamic, dynamic>>()),
        ).thenAnswer((invocation) async {
          captured = invocation.positionalArguments[1] as Map<String, dynamic>;
        });
        when(() => mockBox.length).thenReturn(1);

        // Act
        await sut.cacheSingleLink(tLink);

        // Assert
        expect(captured, isNotNull);
        final tags = captured!['tags'];
        expect(tags, isA<List<dynamic>>());
        for (final tag in tags as List<dynamic>) {
          expect(tag, isA<Map<String, dynamic>>());
        }
      },
    );
  });

  // ---------------------------------------------------------------------------
  // removeCachedLink
  // ---------------------------------------------------------------------------
  group('removeCachedLink', () {
    test('should delete link by id', () async {
      // Arrange
      when(() => mockBox.delete(any<dynamic>())).thenAnswer((_) async {});

      // Act
      await sut.removeCachedLink('link-1');

      // Assert
      verify(() => mockBox.delete('link-1')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // updateCachedFavorite
  // ---------------------------------------------------------------------------
  group('updateCachedFavorite', () {
    test('should update isFavorite field in cached map', () async {
      // Arrange
      when(() => mockBox.get('link-1')).thenReturn(tLinkMap1);
      when(
        () => mockBox.put(any<dynamic>(), any<Map<dynamic, dynamic>>()),
      ).thenAnswer((_) async {});

      // Act
      await sut.updateCachedFavorite('link-1', isFavorite: true);

      // Assert
      verify(
        () => mockBox.put(
          'link-1',
          any(
            that: isA<Map<String, dynamic>>().having(
              (m) => m['isFavorite'],
              'isFavorite',
              isTrue,
            ),
          ),
        ),
      ).called(1);
    });

    test('should do nothing when id not found', () async {
      // Arrange
      when(() => mockBox.get('nonexistent')).thenReturn(null);

      // Act
      await sut.updateCachedFavorite('nonexistent', isFavorite: true);

      // Assert
      verifyNever(
        () => mockBox.put(any<dynamic>(), any<Map<dynamic, dynamic>>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // clearAll
  // ---------------------------------------------------------------------------
  group('clearAll', () {
    test('should clear the box', () async {
      // Arrange
      when(() => mockBox.clear()).thenAnswer((_) async => 0);

      // Act
      await sut.clearAll();

      // Assert
      verify(() => mockBox.clear()).called(1);
    });
  });
}
