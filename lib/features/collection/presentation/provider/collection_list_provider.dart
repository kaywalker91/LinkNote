import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_list_provider.g.dart';

@riverpod
class CollectionList extends _$CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return PaginatedState<CollectionEntity>(
      items: List.generate(
        6,
        (i) => CollectionEntity(
          id: 'col_$i',
          name: 'Collection $i',
          description: 'A collection of interesting links',
          linkCount: i * 5 + 3,
          createdAt: DateTime.now().subtract(Duration(days: i * 7)),
          updatedAt: DateTime.now().subtract(Duration(days: i)),
        ),
      ),
      hasMore: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    // TODO(linknote): Fetch next page and append
    state = AsyncData(current.copyWith(isLoadingMore: false));
  }
}
