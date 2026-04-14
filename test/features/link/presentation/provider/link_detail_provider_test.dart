import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/usecase/delete_link_usecase.dart';
import 'package:linknote/features/link/domain/usecase/fetch_links_usecase.dart';
import 'package:linknote/features/link/domain/usecase/get_link_detail_usecase.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockGetLinkDetailUsecase extends Mock implements GetLinkDetailUsecase {}

class MockDeleteLinkUsecase extends Mock implements DeleteLinkUsecase {}

class MockFetchLinksUsecase extends Mock implements FetchLinksUsecase {}

void main() {
  late MockGetLinkDetailUsecase mockGetDetail;
  late MockDeleteLinkUsecase mockDelete;
  late MockFetchLinksUsecase mockFetch;

  final tNow = DateTime(2026);
  final tLink = LinkEntity(
    id: 'link-1',
    url: 'https://example.com',
    title: 'Test Link',
    createdAt: tNow,
    updatedAt: tNow,
  );

  setUp(() {
    mockGetDetail = MockGetLinkDetailUsecase();
    mockDelete = MockDeleteLinkUsecase();
    mockFetch = MockFetchLinksUsecase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getLinkDetailUsecaseProvider.overrideWithValue(mockGetDetail),
        deleteLinkUsecaseProvider.overrideWithValue(mockDelete),
        fetchLinksUsecaseProvider.overrideWithValue(mockFetch),
      ],
    );
  }

  group('LinkDetail', () {
    group('build', () {
      test('should return link entity on success', () async {
        when(
          () => mockGetDetail.call('link-1'),
        ).thenAnswer((_) async => success(tLink));

        final container = createContainer();
        addTearDown(container.dispose);

        final result = await container.read(
          linkDetailProvider('link-1').future,
        );

        expect(result.id, 'link-1');
        expect(result.title, 'Test Link');
      });

      test('should have error state on failure', () async {
        when(() => mockGetDetail.call('link-1')).thenAnswer(
          (_) async => error(const Failure.server(message: 'Not found')),
        );

        final container = createContainer();
        addTearDown(container.dispose);

        final sub = container.listen(linkDetailProvider('link-1'), (_, __) {});
        addTearDown(sub.close);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final state = container.read(linkDetailProvider('link-1'));
        expect(state.hasError, isTrue);
        expect(state.error, isA<Failure>());
      });
    });

    group('delete', () {
      test('should invalidate linkListProvider on success', () async {
        when(
          () => mockGetDetail.call('link-1'),
        ).thenAnswer((_) async => success(tLink));
        when(
          () => mockDelete.call('link-1'),
        ).thenAnswer((_) async => success(null));
        when(
          () => mockFetch.call(
            cursor: any(named: 'cursor'),
            favoritesOnly: any(named: 'favoritesOnly'),
            collectionId: any(named: 'collectionId'),
          ),
        ).thenAnswer(
          (_) async => success(const PaginatedState<LinkEntity>(items: [])),
        );

        final container = createContainer();
        addTearDown(container.dispose);

        // Load detail
        await container.read(linkDetailProvider('link-1').future);
        // Load list to track invalidation
        await container.read(linkListProvider.future);

        // Act
        await container.read(linkDetailProvider('link-1').notifier).delete();

        // Assert — delete was called
        verify(() => mockDelete.call('link-1')).called(1);
      });

      test('should throw on delete failure', () async {
        when(
          () => mockGetDetail.call('link-1'),
        ).thenAnswer((_) async => success(tLink));
        when(() => mockDelete.call('link-1')).thenAnswer(
          (_) async => error(const Failure.server(message: 'Delete failed')),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkDetailProvider('link-1').future);

        await expectLater(
          container.read(linkDetailProvider('link-1').notifier).delete(),
          throwsA(isA<Failure>()),
        );
      });
    });
  });
}
