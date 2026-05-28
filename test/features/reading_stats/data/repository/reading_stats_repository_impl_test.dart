import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/reading_stats/data/datasource/reading_stats_local_datasource.dart';
import 'package:linknote/features/reading_stats/data/repository/reading_stats_repository_impl.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:mocktail/mocktail.dart';

// F2 closure (docs/harness-followups.md) — Contract AC-12 mandated:
// "when datasource throws HiveError, repository returns CacheFailure".
// Sprint-1 shipped the impl correctly (`on Object catch` captures both
// Error and Exception) but the dedicated repository-level test directory
// did not exist. These tests close that gap.

class _MockDatasource extends Mock implements ReadingStatsLocalDatasource {}

class _FakeEvent extends Fake implements ReadingEventEntity {}

void main() {
  late _MockDatasource datasource;
  late ReadingStatsRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(_FakeEvent());
  });

  setUp(() {
    datasource = _MockDatasource();
    sut = ReadingStatsRepositoryImpl(datasource);
  });

  final tEvent = ReadingEventEntity(
    linkId: 'link-1',
    timestamp: DateTime(2026, 5, 11, 12).toUtc(),
    durationSeconds: 45,
  );

  group('recordReadEvent', () {
    test('returns success(null) when datasource completes normally', () async {
      when(() => datasource.recordEvent(any(), any())).thenAnswer((_) async {});

      final result = await sut.recordReadEvent(tEvent);

      expect(result.isSuccess, isTrue);
      expect(result.failure, isNull);
      verify(() => datasource.recordEvent('link-1', tEvent)).called(1);
    });

    test(
      'returns CacheFailure when datasource throws HiveError (AC-12)',
      () async {
        when(
          () => datasource.recordEvent(any(), any()),
        ).thenThrow(HiveError('box closed'));

        final result = await sut.recordReadEvent(tEvent);

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<CacheFailure>());
        expect(
          (result.failure! as CacheFailure).message,
          contains('recordReadEvent'),
        );
        expect(
          (result.failure! as CacheFailure).message,
          isNot(contains('box closed')),
          reason: 'raw exception text must not leak into Failure.message (F5)',
        );
      },
    );

    test(
      'returns CacheFailure when datasource throws generic Exception',
      () async {
        when(
          () => datasource.recordEvent(any(), any()),
        ).thenThrow(Exception('disk full'));

        final result = await sut.recordReadEvent(tEvent);

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<CacheFailure>());
      },
    );
  });

  group('getReadingStats', () {
    final tStats = ReadingStatsEntity(
      linkId: 'link-1',
      totalReads: 3,
      lastReadAt: DateTime(2026, 5, 11, 12).toUtc(),
    );

    test('returns success(stats) when datasource completes normally', () async {
      when(() => datasource.getStats(any())).thenAnswer((_) async => tStats);

      final result = await sut.getReadingStats('link-1');

      expect(result.isSuccess, isTrue);
      expect(result.data, tStats);
      verify(() => datasource.getStats('link-1')).called(1);
    });

    test(
      'returns CacheFailure when datasource throws HiveError (AC-12)',
      () async {
        when(
          () => datasource.getStats(any()),
        ).thenThrow(HiveError('box corrupted'));

        final result = await sut.getReadingStats('link-1');

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<CacheFailure>());
        expect(
          (result.failure! as CacheFailure).message,
          contains('getReadingStats'),
        );
        expect(
          (result.failure! as CacheFailure).message,
          isNot(contains('box corrupted')),
          reason: 'raw exception text must not leak into Failure.message (F5)',
        );
      },
    );

    test(
      'returns CacheFailure when datasource throws generic Exception',
      () async {
        when(
          () => datasource.getStats(any()),
        ).thenThrow(Exception('read timeout'));

        final result = await sut.getReadingStats('link-1');

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<CacheFailure>());
      },
    );
  });
}
