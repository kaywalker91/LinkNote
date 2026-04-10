import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/features/search/presentation/provider/user_tags_provider.dart';

class SearchFilterBar extends ConsumerWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchProvider.select((s) => s.filter));
    final tagsAsync = ref.watch(userTagsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.xs,
        ),
        children: [
          // Favorites filter.
          FilterChip(
            avatar: Icon(
              filter.favoritesOnly ? Icons.star : Icons.star_border,
              size: 18,
            ),
            label: const Text('즐겨찾기'),
            selected: filter.favoritesOnly,
            selectedColor: colorScheme.primaryContainer,
            onSelected: (_) =>
                ref.read(searchProvider.notifier).toggleFavoritesFilter(),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Date range filter.
          ActionChip(
            avatar: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              filter.dateFrom != null || filter.dateTo != null
                  ? _formatDateRange(filter.dateFrom, filter.dateTo)
                  : '날짜',
            ),
            onPressed: () => _showDateRangePicker(context, ref),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Tag filter chips.
          ...tagsAsync.when(
            data: (tags) => tags.map(
              (tag) {
                final selected = filter.selectedTagIds.contains(tag.id);
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(tag.name),
                    selected: selected,
                    selectedColor: colorScheme.primaryContainer,
                    onSelected: (_) => ref
                        .read(searchProvider.notifier)
                        .toggleTagFilter(
                          tag.id,
                        ),
                  ),
                );
              },
            ),
            loading: () => [const SizedBox.shrink()],
            error: (_, __) => [const SizedBox.shrink()],
          ),

          // Clear filters button.
          if (filter.hasActiveFilters) ...[
            ActionChip(
              avatar: const Icon(Icons.clear_all, size: 18),
              label: const Text('초기화'),
              onPressed: () => ref.read(searchProvider.notifier).clearFilters(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? from, DateTime? to) {
    final fromStr = from != null ? '${from.month}/${from.day}' : '';
    final toStr = to != null ? '${to.month}/${to.day}' : '';
    if (fromStr.isNotEmpty && toStr.isNotEmpty) return '$fromStr~$toStr';
    if (fromStr.isNotEmpty) return '$fromStr~';
    return '~$toStr';
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final filter = ref.read(searchProvider).filter;
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: filter.dateFrom != null && filter.dateTo != null
          ? DateTimeRange(start: filter.dateFrom!, end: filter.dateTo!)
          : null,
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null) {
      ref
          .read(searchProvider.notifier)
          .setDateRange(
            picked.start,
            picked.end,
          );
    }
  }
}
