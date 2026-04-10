import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/extensions/date_time_extensions.dart';

void main() {
  group('DateTimeExtensions', () {
    group('timeAgo', () {
      test('should return "방금 전" for less than 60 seconds ago', () {
        final now = DateTime.now().subtract(const Duration(seconds: 30));
        expect(now.timeAgo(), equals('방금 전'));
      });

      test('should return minutes ago', () {
        final time = DateTime.now().subtract(const Duration(minutes: 5));
        expect(time.timeAgo(), equals('5분 전'));
      });

      test('should return hours ago', () {
        final time = DateTime.now().subtract(const Duration(hours: 3));
        expect(time.timeAgo(), equals('3시간 전'));
      });

      test('should return days ago', () {
        final time = DateTime.now().subtract(const Duration(days: 2));
        expect(time.timeAgo(), equals('2일 전'));
      });

      test('should return weeks ago', () {
        final time = DateTime.now().subtract(const Duration(days: 14));
        expect(time.timeAgo(), equals('2주 전'));
      });

      test('should return months ago', () {
        final time = DateTime.now().subtract(const Duration(days: 60));
        expect(time.timeAgo(), equals('2개월 전'));
      });

      test('should return years ago', () {
        final time = DateTime.now().subtract(const Duration(days: 400));
        expect(time.timeAgo(), equals('1년 전'));
      });
    });
  });
}
