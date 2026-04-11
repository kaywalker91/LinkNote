import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/paginated_list_view.dart';
import 'package:linknote/shared/widgets/skeleton/collection_card_skeleton.dart';

class CollectionListScreen extends ConsumerWidget {
  const CollectionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'collections_fab',
        onPressed: () => context.push(Routes.collectionNew),
        child: const Icon(Icons.add),
      ),
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
          onRefresh: () => ref.read(collectionListProvider.notifier).refresh(),
          onLoadMore: () =>
              ref.read(collectionListProvider.notifier).loadMore(),
          empty: const EmptyStateWidget(
            icon: Icons.folder_outlined,
            message: 'No collections yet',
            subMessage: 'Organize your links into collections',
          ),
          itemBuilder: (context, collection, _) =>
              _CollectionCard(collection: collection),
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});
  final CollectionEntity collection;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(Routes.collectionDetailPath(collection.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (collection.description != null)
                      Text(
                        collection.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      '${collection.linkCount} links',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
