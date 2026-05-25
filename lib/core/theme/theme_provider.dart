import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/user_preferences_controller.dart';
import 'app_theme.dart';
import 'theme_unlock_provider.dart';

final themeControllerProvider = NotifierProvider<ThemeController, AppThemeType>(ThemeController.new);

final themeTypeProvider = themeControllerProvider;

class ThemeController extends Notifier<AppThemeType> {
  @override
  AppThemeType build() {
    final prefs = ref.watch(userPreferencesControllerProvider);
    final rewardThemeUnlockUntil = ref.watch(themeUnlockProvider);
    final type = prefs.maybeWhen(
      data: (p) => p.themeType,
      orElse: () => AppThemeType.light,
    );

    final next = type == AppThemeType.system ? AppThemeType.light : type;
    if (next.isRewardTheme && rewardThemeUnlockUntil == null) {
      return AppThemeType.light;
    }

    return next;
  }

  Future<void> setTheme(AppThemeType type) async {
    final next = type == AppThemeType.system ? AppThemeType.light : type;
    await ref.read(userPreferencesControllerProvider.notifier).updateTheme(next);
  }
}

typedef ThemeTypeNotifier = ThemeController;

final themeModeProvider = Provider<ThemeMode>((ref) {
  final type = ref.watch(themeTypeProvider);
  switch (type) {
    case AppThemeType.dark:
      return ThemeMode.dark;
    case AppThemeType.system:
      return ThemeMode.light;
    default:
      return ThemeMode.light;
  }
});