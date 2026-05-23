import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/reading_stats/presentation/widget/reading_stats_badge.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/utils/highlight_text.dart';
import 'package:linknote/shared/widgets/ln/ln_tag.dart';
import 'package:linknote/shared/widgets/ln/ln_thumb.dart';

enum LnLinkCardVariant { list, magazine, compact }

/// Link card with 3 variants. Currently fully implemented: `list`.
/// `magazine` and `compact` render as styled list fallbacks for now.
class LnLinkCard extends ConsumerWidget {
  const LnLinkCard({
    required this.link,
    super.key,
    this.variant = LnLinkCardVariant.list,
    this.onTap,
    this.onLongPress,
    this.onFavoriteTap,
    this.onMoreTap,
    this.favoriteBusy = false,
    this.highlightText,
  });

  final LinkEntity link;
  final LnLinkCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMoreTap;
  final bool favoriteBusy;
  final String? highlightText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LnThumb(url: link.thumbnailUrl),
            const SizedBox(width: 14),
            Expanded(child: _body(context)),
            _trailing(context),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final palette = context.palette;
    final host = _hostOf(link.url);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                host,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: palette.ink3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _title(context),
        if (link.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: link.tags
                .take(3)
                .map((t) => LnTag(name: t.name, dense: true))
                .toList(),
          ),
        ],
        if (link.collectionName != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.folder_rounded,
                size: 12,
                color: palette.ink4,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  link.collectionName!,
                  style: AppTextStyles.caption.copyWith(color: palette.ink3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ..._visibilityPills(context),
            ],
          ),
        ],
        ReadingStatsBadge(linkId: link.id, compact: true),
      ],
    );
  }

  Widget _title(BuildContext context) {
    final palette = context.palette;
    final style = AppTextStyles.titleM.copyWith(color: palette.ink);
    final query = highlightText;
    if (query == null || query.isEmpty) {
      return Text(
        link.title,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    final spans = buildHighlightedSpans(
      text: link.title,
      query: query,
      highlightBg: palette.forestSoft,
      highlightFg: palette.forestInk,
    );
    if (spans == null) {
      return Text(
        link.title,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _trailing(BuildContext context) {
    final palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (favoriteBusy)
          const Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            icon: Icon(
              link.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: link.isFavorite ? palette.amber : palette.ink4,
              size: 22,
            ),
            visualDensity: VisualDensity.compact,
            onPressed: onFavoriteTap,
          ),
        if (onMoreTap != null)
          IconButton(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: palette.ink4,
              size: 20,
            ),
            visualDensity: VisualDensity.compact,
            onPressed: onMoreTap,
          ),
      ],
    );
  }

  // Visual indicator only — NOT access control. A Lock pill does not gate
  // entry; real enforcement (backend RLS / biometric / PIN) is a separate
  // track. These pills only surface the parent collection's state.
  List<Widget> _visibilityPills(BuildContext context) {
    final palette = context.palette;
    return [
      if (link.collectionVisibility == CollectionVisibility.public)
        _pill(
          icon: Icons.public,
          bg: palette.forestSoft,
          fg: palette.forestInk,
          label: 'Public collection',
        ),
      if (link.collectionLockedAt != null)
        _pill(
          icon: Icons.lock_outline,
          bg: palette.slateSoft,
          fg: palette.slate,
          label: 'Locked collection',
        ),
    ];
  }

  Widget _pill({
    required IconData icon,
    required Color bg,
    required Color fg,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Tooltip(
        message: label,
        child: Semantics(
          label: label,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 12, color: fg),
          ),
        ),
      ),
    );
  }

  String _hostOf(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.isNotEmpty) return uri.host;
      return url;
    } on Exception {
      return url;
    }
  }
}
