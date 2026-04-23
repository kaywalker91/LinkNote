import 'package:flutter/material.dart';

abstract final class AppShadows {
  /// Subtle card shadow (handoff: sh-1).
  static const List<BoxShadow> sh1 = [
    BoxShadow(
      color: Color(0x0A111714),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x08111714),
      blurRadius: 1,
      offset: Offset(0, 1),
    ),
  ];

  /// Raised shadow (handoff: sh-2).
  static const List<BoxShadow> sh2 = [
    BoxShadow(
      color: Color(0x0F111714),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0A111714),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Forest FAB glow (handoff: 0 4px 12px rgba(31,110,83,.28)).
  static const List<BoxShadow> fabForest = [
    BoxShadow(
      color: Color(0x471F6E53),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Bottom-sheet top rim (handoff: 0 -8px 32px rgba(0,0,0,.12)).
  static const List<BoxShadow> sheetTop = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 32,
      offset: Offset(0, -8),
    ),
  ];

  // Backward-compatible aliases
  static const List<BoxShadow> card = sh1;
  static const List<BoxShadow> elevated = sh2;

  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
}
