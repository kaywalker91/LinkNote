import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_palette.dart';
import 'package:linknote/app/theme/app_theme.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Disable runtime font fetching so AppTheme builders don't hit the network
  // (asset/cached fonts are used; fallback to platform font on miss).
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppPalette', () {
    test('light factory mirrors AppColors exactly (light regression zero)', () {
      final p = AppPalette.light();
      expect(p.forest, AppColors.forest);
      expect(p.forestSoft, AppColors.forestSoft);
      expect(p.forestInk, AppColors.forestInk);
      expect(p.amber, AppColors.amber);
      expect(p.amberSoft, AppColors.amberSoft);
      expect(p.amberInk, AppColors.amberInk);
      expect(p.bg, AppColors.bg);
      expect(p.bgAlt, AppColors.bgAlt);
      expect(p.bgSunk, AppColors.bgSunk);
      expect(p.ink, AppColors.ink);
      expect(p.ink2, AppColors.ink2);
      expect(p.ink3, AppColors.ink3);
      expect(p.ink4, AppColors.ink4);
      expect(p.ink5, AppColors.ink5);
      expect(p.line, AppColors.line);
      expect(p.lineStrong, AppColors.lineStrong);
    });

    test('dark factory differs from light on every surface/ink token', () {
      final light = AppPalette.light();
      final dark = AppPalette.dark();
      // Surfaces and ink must invert; if any matches, dark mode is broken.
      expect(dark.bg, isNot(light.bg));
      expect(dark.bgAlt, isNot(light.bgAlt));
      expect(dark.bgSunk, isNot(light.bgSunk));
      expect(dark.ink, isNot(light.ink));
      expect(dark.ink2, isNot(light.ink2));
      expect(dark.ink3, isNot(light.ink3));
      expect(dark.line, isNot(light.line));
      expect(dark.lineStrong, isNot(light.lineStrong));
    });

    test('lerp interpolates between palettes', () {
      final light = AppPalette.light();
      final dark = AppPalette.dark();
      final mid = light.lerp(dark, 0.5);
      expect(mid.bg, isNot(light.bg));
      expect(mid.bg, isNot(dark.bg));
    });

    test('copyWith overrides only specified field', () {
      final p = AppPalette.light();
      final copy = p.copyWith(bg: const Color(0xFF000000));
      expect(copy.bg, const Color(0xFF000000));
      expect(copy.ink, p.ink);
    });
  });

  group('AppTheme palette wiring', () {
    testWidgets('light theme registers AppPalette.light', (tester) async {
      final ext = AppTheme.light.extension<AppPalette>();
      expect(ext, isNotNull);
      expect(ext!.bg, AppColors.bg);
    });

    testWidgets('dark theme registers AppPalette.dark', (tester) async {
      final ext = AppTheme.dark.extension<AppPalette>();
      expect(ext, isNotNull);
      expect(ext!.bg, isNot(AppColors.bg));
      expect(ext.ink, isNot(AppColors.ink));
    });

    testWidgets('dark theme primary stays forest-tuned', (tester) async {
      final ext = AppTheme.dark.extension<AppPalette>()!;
      // Forest is brighter in dark (luminance > light forest).
      expect(
        ext.forest.computeLuminance(),
        greaterThan(AppColors.forest.computeLuminance()),
      );
    });
  });

  group('context.palette', () {
    testWidgets('returns dark palette inside dark theme', (tester) async {
      late AppPalette captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (c) {
              captured = c.palette;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured.bg, AppPalette.dark().bg);
      expect(captured.ink, AppPalette.dark().ink);
    });

    testWidgets('returns light palette inside light theme', (tester) async {
      late AppPalette captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (c) {
              captured = c.palette;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured.bg, AppColors.bg);
    });

    testWidgets(
      'falls back to light palette when extension is missing',
      (tester) async {
        late AppPalette captured;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (c) {
                captured = c.palette;
                return const SizedBox();
              },
            ),
          ),
        );
        expect(captured.bg, AppColors.bg);
      },
    );
  });
}
