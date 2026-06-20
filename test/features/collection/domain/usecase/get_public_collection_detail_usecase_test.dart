import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/features/collection/domain/usecase/get_public_collection_detail_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository extends Mock implements ICollectionRepository {}

void main() {
  late MockCollectionRepository repository;
  late GetPublicCollectionDetailUsecase sut;

  setUp(() {
    repository = MockCollectionRepository();
    sut = GetPublicCollectionDetailUsecase(repository);
  });

  final tCollection = CollectionEntity(
    id: 'col-1',
    name: 'Public',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    visibility: CollectionVisibility.public,
  );

  test('delegates to getPublicCollectionById and returns success', () async {
    when(
      () => repository.getPublicCollectionById(any()),
    ).thenAnswer((_) async => success(tCollection));

    final result = await sut('col-1');

    expect(result.data, equals(tCollection));
    verify(() => repository.getPublicCollectionById('col-1')).called(1);
  });

  test('passes through a repository failure', () async {
    const tFailure = Failure.unknown();
    when(
      () => repository.getPublicCollectionById(any()),
    ).thenAnswer((_) async => error(tFailure));

    final result = await sut('missing');

    expect(result.failure, equals(tFailure));
  });
}
