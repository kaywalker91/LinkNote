import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
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
import 'package:linknote/shared/widgets/ln/ln_icon_btn.dart';
import 'package:linknote/shared/widgets/ln/ln_link_card.dart';
import 'package:linknote/shared/widgets/ln/ln_top_bar.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';
import 'package:linknote/shared/widgets/skeleton/profile_header_skeleton.dart';

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({required this.collectionId, super.key});
  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final detailAsync = ref.watch(collectionDetailProvider(collectionId));
    final linksAsync = ref.watch(collectionLinksProvider(collectionId));

    return Scaffold(
      backgroundColor: palette.bgAlt,
      appBar: LnTopBar(
        leading: LnIconBtn(
          icon: Icons.arrow_back_rounded,
          tooltip: '뒤로',
          onPressed: () => context.pop(),
        ),
        title: detailAsync.maybeWhen(
          data: (c) => c.name,
          orElse: () => '컬렉션',
        ),
        actions: detailAsync.maybeWhen(
          data: (_) => [
            LnIconBtn(
              icon: Icons.edit_outlined,
              tooltip: '편집',
              onPressed: () =>
                  context.push(Routes.collectionEditPath(collectionId)),
            ),
            LnIconBtn(
              icon: Icons.delete_outline,
              tooltip: '삭제',
              color: palette.rose,
              onPressed: () => _confirmDelete(context, ref),
            ),
            const SizedBox(width: 4),
          ],
          orElse: () => const <Widget>[],
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.lg,
                    AppSpacing.screenPadding,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.name,
                        style: AppTextStyles.heading2.copyWith(
                          color: palette.ink,
                        ),
                      ),
                      if (collection.description != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          collection.description!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: palette.ink2,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '링크 ${collection.linkCount}개',
                        style: AppTextStyles.caption.copyWith(
                          color: palette.ink3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _VisibilityControls(
                        collectionId: collectionId,
                        collection: collection,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: palette.line,
                      ),
                    ],
                  ),
                ),
              ),
              ..._buildLinksSection(context, ref, linksAsync),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.huge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialogWidget.show(
      context,
      title: '컬렉션 삭제',
      message: '이 컬렉션과 모든 데이터가 삭제됩니다.',
      confirmLabel: '삭제',
      isDestructive: true,
    );
    if (!(confirmed ?? false) || !context.mounted) return;
    try {
      await ref
          .read(collectionListProvider.notifier)
          .deleteCollection(collectionId);
      if (context.mounted) {
        context
          ..showSuccessSnackBar('Collection deleted')
          ..pop();
      }
    } on Object catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('Failed to delete collection');
      }
    }
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
                message: '이 컬렉션에 링크가 없어요',
                subMessage: '홈 화면에서 링크를 이 컬렉션에 추가해보세요',
              ),
            ),
          ];
        }
        return [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final link = links[i];
                return LnLinkCard(
                  link: link,
                  onTap: () => UrlLauncherHelper.launch(context, link.url),
                  onLongPress: () =>
                      context.push(Routes.linkDetailPath(link.id)),
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

/// In-app visibility/lock toggles. Lock is a visual marker only — access
/// control is enforced backend-side (RLS), out of scope here.
class _VisibilityControls extends ConsumerWidget {
  const _VisibilityControls({
    required this.collectionId,
    required this.collection,
  });

  final String collectionId;
  final CollectionEntity collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final isPublic = collection.visibility == CollectionVisibility.public;
    final isLocked = collection.lockedAt != null;

    return Column(
      children: [
        SwitchListTile(
          key: const ValueKey('collection-visibility-toggle'),
          contentPadding: EdgeInsets.zero,
          dense: true,
          secondary: Icon(
            isPublic ? Icons.public : Icons.lock_outline,
            color: palette.ink2,
          ),
          title: Text(
            '공개',
            style: AppTextStyles.bodyMedium.copyWith(color: palette.ink),
          ),
          subtitle: Text(
            isPublic ? '누구나 볼 수 있어요' : '나만 볼 수 있어요',
            style: AppTextStyles.caption.copyWith(color: palette.ink3),
          ),
          value: isPublic,
          onChanged: (value) => _apply(
            context,
            () => ref
                .read(collectionDetailProvider(collectionId).notifier)
                .setVisibility(
                  value
                      ? CollectionVisibility.public
                      : CollectionVisibility.private,
                ),
          ),
        ),
        SwitchListTile(
          key: const ValueKey('collection-lock-toggle'),
          contentPadding: EdgeInsets.zero,
          dense: true,
          secondary: Icon(
            isLocked ? Icons.lock : Icons.lock_open_outlined,
            color: palette.ink2,
          ),
          title: Text(
            '잠금',
            style: AppTextStyles.bodyMedium.copyWith(color: palette.ink),
          ),
          value: isLocked,
          onChanged: (value) => _apply(
            context,
            () => ref
                .read(collectionDetailProvider(collectionId).notifier)
                .setLocked(locked: value),
          ),
        ),
      ],
    );
  }

  Future<void> _apply(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on Object catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('Failed to update collection');
      }
    }
  }
}
