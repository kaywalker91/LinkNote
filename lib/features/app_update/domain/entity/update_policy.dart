import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_policy.freezed.dart';

/// Outcome of comparing the running version against the remote update policy.
@freezed
sealed class UpdatePolicy with _$UpdatePolicy {
  /// Running version satisfies the remote policy — no action.
  const factory UpdatePolicy.upToDate() = UpToDate;

  /// A newer version exists; surfacing is non-blocking and dismissible.
  const factory UpdatePolicy.optional({
    required int latestVersionCode,
    String? message,
    String? storeUrl,
  }) = OptionalUpdate;

  /// Running version is below the minimum supported — blocking.
  const factory UpdatePolicy.forced({
    required int minVersionCode,
    String? message,
    String? storeUrl,
  }) = ForcedUpdate;
}
