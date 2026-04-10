import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/data/datasource/link_local_datasource.dart';
import 'package:linknote/features/link/data/datasource/link_remote_datasource.dart';
import 'package:linknote/features/link/data/repository/link_repository_impl.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock implements LinkRemoteDataSource {}

class MockLocalDataSource extends Mock implements LinkLocalDataSource {}

class FakeLinkEntity extends Fake implements LinkEntity {}

void main() {
  late LinkRepositoryImpl sut;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUpAll(() {
    registerFallbackValue(FakeLinkEntity());
  });

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    sut = LinkRepositoryImpl(
      mockRemote,
      mockLocal,
      userId: 'test-user-id',
    );
  });

  final tLink = LinkEntity(
    id: 'link-1',
    url: 'https://example.com',
    title: 'Test Link',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final tLinks = [tLink];

  final tPaginatedState = PaginatedState<LinkEntity>(
    items: tLinks,
  );

  // ---------------------------------------------------------------------------
  // getLinks
  // ---------------------------------------------------------------------------
  group('getLinks', () {
    test(
      'should cache links and return remote data on success (initial fetch)',
      () async {
        // Arrange
        when(
          () => mockRemote.getLinks(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(tPaginatedState));
        when(() => mockLocal.cacheLinks(any())).thenAnswer((_) async {});

        // Act
        final result = await sut.getLinks();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.items, equals(tLinks));
        verify(() => mockLocal.cacheLinks(tLinks)).called(1);
      },
    );

    test(
      'should fall back to local cache when remote fails (initial fetch)',
      () async {
        // Arrange
        const tFailure = Failure.network(message: 'No connection');
        final tCachedState = PaginatedState<LinkEntity>(items: tLinks);

        when(
          () => mockRemote.getLinks(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => error(tFailure));
        when(
          () => mockLocal.getCachedLinks(
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenReturn(success(tCachedState));

        // Act
        final result = await sut.getLinks();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.items, equals(tLinks));
        verify(
          () => mockLocal.getCachedLinks(
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).called(1);
      },
    );

    test(
      'should NOT fall back to local cache for paginated fetch (cursor != null)',
      () async {
        // Arrange
        const tFailure = Failure.network(message: 'No connection');
        when(
          () => mockRemote.getLinks(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => error(tFailure));

        // Act
        final result = await sut.getLinks(cursor: 'some-cursor');

        // Assert
        expect(result.isFailure, isTrue);
        verifyNever(
          () => mockLocal.getCachedLinks(
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        );
      },
    );

    test('should cache subsequent pages as well', () async {
      // Arrange
      when(
        () => mockRemote.getLinks(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
          favoritesOnly: any(named: 'favoritesOnly'),
        ),
      ).thenAnswer((_) async => success(tPaginatedState));
      when(() => mockLocal.cacheLinks(any())).thenAnswer((_) async {});

      // Act
      await sut.getLinks(cursor: 'some-cursor');

      // Assert
      verify(() => mockLocal.cacheLinks(tLinks)).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // getLinkById
  // ---------------------------------------------------------------------------
  group('getLinkById', () {
    test('should cache and return link on remote success', () async {
      // Arrange
      when(
        () => mockRemote.getLinkById(any()),
      ).thenAnswer((_) async => success(tLink));
      when(() => mockLocal.cacheSingleLink(any())).thenAnswer((_) async {});

      // Act
      final result = await sut.getLinkById('link-1');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tLink));
      verify(() => mockLocal.cacheSingleLink(tLink)).called(1);
    });

    test('should fall back to cache on remote failure', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Not found');
      when(
        () => mockRemote.getLinkById(any()),
      ).thenAnswer((_) async => error(tFailure));
      when(() => mockLocal.getCachedLinkById(any())).thenReturn(success(tLink));

      // Act
      final result = await sut.getLinkById('link-1');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tLink));
      verify(() => mockLocal.getCachedLinkById('link-1')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // createLink
  // ---------------------------------------------------------------------------
  group('createLink', () {
    test('should cache created link on remote success', () async {
      // Arrange
      when(
        () => mockRemote.createLink(any(), any()),
      ).thenAnswer((_) async => success(tLink));
      when(() => mockLocal.cacheSingleLink(any())).thenAnswer((_) async {});

      // Act
      final result = await sut.createLink(tLink);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.createLink(tLink, 'test-user-id')).called(1);
      verify(() => mockLocal.cacheSingleLink(tLink)).called(1);
    });

    test('should NOT cache on remote failure', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Create failed');
      when(
        () => mockRemote.createLink(any(), any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.createLink(tLink);

      // Assert
      expect(result.isFailure, isTrue);
      verifyNever(() => mockLocal.cacheSingleLink(any()));
    });
  });

  // ---------------------------------------------------------------------------
  // deleteLink
  // ---------------------------------------------------------------------------
  group('deleteLink', () {
    test('should remove cached link on remote success', () async {
      // Arrange
      when(
        () => mockRemote.deleteLink(any()),
      ).thenAnswer((_) async => success(null));
      when(() => mockLocal.removeCachedLink(any())).thenAnswer((_) async {});

      // Act
      final result = await sut.deleteLink('link-1');

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.removeCachedLink('link-1')).called(1);
    });

    test('should return failure on remote failure', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Delete failed');
      when(
        () => mockRemote.deleteLink(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.deleteLink('link-1');

      // Assert
      expect(result.isFailure, isTrue);
      verifyNever(() => mockLocal.removeCachedLink(any()));
    });
  });

  // ---------------------------------------------------------------------------
  // toggleFavorite
  // ---------------------------------------------------------------------------
  group('toggleFavorite', () {
    test('should update cache on remote success', () async {
      // Arrange
      final tFavLink = tLink.copyWith(isFavorite: true);
      when(
        () => mockRemote.toggleFavorite(
          any(),
          isFavorite: any(named: 'isFavorite'),
        ),
      ).thenAnswer((_) async => success(tFavLink));
      when(
        () => mockLocal.updateCachedFavorite(
          any(),
          isFavorite: any(named: 'isFavorite'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await sut.toggleFavorite('link-1', isFavorite: true);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(
        () => mockLocal.updateCachedFavorite('link-1', isFavorite: true),
      ).called(1);
    });
  });
}
