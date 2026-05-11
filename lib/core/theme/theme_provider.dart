import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

final themeTypeProvider =
    StateNotifierProvider<ThemeTypeNotifier, AppThemeType>((ref) {
      return ThemeTypeNotifier();
    });

class ThemeTypeNotifier extends StateNotifier<AppThemeType> {
  ThemeTypeNotifier() : super(AppThemeType.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_type') ?? 0;
    if (index < AppThemeType.values.length) {
      state = AppThemeType.values[index];
    }
  }

  void setTheme(AppThemeType type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_type', type.index);
  }
}

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
