import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/logger/app_logger.dart';
import 'package:linknote/features/reading_stats/data/datasource/reading_stats_local_datasource.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/domain/repository/i_reading_stats_repository.dart';

// AC-12: All exceptions (HiveError, generic Exception) are caught and returned
// as error<T>(Failure.cache(message: '<context>')). The raw exception is logged
// via appLogger, not embedded in the message (F5), so it cannot leak to the UI.
// The app must NOT crash on Hive write/read failure.
class ReadingStatsRepositoryImpl implements IReadingStatsRepository {
  const ReadingStatsRepositoryImpl(this._datasource);

  final ReadingStatsLocalDatasource _datasource;

  @override
  Future<Result<void>> recordReadEvent(ReadingEventEntity event) async {
    try {
      await _datasource.recordEvent(event.linkId, event);
      return success<void>(null);
    } on Object catch (e, st) {
      // HiveError extends Error (not Exception); catching Object captures both.
      appLogger.w('recordReadEvent failed', error: e, stackTrace: st);
      return error<void>(
        const Failure.cache(message: 'recordReadEvent'),
      );
    }
  }

  @override
  Future<Result<ReadingStatsEntity>> getReadingStats(String linkId) async {
    try {
      final stats = await _datasource.getStats(linkId);
      return success(stats);
    } on Object catch (e, st) {
      // HiveError extends Error (not Exception); catching Object captures both.
      appLogger.w('getReadingStats failed', error: e, stackTrace: st);
      return error<ReadingStatsEntity>(
        const Failure.cache(message: 'getReadingStats'),
      );
    }
  }
}
