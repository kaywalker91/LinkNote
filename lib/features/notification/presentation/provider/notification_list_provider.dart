import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/features/notification/presentation/provider/notification_di_providers.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_list_provider.g.dart';

@riverpod
class NotificationList extends _$NotificationList {
  @override
  Future<PaginatedState<NotificationEntity>> build() async {
    return _fetch();
  }

  Future<PaginatedState<NotificationEntity>> _fetch({
    String? cursor,
  }) async {
    final result = await ref
        .read(fetchNotificationsUsecaseProvider)
        .call(cursor: cursor);
    if (result.isSuccess) return result.data!;
    throw Exception(
      result.failure?.message ?? 'Failed to fetch notifications',
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await _fetch(cursor: current.nextCursor);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          hasMore: next.hasMore,
          nextCursor: next.nextCursor,
          isLoadingMore: false,
        ),
      );
    } on Exception catch (e) {
      state = AsyncData(
        current.copyWith(
          isLoadingMore: false,
          loadMoreError: e,
        ),
      );
    }
  }

  Future<void> markRead(String id) async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update
    final previous = current;
    final updated = current.items.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = AsyncData(current.copyWith(items: updated));

    final result = await ref.read(markNotificationReadUsecaseProvider).call(id);
    if (result.isFailure) {
      state = AsyncData(previous);
    }
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update
    final previous = current;
    final updated = current.items.map((n) => n.copyWith(isRead: true)).toList();
    state = AsyncData(current.copyWith(items: updated));

    final result = await ref
        .read(markAllNotificationsReadUsecaseProvider)
        .call();
    if (result.isFailure) {
      state = AsyncData(previous);
    }
  }
}
