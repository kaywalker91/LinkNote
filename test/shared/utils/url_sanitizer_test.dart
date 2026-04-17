// dart format off
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/utils/url_sanitizer.dart';

void main()
{
  group('UrlSanitizer.extract', ()
  {
    test('returns null for empty string', ()
    {
      expect(UrlSanitizer.extract(''), isNull);
    });

    test('returns null for whitespace-only string', ()
    {
      expect(UrlSanitizer.extract('   \n\t  '), isNull);
    });

    test('returns the input as-is for a well-formed https URL', ()
    {
      const url = 'https://example.com/path?q=1';
      expect(UrlSanitizer.extract(url), url);
    });

    test('returns the input as-is for a well-formed http URL', ()
    {
      const url = 'http://example.com';
      expect(UrlSanitizer.extract(url), url);
    });

    test('trims surrounding whitespace', ()
    {
      expect(
        UrlSanitizer.extract('  https://example.com  '),
        'https://example.com',
      );
    });

    test('strips zero-width / NBSP / BOM characters before parsing', ()
    {
      const raw = '\u200bhttps://example.com\ufeff\u00a0';
      expect(UrlSanitizer.extract(raw), 'https://example.com');
    });

    test('extracts URL when input is "title - URL" (YouTube share case)', ()
    {
      const raw =
          '하네스 엔지니어링 - 50점짜리 Codex를 88점으로 만드는 법 - '
          'https://youtube.com/watch?v=p9mRnsx7yv4&si=LLAhSDDM4YQ_Xv4X';
      expect(
        UrlSanitizer.extract(raw),
        'https://youtube.com/watch?v=p9mRnsx7yv4&si=LLAhSDDM4YQ_Xv4X',
      );
    });

    test('extracts URL when embedded in prose with trailing punctuation', ()
    {
      expect(
        UrlSanitizer.extract('Check this out https://example.com/foo.'),
        'https://example.com/foo',
      );
    });

    test('extracts first URL when multiple are present', ()
    {
      expect(
        UrlSanitizer.extract('a https://one.com b https://two.com'),
        'https://one.com',
      );
    });

    test('prepends https:// for scheme-less domain with path', ()
    {
      expect(
        UrlSanitizer.extract('youtu.be/dQw4w9WgXcQ'),
        'https://youtu.be/dQw4w9WgXcQ',
      );
    });

    test('prepends https:// for www-prefixed domain', ()
    {
      expect(
        UrlSanitizer.extract('www.example.com'),
        'https://www.example.com',
      );
    });

    test('does NOT treat a sentence with spaces as scheme-less URL', ()
    {
      expect(UrlSanitizer.extract('hello world how are you'), isNull);
    });

    test('returns null for garbage input with no URL and spaces', ()
    {
      expect(UrlSanitizer.extract('그냥 제목만 있는 텍스트'), isNull);
    });

    test('case-insensitive scheme match (HTTPS://)', ()
    {
      expect(
        UrlSanitizer.extract('HTTPS://EXAMPLE.COM/PATH'),
        'HTTPS://EXAMPLE.COM/PATH',
      );
    });

    test('returns null for URL longer than max length (DOS guard)', ()
    {
      final longUrl = 'https://example.com/${'a' * 2100}';
      expect(longUrl.length, greaterThan(2048));
      expect(UrlSanitizer.extract(longUrl), isNull);
    });

    test('accepts URL at exactly the max length boundary', ()
    {
      const prefix = 'https://example.com/';
      final url = prefix + 'a' * (2048 - prefix.length);
      expect(url.length, 2048);
      expect(UrlSanitizer.extract(url), url);
    });
  });

  group('UrlSanitizer.wouldAlter', ()
  {
    test('returns false for already-clean URL', ()
    {
      expect(UrlSanitizer.wouldAlter('https://example.com'), isFalse);
    });

    test('returns true when extraction happens', ()
    {
      expect(
        UrlSanitizer.wouldAlter('title text https://example.com'),
        isTrue,
      );
    });

    test('returns true for scheme-less input', ()
    {
      expect(UrlSanitizer.wouldAlter('youtu.be/xxx'), isTrue);
    });

    test('returns false when no URL can be extracted', ()
    {
      expect(UrlSanitizer.wouldAlter('제목만 있음'), isFalse);
    });
  });
}
