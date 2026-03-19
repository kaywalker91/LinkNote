import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_state.freezed.dart';

@freezed
sealed class PaginatedState<T> with _$PaginatedState<T> {
  const factory PaginatedState({
    @Default([]) List<T> items,
    @Default(false) bool hasMore,
    String? nextCursor,
    @Default(false) bool isLoadingMore,
    Object? loadMoreError,
  }) = _PaginatedState<T>;
}
