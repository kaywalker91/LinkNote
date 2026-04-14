import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_filter_provider.freezed.dart';
part 'link_filter_provider.g.dart';

@freezed
abstract class LinkFilter with _$LinkFilter {
  const factory LinkFilter({
    @Default(false) bool favoritesOnly,
    String? collectionId,
  }) = _LinkFilter;
}

@riverpod
class LinkFilterNotifier extends _$LinkFilterNotifier {
  @override
  LinkFilter build() => const LinkFilter();

  void setFavoritesOnly({required bool value}) {
    state = state.copyWith(favoritesOnly: value);
  }

  void setCollectionId(String? collectionId) {
    state = state.copyWith(collectionId: collectionId);
  }
}
