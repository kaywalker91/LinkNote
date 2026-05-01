// goldenTest is a Future-returning fire-and-forget — alchemist's API matches
// flutter_test's testWidgets pattern.
// ignore_for_file: discarded_futures

import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/ln/ln_brand.dart';

import '_golden_helpers.dart';

void main() {
  group('Ln brand goldens', () {
    goldenTest(
      'wordmark + mark — light/dark',
      fileName: 'ln_brand',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          GoldenTestScenario(
            name: 'wordmark / light',
            child: themedScenario(
              dark: false,
              child: const LinkNoteWordmark(),
            ),
          ),
          GoldenTestScenario(
            name: 'wordmark / dark',
            child: themedScenario(
              dark: true,
              child: const LinkNoteWordmark(),
            ),
          ),
          GoldenTestScenario(
            name: 'mark / light',
            child: themedScenario(
              dark: false,
              child: const LinkNoteMark(),
            ),
          ),
          GoldenTestScenario(
            name: 'mark / dark',
            child: themedScenario(
              dark: true,
              child: const LinkNoteMark(),
            ),
          ),
        ],
      ),
    );
  });
}
