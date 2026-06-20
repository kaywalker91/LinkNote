import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/share_intent/domain/service/shared_intent_service.dart';

void main() {
  group('SharedIntentService.extractPublicCollectionId', () {
    test('returns id for a canonical empty-authority deep link', () {
      expect(
        SharedIntentService.extractPublicCollectionId(
          'linknote:///collections/public/abc-123',
        ),
        'abc-123',
      );
    });

    test('trims surrounding whitespace before parsing', () {
      expect(
        SharedIntentService.extractPublicCollectionId(
          '  linknote:///collections/public/xyz  ',
        ),
        'xyz',
      );
    });

    test('returns null for a shared web URL (not a deep link)', () {
      expect(
        SharedIntentService.extractPublicCollectionId('https://flutter.dev'),
        isNull,
      );
    });

    test('returns null for a non-linknote scheme', () {
      expect(
        SharedIntentService.extractPublicCollectionId(
          'https:///collections/public/abc',
        ),
        isNull,
      );
    });

    test(
      'returns null for a linknote link that is not a public collection',
      () {
        expect(
          SharedIntentService.extractPublicCollectionId(
            'linknote:///links/new',
          ),
          isNull,
        );
      },
    );

    test('returns null when the id segment is missing', () {
      expect(
        SharedIntentService.extractPublicCollectionId(
          'linknote:///collections/public/',
        ),
        isNull,
      );
    });

    test('returns null for null payload', () {
      expect(SharedIntentService.extractPublicCollectionId(null), isNull);
    });
  });
}
