import 'dart:async';
import 'dart:io';

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

  // Detect CI at runtime — GitHub Actions, GitLab, CircleCI, Travis, and most
  // hosted runners set `CI=true` in the environment. `bool.fromEnvironment`
  // would only see compile-time --dart-define values, so it always evaluated
  // to false in our CI workflow and accidentally enabled platform goldens.
  final isRunningInCi = Platform.environment['CI']?.toLowerCase() == 'true';

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: !isRunningInCi),
    ),
    run: testMain,
  );
}
