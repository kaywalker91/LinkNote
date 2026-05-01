// goldenTest is a Future-returning fire-and-forget — alchemist's API matches
// flutter_test's testWidgets pattern.
// ignore_for_file: discarded_futures

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/ln/ln_icon_btn.dart';
import 'package:linknote/shared/widgets/ln/ln_segmented.dart';
import 'package:linknote/shared/widgets/ln/ln_tag.dart';
import 'package:linknote/shared/widgets/ln/ln_tags.dart';
import 'package:linknote/shared/widgets/ln/ln_thumb.dart';
import 'package:linknote/shared/widgets/ln/ln_top_bar.dart';

import '_golden_helpers.dart';

void main() {
  group('Ln atoms goldens', () {
    goldenTest(
      'LnTopBar — light/dark',
      fileName: 'ln_top_bar',
      builder: () => GoldenTestGroup(
        columns: 1,
        children: [
          GoldenTestScenario(
            name: 'standard / light',
            child: themedScenario(
              dark: false,
              width: 380,
              padding: EdgeInsets.zero,
              child: const SizedBox(
                height: 56,
                child: LnTopBar(title: '내 서랍'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'standard / dark',
            child: themedScenario(
              dark: true,
              width: 380,
              padding: EdgeInsets.zero,
              child: const SizedBox(
                height: 56,
                child: LnTopBar(title: '내 서랍'),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'LnIconBtn — light/dark',
      fileName: 'ln_icon_btn',
      builder: () => GoldenTestGroup(
        columns: 4,
        children: [
          GoldenTestScenario(
            name: 'plain / light',
            child: themedScenario(
              dark: false,
              child: const LnIconBtn(icon: Icons.star_outline_rounded),
            ),
          ),
          GoldenTestScenario(
            name: 'plain / dark',
            child: themedScenario(
              dark: true,
              child: const LnIconBtn(icon: Icons.star_outline_rounded),
            ),
          ),
          GoldenTestScenario(
            name: 'badge / light',
            child: themedScenario(
              dark: false,
              child: const LnIconBtn(
                icon: Icons.notifications_outlined,
                badge: true,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'badge / dark',
            child: themedScenario(
              dark: true,
              child: const LnIconBtn(
                icon: Icons.notifications_outlined,
                badge: true,
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'LnSegmented — light/dark',
      fileName: 'ln_segmented',
      builder: () => GoldenTestGroup(
        columns: 1,
        children: [
          GoldenTestScenario(
            name: 'two-segment / light',
            child: themedScenario(
              dark: false,
              width: 280,
              child: LnSegmented(
                labels: const ['전체', '★ 즐겨찾기'],
                selectedIndex: 0,
                onChanged: (_) {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'two-segment / dark',
            child: themedScenario(
              dark: true,
              width: 280,
              child: LnSegmented(
                labels: const ['전체', '★ 즐겨찾기'],
                selectedIndex: 0,
                onChanged: (_) {},
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'LnTag — 5 tones × light/dark',
      fileName: 'ln_tag',
      builder: () => GoldenTestGroup(
        columns: 5,
        children: [
          for (final tone in LnTagTone.values)
            GoldenTestScenario(
              name: '${tone.name} / light',
              child: themedScenario(
                dark: false,
                child: LnTag(name: tone.name, tone: tone),
              ),
            ),
          for (final tone in LnTagTone.values)
            GoldenTestScenario(
              name: '${tone.name} / dark',
              child: themedScenario(
                dark: true,
                child: LnTag(name: tone.name, tone: tone),
              ),
            ),
        ],
      ),
    );

    goldenTest(
      'LnThumb — light/dark (no url placeholder)',
      fileName: 'ln_thumb',
      builder: () => GoldenTestGroup(
        columns: 3,
        children: [
          GoldenTestScenario(
            name: 'sm / light',
            child: themedScenario(
              dark: false,
              child: const LnThumb(size: LnThumbSize.sm),
            ),
          ),
          GoldenTestScenario(
            name: 'md / light',
            child: themedScenario(
              dark: false,
              child: const LnThumb(),
            ),
          ),
          GoldenTestScenario(
            name: 'lg / light',
            child: themedScenario(
              dark: false,
              width: 240,
              child: const LnThumb(
                size: LnThumbSize.lg,
                hostPill: 'flutter.dev',
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'sm / dark',
            child: themedScenario(
              dark: true,
              child: const LnThumb(size: LnThumbSize.sm),
            ),
          ),
          GoldenTestScenario(
            name: 'md / dark',
            child: themedScenario(
              dark: true,
              child: const LnThumb(),
            ),
          ),
          GoldenTestScenario(
            name: 'lg / dark',
            child: themedScenario(
              dark: true,
              width: 240,
              child: const LnThumb(
                size: LnThumbSize.lg,
                hostPill: 'flutter.dev',
              ),
            ),
          ),
        ],
      ),
    );
  });
}
