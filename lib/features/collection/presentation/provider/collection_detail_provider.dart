import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_detail_provider.g.dart';

@riverpod
class CollectionDetail extends _$CollectionDetail {
  @override
  Future<CollectionEntity> build(String collectionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return CollectionEntity(
      id: collectionId,
      name: 'Collection Detail',
      description: 'A detailed view of this collection',
      linkCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(collectionId));
  }
}
