import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/features/collection/presentation/provider/public_collection_detail_provider.dart';
import 'package:linknote/features/collection/presentation/provider/public_collection_links_provider.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/utils/url_launcher_helper.dart';
import 'package:linknote/shared/widgets/empty_state_illustration.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/ln/ln_icon_btn.dart';
import 'package:linknote/shared/widgets/ln/ln_link_card.dart';
import 'package:linknote/shared/widgets/ln/ln_top_bar.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';
import 'package:linknote/shared/widgets/skeleton/profile_header_skeleton.dart';

/// Read-only view of a `public` collection, opened by a non-owner via a deep
/// link. Owner-only affordances (edit, delete, visibility/lock toggles, link
/// detail navigation) are intentionally absent — this surface only reads.
class PublicCollectionDetailScreen extends ConsumerWidget {
  const PublicCollectionDetailScreen({required this.collectionId, super.key});
  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final detailAsync = ref.watch(publicCollectionDetailProvider(collectionId));
    final linksAsync = ref.watch(publicCollectionLinksProvider(collectionId));

    return Scaffold(
      backgroundColor: palette.bgAlt,
      appBar: LnTopBar(
        leading: LnIconBtn(
          icon: Icons.arrow_back_rounded,
          tooltip: '뒤로',
          // A cold deep link has nothing to pop — fall back to home.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
        ),
        title: detailAsync.maybeWhen(
          data: (c) => c.name,
          orElse: () => '컬렉션',
        ),
      ),
      body: detailAsync.when(
        loading: () => const ProfileHeaderSkeleton(),
        error: (error, _) => ErrorStateWidget.fromError(
          error,
          onRetry: () =>
              ref.invalidate(publicCollectionDetailProvider(collectionId)),
        ),
        data: (collection) => RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(publicCollectionDetailProvider(collectionId))
              ..invalidate(publicCollectionLinksProvider(collectionId));
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
                ref.invalidate(publicCollectionLinksProvider(collectionId)),
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
              ),
            ),
          ];
        }
        return [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final link = links[i];
                // Read-only: tap opens the URL. No long-press to link detail
                // (that route is owner-scoped and would fail for a non-owner).
                return LnLinkCard(
                  link: link,
                  onTap: () => UrlLauncherHelper.launch(context, link.url),
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
