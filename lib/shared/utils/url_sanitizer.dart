// dart format off
/// Extract a usable URL from arbitrary user input.
///
/// Input comes from pastes that may include:
/// - Plain URLs: `"https://example.com"`
/// - Title + URL (YouTube share sheet, etc.):
///   `"하네스 엔지니어링 - https://youtube.com/watch?v=xxx"`
/// - Hidden Unicode (ZWSP / NBSP / BOM) from clipboards
/// - Scheme-less domains: `"youtu.be/xxx"`, `"www.foo.com"`
///
/// Returns `null` when no URL can be salvaged.
abstract final class UrlSanitizer
{
  static final RegExp _invisible = RegExp(
    r'[\u200b-\u200f\ufeff\u00a0\u2028\u2029]',
  );

  static final RegExp _urlPattern = RegExp(
    r'https?://\S+',
    caseSensitive: false,
  );

  static final RegExp _whitespace = RegExp(r'\s');

  /// Returns the first usable URL inside [raw], or `null` when none found.
  static String? extract(String raw)
  {
    final cleaned = raw.replaceAll(_invisible, '').trim();
    if (cleaned.isEmpty) return null;

    // Fast path — input is already a well-formed URL.
    final direct = Uri.tryParse(cleaned);
    if (direct != null && direct.hasScheme && direct.host.isNotEmpty)
    {
      return cleaned;
    }

    // Embedded URL — user pasted "title text https://real-url".
    final match = _urlPattern.firstMatch(cleaned);
    if (match != null)
    {
      final extracted = _trimTrailingPunctuation(match.group(0)!);
      final parsed = Uri.tryParse(extracted);
      if (parsed != null && parsed.host.isNotEmpty)
      {
        return extracted;
      }
    }

    // Scheme-less fallback — "youtu.be/xxx" or "www.foo.com".
    // Only when cleaned has no whitespace — a sentence "hello world" would
    // otherwise become "https://hello world".
    if (!cleaned.contains(_whitespace))
    {
      final prepended = Uri.tryParse('https://$cleaned');
      if (prepended != null && prepended.host.isNotEmpty)
      {
        return 'https://$cleaned';
      }
    }

    return null;
  }

  /// Whether the sanitizer would alter [raw] when extracting.
  ///
  /// Used by the save-time form to decide whether to show an
  /// "URL extracted" snackbar after auto-fixing a paste.
  static bool wouldAlter(String raw)
  {
    final extracted = extract(raw);
    if (extracted == null) return false;
    return extracted != raw.trim();
  }

  /// Strip trailing punctuation the regex may have swept into a URL match
  /// (e.g. a trailing comma, period, or closing paren from prose).
  static String _trimTrailingPunctuation(String url)
  {
    var end = url.length;
    while (end > 0)
    {
      final c = url.codeUnitAt(end - 1);
      final isStrip =
          c == 0x29 || c == 0x5d || c == 0x7d ||
          c == 0x2e || c == 0x2c || c == 0x3b ||
          c == 0x3a || c == 0x21 || c == 0x3f;
      if (!isStrip) break;
      end--;
    }
    return url.substring(0, end);
  }
}
