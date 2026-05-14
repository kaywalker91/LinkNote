import 'package:linknote/core/logger/app_logger.dart';

/// Maps [rows] into [T] one item at a time, so a single malformed row
/// cannot wipe out the entire fetch. Every parse failure is forwarded to
/// [onError] (or logged as a warning by default) instead of being silently
/// swallowed.
///
/// [label] identifies the caller in the default warning log (e.g.
/// `'CollectionRemoteDataSource.getCollections'`).
///
/// Source lesson: `memory/feedback_per_row_parse_tolerance.md`.
List<T> parseRowsTolerant<T>(
  Iterable<Map<String, dynamic>> rows,
  T Function(Map<String, dynamic> row) parse, {
  required String label,
  void Function(Object error, StackTrace stackTrace)? onError,
}) {
  final items = <T>[];
  for (final row in rows) {
    try {
      items.add(parse(row));
    } on Object catch (e, st) {
      if (onError != null) {
        onError(e, st);
      } else {
        appLogger.w(
          '$label: failed to parse a row, skipping',
          error: e,
          stackTrace: st,
        );
      }
    }
  }
  return items;
}
