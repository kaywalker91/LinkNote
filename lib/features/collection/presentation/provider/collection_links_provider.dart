import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_links_provider.g.dart';

@riverpod
Future<List<LinkEntity>> collectionLinks(
  Ref ref,
  String collectionId,
) async {
  final usecase = ref.watch(fetchLinksUsecaseProvider);
  final result = await usecase(collectionId: collectionId);
  return result.data?.items ?? [];
}
