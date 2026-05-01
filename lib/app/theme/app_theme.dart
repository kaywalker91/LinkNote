import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_palette.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/app/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final palette = AppPalette.light();
    return _build(
      palette: palette,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.forest,
        primary: palette.forest,
        onPrimary: Colors.white,
        surface: palette.bg,
        onSurface: palette.ink,
        error: AppColors.error,
      ),
      navBarIndicator: palette.forestSoft,
      navBarSelectedIcon: palette.forest,
      snackBarBackground: palette.ink,
      snackBarForeground: palette.bg,
    );
  }

  static ThemeData get dark {
    final palette = AppPalette.dark();
    return _build(
      brightness: Brightness.dark,
      palette: palette,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.forest,
        brightness: Brightness.dark,
        primary: palette.forest,
        onPrimary: Colors.white,
        surface: palette.bg,
        onSurface: palette.ink,
        error: AppColors.error,
      ),
      // Soft forest tint for dark indicator (forestSoft is already dark in dark
      // palette so we use it directly without an alpha overlay).
      navBarIndicator: palette.forestSoft,
      navBarSelectedIcon: palette.forestInk,
      snackBarBackground: palette.bgSunk,
      snackBarForeground: palette.ink,
    );
  }

  static ThemeData _build({
    required AppPalette palette,
    required ColorScheme colorScheme,
    required Color navBarIndicator,
    required Color navBarSelectedIcon,
    required Color snackBarBackground,
    required Color snackBarForeground,
    Brightness brightness = Brightness.light,
  }) {
    final textTheme =
        GoogleFonts.interTextTheme(
          ThemeData(brightness: brightness).textTheme,
        ).copyWith(
          displayLarge: AppTextStyles.displaySans,
          displayMedium: AppTextStyles.displaySerif,
          headlineLarge: AppTextStyles.heading1,
          headlineMedium: AppTextStyles.heading2,
          headlineSmall: AppTextStyles.heading3,
          titleLarge: AppTextStyles.titleL,
          titleMedium: AppTextStyles.titleM,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.label,
          labelMedium: AppTextStyles.caption,
          labelSmall: AppTextStyles.caption,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.bgAlt,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.bg,
        foregroundColor: palette.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleL.copyWith(color: palette.ink),
      ),
      cardTheme: CardThemeData(
        color: palette.bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: palette.line,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: palette.lineStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: palette.lineStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: palette.forest,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.forest,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.bg,
        indicatorColor: navBarIndicator,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: navBarSelectedIcon);
          }
          return IconThemeData(color: palette.ink4);
        }),
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.bgSunk,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: palette.line),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.forest,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.fab),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarBackground,
        contentTextStyle: TextStyle(color: snackBarForeground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
