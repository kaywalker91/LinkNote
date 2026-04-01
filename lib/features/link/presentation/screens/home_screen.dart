import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_filter_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/shared/widgets/confirmation_dialog_widget.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/link_list_tile.dart';
import 'package:linknote/shared/widgets/offline_banner_widget.dart';
import 'package:linknote/shared/widgets/paginated_list_view.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(linkListProvider);
    final filter = ref.watch(linkFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkNote'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: !filter.favoritesOnly,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  onSelected: (_) => ref
                      .read(linkFilterProvider.notifier)
                      .setFavoritesOnly(value: false),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilterChip(
                  label: const Text('Favorites'),
                  selected: filter.favoritesOnly,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  onSelected: (_) => ref
                      .read(linkFilterProvider.notifier)
                      .setFavoritesOnly(value: true),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const OfflineBannerWidget(),
          Expanded(
            child: linksAsync.when(
              loading: () => ListView.builder(
                itemCount: 8,
                itemBuilder: (_, __) => const LinkCardSkeleton(),
              ),
              error: (error, _) => ErrorStateWidget(
                message: error.toString(),
                onRetry: () => ref.read(linkListProvider.notifier).refresh(),
              ),
              data: (_) => const _LinkListBody(),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: FloatingActionButton(
          onPressed: () => context.push(Routes.linkAdd),
          elevation: 6,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _LinkListBody extends ConsumerWidget {
  const _LinkListBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(linkListProvider).value;
    if (state == null) return const SizedBox.shrink();

    return PaginatedListView<LinkEntity>(
      items: state.items,
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      loadMoreError: state.loadMoreError,
      onRefresh: () => ref.read(linkListProvider.notifier).refresh(),
      onLoadMore: () => ref.read(linkListProvider.notifier).loadMore(),
      empty: EmptyStateWidget(
        icon: Icons.bookmarks_outlined,
        message: 'No links yet',
        subMessage: 'Tap + to save your first link',
        actionLabel: 'Add Link',
        onAction: () => context.push(Routes.linkAdd),
      ),
      itemBuilder: (context, link, _) => LinkListTile(
        link: link,
        onTap: () => context.push(Routes.linkDetailPath(link.id)),
        onFavoriteTap: () =>
            ref.read(linkListProvider.notifier).toggleFavorite(link.id),
        onMoreTap: () => _showMoreSheet(context, ref, link.id),
      ),
    );
  }

  void _showMoreSheet(BuildContext context, WidgetRef ref, String linkId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push(Routes.linkEditPath(linkId));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final confirmed = await ConfirmationDialogWidget.show(
                  context,
                  title: 'Delete Link',
                  message: 'This link will be permanently removed.',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                );
                if (confirmed ?? false) {
                  await ref.read(linkListProvider.notifier).deleteLink(linkId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
