import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/usecase/delete_link_usecase.dart';
import 'package:linknote/features/link/domain/usecase/fetch_links_usecase.dart';
import 'package:linknote/features/link/domain/usecase/toggle_favorite_usecase.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockFetchLinksUsecase extends Mock implements FetchLinksUsecase {}

class MockDeleteLinkUsecase extends Mock implements DeleteLinkUsecase {}

class MockToggleFavoriteUsecase extends Mock implements ToggleFavoriteUsecase {}

class FakeLinkEntity extends Fake implements LinkEntity {}

void main() {
  late MockFetchLinksUsecase mockFetch;
  late MockDeleteLinkUsecase mockDelete;
  late MockToggleFavoriteUsecase mockToggle;

  final tNow = DateTime(2026);
  final tLink1 = LinkEntity(
    id: 'link-1',
    url: 'https://example.com',
    title: 'Link 1',
    createdAt: tNow,
    updatedAt: tNow,
  );
  final tLink2 = LinkEntity(
    id: 'link-2',
    url: 'https://example2.com',
    title: 'Link 2',
    createdAt: tNow,
    updatedAt: tNow,
  );

  setUpAll(() {
    registerFallbackValue(FakeLinkEntity());
  });

  setUp(() {
    mockFetch = MockFetchLinksUsecase();
    mockDelete = MockDeleteLinkUsecase();
    mockToggle = MockToggleFavoriteUsecase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        fetchLinksUsecaseProvider.overrideWithValue(mockFetch),
        deleteLinkUsecaseProvider.overrideWithValue(mockDelete),
        toggleFavoriteUsecaseProvider.overrideWithValue(mockToggle),
      ],
    );
  }

  group('LinkList', () {
    group('build', () {
      test('should return paginated links on success', () async {
        // Arrange
        final tState = PaginatedState<LinkEntity>(items: [tLink1, tLink2]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(tState));

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        final result = await container.read(linkListProvider.future);

        // Assert
        expect(result.items, [tLink1, tLink2]);
      });

      test('should have error state when fetch fails', () async {
        // Arrange
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer(
          (_) async => error(const Failure.server(message: 'Network error')),
        );

        final container = createContainer();
        addTearDown(container.dispose);

        // Keep provider alive by listening
        final sub = container.listen(linkListProvider, (_, __) {});
        addTearDown(sub.close);

        // Wait for async build to settle
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        // Assert
        final state = container.read(linkListProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<Failure>());
      });
    });

    group('loadMore', () {
      test('should append items from next page', () async {
        // Arrange — initial page
        final page1 = PaginatedState<LinkEntity>(
          items: [tLink1],
          hasMore: true,
          nextCursor: 'cursor-1',
        );
        final page2 = PaginatedState<LinkEntity>(items: [tLink2]);

        var callCount = 0;
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          return success(callCount == 1 ? page1 : page2);
        });

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        // Act
        await container.read(linkListProvider.notifier).loadMore();

        // Assert
        final state = container.read(linkListProvider).value!;
        expect(state.items.length, 2);
        expect(state.items[0].id, 'link-1');
        expect(state.items[1].id, 'link-2');
        expect(state.isLoadingMore, isFalse);
      });

      test('should not load when hasMore is false', () async {
        // Arrange
        final page = PaginatedState<LinkEntity>(items: [tLink1]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(page));

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        // Act
        await container.read(linkListProvider.notifier).loadMore();

        // Assert — fetch called only once (build)
        verify(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).called(1);
      });
    });

    group('deleteLink', () {
      test('should optimistically remove link and keep on success', () async {
        // Arrange
        final page = PaginatedState<LinkEntity>(items: [tLink1, tLink2]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(page));
        when(
          () => mockDelete.call('link-1'),
        ).thenAnswer((_) async => success(null));

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        // Act
        await container.read(linkListProvider.notifier).deleteLink('link-1');

        // Assert
        final state = container.read(linkListProvider).value!;
        expect(state.items.length, 1);
        expect(state.items[0].id, 'link-2');
      });

      test('should rollback on delete failure', () async {
        // Arrange
        final page = PaginatedState<LinkEntity>(items: [tLink1, tLink2]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(page));
        when(() => mockDelete.call('link-1')).thenAnswer(
          (_) async => error(const Failure.server(message: 'Failed')),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        // Act
        await container.read(linkListProvider.notifier).deleteLink('link-1');

        // Assert — rolled back
        final state = container.read(linkListProvider).value!;
        expect(state.items.length, 2);
      });
    });

    group('toggleFavorite', () {
      test('should optimistically toggle and keep on success', () async {
        // Arrange
        final page = PaginatedState<LinkEntity>(items: [tLink1]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(page));
        when(
          () => mockToggle.call(
            'link-1',
            isFavorite: any(named: 'isFavorite'),
          ),
        ).thenAnswer(
          (_) async => success(tLink1.copyWith(isFavorite: true)),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        // Act
        await container
            .read(linkListProvider.notifier)
            .toggleFavorite('link-1');

        // Assert
        final state = container.read(linkListProvider).value!;
        expect(state.items[0].isFavorite, isTrue);
      });

      test('should rollback on toggle failure', () async {
        // Arrange
        final page = PaginatedState<LinkEntity>(items: [tLink1]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(page));
        when(
          () => mockToggle.call(
            'link-1',
            isFavorite: any(named: 'isFavorite'),
          ),
        ).thenAnswer(
          (_) async => error(const Failure.server(message: 'Failed')),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        // Act
        await container
            .read(linkListProvider.notifier)
            .toggleFavorite('link-1');

        // Assert — rolled back to false
        final state = container.read(linkListProvider).value!;
        expect(state.items[0].isFavorite, isFalse);
      });
    });
  });
}
