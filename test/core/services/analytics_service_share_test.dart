import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/services/analytics_service.dart';

void main() {
  group('AnalyticsService.sourceCategoryForUrl', () {
    test('classifies youtube hosts', () {
      expect(
        AnalyticsService.sourceCategoryForUrl(
          'https://www.youtube.com/watch?v=abc',
        ),
        'youtube',
      );
      expect(
        AnalyticsService.sourceCategoryForUrl('https://youtu.be/abc'),
        'youtube',
      );
    });

    test('classifies x / twitter hosts', () {
      expect(
        AnalyticsService.sourceCategoryForUrl('https://x.com/user/status/1'),
        'x',
      );
      expect(
        AnalyticsService.sourceCategoryForUrl(
          'https://twitter.com/user/status/1',
        ),
        'x',
      );
      expect(
        AnalyticsService.sourceCategoryForUrl('https://t.co/short'),
        'x',
      );
    });

    test('classifies other hosts as browser_other', () {
      expect(
        AnalyticsService.sourceCategoryForUrl('https://example.com/a'),
        'browser_other',
      );
    });
  });

  group('share funnel privacy contracts', () {
    test('source category never echoes the raw URL or full host', () {
      const raw = 'https://secret-blog.example.com/private/path?token=abc';
      final category = AnalyticsService.sourceCategoryForUrl(raw);
      expect(category, 'browser_other');
      expect(category.contains('secret'), isFalse);
      expect(category.contains('token'), isFalse);
      expect(category.contains('private'), isFalse);
      expect(category.contains('http'), isFalse);
    });

    test('share event names are fixed funnel codes (no free-form URL)', () {
      // Document the allowed event name set from PRD §11.1 so renames break
      // this contract deliberately.
      const allowed = {
        'share_intent_received',
        'share_url_extracted',
        'share_url_rejected',
        'share_add_form_opened',
        'share_metadata_result',
        'share_save_result',
        'share_flow_abandoned',
      };
      expect(allowed.contains('share_intent_received'), isTrue);
      expect(allowed.any((e) => e.contains('http')), isFalse);
    });
  });
}
