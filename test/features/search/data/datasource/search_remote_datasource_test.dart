import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/search/data/datasource/search_remote_datasource.dart';

void main() {
  group('SearchRemoteDataSource - tsQuery sanitization', () {
    // P1-4: 특수문자가 tsquery에 주입되지 않도록 sanitize 검증
    // sanitizeTsQuery를 static/visible로 추출하여 단위 테스트

    test('should remove single quotes from words', () {
      final result = SearchRemoteDataSource.sanitizeTsQuery("it's a test");
      expect(result, "'its' & 'a' & 'test'");
    });

    test('should remove SQL injection characters', () {
      final result = SearchRemoteDataSource.sanitizeTsQuery("'; DROP TABLE;");
      expect(result, "'DROP' & 'TABLE'");
    });

    test('should handle parentheses and special tsquery operators', () {
      final result = SearchRemoteDataSource.sanitizeTsQuery(
        'hello | world & (test)',
      );
      expect(result, "'hello' & 'world' & 'test'");
    });

    test('should preserve Korean characters', () {
      final result = SearchRemoteDataSource.sanitizeTsQuery('플러터 개발');
      expect(result, "'플러터' & '개발'");
    });

    test('should preserve hyphens and underscores', () {
      final result = SearchRemoteDataSource.sanitizeTsQuery('my-app my_lib');
      expect(result, "'my-app' & 'my_lib'");
    });

    test('should return empty string for only special characters', () {
      final result = SearchRemoteDataSource.sanitizeTsQuery("'!@#\$%^&*()");
      expect(result, '');
    });

    test('should handle multiple spaces', () {
      final result = SearchRemoteDataSource.sanitizeTsQuery(
        '  hello   world  ',
      );
      expect(result, "'hello' & 'world'");
    });

    test('should handle empty string', () {
      final result = SearchRemoteDataSource.sanitizeTsQuery('');
      expect(result, '');
    });
  });
}
