import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/search/presentation/provider/search_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_tags_provider.g.dart';

@riverpod
Future<List<TagEntity>> userTags(Ref ref) async {
  final dataSource = ref.watch(searchRemoteDataSourceProvider);
  final result = await dataSource.fetchUserTags();
  if (result.isSuccess) return result.data!;
  return [];
}
