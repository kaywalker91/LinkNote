import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';
import 'package:linknote/features/reading_stats/domain/repository/i_reading_stats_repository.dart';

// AC-4 + AC-8 + AC-13: RecordReadEventUsecase validates the entity then delegates
// to the repository. Validations run most-fundamental-first so the returned
// failure is the most meaningful when several are violated at once:
// AC-4:  empty linkId → Validation: empty linkId (entity is unidentified)
// AC-13: future timestamp → Validation: timestamp_in_future
// AC-13: negative durationSeconds → Validation: negative_duration
class RecordReadEventUsecase {
  // F6a: `now` is injectable (defaults to DateTime.now) so the future-timestamp
  // boundary can be tested deterministically without depending on the wall clock.
  RecordReadEventUsecase(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final IReadingStatsRepository _repository;
  final DateTime Function() _now;

  Future<Result<void>> call(ReadingEventEntity event) async {
    // AC-4: empty linkId returns failure without writing. Checked first because
    // an unidentified entity cannot be meaningfully recorded anywhere.
    if (event.linkId.isEmpty) {
      return error<void>(
        const Failure.cache(message: 'Validation: empty linkId'),
      );
    }

    // AC-13: timestamp must not be in the future
    if (event.timestamp.isAfter(_now().toUtc())) {
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

    return _repository.recordReadEvent(event);
  }
}
