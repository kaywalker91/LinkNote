import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/app_scaffold_with_nav_bar.dart';

void main() {
  group('AppScaffoldWithNavBar.destinationLabels', () {
    test('should expose 4 bottom nav destinations', () {
      expect(AppScaffoldWithNavBar.destinationLabels.length, 4);
    });

    test('should contain Home, Search, Collections, Profile (in order)', () {
      expect(
        AppScaffoldWithNavBar.destinationLabels,
        equals(const ['Home', 'Search', 'Collections', 'Profile']),
      );
    });

    test('should NOT contain Notifications (moved to AppBar bell)', () {
      expect(
        AppScaffoldWithNavBar.destinationLabels,
        isNot(contains('Notifications')),
      );
    });
  });
}
