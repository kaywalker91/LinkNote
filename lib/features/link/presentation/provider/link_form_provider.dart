import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/services/og_tag_service.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
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

    /// Original createdAt preserved for edit mode.
    DateTime? originalCreatedAt,
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
      originalCreatedAt: link.createdAt,
    );
  }

  Future<void> parseOgTags(String url) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isParsingOg: true));
    try {
      final ogService = ref.read(ogTagServiceProvider);
      final result = await ogService.fetchOgTags(url);
      // Re-read state after await to avoid overwriting user edits (TOCTOU).
      final latest = state.value;
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(
          isParsingOg: false,
          title:
              result.title ??
              (latest.title.isEmpty ? _extractTitle(url) : latest.title),
          description: result.description ?? latest.description,
          thumbnailUrl: result.imageUrl ?? latest.thumbnailUrl,
        ),
      );
    } on Exception catch (_) {
      final latest = state.value;
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(
          isParsingOg: false,
          title: latest.title.isEmpty ? _extractTitle(url) : latest.title,
        ),
      );
    }
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

  void updateCollectionId(String? collectionId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(collectionId: collectionId));
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
    state = AsyncData(
      current.copyWith(
        tags: current.tags.where((t) => t.id != tagId).toList(),
      ),
    );
  }

  Future<bool> submit() async {
    final current = state.value;
    if (current == null || current.url.isEmpty || current.title.isEmpty) {
      state = AsyncData(
        (current ?? const LinkFormState()).copyWith(
          errorMessage: 'URL and title are required',
        ),
      );
      return false;
    }
    state = AsyncData(current.copyWith(isSubmitting: true, errorMessage: null));

    final now = DateTime.now();
    final entity = LinkEntity(
      id: linkId ?? '',
      url: current.url,
      title: current.title,
      description: current.description.isEmpty ? null : current.description,
      thumbnailUrl: current.thumbnailUrl,
      collectionId: current.collectionId,
      memo: current.memo.isEmpty ? null : current.memo,
      tags: current.tags,
      isFavorite: current.isFavorite,
      createdAt: current.originalCreatedAt ?? now,
      updatedAt: now,
    );

    final result = linkId == null
        ? await ref.read(createLinkUsecaseProvider).call(entity)
        : await ref.read(updateLinkUsecaseProvider).call(entity);

    if (result.isSuccess) {
      state = AsyncData(current.copyWith(isSubmitting: false));
      ref.invalidate(linkListProvider);
      return true;
    } else {
      state = AsyncData(
        current.copyWith(
          isSubmitting: false,
          errorMessage: result.failure?.message ?? 'Failed to save link',
        ),
      );
      return false;
    }
  }

  String _extractTitle(String url) {
    try {
      return Uri.parse(url).host;
    } on Exception catch (_) {
      return url;
    }
  }
}
