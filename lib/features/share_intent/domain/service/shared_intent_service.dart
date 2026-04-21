import 'package:linknote/shared/utils/url_sanitizer.dart';

/// Domain service that extracts a savable URL from a raw share-intent payload.
///
/// Delegates to [UrlSanitizer] so cold-start intents and in-form paste input
/// share the same rules (YouTube "title + URL", hidden Unicode, etc.).
abstract final class SharedIntentService {
  /// Returns a usable URL from [payload], or `null` when none can be salvaged.
  static String? extractUrl(String? payload) {
    if (payload == null) return null;
    return UrlSanitizer.extract(payload);
  }
}
