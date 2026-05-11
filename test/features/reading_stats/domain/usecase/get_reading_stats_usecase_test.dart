import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/domain/repository/i_reading_stats_repository.dart';
import 'package:linknote/features/reading_stats/domain/usecase/get_reading_stats_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockReadingStatsRepository extends Mock
    implements IReadingStatsRepository {}

void main() {
  late GetReadingStatsUsecase sut;
  late MockReadingStatsRepository mockRepository;

  setUp(() {
    mockRepository = MockReadingStatsRepository();
    sut = GetReadingStatsUsecase(mockRepository);
  });

  // ---------------------------------------------------------------------------
  // AC-9: returns correct entity from repository
  // ---------------------------------------------------------------------------
  group('GetReadingStatsUsecase — AC-9', () {
    test(
      'should return stats entity when repository succeeds',
      () async {
        // Arrange
        final tStats = ReadingStatsEntity(
          linkId: 'link-1',
          totalReads: 5,
          lastReadAt: DateTime(2026, 3, 10).toUtc(),
        );
        when(
          () => mockRepository.getReadingStats(any()),
        ).thenAnswer((_) async => success(tStats));

        // Act
        final result = await sut.call('link-1');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.linkId, 'link-1');
        expect(result.data!.totalReads, 5);
        expect(result.data!.lastReadAt, DateTime(2026, 3, 10).toUtc());
        verify(() => mockRepository.getReadingStats('link-1')).called(1);
      },
    );

    test(
      'should return entity with totalReads == 0 and lastReadAt == null when '
      'no events exist (AC-5 empty case handled without error)',
      () async {
        // Arrange
        // totalReads omitted — defaults to 0 per @Default(0) in entity definition
        const tEmpty = ReadingStatsEntity(linkId: 'link-new');
        when(
          () => mockRepository.getReadingStats(any()),
        ).thenAnswer((_) async => success(tEmpty));

        // Act
        final result = await sut.call('link-new');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.totalReads, 0);
        expect(result.data!.lastReadAt, isNull);
      },
    );

    test('should propagate failure when repository returns error', () async {
      // Arrange
      const tFailure = Failure.cache(message: 'read error');
      when(
        () => mockRepository.getReadingStats(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call('link-1');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
    });
  });
}
