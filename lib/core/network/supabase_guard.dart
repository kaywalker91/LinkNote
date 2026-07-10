import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/logger/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps a Supabase-backed [body] with the project's canonical remote error
/// policy, so every remote datasource maps failures identically:
///
/// - [PostgrestException] -> [Failure.server] carrying the DB message.
/// - Any other error (including Dart [Error] subtypes such as the `_TypeError`
///   from a bad JSON cast) -> logged via [appLogger] under [label], then a
///   message-less [Failure.unknown] so the raw error never leaks to the UI.
///
/// [body] returns a [Result] itself, so success and validation branches
/// (`success(...)`, an early `error(Failure.auth(...))`, not-found handling)
/// pass straight through untouched — the guard only replaces the identical
/// try/catch scaffolding that was copied across every datasource method.
///
/// Intentionally NOT applied to the auth or reading_stats datasources: those
/// carry a different error policy and are excluded on purpose.
Future<Result<T>> guardSupabase<T>(
  Future<Result<T>> Function() body, {
  required String label,
}) async {
  try {
    return await body();
  } on PostgrestException catch (e) {
    return error(Failure.server(message: e.message));
  } on Object catch (e, st) {
    appLogger.w(label, error: e, stackTrace: st);
    return error(const Failure.unknown());
  }
}
