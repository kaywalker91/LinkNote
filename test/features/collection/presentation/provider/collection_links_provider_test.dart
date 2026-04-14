import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/presentation/provider/collection_links_provider.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/usecase/fetch_links_usecase.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFetchLinksUsecase extends Mock implements FetchLinksUsecase {}

void main() {
  late MockFetchLinksUsecase mockFetch;

  final tNow = DateTime(2026);
  final tLink = LinkEntity(
    id: 'link-1',
    url: 'https://example.com',
    title: 'Link 1',
    createdAt: tNow,
    updatedAt: tNow,
  );

  setUp(() {
    mockFetch = MockFetchLinksUsecase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        fetchLinksUsecaseProvider.overrideWithValue(mockFetch),
      ],
    );
  }

  group('collectionLinks', () {
    test('should return link items on success', () async {
      // Arrange
      final tState = PaginatedState<LinkEntity>(items: [tLink]);
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
      final result = await container.read(
        collectionLinksProvider('col-1').future,
      );

      // Assert
      expect(result, [tLink]);
    });

    test('should throw Failure when fetch fails', () async {
      // Arrange
      const failure = Failure.server(message: 'Network error');
      when(
        () => mockFetch.call(
          cursor: any(named: 'cursor'),
          favoritesOnly: any(named: 'favoritesOnly'),
          collectionId: any(named: 'collectionId'),
        ),
      ).thenAnswer((_) async => error(failure));

      final container = createContainer();
      addTearDown(container.dispose);

      final sub = container.listen(
        collectionLinksProvider('col-1'),
        (_, __) {},
      );
      addTearDown(sub.close);

      // Let async build settle
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Assert
      final state = container.read(collectionLinksProvider('col-1'));
      expect(state.hasError, isTrue);
      expect(state.error, isA<Failure>());
    });
  });
}
