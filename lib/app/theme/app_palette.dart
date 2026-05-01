import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_colors.dart';

/// Brightness-aware design tokens.
///
/// Light values mirror [AppColors] exactly so existing light surfaces are
/// byte-identical. Dark values are forest-tuned: green-tinted near-black
/// surfaces + light ink + softened accent variants for sufficient contrast.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.forest,
    required this.forestSoft,
    required this.forestInk,
    required this.amber,
    required this.amberSoft,
    required this.amberInk,
    required this.slate,
    required this.slateSoft,
    required this.rose,
    required this.roseSoft,
    required this.lilac,
    required this.lilacSoft,
    required this.bg,
    required this.bgAlt,
    required this.bgSunk,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.ink5,
    required this.line,
    required this.lineStrong,
  });

  final Color forest;
  final Color forestSoft;
  final Color forestInk;
  final Color amber;
  final Color amberSoft;
  final Color amberInk;
  final Color slate;
  final Color slateSoft;
  final Color rose;
  final Color roseSoft;
  final Color lilac;
  final Color lilacSoft;
  final Color bg;
  final Color bgAlt;
  final Color bgSunk;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color ink4;
  final Color ink5;
  final Color line;
  final Color lineStrong;

  factory AppPalette.light() => const AppPalette(
    forest: AppColors.forest,
    forestSoft: AppColors.forestSoft,
    forestInk: AppColors.forestInk,
    amber: AppColors.amber,
    amberSoft: AppColors.amberSoft,
    amberInk: AppColors.amberInk,
    slate: AppColors.slate,
    slateSoft: AppColors.slateSoft,
    rose: AppColors.rose,
    roseSoft: AppColors.roseSoft,
    lilac: AppColors.lilac,
    lilacSoft: AppColors.lilacSoft,
    bg: AppColors.bg,
    bgAlt: AppColors.bgAlt,
    bgSunk: AppColors.bgSunk,
    ink: AppColors.ink,
    ink2: AppColors.ink2,
    ink3: AppColors.ink3,
    ink4: AppColors.ink4,
    ink5: AppColors.ink5,
    line: AppColors.line,
    lineStrong: AppColors.lineStrong,
  );

  factory AppPalette.dark() => const AppPalette(
    // Forest accent — brighter for contrast on dark surfaces.
    forest: Color(0xFF3FA37C),
    // Forest-tinted dark surface for selection/indicator backgrounds.
    forestSoft: Color(0xFF1B3A2D),
    // Light forest used as foreground on forestSoft dark bg.
    forestInk: Color(0xFFA8D9C0),

    // Amber — slightly muted for dark mode.
    amber: Color(0xFFD9A05E),
    amberSoft: Color(0xFF3D2E1A),
    amberInk: Color(0xFFF5DDB6),

    // Slate — inverted for tag pills (text becomes light).
    slate: Color(0xFFA9B3BF),
    slateSoft: Color(0xFF2A3340),

    // Rose / Lilac — soft variants are warm/cool dark tints.
    rose: Color(0xFFD78B85),
    roseSoft: Color(0xFF3D241F),
    lilac: Color(0xFFA294D1),
    lilacSoft: Color(0xFF2D2540),

    // Surfaces — forest-tinted near-black (not slate-blue).
    bg: Color(0xFF141A17),
    bgAlt: Color(0xFF0E1311),
    bgSunk: Color(0xFF0A0F0C),

    // Ink — light readable text on dark surfaces.
    ink: Color(0xFFE8EDE9),
    ink2: Color(0xFFB8C2BC),
    ink3: Color(0xFF8A938D),
    ink4: Color(0xFF5C645E),
    ink5: Color(0xFF3D423F),

    // Lines — subtle dark dividers.
    line: Color(0xFF1F2622),
    lineStrong: Color(0xFF2A322D),
  );

  @override
  AppPalette copyWith({
    Color? forest,
    Color? forestSoft,
    Color? forestInk,
    Color? amber,
    Color? amberSoft,
    Color? amberInk,
    Color? slate,
    Color? slateSoft,
    Color? rose,
    Color? roseSoft,
    Color? lilac,
    Color? lilacSoft,
    Color? bg,
    Color? bgAlt,
    Color? bgSunk,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? ink4,
    Color? ink5,
    Color? line,
    Color? lineStrong,
  }) {
    return AppPalette(
      forest: forest ?? this.forest,
      forestSoft: forestSoft ?? this.forestSoft,
      forestInk: forestInk ?? this.forestInk,
      amber: amber ?? this.amber,
      amberSoft: amberSoft ?? this.amberSoft,
      amberInk: amberInk ?? this.amberInk,
      slate: slate ?? this.slate,
      slateSoft: slateSoft ?? this.slateSoft,
      rose: rose ?? this.rose,
      roseSoft: roseSoft ?? this.roseSoft,
      lilac: lilac ?? this.lilac,
      lilacSoft: lilacSoft ?? this.lilacSoft,
      bg: bg ?? this.bg,
      bgAlt: bgAlt ?? this.bgAlt,
      bgSunk: bgSunk ?? this.bgSunk,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      ink4: ink4 ?? this.ink4,
      ink5: ink5 ?? this.ink5,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      forest: Color.lerp(forest, other.forest, t)!,
      forestSoft: Color.lerp(forestSoft, other.forestSoft, t)!,
      forestInk: Color.lerp(forestInk, other.forestInk, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      amberInk: Color.lerp(amberInk, other.amberInk, t)!,
      slate: Color.lerp(slate, other.slate, t)!,
      slateSoft: Color.lerp(slateSoft, other.slateSoft, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
      roseSoft: Color.lerp(roseSoft, other.roseSoft, t)!,
      lilac: Color.lerp(lilac, other.lilac, t)!,
      lilacSoft: Color.lerp(lilacSoft, other.lilacSoft, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      bgAlt: Color.lerp(bgAlt, other.bgAlt, t)!,
      bgSunk: Color.lerp(bgSunk, other.bgSunk, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      ink4: Color.lerp(ink4, other.ink4, t)!,
      ink5: Color.lerp(ink5, other.ink5, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
    );
  }
}
