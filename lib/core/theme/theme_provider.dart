import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/shared_prefs_provider.dart';
import 'app_theme.dart';

final themeControllerProvider =
    NotifierProvider<ThemeController, AppThemeType>(ThemeController.new);

final themeTypeProvider = themeControllerProvider;

class ThemeController extends Notifier<AppThemeType> {
  static const _themeKey = 'theme_type';

  @override
  AppThemeType build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final index = prefs.getInt('theme_type') ?? 0;
    if (index < AppThemeType.values.length) {
      return AppThemeType.values[index];
    }
    return AppThemeType.light;
  }

  Future<void> setTheme(AppThemeType type) async {
    state = type;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_themeKey, type.index);
  }
}

typedef ThemeTypeNotifier = ThemeController;

/// Backwards-compatible alias used in app_settings_screen and doctor_detail_screen
final themeModeProvider = Provider<ThemeMode>((ref) {
  final type = ref.watch(themeTypeProvider);
  switch (type) {
    case AppThemeType.dark:
      return ThemeMode.dark;
    default:
      return ThemeMode.light;
  }
});

