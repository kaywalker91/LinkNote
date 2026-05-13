import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/shared/extensions/date_time_extensions.dart';

class ReadingStatsBadge extends ConsumerWidget {
  const ReadingStatsBadge({required this.linkId, super.key});

  final String linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(linkReadingStatsProvider(linkId));

    return statsAsync.when(
      loading: () => const SizedBox(
        key: ValueKey('reading_stats_badge_skeleton'),
        height: 16,
      ),
      data: (stats) {
        if (stats.totalReads == 0) {
          return const Text('아직 읽지 않음');
        }
        final buffer = StringBuffer('${stats.totalReads}회 읽음');
        if (stats.lastReadAt != null) {
          buffer.write(' · 최근 ${stats.lastReadAt!.timeAgo()}');
        }
        return Text(buffer.toString());
      },
      error: (_, __) => const Text('아직 읽지 않음'),
    );
  }
}
