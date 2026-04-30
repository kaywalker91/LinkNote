import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/shared/widgets/og_thumbnail_widget.dart';
import 'package:linknote/shared/widgets/tag_chip_widget.dart';

class LinkListTile extends StatelessWidget {
  const LinkListTile({
    required this.link,
    super.key,
    this.onTap,
    this.onLongPress,
    this.onFavoriteTap,
    this.onMoreTap,
    this.isCompact = false,
    this.favoriteBusy = false,
    this.highlightText,
  });

  final LinkEntity link;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMoreTap;
  final bool isCompact;
  final bool favoriteBusy;
  final String? highlightText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    final urlStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
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
                  _highlightedText(
                    text: link.title,
                    style: titleStyle,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 2),
                  _highlightedText(
                    text: _displayUrl(link.url),
                    style: urlStyle,
                    maxLines: 1,
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
                if (favoriteBusy)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
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

  Widget _highlightedText({
    required String text,
    required TextStyle? style,
    required int maxLines,
  }) {
    final query = highlightText;
    if (query == null || query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
    final spans = _buildHighlightedSpans(text: text, query: query);
    if (spans == null) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<TextSpan>? _buildHighlightedSpans({
    required String text,
    required String query,
  }) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    var cursor = 0;
    var matched = false;
    while (cursor < text.length) {
      final hit = lowerText.indexOf(lowerQuery, cursor);
      if (hit == -1) {
        spans.add(TextSpan(text: text.substring(cursor)));
        break;
      }
      if (hit > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, hit)));
      }
      spans.add(
        TextSpan(
          text: text.substring(hit, hit + query.length),
          style: const TextStyle(
            backgroundColor: AppColors.forestSoft,
            color: AppColors.forestInk,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      matched = true;
      cursor = hit + query.length;
    }
    return matched ? spans : null;
  }

  String _displayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } on Exception catch (_) {
      return url;
    }
  }
}
