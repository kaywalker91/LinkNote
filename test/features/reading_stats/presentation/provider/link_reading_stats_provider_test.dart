import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/domain/usecase/get_reading_stats_usecase.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/features/reading_stats/presentation/provider/reading_stats_di_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetReadingStatsUsecase extends Mock
    implements GetReadingStatsUsecase {}

void main() {
  late _MockGetReadingStatsUsecase mockUsecase;

  setUp(() {
    mockUsecase = _MockGetReadingStatsUsecase();
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        getReadingStatsUsecaseProvider.overrideWithValue(mockUsecase),
      ],
    );
  }

  group('linkReadingStatsProvider — AC-8 silent-fallback', () {
    test(
      'should resolve to AsyncData with zero-stats entity when usecase returns Failure',
      () async {
        // Arrange
        const tFailure = Failure.cache(message: 'read error');
        when(
          () => mockUsecase.call('link-1'),
        ).thenAnswer((_) async => error(tFailure));

        final container = makeContainer();
        addTearDown(container.dispose);

        // Act
        final result = await container.read(
          linkReadingStatsProvider('link-1').future,
        );

        // Assert — silent fallback: Failure maps to zero-stats entity, NOT error
        expect(result.linkId, equals('link-1'));
        expect(result.totalReads, equals(0));
        expect(result.lastReadAt, isNull);
      },
    );

    test(
      'should resolve to AsyncData with exact entity when usecase returns success',
      () async {
        // Arrange
        final tEntity = ReadingStatsEntity(
          linkId: 'a',
          totalReads: 7,
          lastReadAt: DateTime(2026, 5, 12),
        );
        when(
          () => mockUsecase.call('a'),
        ).thenAnswer((_) async => success(tEntity));

        final container = makeContainer();
        addTearDown(container.dispose);

        // Act
        final result = await container.read(
          linkReadingStatsProvider('a').future,
        );

        // Assert
        expect(result.linkId, equals('a'));
        expect(result.totalReads, equals(7));
        expect(result.lastReadAt, equals(DateTime(2026, 5, 12)));
      },
    );
  });
}
