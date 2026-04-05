import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/shared/extensions/date_time_extensions.dart';
import 'package:linknote/shared/widgets/confirmation_dialog_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/og_thumbnail_widget.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';
import 'package:linknote/shared/widgets/tag_chip_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkDetailScreen extends ConsumerWidget {
  const LinkDetailScreen({required this.linkId, super.key});
  final String linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkAsync = ref.watch(linkDetailProvider(linkId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          linkAsync.maybeWhen(
            data: (link) => Row(
              children: [
                IconButton(
                  icon: Icon(
                    link.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: link.isFavorite ? Colors.amber : null,
                  ),
                  onPressed: () => ref
                      .read(linkListProvider.notifier)
                      .toggleFavorite(linkId),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push(Routes.linkEditPath(linkId)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    final confirm = await ConfirmationDialogWidget.show(
                      context,
                      title: 'Delete Link',
                      message: 'This action cannot be undone.',
                      confirmLabel: 'Delete',
                      isDestructive: true,
                    );
                    if ((confirm ?? false) && context.mounted) {
                      await ref
                          .read(linkDetailProvider(linkId).notifier)
                          .delete();
                      if (context.mounted) context.pop();
                    }
                  },
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: linkAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: LinkCardSkeleton(),
        ),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () =>
              ref.read(linkDetailProvider(linkId).notifier).refresh(),
        ),
        data: (link) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (link.thumbnailUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: OgThumbnailWidget(
                    thumbnailUrl: link.thumbnailUrl,
                    size: double.infinity,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                link.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () async {
                  final uri = Uri.tryParse(link.url);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  link.url,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Added ${link.createdAt.timeAgo()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              if (link.description?.isNotEmpty ?? false) ...[
                const Divider(height: AppSpacing.xxl),
                Text(
                  link.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (link.memo?.isNotEmpty ?? false) ...[
                const Divider(height: AppSpacing.xxl),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  link.memo!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (link.tags.isNotEmpty) ...[
                const Divider(height: AppSpacing.xxl),
                Text(
                  'Tags',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: link.tags
                      .map((tag) => TagChipWidget(label: tag.name))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
