import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:google_fonts/google_fonts.dart';

/// Alchemist setup.
///
/// CI goldens use Ahem font (deterministic across platforms) and obscured text
/// blocks. Local platform goldens use real fonts + shadows for human review.
///
/// Platform goldens are gitignored (see `.gitignore`); only `goldens/ci/` is
/// tracked so CI verifies a stable cross-platform baseline.
///
/// Disables Google Fonts runtime fetching — the Inter / JetBrainsMono /
/// Fraunces TTFs are bundled under `assets/fonts/`, so the package resolves
/// them from the asset bundle instead of hitting `fonts.gstatic.com`. Keeps
/// tests offline-deterministic and side-steps the package's stale-URL issue.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  const isRunningInCi = bool.fromEnvironment('CI');

  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      // Compile-time `!isRunningInCi` matches the default when running locally,
      // but when CI=true the const folds to `enabled: false`. Both branches
      // matter, so the redundancy hint is wrong here.
      // ignore: avoid_redundant_argument_values
      platformGoldensConfig: PlatformGoldensConfig(enabled: !isRunningInCi),
    ),
    run: testMain,
  );
}
