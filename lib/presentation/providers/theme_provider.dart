import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';
import '../../core/theme/app_theme.dart';

final themeTypeProvider = NotifierProvider<ThemeTypeNotifier, AppThemeType>(ThemeTypeNotifier.new);

class ThemeTypeNotifier extends Notifier<AppThemeType> {
  static const _themeKey = 'app_theme_type';

  @override
  AppThemeType build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final typeIndex = prefs.getInt(_themeKey) ?? 0;
    return AppThemeType.values[typeIndex];
  }

  void setTheme(AppThemeType type) {
    state = type;
    ref.read(sharedPreferencesProvider).setInt(_themeKey, type.index);
  }
}

// Keep themeModeProvider for system/light/dark overrides if needed, 
// but we'll primarily use themeTypeProvider for explicit selections.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final type = ref.watch(themeTypeProvider);
  if (type == AppThemeType.dark) return ThemeMode.dark;
  return ThemeMode.light;
});
