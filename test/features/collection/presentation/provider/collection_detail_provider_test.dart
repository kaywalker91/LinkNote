import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/usecase/get_collection_detail_usecase.dart';
import 'package:linknote/features/collection/presentation/provider/collection_detail_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCollectionDetailUsecase extends Mock
    implements GetCollectionDetailUsecase {}

void main() {
  late MockGetCollectionDetailUsecase mockDetail;

  final tCollection = CollectionEntity(
    id: 'col-1',
    name: 'Test',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  setUp(() {
    mockDetail = MockGetCollectionDetailUsecase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getCollectionDetailUsecaseProvider.overrideWithValue(mockDetail),
      ],
    );
  }

  group('CollectionDetail', () {
    test('should return CollectionEntity on success', () async {
      // Arrange
      when(() => mockDetail.call(any())).thenAnswer(
        (_) async => success(tCollection),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      // Act
      final result = await container.read(
        collectionDetailProvider('col-1').future,
      );

      // Assert
      expect(result, equals(tCollection));
      verify(() => mockDetail.call('col-1')).called(1);
    });

    test('should surface Failure when usecase fails', () async {
      // Arrange
      const failure = Failure.network(message: 'offline');
      when(() => mockDetail.call(any())).thenAnswer(
        (_) async => error(failure),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      final sub = container.listen(
        collectionDetailProvider('col-1'),
        (_, __) {},
      );
      addTearDown(sub.close);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Assert
      final state = container.read(collectionDetailProvider('col-1'));
      expect(state.hasError, isTrue);
      expect(state.error, isA<Failure>());
    });

    test('refresh should re-invoke usecase', () async {
      // Arrange
      var callCount = 0;
      when(() => mockDetail.call(any())).thenAnswer((_) async {
        callCount++;
        return success(tCollection);
      });

      final container = createContainer();
      addTearDown(container.dispose);

      final sub = container.listen(
        collectionDetailProvider('col-1'),
        (_, __) {},
      );
      addTearDown(sub.close);
      await container.read(collectionDetailProvider('col-1').future);
      expect(callCount, 1);

      // Act
      await container
          .read(collectionDetailProvider('col-1').notifier)
          .refresh();

      // Assert
      expect(callCount, 2);
    });
  });
}
