import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/extensions/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    group('isValidUrl', () {
      test('should return true for URL with absolute path', () {
        expect('https://example.com/'.isValidUrl, isTrue);
      });

      test('should return true for URL with nested path', () {
        expect('https://example.com/path/to/page'.isValidUrl, isTrue);
      });

      test('should return true for URL without path', () {
        expect('https://example.com'.isValidUrl, isTrue);
      });

      test('should return false for scheme-only string', () {
        expect('https://'.isValidUrl, isFalse);
      });

      test('should return false for empty string', () {
        expect(''.isValidUrl, isFalse);
      });

      test('should return false for plain text', () {
        expect('not a url'.isValidUrl, isFalse);
      });
    });

    group('truncated', () {
      test('should return original string when shorter than maxLength', () {
        expect('hello'.truncated(10), equals('hello'));
      });

      test('should return original string when equal to maxLength', () {
        expect('hello'.truncated(5), equals('hello'));
      });

      test('should truncate and add ellipsis when longer than maxLength', () {
        expect('hello world'.truncated(5), equals('hello...'));
      });
    });
  });
}
