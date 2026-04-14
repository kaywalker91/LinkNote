import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_list_provider.g.dart';

@riverpod
class CollectionList extends _$CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() async {
    return _fetch();
  }

  Future<PaginatedState<CollectionEntity>> _fetch({String? cursor}) async {
    final result = await ref
        .read(getCollectionsUsecaseProvider)
        .call(cursor: cursor);
    if (result.isSuccess) return result.data!;
    Error.throwWithStackTrace(result.failure!, StackTrace.current);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
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
        current.copyWith(isLoadingMore: false, loadMoreError: e),
      );
    }
  }

  Future<void> createCollection({
    required String name,
    String? description,
  }) async {
    final now = DateTime.now();
    final entity = CollectionEntity(
      id: '',
      name: name,
      createdAt: now,
      updatedAt: now,
      description: description,
    );

    final result = await ref.read(createCollectionUsecaseProvider).call(entity);
    if (result.isFailure) {
      Error.throwWithStackTrace(result.failure!, StackTrace.current);
    }
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(items: [result.data!, ...current.items]),
      );
    }
  }

  Future<void> updateCollection({
    required String id,
    required String name,
    String? description,
  }) async {
    final current = state.value;
    if (current == null) return;

    final existing = current.items.firstWhere((c) => c.id == id);
    final updated = existing.copyWith(
      name: name,
      description: description,
      updatedAt: DateTime.now(),
    );

    final result = await ref
        .read(updateCollectionUsecaseProvider)
        .call(updated);
    if (result.isFailure) {
      Error.throwWithStackTrace(result.failure!, StackTrace.current);
    }
    state = AsyncData(
      current.copyWith(
        items: current.items.map((c) {
          if (c.id == id) return result.data!;
          return c;
        }).toList(),
      ),
    );
  }

  Future<void> deleteCollection(String id) async {
    final current = state.value;
    if (current == null) return;

    final previous = current;
    // Optimistic removal
    state = AsyncData(
      current.copyWith(
        items: current.items.where((c) => c.id != id).toList(),
      ),
    );

    final result = await ref.read(deleteCollectionUsecaseProvider).call(id);
    if (result.isFailure) {
      state = AsyncData(previous);
    }
  }
}
