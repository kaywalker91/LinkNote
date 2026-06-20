import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/usecase/get_public_collection_detail_usecase.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:linknote/features/collection/presentation/provider/public_collection_links_provider.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/usecase/fetch_public_links_usecase.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPublicCollectionDetailUsecase extends Mock
    implements GetPublicCollectionDetailUsecase {}

class MockFetchPublicLinksUsecase extends Mock
    implements FetchPublicLinksUsecase {}

void main() {
  late MockGetPublicCollectionDetailUsecase mockDetail;
  late MockFetchPublicLinksUsecase mockLinks;

  setUp(() {
    mockDetail = MockGetPublicCollectionDetailUsecase();
    mockLinks = MockFetchPublicLinksUsecase();
  });

  final tCollection = CollectionEntity(
    id: 'col-1',
    name: 'Public',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    visibility: CollectionVisibility.public,
  );
  final tLink = LinkEntity(
    id: 'link-1',
    url: 'https://example.com',
    title: 'Test',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        getPublicCollectionDetailUsecaseProvider.overrideWithValue(mockDetail),
        fetchPublicLinksUsecaseProvider.overrideWithValue(mockLinks),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('fetches links once the parent public collection resolves', () async {
    when(() => mockDetail.call(any())).thenAnswer(
      (_) async => success(tCollection),
    );
    when(() => mockLinks.call(any())).thenAnswer(
      (_) async => success(PaginatedState<LinkEntity>(items: [tLink])),
    );

    final container = createContainer();
    final result = await container.read(
      publicCollectionLinksProvider('col-1').future,
    );

    expect(result, equals([tLink]));
    verify(() => mockLinks.call('col-1')).called(1);
  });

  test('does NOT fetch links when the parent collection errors', () async {
    // Gate: a non-public/absent parent must short-circuit before any link read.
    when(() => mockDetail.call(any())).thenAnswer(
      (_) async => error(const Failure.unknown()),
    );

    final container = createContainer();
    // Observe the auto-dispose build-error via a listener + settled event queue
    // (not `.future`, which raises a disposal StateError).
    final sub = container.listen(
      publicCollectionLinksProvider('missing'),
      (_, __) {},
    );
    addTearDown(sub.close);

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(publicCollectionLinksProvider('missing'));
    expect(state.hasError, isTrue);
    expect(state.error, isA<Failure>());
    // Gate: the parent failed to resolve, so links were never fetched.
    verifyNever(() => mockLinks.call(any()));
  });
}
