import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/features/link/domain/usecase/fetch_public_links_usecase.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockLinkRepository extends Mock implements ILinkRepository {}

void main() {
  late MockLinkRepository repository;
  late FetchPublicLinksUsecase sut;

  setUp(() {
    repository = MockLinkRepository();
    sut = FetchPublicLinksUsecase(repository);
  });

  const tState = PaginatedState<LinkEntity>(items: []);

  test(
    'delegates to getPublicLinksByCollectionId and returns success',
    () async {
      when(
        () => repository.getPublicLinksByCollectionId(any()),
      ).thenAnswer((_) async => success(tState));

      final result = await sut('col-1');

      expect(result.data, equals(tState));
      verify(() => repository.getPublicLinksByCollectionId('col-1')).called(1);
    },
  );

  test('passes through a repository failure', () async {
    const tFailure = Failure.unknown();
    when(
      () => repository.getPublicLinksByCollectionId(any()),
    ).thenAnswer((_) async => error(tFailure));

    final result = await sut('col-1');

    expect(result.failure, equals(tFailure));
  });
}
