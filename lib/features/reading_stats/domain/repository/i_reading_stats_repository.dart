import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';

// AC-3: IReadingStatsRepository declares two methods.
// Uses existing Result<T> record typedef and top-level success/error constructors.
abstract interface class IReadingStatsRepository {
  Future<Result<void>> recordReadEvent(ReadingEventEntity event);
  Future<Result<ReadingStatsEntity>> getReadingStats(String linkId);
}
