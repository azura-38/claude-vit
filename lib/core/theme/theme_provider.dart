import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/user_preferences_controller.dart';
import 'app_theme.dart';

final themeControllerProvider =
    NotifierProvider<ThemeController, AppThemeType>(ThemeController.new);

final themeTypeProvider = themeControllerProvider;

class ThemeController extends Notifier<AppThemeType> {
  @override
  AppThemeType build() {
    final prefs = ref.watch(userPreferencesControllerProvider);
    return prefs.maybeWhen(
      data: (p) => p.themeType,
      orElse: () => AppThemeType.system,
    );
  }

  Future<void> setTheme(AppThemeType type) async {
    await ref.read(userPreferencesControllerProvider.notifier).updateTheme(type);
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

