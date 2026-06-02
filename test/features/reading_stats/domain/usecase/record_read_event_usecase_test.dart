import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';
import 'package:linknote/features/reading_stats/domain/repository/i_reading_stats_repository.dart';
import 'package:linknote/features/reading_stats/domain/usecase/record_read_event_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockReadingStatsRepository extends Mock
    implements IReadingStatsRepository {}

class FakeReadingEventEntity extends Fake implements ReadingEventEntity {}

void main() {
  late RecordReadEventUsecase sut;
  late MockReadingStatsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeReadingEventEntity());
  });

  setUp(() {
    mockRepository = MockReadingStatsRepository();
    sut = RecordReadEventUsecase(mockRepository);
  });

  final tValidEntity = ReadingEventEntity(
    linkId: 'link-1',
    timestamp: DateTime(2026, 1, 1, 12).toUtc(),
    durationSeconds: 30,
  );

  // ---------------------------------------------------------------------------
  // AC-8: repository delegation + error propagation
  // ---------------------------------------------------------------------------
  group('RecordReadEventUsecase — AC-8', () {
    test(
      'should call repository.recordReadEvent once with the correct entity',
      () async {
        // Arrange
        when(
          () => mockRepository.recordReadEvent(any()),
        ).thenAnswer((_) async => success(null));

        // Act
        final result = await sut.call(tValidEntity);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockRepository.recordReadEvent(tValidEntity)).called(1);
      },
    );

    test(
      'should propagate failure when repository returns an error result',
      () async {
        // Arrange
        const tFailure = Failure.cache(message: 'write error');
        when(
          () => mockRepository.recordReadEvent(any()),
        ).thenAnswer((_) async => error(tFailure));

        // Act
        final result = await sut.call(tValidEntity);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, equals(tFailure));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // AC-13: validation — future timestamp
  // ---------------------------------------------------------------------------
  group('RecordReadEventUsecase — AC-13 future timestamp', () {
    test(
      'should return failure with Validation: prefix when timestamp is in the future',
      () async {
        // Arrange
        final futureEntity = ReadingEventEntity(
          linkId: 'link-1',
          timestamp: DateTime.now().toUtc().add(const Duration(hours: 1)),
          durationSeconds: 30,
        );

        // Act
        final result = await sut.call(futureEntity);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<CacheFailure>());
        expect(
          result.failure!.message,
          startsWith('Validation:'),
        );
        verifyNever(() => mockRepository.recordReadEvent(any()));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // AC-13: validation — negative durationSeconds
  // ---------------------------------------------------------------------------
  group('RecordReadEventUsecase — AC-13 negative duration', () {
    test(
      'should return failure with Validation: prefix when durationSeconds is negative',
      () async {
        // Arrange
        final negDurationEntity = ReadingEventEntity(
          linkId: 'link-1',
          timestamp: DateTime(2026, 1, 1, 12).toUtc(),
          durationSeconds: -1,
        );

        // Act
        final result = await sut.call(negDurationEntity);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<CacheFailure>());
        expect(
          result.failure!.message,
          startsWith('Validation:'),
        );
        verifyNever(() => mockRepository.recordReadEvent(any()));
      },
    );

    test(
      'should allow durationSeconds == 0 (boundary: zero is valid)',
      () async {
        // Arrange
        final zeroDuration = ReadingEventEntity(
          linkId: 'link-1',
          timestamp: DateTime(2026, 1, 1, 12).toUtc(),
          durationSeconds: 0,
        );
        when(
          () => mockRepository.recordReadEvent(any()),
        ).thenAnswer((_) async => success(null));

        // Act
        final result = await sut.call(zeroDuration);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockRepository.recordReadEvent(zeroDuration)).called(1);
      },
    );

    test(
      'should allow null durationSeconds (optional field)',
      () async {
        // Arrange
        final nullDuration = ReadingEventEntity(
          linkId: 'link-1',
          timestamp: DateTime(2026, 1, 1, 12).toUtc(),
        );
        when(
          () => mockRepository.recordReadEvent(any()),
        ).thenAnswer((_) async => success(null));

        // Act
        final result = await sut.call(nullDuration);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockRepository.recordReadEvent(nullDuration)).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // AC-4/AC-13: validation precedence — empty linkId is the most fundamental
  // violation, so it must be reported first even when other validations also
  // fail (an unidentified entity cannot be meaningfully recorded anywhere).
  // ---------------------------------------------------------------------------
  group('RecordReadEventUsecase — validation precedence', () {
    test(
      'should return empty linkId failure first when all validations fail',
      () async {
        // Arrange: empty linkId + future timestamp + negative duration
        final allInvalid = ReadingEventEntity(
          linkId: '',
          timestamp: DateTime.now().toUtc().add(const Duration(hours: 1)),
          durationSeconds: -1,
        );

        // Act
        final result = await sut.call(allInvalid);

        // Assert: empty linkId takes precedence over timestamp/duration checks
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<CacheFailure>());
        expect(result.failure!.message, equals('Validation: empty linkId'));
        verifyNever(() => mockRepository.recordReadEvent(any()));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // F6a: injectable clock — the future-timestamp check reads "now" from an
  // injected callback (defaulting to DateTime.now) so the boundary is
  // deterministically testable instead of depending on the wall clock.
  // ---------------------------------------------------------------------------
  group('RecordReadEventUsecase — injected clock (F6a)', () {
    final fixedNow = DateTime(2026, 6, 1, 12).toUtc();
    late RecordReadEventUsecase sutWithClock;

    setUp(() {
      sutWithClock = RecordReadEventUsecase(
        mockRepository,
        now: () => fixedNow,
      );
    });

    test(
      'should reject a timestamp strictly after the injected now',
      () async {
        // Arrange
        final entity = ReadingEventEntity(
          linkId: 'link-1',
          timestamp: fixedNow.add(const Duration(seconds: 1)),
          durationSeconds: 10,
        );

        // Act
        final result = await sutWithClock.call(entity);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failure!.message,
          equals('Validation: timestamp_in_future'),
        );
        verifyNever(() => mockRepository.recordReadEvent(any()));
      },
    );

    test(
      'should accept a timestamp equal to the injected now (boundary)',
      () async {
        // Arrange
        when(
          () => mockRepository.recordReadEvent(any()),
        ).thenAnswer((_) async => success(null));
        final entity = ReadingEventEntity(
          linkId: 'link-1',
          timestamp: fixedNow,
          durationSeconds: 10,
        );

        // Act
        final result = await sutWithClock.call(entity);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockRepository.recordReadEvent(entity)).called(1);
      },
    );
  });
}
