import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/usecase/get_collection_detail_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/update_collection_visibility_usecase.dart';
import 'package:linknote/features/collection/presentation/provider/collection_detail_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCollectionDetailUsecase extends Mock
    implements GetCollectionDetailUsecase {}

class MockUpdateCollectionVisibilityUsecase extends Mock
    implements UpdateCollectionVisibilityUsecase {}

void main() {
  late MockGetCollectionDetailUsecase mockDetail;
  late MockUpdateCollectionVisibilityUsecase mockVisibility;

  final tCollection = CollectionEntity(
    id: 'col-1',
    name: 'Test',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(CollectionVisibility.private);
  });

  setUp(() {
    mockDetail = MockGetCollectionDetailUsecase();
    mockVisibility = MockUpdateCollectionVisibilityUsecase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getCollectionDetailUsecaseProvider.overrideWithValue(mockDetail),
        updateCollectionVisibilityUsecaseProvider.overrideWithValue(
          mockVisibility,
        ),
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

  group('visibility/lock toggle', () {
    setUp(() {
      when(() => mockDetail.call(any())).thenAnswer(
        (_) async => success(tCollection),
      );
    });

    test('setVisibility persists new visibility and updates state', () async {
      final tPublic = tCollection.copyWith(
        visibility: CollectionVisibility.public,
      );
      when(
        () => mockVisibility.call(
          id: any(named: 'id'),
          visibility: any(named: 'visibility'),
          lockedAt: any(named: 'lockedAt'),
        ),
      ).thenAnswer((_) async => success(tPublic));

      final container = createContainer();
      addTearDown(container.dispose);
      await container.read(collectionDetailProvider('col-1').future);

      await container
          .read(collectionDetailProvider('col-1').notifier)
          .setVisibility(CollectionVisibility.public);

      verify(
        () => mockVisibility.call(
          id: 'col-1',
          visibility: CollectionVisibility.public,
          lockedAt: null,
        ),
      ).called(1);
      final state = container.read(collectionDetailProvider('col-1'));
      expect(state.value!.visibility, CollectionVisibility.public);
    });

    test('setVisibility is a no-op when already in the target state', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      await container.read(collectionDetailProvider('col-1').future);

      // tCollection defaults to private.
      await container
          .read(collectionDetailProvider('col-1').notifier)
          .setVisibility(CollectionVisibility.private);

      verifyNever(
        () => mockVisibility.call(
          id: any(named: 'id'),
          visibility: any(named: 'visibility'),
          lockedAt: any(named: 'lockedAt'),
        ),
      );
    });

    test('setLocked(true) sends a non-null lockedAt', () async {
      when(
        () => mockVisibility.call(
          id: any(named: 'id'),
          visibility: any(named: 'visibility'),
          lockedAt: any(named: 'lockedAt'),
        ),
      ).thenAnswer(
        (_) async => success(tCollection.copyWith(lockedAt: DateTime(2026, 6))),
      );

      final container = createContainer();
      addTearDown(container.dispose);
      await container.read(collectionDetailProvider('col-1').future);

      await container
          .read(collectionDetailProvider('col-1').notifier)
          .setLocked(locked: true);

      final captured = verify(
        () => mockVisibility.call(
          id: 'col-1',
          visibility: CollectionVisibility.private,
          lockedAt: captureAny(named: 'lockedAt'),
        ),
      ).captured.single;
      expect(captured, isNotNull);
    });

    test('failure rolls back to previous state and rethrows', () async {
      when(
        () => mockVisibility.call(
          id: any(named: 'id'),
          visibility: any(named: 'visibility'),
          lockedAt: any(named: 'lockedAt'),
        ),
      ).thenAnswer(
        (_) async => error(const Failure.server(message: 'denied')),
      );

      final container = createContainer();
      addTearDown(container.dispose);
      await container.read(collectionDetailProvider('col-1').future);

      await expectLater(
        container
            .read(collectionDetailProvider('col-1').notifier)
            .setVisibility(CollectionVisibility.public),
        throwsA(isA<Failure>()),
      );

      final state = container.read(collectionDetailProvider('col-1'));
      expect(state.value!.visibility, CollectionVisibility.private);
    });
  });
}
