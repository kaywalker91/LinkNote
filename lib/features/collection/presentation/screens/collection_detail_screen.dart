import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/collection/presentation/provider/collection_detail_provider.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/skeleton/profile_header_skeleton.dart';

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({super.key, required this.collectionId});
  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(collectionDetailProvider(collectionId));

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.maybeWhen(
          data: (c) => Text(c.name),
          orElse: () => const Text('Collection'),
        ),
      ),
      body: detailAsync.when(
        loading: () => const ProfileHeaderSkeleton(),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref
              .read(collectionDetailProvider(collectionId).notifier)
              .refresh(),
        ),
        data: (collection) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collection.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    if (collection.description != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(collection.description!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              )),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${collection.linkCount} links',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const Divider(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.huge),
                  child: Text('Links coming soon...'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
