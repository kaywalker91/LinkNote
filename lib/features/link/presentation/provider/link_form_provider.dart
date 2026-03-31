import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_form_provider.freezed.dart';
part 'link_form_provider.g.dart';

@freezed
abstract class LinkFormState with _$LinkFormState {
  const factory LinkFormState({
    @Default('') String url,
    @Default('') String title,
    @Default('') String description,
    String? thumbnailUrl,
    String? collectionId,
    @Default('') String memo,
    @Default([]) List<TagEntity> tags,
    @Default(false) bool isFavorite,
    @Default(false) bool isParsingOg,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _LinkFormState;
}

@riverpod
class LinkForm extends _$LinkForm {
  @override
  Future<LinkFormState> build(String? linkId) async {
    if (linkId == null) return const LinkFormState();
    final link = await ref.read(linkDetailProvider(linkId).future);
    return LinkFormState(
      url: link.url,
      title: link.title,
      description: link.description ?? '',
      thumbnailUrl: link.thumbnailUrl,
      collectionId: link.collectionId,
      memo: link.memo ?? '',
      tags: link.tags,
      isFavorite: link.isFavorite,
    );
  }

  Future<void> parseOgTags(String url) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isParsingOg: true));
    // TODO(linknote): Implement OG tag parsing via network
    await Future.delayed(const Duration(seconds: 1));
    state = AsyncData(current.copyWith(
      isParsingOg: false,
      title: current.title.isEmpty ? _extractTitle(url) : current.title,
    ));
  }

  void updateUrl(String url) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(url: url));
  }

  void updateTitle(String title) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(title: title));
  }

  void updateDescription(String description) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(description: description));
  }

  void updateMemo(String memo) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(memo: memo));
  }

  void toggleFavorite() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isFavorite: !current.isFavorite));
  }

  void addTag(TagEntity tag) {
    final current = state.value;
    if (current == null) return;
    if (current.tags.any((t) => t.id == tag.id)) return;
    state = AsyncData(current.copyWith(tags: [...current.tags, tag]));
  }

  void removeTag(String tagId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      tags: current.tags.where((t) => t.id != tagId).toList(),
    ));
  }

  Future<bool> submit() async {
    final current = state.value;
    if (current == null || current.url.isEmpty || current.title.isEmpty) {
      state = AsyncData((current ?? const LinkFormState()).copyWith(
        errorMessage: 'URL and title are required',
      ));
      return false;
    }
    state = AsyncData(current.copyWith(isSubmitting: true, errorMessage: null));
    // TODO(linknote): Call CreateLinkUsecase or UpdateLinkUsecase
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncData(current.copyWith(isSubmitting: false));
    return true;
  }

  String _extractTitle(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return url;
    }
  }
}
