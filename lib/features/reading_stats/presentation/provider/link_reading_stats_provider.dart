import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/reading_stats_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_reading_stats_provider.g.dart';

@riverpod
Future<ReadingStatsEntity> linkReadingStats(Ref ref, String linkId) async {
  final usecase = ref.watch(getReadingStatsUsecaseProvider);
  final result = await usecase.call(linkId);
  return result.data ?? ReadingStatsEntity(linkId: linkId);
}
