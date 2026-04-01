import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/shared/widgets/og_thumbnail_widget.dart';
import 'package:linknote/shared/widgets/tag_chip_widget.dart';

class LinkListTile extends StatelessWidget {
  const LinkListTile({
    super.key,
    required this.link,
    this.onTap,
    this.onFavoriteTap,
    this.onMoreTap,
    this.isCompact = false,
    this.favoriteBusy = false,
  });

  final LinkEntity link;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMoreTap;
  final bool isCompact;
  final bool favoriteBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OgThumbnailWidget(
              thumbnailUrl: link.thumbnailUrl,
              size: isCompact ? 56 : 80,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _displayUrl(link.url),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (link.collectionName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 12,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          link.collectionName!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ],
                  if (link.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: link.tags
                          .take(3)
                          .map(
                            (tag) =>
                                TagChipWidget(label: tag.name, isDense: true),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                favoriteBusy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(
                          link.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: link.isFavorite
                              ? Colors.amber
                              : colorScheme.outline,
                          size: 22,
                        ),
                        onPressed: onFavoriteTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                if (onMoreTap != null)
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.outline,
                      size: 18,
                    ),
                    onPressed: onMoreTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _displayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return url;
    }
  }
}
