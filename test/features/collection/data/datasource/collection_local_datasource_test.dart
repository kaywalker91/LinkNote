import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/data/datasource/collection_local_datasource.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockBox extends Mock implements Box<Map<dynamic, dynamic>> {}

void main() {
  late CollectionLocalDataSource sut;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    sut = CollectionLocalDataSource(mockBox);
  });

  final tCollectionMap1 = <dynamic, dynamic>{
    'id': 'col-1',
    'name': 'Tech Articles',
    'createdAt': '2026-01-02T00:00:00.000',
    'updatedAt': '2026-01-02T00:00:00.000',
    'linkCount': 5,
  };

  final tCollectionMap2 = <dynamic, dynamic>{
    'id': 'col-2',
    'name': 'Design',
    'createdAt': '2026-01-01T00:00:00.000',
    'updatedAt': '2026-01-01T00:00:00.000',
    'linkCount': 3,
  };

  final tCollectionMap3 = <dynamic, dynamic>{
    'id': 'col-3',
    'name': 'Flutter',
    'createdAt': '2026-01-03T00:00:00.000',
    'updatedAt': '2026-01-03T00:00:00.000',
    'description': 'Flutter resources',
    'linkCount': 10,
  };

  // ---------------------------------------------------------------------------
  // getCachedCollections
  // ---------------------------------------------------------------------------
  group('getCachedCollections', () {
    test('should return cached collections sorted by createdAt descending', () {
      // Arrange
      when(() => mockBox.isEmpty).thenReturn(false);
      when(() => mockBox.values).thenReturn([
        tCollectionMap1,
        tCollectionMap2,
        tCollectionMap3,
      ]);

      // Act
      final result = sut.getCachedCollections();

      // Assert
      expect(result.isSuccess, isTrue);
      final items = result.data!.items;
      expect(items, hasLength(3));
      expect(items[0].id, 'col-3'); // 2026-01-03
      expect(items[1].id, 'col-1'); // 2026-01-02
      expect(items[2].id, 'col-2'); // 2026-01-01
    });

    test('should return CacheFailure when box is empty', () {
      // Arrange
      when(() => mockBox.isEmpty).thenReturn(true);

      // Act
      final result = sut.getCachedCollections();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<CacheFailure>());
    });

    test('should skip unparseable entries gracefully', () {
      // Arrange
      final badMap = <dynamic, dynamic>{'invalid': 'data'};
      when(() => mockBox.isEmpty).thenReturn(false);
      when(() => mockBox.values).thenReturn([tCollectionMap1, badMap]);

      // Act
      final result = sut.getCachedCollections();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.items, hasLength(1));
      expect(result.data!.items[0].id, 'col-1');
    });
  });

  // ---------------------------------------------------------------------------
  // getCachedCollectionById
  // ---------------------------------------------------------------------------
  group('getCachedCollectionById', () {
    test('should return collection when found in cache', () {
      // Arrange
      when(() => mockBox.get('col-1')).thenReturn(tCollectionMap1);

      // Act
      final result = sut.getCachedCollectionById('col-1');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.id, 'col-1');
      expect(result.data!.name, 'Tech Articles');
    });

    test('should return CacheFailure when id not found', () {
      // Arrange
      when(() => mockBox.get(any<dynamic>())).thenReturn(null);

      // Act
      final result = sut.getCachedCollectionById('nonexistent');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<CacheFailure>());
    });

    test('should return CacheFailure when stored data is unparseable', () {
      // Arrange
      final badMap = <dynamic, dynamic>{'invalid': 'data'};
      when(() => mockBox.get('bad-col')).thenReturn(badMap);

      // Act
      final result = sut.getCachedCollectionById('bad-col');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<CacheFailure>());
    });
  });

  // ---------------------------------------------------------------------------
  // cacheCollections
  // ---------------------------------------------------------------------------
  group('cacheCollections', () {
    test('should putAll collections to box', () async {
      // Arrange
      final tCollections = [
        CollectionEntity(
          id: 'col-1',
          name: 'Test',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];
      when(() => mockBox.putAll(any())).thenAnswer((_) async {});
      when(() => mockBox.length).thenReturn(1);

      // Act
      await sut.cacheCollections(tCollections);

      // Assert
      verify(
        () => mockBox.putAll(
          any(
            that: isA<Map<String, Map<String, dynamic>>>().having(
              (m) => m.containsKey('col-1'),
              'has col-1',
              isTrue,
            ),
          ),
        ),
      ).called(1);
    });

    test('should silently handle exceptions', () async {
      // Arrange
      final tCollections = [
        CollectionEntity(
          id: 'col-1',
          name: 'Test',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];
      when(() => mockBox.putAll(any())).thenThrow(Exception('Hive error'));

      // Act & Assert — should not throw
      await sut.cacheCollections(tCollections);
    });
  });

  // ---------------------------------------------------------------------------
  // cacheSingleCollection
  // ---------------------------------------------------------------------------
  group('cacheSingleCollection', () {
    test('should put single collection to box', () async {
      // Arrange
      final tCollection = CollectionEntity(
        id: 'col-1',
        name: 'Test',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      when(
        () => mockBox.put(any<dynamic>(), any<Map<dynamic, dynamic>>()),
      ).thenAnswer((_) async {});
      when(() => mockBox.length).thenReturn(1);

      // Act
      await sut.cacheSingleCollection(tCollection);

      // Assert
      verify(() => mockBox.put('col-1', any())).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // removeCachedCollection
  // ---------------------------------------------------------------------------
  group('removeCachedCollection', () {
    test('should delete collection by id', () async {
      // Arrange
      when(() => mockBox.delete(any<dynamic>())).thenAnswer((_) async {});

      // Act
      await sut.removeCachedCollection('col-1');

      // Assert
      verify(() => mockBox.delete('col-1')).called(1);
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
