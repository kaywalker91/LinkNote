import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/features/reading_stats/data/datasource/reading_stats_local_datasource.dart';
import 'package:linknote/features/reading_stats/data/repository/reading_stats_repository_impl.dart';
import 'package:linknote/features/reading_stats/domain/repository/i_reading_stats_repository.dart';
import 'package:linknote/features/reading_stats/domain/usecase/get_reading_stats_usecase.dart';
import 'package:linknote/features/reading_stats/domain/usecase/record_read_event_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_stats_di_providers.g.dart';

@riverpod
ReadingStatsLocalDatasource readingStatsLocalDatasource(Ref ref) {
  return ReadingStatsLocalDatasource(
    Hive.box<Map<dynamic, dynamic>>('reading_stats'),
  );
}

@riverpod
IReadingStatsRepository readingStatsRepository(Ref ref) {
  return ReadingStatsRepositoryImpl(
    ref.watch(readingStatsLocalDatasourceProvider),
  );
}

@riverpod
RecordReadEventUsecase recordReadEventUsecase(Ref ref) {
  return RecordReadEventUsecase(ref.watch(readingStatsRepositoryProvider));
}

@riverpod
GetReadingStatsUsecase getReadingStatsUsecase(Ref ref) {
  return GetReadingStatsUsecase(ref.watch(readingStatsRepositoryProvider));
}
