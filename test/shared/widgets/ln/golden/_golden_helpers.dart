import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_palette.dart';
import 'package:linknote/app/theme/app_theme.dart';

/// Wraps a widget in a [Theme] + tinted backdrop so light/dark scenarios
/// share visible context (background, ink) inside a single golden image.
Widget themedScenario({
  required bool dark,
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(16),
  double? width,
}) {
  final theme = dark ? AppTheme.dark : AppTheme.light;
  final palette = dark ? AppPalette.dark() : AppPalette.light();
  final body = Container(
    width: width,
    padding: padding,
    color: palette.bgAlt,
    child: child,
  );
  return Theme(data: theme, child: body);
}
