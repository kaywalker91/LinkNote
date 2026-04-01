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

  Future<void> createCollection({
    required String name,
    String? description,
  }) async {
    final current = state.value;
    if (current == null) return;
    final newCollection = CollectionEntity(
      id: 'col_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      linkCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = AsyncData(
      current.copyWith(
        items: [newCollection, ...current.items],
      ),
    );
    // TODO(linknote): Call CreateCollectionUsecase
  }

  Future<void> updateCollection({
    required String id,
    required String name,
    String? description,
  }) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: current.items.map((c) {
          if (c.id != id) return c;
          return c.copyWith(
            name: name,
            description: description,
            updatedAt: DateTime.now(),
          );
        }).toList(),
      ),
    );
    // TODO(linknote): Call UpdateCollectionUsecase
  }

  Future<void> deleteCollection(String id) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: current.items.where((c) => c.id != id).toList(),
      ),
    );
    // TODO(linknote): Call DeleteCollectionUsecase
  }
}
