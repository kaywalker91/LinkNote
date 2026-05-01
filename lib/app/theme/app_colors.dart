import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand — forest (primary accent)
  static const Color forest = Color(0xFF1F6E53);
  static const Color forestInk = Color(0xFF134433);
  static const Color forestSoft = Color(0xFFE8F1EC);

  // Accent — amber (favorite / memo highlight)
  static const Color amber = Color(0xFFC8863E);
  static const Color amberSoft = Color(0xFFFBF1DF);
  static const Color amberInk = Color(0xFF6B4319);

  // Accent — slate (tech tag)
  static const Color slate = Color(0xFF2E3A47);
  static const Color slateSoft = Color(0xFFEBEEF1);

  // Accent — rose (design tag / notification)
  static const Color rose = Color(0xFFB85450);
  static const Color roseSoft = Color(0xFFF6E5E3);

  // Accent — lilac (AI / tool tag)
  static const Color lilac = Color(0xFF7A6AA8);
  static const Color lilacSoft = Color(0xFFEEE8F5);

  // Surfaces
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgAlt = Color(0xFFFAFAF7);
  static const Color bgSunk = Color(0xFFF4F4EF);

  // Ink (text)
  static const Color ink = Color(0xFF111714);
  static const Color ink2 = Color(0xFF3D453F);
  static const Color ink3 = Color(0xFF6F7671);
  static const Color ink4 = Color(0xFFA5ABA7);
  static const Color ink5 = Color(0xFFCDD1CD);

  // Lines
  static const Color line = Color(0xFFEEEEE9);
  static const Color lineStrong = Color(0xFFE2E2DB);

  // Primary aliases (backward compat)
  static const Color primary = forest;
  static const Color primaryLight = forestSoft;
  static const Color primaryDark = forestInk;

  // Surface aliases (backward compat — previous palette used surface/surfaceVariant/background)
  static const Color surface = bg;
  static const Color surfaceVariant = bgAlt;
  static const Color background = bgAlt;

  // Text aliases (backward compat)
  static const Color textPrimary = ink;
  static const Color textSecondary = ink3;
  static const Color textHint = ink4;

  // Border aliases (backward compat)
  static const Color border = lineStrong;
  static const Color borderLight = line;

  // Semantic (kept from prior palette; handoff uses rose as destructive accent in UI)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = amber;
  static const Color error = rose;
  static const Color info = Color(0xFF3B82F6);

  // Hex strings (persisted in entities like TagEntity.color)
  static const String defaultTagColorHex = '#1F6E53'; // forest
}
