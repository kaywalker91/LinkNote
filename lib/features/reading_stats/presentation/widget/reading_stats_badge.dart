import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/extensions/date_time_extensions.dart';

class ReadingStatsBadge extends ConsumerWidget {
  const ReadingStatsBadge({
    required this.linkId,
    super.key,
    this.compact = false,
  });

  final String linkId;

  /// When true, renders a compact mini badge (no 읽음/최근 suffixes,
  /// SizedBox.shrink() for zero/loading/error states — no skeleton key).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(linkReadingStatsProvider(linkId));

    if (compact) {
      return statsAsync.when(
        loading: () => const SizedBox.shrink(),
        data: (stats) {
          if (stats.totalReads == 0) return const SizedBox.shrink();
          final buffer = StringBuffer('${stats.totalReads}회');
          if (stats.lastReadAt != null) {
            buffer.write(' · ${stats.lastReadAt!.timeAgo()}');
          }
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              buffer.toString(),
              style: AppTextStyles.caption.copyWith(
                color: context.palette.ink3,
              ),
            ),
          );
        },
        error: (_, __) => const SizedBox.shrink(),
      );
    }

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
