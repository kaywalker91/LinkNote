import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/features/reading_stats/presentation/provider/reading_stats_di_providers.dart';
import 'package:linknote/features/reading_stats/presentation/widget/reading_stats_badge.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/extensions/date_time_extensions.dart';
import 'package:linknote/shared/utils/url_launcher_helper.dart';
import 'package:linknote/shared/widgets/confirmation_dialog_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/ln/ln_icon_btn.dart';
import 'package:linknote/shared/widgets/ln/ln_tag.dart';
import 'package:linknote/shared/widgets/ln/ln_thumb.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';

class LinkDetailScreen extends ConsumerStatefulWidget {
  const LinkDetailScreen({required this.linkId, super.key});
  final String linkId;

  @override
  ConsumerState<LinkDetailScreen> createState() => _LinkDetailScreenState();
}

class _LinkDetailScreenState extends ConsumerState<LinkDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(recordReadEventUsecaseProvider)
            .call(
              ReadingEventEntity(
                linkId: widget.linkId,
                timestamp: DateTime.now().toUtc(),
              ),
            )
            .then((_) {
              if (mounted) {
                ref.invalidate(linkReadingStatsProvider(widget.linkId));
              }
            }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final linkId = widget.linkId;
    final linkAsync = ref.watch(linkDetailProvider(linkId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          linkAsync.maybeWhen(
            data: (link) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LnIconBtn(
                  icon: link.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: link.isFavorite ? palette.amber : palette.ink3,
                  onPressed: () => ref
                      .read(linkListProvider.notifier)
                      .toggleFavorite(linkId),
                ),
                LnIconBtn(
                  icon: Icons.edit_outlined,
                  onPressed: () => context.push(Routes.linkEditPath(linkId)),
                ),
                LnIconBtn(
                  icon: Icons.delete_outline,
                  color: palette.rose,
                  onPressed: () async {
                    final confirm = await ConfirmationDialogWidget.show(
                      context,
                      title: '링크 삭제',
                      message: '되돌릴 수 없습니다.',
                      confirmLabel: '삭제',
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
                const SizedBox(width: AppSpacing.xs),
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
        error: (error, _) => ErrorStateWidget.fromError(
          error,
          onRetry: () =>
              ref.read(linkDetailProvider(linkId).notifier).refresh(),
        ),
        data: (link) => RefreshIndicator(
          onRefresh: () async =>
              ref.read(linkDetailProvider(linkId).notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LnThumb(
                  url: link.thumbnailUrl,
                  size: LnThumbSize.lg,
                  hostPill: _hostOf(link.url),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  link.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () => UrlLauncherHelper.launch(context, link.url),
                  child: Text(
                    link.url,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      height: 1.4,
                      color: palette.forest,
                      decoration: TextDecoration.underline,
                      decorationColor: palette.forest,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${link.createdAt.timeAgo()} 저장 · '
                  '${link.createdAt.formattedDate()}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: palette.ink3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ReadingStatsBadge(linkId: linkId),
                if (link.description?.isNotEmpty ?? false) ...[
                  Divider(
                    height: AppSpacing.xxl,
                    thickness: 1,
                    color: palette.line,
                  ),
                  Text(
                    link.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: palette.ink2,
                    ),
                  ),
                ],
                if (link.memo?.isNotEmpty ?? false) ...[
                  Divider(
                    height: AppSpacing.xxl,
                    thickness: 1,
                    color: palette.line,
                  ),
                  const _MemoHeaderPill(),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.only(left: AppSpacing.lg),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: palette.amber,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      link.memo!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: palette.ink,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                if (link.tags.isNotEmpty) ...[
                  Divider(
                    height: AppSpacing.xxl,
                    thickness: 1,
                    color: palette.line,
                  ),
                  Text(
                    '태그',
                    style: AppTextStyles.titleM.copyWith(
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: link.tags
                        .map((tag) => LnTag(name: tag.name))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _hostOf(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final host = uri.host;
    return host.isEmpty ? null : host;
  }
}

class _MemoHeaderPill extends StatelessWidget {
  const _MemoHeaderPill();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: palette.amberSoft,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📝', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            '메모',
            style: AppTextStyles.label.copyWith(
              color: palette.amberInk,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
