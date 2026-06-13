import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Alchemist setup.
///
/// Goldens render with the Ahem font (deterministic across platforms) plus
/// obscured text blocks, with a single tracked baseline under `goldens/ci/`.
///
/// Real-font "platform" goldens are disabled. They were gitignored,
/// per-developer, and drifted out of sync (stale baselines / missing files),
/// so they only ever forced `--exclude-tags golden` locally without gating CI.
///
/// Cross-platform Skia anti-aliasing differs by a sub-percent margin (measured
/// max 0.88% on macOS vs the Linux `ci/` baselines), so a pixel-exact compare
/// fails locally even when nothing changed. So that developers can run the
/// full suite (golden included) without excluding tags, the comparator
/// tolerates up to [_localGoldenTolerance] of differing pixels **locally
/// only**. On CI (`CI=true`) it stays pixel-exact, preserving the regression
/// gate — a genuine visual change still fails there.
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
  // to false in our CI workflow.
  final isRunningInCi = Platform.environment['CI']?.toLowerCase() == 'true';

  // Locally, swap in a tolerant comparator so cross-platform Skia noise does
  // not fail unchanged goldens. On CI keep the default pixel-exact comparator
  // (the bootstrap installs a LocalFileComparator before this runs).
  final current = goldenFileComparator;
  if (!isRunningInCi && current is LocalFileComparator) {
    goldenFileComparator = _TolerantGoldenFileComparator(
      current.basedir.resolve('flutter_test_config.dart'),
      tolerance: _localGoldenTolerance,
    );
  }

  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}

/// Max fraction (0–1) of differing pixels tolerated when comparing goldens
/// locally. Sized just above the measured cross-platform Skia noise (max
/// 0.88% on macOS vs the Linux `ci/` baselines) with ~1.7x headroom. Local
/// only — CI compares pixel-exact (tolerance 0).
const _localGoldenTolerance = 0.015;

/// A [LocalFileComparator] that passes when the pixel difference is at or
/// below [tolerance], instead of requiring a byte-exact match.
class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(super.testFile, {required this.tolerance});

  /// Max fraction (0–1) of differing pixels treated as a pass.
  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
