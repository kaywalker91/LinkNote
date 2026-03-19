import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_detail_provider.g.dart';

@riverpod
class LinkDetail extends _$LinkDetail {
  @override
  Future<LinkEntity> build(String linkId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return LinkEntity(
      id: linkId,
      url: 'https://example.com/article-$linkId',
      title: 'Sample Article',
      description: 'A detailed article description for link $linkId.',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(linkId));
  }

  Future<void> delete() async {
    // TODO(linknote): Call DeleteLinkUsecase
    // Invalidate list provider after deletion
    ref.invalidate(linkListProvider);
  }
}
