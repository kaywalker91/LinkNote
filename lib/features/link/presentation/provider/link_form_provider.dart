import 'dart:async' show unawaited;

import 'package:async/async.dart' show CancelableOperation;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/services/analytics_service.dart';
import 'package:linknote/core/services/og_tag_service.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/search/presentation/provider/user_tags_provider.dart';
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

/// AutoDispose (default): form state is per-screen; discard on close.
@riverpod
class LinkForm extends _$LinkForm {
  CancelableOperation<Result<OgTagResult>>? _pendingOgParse;

  @override
  Future<LinkFormState> build(String? linkId) async {
    ref.onDispose(() {
      final pending = _pendingOgParse;
      if (pending != null) unawaited(pending.cancel());
    });
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

  /// Fetches OG metadata for [url].
  ///
  /// When [fromShare] is true, emits a privacy-safe
  /// `share_metadata_result` analytics event (no raw URL).
  Future<void> parseOgTags(String url, {bool fromShare = false}) async {
    final current = state.value;
    if (current == null) return;

    // Cancel any in-flight OG parse.
    await _pendingOgParse?.cancel();

    state = AsyncData(
      current.copyWith(isParsingOg: true, errorMessage: null),
    );
    final ogService = ref.read(ogTagServiceProvider);
    final operation = CancelableOperation.fromFuture(
      ogService.fetchOgTags(url),
    );
    _pendingOgParse = operation;
    final result = await operation.valueOrCancellation();
    if (result == null) return; // Cancelled.

    // Re-read state after await to avoid overwriting user edits (TOCTOU).
    final latest = state.value;
    if (latest == null) return;

    if (result.isFailure) {
      if (fromShare) {
        unawaited(
          ref
              .read(analyticsServiceProvider)
              .logShareMetadataResult(
                success: false,
                failureCode: 'og_fetch_failed',
              ),
        );
      }
      state = AsyncData(
        latest.copyWith(
          isParsingOg: false,
          // Empty title only — never clobber a user-entered title.
          title: latest.title.isEmpty ? _extractTitle(url) : latest.title,
          errorMessage: _ogFailureMessage(result.failure!),
        ),
      );
      return;
    }

    if (fromShare) {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logShareMetadataResult(success: true),
      );
    }

    final og = result.data!;
    state = AsyncData(
      latest.copyWith(
        isParsingOg: false,
        // Empty-field-only merge: late OG results must not overwrite edits.
        title: latest.title.isNotEmpty
            ? latest.title
            : ((og.title?.isNotEmpty ?? false)
                  ? og.title!
                  : _extractTitle(url)),
        description: latest.description.isNotEmpty
            ? latest.description
            : (og.description ?? latest.description),
        thumbnailUrl:
            (latest.thumbnailUrl != null && latest.thumbnailUrl!.isNotEmpty)
            ? latest.thumbnailUrl
            : (og.imageUrl ?? latest.thumbnailUrl),
      ),
    );
  }

  String _ogFailureMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => '링크 정보를 불러오지 못했어요. URL은 저장할 수 있어요.',
      ServerFailure() => '링크 정보를 불러오지 못했어요. URL은 저장할 수 있어요.',
      _ => '링크 정보를 불러오지 못했어요. URL은 저장할 수 있어요.',
    };
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
          errorMessage: 'URL과 제목을 입력해 주세요.',
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
      // Refresh the link list, plus the search tag list since editing tags can
      // create new tags or orphan removed ones.
      ref
        ..invalidate(linkListProvider)
        ..invalidate(userTagsProvider);
      return true;
    } else {
      state = AsyncData(
        current.copyWith(
          isSubmitting: false,
          errorMessage: result.failure?.message ?? '링크 저장에 실패했어요.',
        ),
      );
      return false;
    }
  }

  String _extractTitle(String url) {
    try {
      return Uri.parse(url).host;
    } on Object catch (_) {
      return url;
    }
  }
}
