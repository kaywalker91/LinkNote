import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/share_intent/presentation/provider/pending_shared_url_provider.dart';

void main() {
  group('PendingSharedUrl', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('defaults to null', () {
      expect(container.read(pendingSharedUrlProvider), isNull);
    });

    test('setInitial stores a non-empty URL', () {
      container
          .read(pendingSharedUrlProvider.notifier)
          .setInitial('https://example.com');

      expect(
        container.read(pendingSharedUrlProvider),
        'https://example.com',
      );
    });

    test('setInitial ignores null', () {
      container.read(pendingSharedUrlProvider.notifier).setInitial(null);

      expect(container.read(pendingSharedUrlProvider), isNull);
    });

    test('setInitial ignores empty string', () {
      container.read(pendingSharedUrlProvider.notifier).setInitial('');

      expect(container.read(pendingSharedUrlProvider), isNull);
    });

    test('consume clears a previously set URL', () {
      container.read(pendingSharedUrlProvider.notifier)
        ..setInitial('https://example.com')
        ..consume();

      expect(container.read(pendingSharedUrlProvider), isNull);
    });
  });
}
