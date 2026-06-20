import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/usecase/get_public_collection_detail_usecase.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:linknote/features/collection/presentation/provider/public_collection_detail_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPublicCollectionDetailUsecase extends Mock
    implements GetPublicCollectionDetailUsecase {}

void main() {
  late MockGetPublicCollectionDetailUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockGetPublicCollectionDetailUsecase();
  });

  final tCollection = CollectionEntity(
    id: 'col-1',
    name: 'Public',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    visibility: CollectionVisibility.public,
  );

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        getPublicCollectionDetailUsecaseProvider.overrideWithValue(mockUsecase),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('returns the public collection on success', () async {
    when(() => mockUsecase.call(any())).thenAnswer(
      (_) async => success(tCollection),
    );

    final container = createContainer();
    final result = await container.read(
      publicCollectionDetailProvider('col-1').future,
    );

    expect(result, equals(tCollection));
    verify(() => mockUsecase.call('col-1')).called(1);
  });

  test(
    'surfaces the failure when the collection is not public/found',
    () async {
      when(() => mockUsecase.call(any())).thenAnswer(
        (_) async => error(const Failure.unknown()),
      );

      final container = createContainer();
      // Observe the auto-dispose build-error via a listener + settled queue
      // rather than `.future` (which raises a disposal StateError).
      final sub = container.listen(
        publicCollectionDetailProvider('missing'),
        (_, __) {},
      );
      await pumpEventQueue();

      final state = sub.read();
      expect(state.hasError, isTrue);
      expect(state.error, isA<Failure>());
    },
  );
}
