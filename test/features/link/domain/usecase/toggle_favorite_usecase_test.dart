import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/features/link/domain/usecase/toggle_favorite_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockLinkRepository extends Mock implements ILinkRepository {}

final _tLink = LinkEntity(
  id: 'link-1',
  url: 'https://example.com',
  title: 'Test Link',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late ToggleFavoriteUsecase sut;
  late MockLinkRepository mockRepository;

  setUp(() {
    mockRepository = MockLinkRepository();
    sut = ToggleFavoriteUsecase(mockRepository);
  });

  test(
    'should return updated LinkEntity when toggle succeeds',
    () async {
      final toggled = _tLink.copyWith(isFavorite: true);
      when(
        () => mockRepository.toggleFavorite('link-1', isFavorite: true),
      ).thenAnswer((_) async => success(toggled));

      final result = await sut.call('link-1', isFavorite: true);

      expect(result.isSuccess, isTrue);
      expect(result.data?.isFavorite, isTrue);
      verify(
        () => mockRepository.toggleFavorite('link-1', isFavorite: true),
      ).called(1);
    },
  );

  test(
    'should return Failure when repository fails',
    () async {
      const tFailure = Failure.server(message: 'Toggle failed');
      when(
        () => mockRepository.toggleFavorite('link-1', isFavorite: true),
      ).thenAnswer((_) async => error(tFailure));

      final result = await sut.call('link-1', isFavorite: true);

      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
    },
  );
}
