import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/profile/presentation/screens/settings_screen.dart';
import 'package:linknote/shared/providers/theme_mode_provider.dart';

class _StubThemeModeNotifier extends ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
  }
}

void main() {
  group('SettingsScreen', () {
    testWidgets('should show app bar with Settings title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeModeProvider.overrideWith(_StubThemeModeNotifier.new),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should show Appearance section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeModeProvider.overrideWith(_StubThemeModeNotifier.new),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('should show theme mode options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeModeProvider.overrideWith(_StubThemeModeNotifier.new),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('System default'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('should show About section with version', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeModeProvider.overrideWith(_StubThemeModeNotifier.new),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('0.1.0+1'), findsOneWidget);
    });
  });
}
