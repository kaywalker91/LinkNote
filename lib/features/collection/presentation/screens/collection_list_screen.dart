import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:linknote/shared/widgets/empty_state_illustration.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/ln/ln_collection_card.dart';
import 'package:linknote/shared/widgets/ln/ln_icon_btn.dart';
import 'package:linknote/shared/widgets/ln/ln_top_bar.dart';
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
        loading: () => const _SkeletonGrid(),
        error: (error, _) => ErrorStateWidget.fromError(
          error,
          onRetry: () => ref.read(collectionListProvider.notifier).refresh(),
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return const EmptyStateWidget(
              illustration: EmptyStateIllustration.collections(),
              message: '아직 컬렉션이 없어요',
              subMessage: '링크를 컬렉션으로 정리해보세요',
            );
          }
          return _PaginatedGrid(
            state: state,
            onRefresh: () =>
                ref.read(collectionListProvider.notifier).refresh(),
            onLoadMore: () =>
                ref.read(collectionListProvider.notifier).loadMore(),
          );
        },
      ),
    );
  }

  String _buildMetaLine(int total) {
    if (total == 0) return '첫 컬렉션을 만들어 보세요';
    return '컬렉션 $total개';
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md + 2,
        AppSpacing.md,
        AppSpacing.md + 2,
        AppSpacing.huge,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.95,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const CollectionCardSkeleton(),
    );
  }
}

class _PaginatedGrid extends StatefulWidget {
  const _PaginatedGrid({
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final PaginatedState<CollectionEntity> state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  State<_PaginatedGrid> createState() => _PaginatedGridState();
}

class _PaginatedGridState extends State<_PaginatedGrid> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.state.hasMore || widget.state.isLoadingMore) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md + 2,
              AppSpacing.md,
              AppSpacing.md + 2,
              0,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final collection = state.items[index];
                  return LnCollectionCard(
                    collection: collection,
                    onTap: () => context.push(
                      Routes.collectionDetailPath(collection.id),
                    ),
                  );
                },
                childCount: state.items.length,
              ),
            ),
          ),
          if (state.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: state.isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink(),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
        ],
      ),
    );
  }
}
