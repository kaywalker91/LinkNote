import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_detail_provider.g.dart';

@riverpod
class LinkDetail extends _$LinkDetail {
  @override
  Future<LinkEntity> build(String linkId) async {
    final result = await ref.read(getLinkDetailUsecaseProvider).call(linkId);
    if (result.isSuccess) return result.data!;
    throw Exception(result.failure?.message ?? 'Failed to load link');
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(linkId));
  }

  Future<void> delete() async {
    final result = await ref.read(deleteLinkUsecaseProvider).call(linkId);
    if (result.isFailure) {
      throw Exception(result.failure?.message ?? 'Failed to delete link');
    }
    ref.invalidate(linkListProvider);
  }
}
