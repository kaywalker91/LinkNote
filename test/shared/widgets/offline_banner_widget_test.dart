import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/providers/connectivity_provider.dart';
import 'package:linknote/shared/widgets/offline_banner_widget.dart';

void main() {
  group('OfflineBannerWidget', () {
    testWidgets('should show banner when offline', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isOnlineProvider.overrideWithValue(false)],
          child: const MaterialApp(
            home: Scaffold(body: OfflineBannerWidget()),
          ),
        ),
      );

      expect(find.text('오프라인 상태입니다'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('should hide banner when online', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isOnlineProvider.overrideWithValue(true)],
          child: const MaterialApp(
            home: Scaffold(body: OfflineBannerWidget()),
          ),
        ),
      );

      expect(find.text('오프라인 상태입니다'), findsNothing);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
    });

    testWidgets('should render SizedBox.shrink when online', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isOnlineProvider.overrideWithValue(true)],
          child: const MaterialApp(
            home: Scaffold(body: OfflineBannerWidget()),
          ),
        ),
      );

      // The widget renders a SizedBox.shrink when online
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 0.0);
      expect(sizedBox.height, 0.0);
    });
  });
}
