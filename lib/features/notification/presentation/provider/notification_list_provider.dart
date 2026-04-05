import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_list_provider.g.dart';

@riverpod
class NotificationList extends _$NotificationList {
  @override
  Future<PaginatedState<NotificationEntity>> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return PaginatedState<NotificationEntity>(
      items: List.generate(
        10,
        (i) => NotificationEntity(
          id: 'notif_$i',
          title: 'New link shared with you',
          body: 'Someone shared "Article $i" with you',
          isRead: i > 3,
          createdAt: DateTime.now().subtract(Duration(hours: i * 2)),
        ),
      ),
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
    // TODO(linknote): Fetch next page
    state = AsyncData(current.copyWith(isLoadingMore: false));
  }

  Future<void> markRead(String id) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.items.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = AsyncData(current.copyWith(items: updated));
    // TODO(linknote): Persist to backend
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.items.map((n) => n.copyWith(isRead: true)).toList();
    state = AsyncData(current.copyWith(items: updated));
    // TODO(linknote): Persist to backend
  }
}
