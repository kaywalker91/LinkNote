import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'public_collection_links_provider.g.dart';

/// Read-only links of a `public` collection (owner-agnostic).
///
/// App-level gate: it first resolves the parent collection via the public
/// detail usecase and only fetches links once that succeeds. If the parent is
/// absent / not public / RLS-blocked, the error propagates and the links fetch
/// is never issued — links are never surfaced for a collection that did not
/// resolve as public. (Gating on the usecase directly, rather than the detail
/// provider's future, keeps this a single async step — the screen still shares
/// the detail provider for the header.)
@riverpod
Future<List<LinkEntity>> publicCollectionLinks(
  Ref ref,
  String collectionId,
) async {
  final detail = await ref
      .watch(getPublicCollectionDetailUsecaseProvider)
      .call(collectionId);
  if (detail.isFailure) {
    Error.throwWithStackTrace(detail.failure!, StackTrace.current);
  }

  final result = await ref
      .watch(fetchPublicLinksUsecaseProvider)
      .call(collectionId);
  if (result.isFailure) {
    Error.throwWithStackTrace(result.failure!, StackTrace.current);
  }
  return result.data!.items;
}
