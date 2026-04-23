import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_filter_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/utils/url_launcher_helper.dart';
import 'package:linknote/shared/widgets/confirmation_dialog_widget.dart';
import 'package:linknote/shared/widgets/empty_state_illustration.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/ln/ln_brand.dart';
import 'package:linknote/shared/widgets/ln/ln_icon_btn.dart';
import 'package:linknote/shared/widgets/ln/ln_link_card.dart';
import 'package:linknote/shared/widgets/ln/ln_segmented.dart';
import 'package:linknote/shared/widgets/ln/ln_top_bar.dart';
import 'package:linknote/shared/widgets/paginated_list_view.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(linkListProvider);
    final items = linksAsync.value?.items ?? const <LinkEntity>[];
    final total = items.length;
    final now = DateTime.now();
    final thisWeek = items
        .where((l) => now.difference(l.createdAt).inDays < 7)
        .length;

    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      appBar: LnTopBar(
        large: true,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: LinkNoteWordmark(),
        ),
        actions: [
          LnIconBtn(
            icon: Icons.notifications_none_rounded,
            badge: true,
            tooltip: '알림',
            onPressed: () {},
          ),
          LnIconBtn(
            icon: Icons.swap_vert_rounded,
            tooltip: '정렬',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        displayTitle: '내 서랍',
        displaySubtitle: _buildMetaLine(total: total, thisWeek: thisWeek),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _HomeSegmented(),
          ),
          Expanded(
            child: linksAsync.when(
              loading: () => ListView.builder(
                itemCount: 8,
                itemBuilder: (_, __) => const LinkCardSkeleton(),
              ),
              error: (error, _) => ErrorStateWidget.fromError(
                error,
                onRetry: () => ref.read(linkListProvider.notifier).refresh(),
              ),
              data: (_) => const _LinkListBody(),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          heroTag: 'home_fab',
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          elevation: 6,
          onPressed: () => context.push(Routes.linkAdd),
          child: const Icon(Icons.add_rounded, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _buildMetaLine({required int total, required int thisWeek}) {
    if (total == 0) return '첫 링크를 저장해 보세요';
    if (thisWeek == 0) return '저장한 링크 $total';
    return '저장한 링크 $total · 이번 주 +$thisWeek';
  }
}

class _HomeSegmented extends ConsumerWidget {
  const _HomeSegmented();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(linkFilterProvider);
    final selected = filter.favoritesOnly ? 1 : 0;
    return LnSegmented(
      labels: const ['전체', '★ 즐겨찾기'],
      selectedIndex: selected,
      onChanged: (idx) => ref
          .read(linkFilterProvider.notifier)
          .setFavoritesOnly(value: idx == 1),
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
        illustration: const EmptyStateIllustration.links(),
        message: 'No links yet',
        subMessage: 'Tap + to save your first link',
        actionLabel: 'Add Link',
        onAction: () => context.push(Routes.linkAdd),
      ),
      itemBuilder: (context, link, _) => LnLinkCard(
        link: link,
        onTap: () => UrlLauncherHelper.launch(context, link.url),
        onLongPress: () => context.push(Routes.linkDetailPath(link.id)),
        onFavoriteTap: () =>
            ref.read(linkListProvider.notifier).toggleFavorite(link.id),
        onMoreTap: () => _showMoreSheet(context, ref, link.id),
      ),
    );
  }

  Future<void> _showMoreSheet(
    BuildContext context,
    WidgetRef ref,
    String linkId,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('View Details'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await context.push(Routes.linkDetailPath(linkId));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await context.push(Routes.linkEditPath(linkId));
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Move to Collection'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _showCollectionPicker(context, ref, linkId);
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
                  if (context.mounted) {
                    context.showSuccessSnackBar('Link deleted');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCollectionPicker(
    BuildContext context,
    WidgetRef ref,
    String linkId,
  ) async {
    final collectionsAsync = ref.read(collectionListProvider);
    final items = collectionsAsync.value?.items ?? <CollectionEntity>[];

    final selected = await showModalBottomSheet<_CollectionPick>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('None'),
              onTap: () => Navigator.of(sheetContext).pop(
                const _CollectionPick(id: null),
              ),
            ),
            const Divider(height: 1),
            ...items.map(
              (c) => ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(c.name),
                onTap: () => Navigator.of(sheetContext).pop(
                  _CollectionPick(id: c.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected == null || !context.mounted) return;

    try {
      await ref
          .read(linkListProvider.notifier)
          .moveToCollection(linkId: linkId, collectionId: selected.id);
      if (context.mounted) {
        context.showSuccessSnackBar(
          selected.id == null
              ? 'Removed from collection'
              : 'Moved to collection',
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('Move failed');
      }
    }
  }
}

class _CollectionPick {
  const _CollectionPick({required this.id});
  final String? id;
}
