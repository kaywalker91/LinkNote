import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/domain/repository/i_reading_stats_repository.dart';

// AC-5 + AC-9: GetReadingStatsUsecase delegates to repository.
// Returns ReadingStatsEntity with totalReads=0 and lastReadAt=null when no
// events exist (repository returns success with empty stats — not a Failure).
class GetReadingStatsUsecase {
  const GetReadingStatsUsecase(this._repository);
  final IReadingStatsRepository _repository;

  Future<Result<ReadingStatsEntity>> call(String linkId) =>
      _repository.getReadingStats(linkId);
}
