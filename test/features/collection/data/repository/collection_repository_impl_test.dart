import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/data/datasource/collection_local_datasource.dart';
import 'package:linknote/features/collection/data/datasource/collection_remote_datasource.dart';
import 'package:linknote/features/collection/data/repository/collection_repository_impl.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock implements CollectionRemoteDataSource {}

class MockLocalDataSource extends Mock implements CollectionLocalDataSource {}

class FakeCollectionEntity extends Fake implements CollectionEntity {}

void main() {
  late CollectionRepositoryImpl sut;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUpAll(() {
    registerFallbackValue(FakeCollectionEntity());
  });

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    sut = CollectionRepositoryImpl(
      mockRemote,
      mockLocal,
      userId: 'test-user-id',
    );
  });

  final tCollection = CollectionEntity(
    id: 'col-1',
    name: 'Test Collection',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final tCollections = [tCollection];

  final tPaginatedState = PaginatedState<CollectionEntity>(
    items: tCollections,
  );

  // ---------------------------------------------------------------------------
  // getCollections
  // ---------------------------------------------------------------------------
  group('getCollections', () {
    test(
      'should cache and return remote data on success (initial fetch)',
      () async {
        // Arrange
        when(
          () => mockRemote.getCollections(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => success(tPaginatedState));
        when(
          () => mockLocal.cacheCollections(any()),
        ).thenAnswer((_) async {});

        // Act
        final result = await sut.getCollections();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.items, equals(tCollections));
        verify(() => mockLocal.cacheCollections(tCollections)).called(1);
      },
    );

    test(
      'should fall back to local cache when remote fails (initial fetch)',
      () async {
        // Arrange
        const tFailure = Failure.network(message: 'No connection');
        final tCachedState = PaginatedState<CollectionEntity>(
          items: tCollections,
        );

        when(
          () => mockRemote.getCollections(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => error(tFailure));
        when(
          () => mockLocal.getCachedCollections(),
        ).thenReturn(success(tCachedState));

        // Act
        final result = await sut.getCollections();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.items, equals(tCollections));
        verify(() => mockLocal.getCachedCollections()).called(1);
      },
    );

    test(
      'should NOT fall back to local cache for paginated fetch (cursor != null)',
      () async {
        // Arrange
        const tFailure = Failure.network(message: 'No connection');
        when(
          () => mockRemote.getCollections(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => error(tFailure));

        // Act
        final result = await sut.getCollections(cursor: 'some-cursor');

        // Assert
        expect(result.isFailure, isTrue);
        verifyNever(() => mockLocal.getCachedCollections());
      },
    );

    test(
      'should NOT cache on paginated success (cursor != null)',
      () async {
        // Arrange
        when(
          () => mockRemote.getCollections(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => success(tPaginatedState));

        // Act
        await sut.getCollections(cursor: 'some-cursor');

        // Assert
        verifyNever(() => mockLocal.cacheCollections(any()));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // getCollectionById
  // ---------------------------------------------------------------------------
  group('getCollectionById', () {
    test('should delegate to remote datasource', () async {
      // Arrange
      when(
        () => mockRemote.getCollectionById(any()),
      ).thenAnswer((_) async => success(tCollection));

      // Act
      final result = await sut.getCollectionById('col-1');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tCollection));
    });
  });

  // ---------------------------------------------------------------------------
  // createCollection
  // ---------------------------------------------------------------------------
  group('createCollection', () {
    test('should cache on remote success', () async {
      // Arrange
      when(
        () => mockRemote.createCollection(any(), any()),
      ).thenAnswer((_) async => success(tCollection));
      when(
        () => mockLocal.cacheSingleCollection(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await sut.createCollection(tCollection);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(
        () => mockRemote.createCollection(tCollection, 'test-user-id'),
      ).called(1);
      verify(() => mockLocal.cacheSingleCollection(tCollection)).called(1);
    });

    test('should NOT cache on remote failure', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Create failed');
      when(
        () => mockRemote.createCollection(any(), any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.createCollection(tCollection);

      // Assert
      expect(result.isFailure, isTrue);
      verifyNever(() => mockLocal.cacheSingleCollection(any()));
    });
  });

  // ---------------------------------------------------------------------------
  // updateCollection
  // ---------------------------------------------------------------------------
  group('updateCollection', () {
    test('should cache on remote success', () async {
      // Arrange
      final tUpdated = tCollection.copyWith(name: 'Updated');
      when(
        () => mockRemote.updateCollection(any()),
      ).thenAnswer((_) async => success(tUpdated));
      when(
        () => mockLocal.cacheSingleCollection(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await sut.updateCollection(tUpdated);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.cacheSingleCollection(tUpdated)).called(1);
    });

    test('should NOT cache on remote failure', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Update failed');
      when(
        () => mockRemote.updateCollection(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.updateCollection(tCollection);

      // Assert
      expect(result.isFailure, isTrue);
      verifyNever(() => mockLocal.cacheSingleCollection(any()));
    });
  });

  // ---------------------------------------------------------------------------
  // deleteCollection
  // ---------------------------------------------------------------------------
  group('deleteCollection', () {
    test('should remove cache on remote success', () async {
      // Arrange
      when(
        () => mockRemote.deleteCollection(any()),
      ).thenAnswer((_) async => success(null));
      when(
        () => mockLocal.removeCachedCollection(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await sut.deleteCollection('col-1');

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.removeCachedCollection('col-1')).called(1);
    });

    test('should NOT remove cache on remote failure', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Delete failed');
      when(
        () => mockRemote.deleteCollection(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.deleteCollection('col-1');

      // Assert
      expect(result.isFailure, isTrue);
      verifyNever(() => mockLocal.removeCachedCollection(any()));
    });
  });
}
