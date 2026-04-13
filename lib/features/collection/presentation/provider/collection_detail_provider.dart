import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_detail_provider.g.dart';

@riverpod
class CollectionDetail extends _$CollectionDetail {
  @override
  Future<CollectionEntity> build(String collectionId) async {
    final result = await ref
        .read(getCollectionDetailUsecaseProvider)
        .call(collectionId);
    if (result.isFailure) {
      Error.throwWithStackTrace(result.failure!, StackTrace.current);
    }
    return result.data!;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(collectionId));
  }
}
