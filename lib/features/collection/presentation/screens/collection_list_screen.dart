import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/shared/widgets/empty_state_illustration.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/ln/ln_icon_btn.dart';
import 'package:linknote/shared/widgets/ln/ln_top_bar.dart';
import 'package:linknote/shared/widgets/paginated_list_view.dart';
import 'package:linknote/shared/widgets/skeleton/collection_card_skeleton.dart';

class CollectionListScreen extends ConsumerWidget {
  const CollectionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionListProvider);
    final items = collectionsAsync.value?.items ?? const <CollectionEntity>[];
    final total = items.length;

    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      appBar: LnTopBar(
        large: true,
        displayTitle: '컬렉션',
        displaySubtitle: _buildMetaLine(total),
        actions: [
          LnIconBtn(
            icon: Icons.add_rounded,
            tooltip: '컬렉션 추가',
            onPressed: () => context.push(Routes.collectionNew),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: FloatingActionButton(
          heroTag: 'collections_fab',
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          elevation: 6,
          onPressed: () => context.push(Routes.collectionNew),
          child: const Icon(Icons.add_rounded, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: collectionsAsync.when(
        loading: () => ListView.builder(
          itemCount: 6,
          itemBuilder: (_, __) => const CollectionCardSkeleton(),
        ),
        error: (error, _) => ErrorStateWidget.fromError(
          error,
          onRetry: () => ref.read(collectionListProvider.notifier).refresh(),
        ),
        data: (state) => PaginatedListView(
          items: state.items,
          hasMore: state.hasMore,
          isLoadingMore: state.isLoadingMore,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.huge,
          ),
          onRefresh: () => ref.read(collectionListProvider.notifier).refresh(),
          onLoadMore: () =>
              ref.read(collectionListProvider.notifier).loadMore(),
          empty: const EmptyStateWidget(
            illustration: EmptyStateIllustration.collections(),
            message: '아직 컬렉션이 없어요',
            subMessage: '링크를 컬렉션으로 정리해보세요',
          ),
          itemBuilder: (context, collection, _) =>
              _CollectionCard(collection: collection),
        ),
      ),
    );
  }

  String _buildMetaLine(int total) {
    if (total == 0) return '첫 컬렉션을 만들어 보세요';
    return '컬렉션 $total개';
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});
  final CollectionEntity collection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.collectionDetailPath(collection.id)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.line),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.forestSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.folder_rounded,
                    color: AppColors.forest,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.name,
                        style: AppTextStyles.titleM.copyWith(
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (collection.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          collection.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.ink3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '링크 ${collection.linkCount}개',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.ink4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
