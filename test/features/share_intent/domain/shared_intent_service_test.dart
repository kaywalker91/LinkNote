import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/share_intent/domain/service/shared_intent_service.dart';

void main() {
  group('SharedIntentService.extractUrl', () {
    test('returns null when payload is null', () {
      expect(SharedIntentService.extractUrl(null), isNull);
    });

    test('returns null when payload is empty', () {
      expect(SharedIntentService.extractUrl(''), isNull);
    });

    test('returns null when payload is whitespace-only', () {
      expect(SharedIntentService.extractUrl('   \n\t  '), isNull);
    });

    test('returns the URL as-is for a plain https payload', () {
      const url = 'https://example.com/path?q=1';
      expect(SharedIntentService.extractUrl(url), url);
    });

    test('extracts URL from YouTube-style "title - URL" payload', () {
      const raw =
          '하네스 엔지니어링 - 50점짜리 Codex를 88점으로 만드는 법 - '
          'https://youtube.com/watch?v=p9mRnsx7yv4';
      expect(
        SharedIntentService.extractUrl(raw),
        'https://youtube.com/watch?v=p9mRnsx7yv4',
      );
    });

    test('extracts URL when embedded in tweet-like prose', () {
      const raw = 'Check this out https://example.com/article';
      expect(SharedIntentService.extractUrl(raw), 'https://example.com/article');
    });

    test('returns null when payload has no extractable URL', () {
      expect(SharedIntentService.extractUrl('just a note with no link'), isNull);
    });

    test('returns null for malformed scheme-only text', () {
      expect(SharedIntentService.extractUrl('https://'), isNull);
    });

    test('strips zero-width / NBSP / BOM characters', () {
      const raw = '\u200bhttps://example.com\ufeff\u00a0';
      expect(SharedIntentService.extractUrl(raw), 'https://example.com');
    });
  });
}
