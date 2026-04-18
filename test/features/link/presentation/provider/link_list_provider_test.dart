import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/usecase/get_collections_usecase.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart'
    as collection_list;
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/usecase/delete_link_usecase.dart';
import 'package:linknote/features/link/domain/usecase/fetch_links_usecase.dart';
import 'package:linknote/features/link/domain/usecase/get_link_detail_usecase.dart';
import 'package:linknote/features/link/domain/usecase/toggle_favorite_usecase.dart';
import 'package:linknote/features/link/domain/usecase/update_link_usecase.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFetchLinksUsecase extends Mock implements FetchLinksUsecase {}

class MockDeleteLinkUsecase extends Mock implements DeleteLinkUsecase {}

class MockToggleFavoriteUsecase extends Mock implements ToggleFavoriteUsecase {}

class MockUpdateLinkUsecase extends Mock implements UpdateLinkUsecase {}

class MockGetCollectionsUsecase extends Mock implements GetCollectionsUsecase {}

class MockGetLinkDetailUsecase extends Mock implements GetLinkDetailUsecase {}

class FakeLinkEntity extends Fake implements LinkEntity {}

void main() {
  late MockFetchLinksUsecase mockFetch;
  late MockDeleteLinkUsecase mockDelete;
  late MockToggleFavoriteUsecase mockToggle;
  late MockUpdateLinkUsecase mockUpdate;

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
    mockUpdate = MockUpdateLinkUsecase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        fetchLinksUsecaseProvider.overrideWithValue(mockFetch),
        deleteLinkUsecaseProvider.overrideWithValue(mockDelete),
        toggleFavoriteUsecaseProvider.overrideWithValue(mockToggle),
        updateLinkUsecaseProvider.overrideWithValue(mockUpdate),
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

      test(
        'should invalidate linkDetailProvider so detail screen refreshes',
        () async {
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

          var detailFetchCount = 0;
          final mockGetDetail = MockGetLinkDetailUsecase();
          when(() => mockGetDetail.call(any())).thenAnswer((_) async {
            detailFetchCount++;
            return success(tLink1);
          });

          final container = ProviderContainer(
            overrides: [
              fetchLinksUsecaseProvider.overrideWithValue(mockFetch),
              deleteLinkUsecaseProvider.overrideWithValue(mockDelete),
              toggleFavoriteUsecaseProvider.overrideWithValue(mockToggle),
              updateLinkUsecaseProvider.overrideWithValue(mockUpdate),
              getLinkDetailUsecaseProvider.overrideWithValue(mockGetDetail),
            ],
          );
          addTearDown(container.dispose);
          await container.read(linkListProvider.future);

          final sub = container.listen(
            linkDetailProvider('link-1'),
            (_, __) {},
          );
          addTearDown(sub.close);
          await container.read(linkDetailProvider('link-1').future);
          expect(detailFetchCount, 1);

          await container
              .read(linkListProvider.notifier)
              .toggleFavorite('link-1');

          await container.read(linkDetailProvider('link-1').future);
          expect(detailFetchCount, 2);
        },
      );

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

    group('moveToCollection', () {
      test('should update link with new collectionId on success', () async {
        // Arrange
        final tUpdated = tLink1.copyWith(
          collectionId: 'col-1',
          collectionName: 'Dev',
        );
        final tState = PaginatedState<LinkEntity>(items: [tLink1]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(tState));
        when(() => mockUpdate.call(any())).thenAnswer(
          (_) async => success(tUpdated),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        // Act
        await container
            .read(linkListProvider.notifier)
            .moveToCollection(linkId: 'link-1', collectionId: 'col-1');

        // Assert
        final state = container.read(linkListProvider).value!;
        expect(state.items[0].collectionId, 'col-1');
        final captured =
            verify(
                  () => mockUpdate.call(captureAny()),
                ).captured.single
                as LinkEntity;
        expect(captured.collectionId, 'col-1');
      });

      test('should support clearing collectionId with null', () async {
        // Arrange
        final tSeeded = tLink1.copyWith(
          collectionId: 'col-1',
          collectionName: 'Dev',
        );
        final tCleared = tLink1.copyWith();
        final tState = PaginatedState<LinkEntity>(items: [tSeeded]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(tState));
        when(() => mockUpdate.call(any())).thenAnswer(
          (_) async => success(tCleared),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        // Act
        await container
            .read(linkListProvider.notifier)
            .moveToCollection(linkId: 'link-1', collectionId: null);

        // Assert
        final captured =
            verify(
                  () => mockUpdate.call(captureAny()),
                ).captured.single
                as LinkEntity;
        expect(captured.collectionId, isNull);
      });

      test(
        'should invalidate collectionListProvider to refresh linkCount',
        () async {
          // Arrange
          final tUpdated = tLink1.copyWith(
            collectionId: 'col-1',
            collectionName: 'Dev',
          );
          final tState = PaginatedState<LinkEntity>(items: [tLink1]);
          when(
            () => mockFetch.call(
              cursor: any(named: 'cursor'),
              favoritesOnly: any(named: 'favoritesOnly'),
              collectionId: any(named: 'collectionId'),
            ),
          ).thenAnswer((_) async => success(tState));
          when(() => mockUpdate.call(any())).thenAnswer(
            (_) async => success(tUpdated),
          );

          var collectionsFetchCount = 0;
          final mockGetCollections = MockGetCollectionsUsecase();
          when(
            () => mockGetCollections.call(cursor: any(named: 'cursor')),
          ).thenAnswer((_) async {
            collectionsFetchCount++;
            return success(
              const PaginatedState<CollectionEntity>(items: []),
            );
          });

          final container = ProviderContainer(
            overrides: [
              fetchLinksUsecaseProvider.overrideWithValue(mockFetch),
              deleteLinkUsecaseProvider.overrideWithValue(mockDelete),
              toggleFavoriteUsecaseProvider.overrideWithValue(mockToggle),
              updateLinkUsecaseProvider.overrideWithValue(mockUpdate),
              getCollectionsUsecaseProvider.overrideWithValue(
                mockGetCollections,
              ),
            ],
          );
          addTearDown(container.dispose);
          await container.read(linkListProvider.future);

          // Keep the collection list provider alive
          final sub = container.listen(
            collection_list.collectionListProvider,
            (_, __) {},
          );
          addTearDown(sub.close);
          await container.read(collection_list.collectionListProvider.future);
          expect(collectionsFetchCount, 1);

          // Act
          await container
              .read(linkListProvider.notifier)
              .moveToCollection(linkId: 'link-1', collectionId: 'col-1');

          // Assert — collectionList should rebuild after invalidate
          await container.read(collection_list.collectionListProvider.future);
          expect(collectionsFetchCount, 2);
        },
      );

      test(
        'should invalidate linkDetailProvider so detail screen refreshes',
        () async {
          // Arrange
          final tUpdated = tLink1.copyWith(
            collectionId: 'col-1',
            collectionName: 'Dev',
          );
          final tState = PaginatedState<LinkEntity>(items: [tLink1]);
          when(
            () => mockFetch.call(
              cursor: any(named: 'cursor'),
              favoritesOnly: any(named: 'favoritesOnly'),
              collectionId: any(named: 'collectionId'),
            ),
          ).thenAnswer((_) async => success(tState));
          when(() => mockUpdate.call(any())).thenAnswer(
            (_) async => success(tUpdated),
          );

          var detailFetchCount = 0;
          final mockGetDetail = MockGetLinkDetailUsecase();
          when(() => mockGetDetail.call(any())).thenAnswer((_) async {
            detailFetchCount++;
            return success(tLink1);
          });

          final container = ProviderContainer(
            overrides: [
              fetchLinksUsecaseProvider.overrideWithValue(mockFetch),
              deleteLinkUsecaseProvider.overrideWithValue(mockDelete),
              toggleFavoriteUsecaseProvider.overrideWithValue(mockToggle),
              updateLinkUsecaseProvider.overrideWithValue(mockUpdate),
              getLinkDetailUsecaseProvider.overrideWithValue(mockGetDetail),
            ],
          );
          addTearDown(container.dispose);
          await container.read(linkListProvider.future);

          // Keep linkDetailProvider('link-1') alive
          final sub = container.listen(
            linkDetailProvider('link-1'),
            (_, __) {},
          );
          addTearDown(sub.close);
          await container.read(linkDetailProvider('link-1').future);
          expect(detailFetchCount, 1);

          // Act
          await container
              .read(linkListProvider.notifier)
              .moveToCollection(linkId: 'link-1', collectionId: 'col-1');

          // Assert — linkDetailProvider rebuilds after invalidate
          await container.read(linkDetailProvider('link-1').future);
          expect(detailFetchCount, 2);
        },
      );

      test('should throw Failure when update fails', () async {
        // Arrange
        final tState = PaginatedState<LinkEntity>(items: [tLink1]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(tState));
        when(() => mockUpdate.call(any())).thenAnswer(
          (_) async => error(const Failure.server(message: 'Failed')),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        // Act + Assert
        await expectLater(
          () => container
              .read(linkListProvider.notifier)
              .moveToCollection(linkId: 'link-1', collectionId: 'col-1'),
          throwsA(isA<Failure>()),
        );
      });

      test(
        'should early return when collectionId is unchanged (non-null → same)',
        () async {
          // Arrange — link is already in col-1; requesting the same collection
          // should skip the usecase entirely.
          final tSeeded = tLink1.copyWith(
            collectionId: 'col-1',
            collectionName: 'Dev',
          );
          final tState = PaginatedState<LinkEntity>(items: [tSeeded]);
          when(
            () => mockFetch.call(
              cursor: any(named: 'cursor'),
              favoritesOnly: any(named: 'favoritesOnly'),
              collectionId: any(named: 'collectionId'),
            ),
          ).thenAnswer((_) async => success(tState));

          final container = createContainer();
          addTearDown(container.dispose);
          await container.read(linkListProvider.future);

          await container
              .read(linkListProvider.notifier)
              .moveToCollection(linkId: 'link-1', collectionId: 'col-1');

          verifyNever(() => mockUpdate.call(any()));
          final state = container.read(linkListProvider).value!;
          expect(state.items[0].collectionId, 'col-1');
        },
      );

      test(
        'should early return when collectionId is unchanged (null → null)',
        () async {
          // Arrange — link has no collection; requesting null should skip.
          final tState = PaginatedState<LinkEntity>(items: [tLink1]);
          when(
            () => mockFetch.call(
              cursor: any(named: 'cursor'),
              favoritesOnly: any(named: 'favoritesOnly'),
              collectionId: any(named: 'collectionId'),
            ),
          ).thenAnswer((_) async => success(tState));

          final container = createContainer();
          addTearDown(container.dispose);
          await container.read(linkListProvider.future);

          await container
              .read(linkListProvider.notifier)
              .moveToCollection(linkId: 'link-1', collectionId: null);

          verifyNever(() => mockUpdate.call(any()));
        },
      );

      test('should rollback to previous state on failure', () async {
        // Arrange — link starts in col-1; move to col-2 will fail, state
        // should revert to col-1 so the UI stays consistent.
        final tSeeded = tLink1.copyWith(
          collectionId: 'col-1',
          collectionName: 'Dev',
        );
        final tState = PaginatedState<LinkEntity>(items: [tSeeded]);
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer((_) async => success(tState));
        when(() => mockUpdate.call(any())).thenAnswer(
          (_) async => error(const Failure.server(message: 'Failed')),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkListProvider.future);

        await expectLater(
          () => container
              .read(linkListProvider.notifier)
              .moveToCollection(linkId: 'link-1', collectionId: 'col-2'),
          throwsA(isA<Failure>()),
        );

        final state = container.read(linkListProvider).value!;
        expect(state.items[0].collectionId, 'col-1');
        expect(state.items[0].collectionName, 'Dev');
      });
    });
  });
}
