import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/features/notification/presentation/provider/notification_list_provider.dart';
import 'package:linknote/shared/extensions/date_time_extensions.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/paginated_list_view.dart';
import 'package:linknote/shared/widgets/skeleton/notification_tile_skeleton.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationListProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => ListView.builder(
          itemCount: 8,
          itemBuilder: (_, __) => const NotificationTileSkeleton(),
        ),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref.read(notificationListProvider.notifier).refresh(),
        ),
        data: (state) => PaginatedListView(
          items: state.items,
          hasMore: state.hasMore,
          isLoadingMore: state.isLoadingMore,
          onRefresh: () =>
              ref.read(notificationListProvider.notifier).refresh(),
          onLoadMore: () =>
              ref.read(notificationListProvider.notifier).loadMore(),
          empty: const EmptyStateWidget(
            icon: Icons.notifications_none_outlined,
            message: 'No notifications',
          ),
          padding: EdgeInsets.zero,
          itemBuilder: (context, notification, _) =>
              _NotificationTile(notification: notification),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});
  final NotificationEntity notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        if (!notification.isRead) {
          await ref
              .read(notificationListProvider.notifier)
              .markRead(notification.id);
        }
      },
      child: Container(
        color: notification.isRead
            ? null
            : colorScheme.primaryContainer.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.isRead
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 20,
                color: notification.isRead
                    ? colorScheme.outline
                    : colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: notification.isRead
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.createdAt.timeAgo(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
