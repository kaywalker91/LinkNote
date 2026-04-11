import 'package:flutter/material.dart';
import 'package:linknote/shared/widgets/app_snack_bar.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  void showSuccessSnackBar(String message) =>
      AppSnackBar.show(this, message: message, type: SnackBarType.success);

  void showErrorSnackBar(String message) =>
      AppSnackBar.show(this, message: message, type: SnackBarType.error);

  void showInfoSnackBar(String message) =>
      AppSnackBar.show(this, message: message);
}
