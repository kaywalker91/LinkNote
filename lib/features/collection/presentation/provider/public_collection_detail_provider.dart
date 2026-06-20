import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'public_collection_detail_provider.g.dart';

/// Read-only public collection detail (owner-agnostic).
///
/// Resolves a `public` collection by id via `GetPublicCollectionDetailUsecase`,
/// which never scopes by the caller's `user_id`. Throws the `Failure` when the
/// collection is absent or not public, so the UI degrades to an error state.
@riverpod
Future<CollectionEntity> publicCollectionDetail(
  Ref ref,
  String collectionId,
) async {
  final result = await ref
      .read(getPublicCollectionDetailUsecaseProvider)
      .call(collectionId);
  if (result.isFailure) {
    Error.throwWithStackTrace(result.failure!, StackTrace.current);
  }
  return result.data!;
}
