import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

const _kThemeModeKey = 'themeMode';

@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final stored = Hive.box<String>('settings').get(_kThemeModeKey);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setThemeMode(ThemeMode mode) {
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    Hive.box<String>('settings').put(_kThemeModeKey, modeStr);
    state = mode;
  }
}

/// Convenience getter used in [LinkNoteApp].
final ThemeModeNotifierProvider themeModePro = themeModeProvider;
