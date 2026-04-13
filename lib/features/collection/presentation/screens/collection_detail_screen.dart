import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/collection/presentation/provider/collection_detail_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_links_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/utils/url_launcher_helper.dart';
import 'package:linknote/shared/widgets/confirmation_dialog_widget.dart';
import 'package:linknote/shared/widgets/empty_state_illustration.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/link_list_tile.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';
import 'package:linknote/shared/widgets/skeleton/profile_header_skeleton.dart';

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({required this.collectionId, super.key});
  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(collectionDetailProvider(collectionId));
    final linksAsync = ref.watch(collectionLinksProvider(collectionId));

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.maybeWhen(
          data: (c) => Text(c.name),
          orElse: () => const Text('Collection'),
        ),
        actions: detailAsync.maybeWhen(
          data: (_) => [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push(Routes.collectionEditPath(collectionId)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed = await ConfirmationDialogWidget.show(
                  context,
                  title: 'Delete Collection',
                  message: 'This collection and all its data will be removed.',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                );
                if ((confirmed ?? false) && context.mounted) {
                  await ref
                      .read(collectionListProvider.notifier)
                      .deleteCollection(collectionId);
                  if (context.mounted) {
                    context
                      ..showSuccessSnackBar('컬렉션이 삭제되었습니다')
                      ..pop();
                  }
                }
              },
            ),
          ],
          orElse: () => null,
        ),
      ),
      body: detailAsync.when(
        loading: () => const ProfileHeaderSkeleton(),
        error: (error, _) => ErrorStateWidget.fromError(
          error,
          onRetry: () => ref
              .read(collectionDetailProvider(collectionId).notifier)
              .refresh(),
        ),
        data: (collection) => RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(collectionDetailProvider(collectionId).notifier)
                .refresh();
            ref.invalidate(collectionLinksProvider(collectionId));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (collection.description != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          collection.description!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${collection.linkCount} links',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const Divider(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              ..._buildLinksSection(context, ref, linksAsync),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLinksSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LinkEntity>> linksAsync,
  ) {
    return linksAsync.when(
      loading: () => [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const LinkCardSkeleton(),
            childCount: 5,
          ),
        ),
      ],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: ErrorStateWidget.fromError(
            error,
            onRetry: () =>
                ref.invalidate(collectionLinksProvider(collectionId)),
          ),
        ),
      ],
      data: (links) {
        if (links.isEmpty) {
          return [
            const SliverToBoxAdapter(
              child: EmptyStateWidget(
                illustration: EmptyStateIllustration.links(),
                message: 'No links in this collection',
                subMessage: 'Add links to this collection from the home screen',
              ),
            ),
          ];
        }
        return [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final link = links[i];
                return LinkListTile(
                  link: link,
                  onTap: () => UrlLauncherHelper.launch(context, link.url),
                  onLongPress: () =>
                      context.push(Routes.linkDetailPath(link.id)),
                  onFavoriteTap: () {},
                );
              },
              childCount: links.length,
            ),
          ),
        ];
      },
    );
  }
}
