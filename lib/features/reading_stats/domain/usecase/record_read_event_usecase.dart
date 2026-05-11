import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';
import 'package:linknote/features/reading_stats/domain/repository/i_reading_stats_repository.dart';

// AC-4 + AC-8 + AC-13: RecordReadEventUsecase validates the entity then delegates
// to the repository. Empty linkId returns CacheFailure without writing.
// AC-13: future timestamp → Validation: timestamp_in_future
// AC-13: negative durationSeconds → Validation: negative_duration
class RecordReadEventUsecase {
  const RecordReadEventUsecase(this._repository);
  final IReadingStatsRepository _repository;

  Future<Result<void>> call(ReadingEventEntity event) async {
    // AC-13: timestamp must not be in the future
    if (event.timestamp.isAfter(DateTime.now().toUtc())) {
      return error<void>(
        const Failure.cache(message: 'Validation: timestamp_in_future'),
      );
    }

    // AC-13: durationSeconds, if non-null, must be >= 0
    final duration = event.durationSeconds;
    if (duration != null && duration < 0) {
      return error<void>(
        const Failure.cache(message: 'Validation: negative_duration'),
      );
    }

    // AC-4: empty linkId returns failure without writing
    if (event.linkId.isEmpty) {
      return error<void>(
        const Failure.cache(message: 'Validation: empty linkId'),
      );
    }

    return _repository.recordReadEvent(event);
  }
}
