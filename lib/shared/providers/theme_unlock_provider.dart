import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';
import '../../core/theme/app_theme.dart';
import 'user_behavior_provider.dart';

class ThemeUnlockState {
  final Map<AppThemeType, DateTime> unlocked;

  ThemeUnlockState({required this.unlocked});

  bool isUnlocked(AppThemeType type) {
    if (type == AppThemeType.light || type == AppThemeType.dark) return true;
    final expiry = unlocked[type];
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  int remainingDays(AppThemeType type) {
    final expiry = unlocked[type];
    if (expiry == null) return 0;
    final diff = expiry.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inDays;
  }

  ThemeUnlockState copyWith({Map<AppThemeType, DateTime>? unlocked}) {
    return ThemeUnlockState(unlocked: unlocked ?? this.unlocked);
  }
}

class ThemeUnlockNotifier extends Notifier<ThemeUnlockState> {
  static const _unlocksKey = 'app_theme_unlocks_v2';

  @override
  ThemeUnlockState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    String? jsonStr = prefs.getString(_unlocksKey);

    // Migration: check old key if new one is missing
    jsonStr ??= prefs.getString('app_theme_unlocks');

    if (jsonStr == null || jsonStr.isEmpty) jsonStr = '{}';

    final Map<AppThemeType, DateTime> unlocked = {};
    try {
      final Map<String, dynamic> data = json.decode(jsonStr);
      data.forEach((key, value) {
        final index = int.tryParse(key);
        if (index != null && index < AppThemeType.values.length) {
          unlocked[AppThemeType.values[index]] = DateTime.parse(value);
        }
      });
    } catch (_) {}

    return ThemeUnlockState(unlocked: unlocked);
  }

  Future<void> _saveToPrefs() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final Map<String, String> data = {};
    state.unlocked.forEach((key, value) {
      data[key.index.toString()] = value.toIso8601String();
    });
    await prefs.setString(_unlocksKey, json.encode(data));
  }

  void unlock(AppThemeType type, {int days = 5}) {
    final newMap = {...state.unlocked};
    newMap[type] = DateTime.now().add(Duration(days: days));
    state = state.copyWith(unlocked: newMap);
    _saveToPrefs();

    try {
      ref.read(userBehaviorProvider.notifier).trackAdWatched();
    } catch (_) {}
  }

  void extend(AppThemeType type, {int days = 1}) {
    final newMap = {...state.unlocked};
    final current = newMap[type] ?? DateTime.now();
    newMap[type] = current.add(Duration(days: days));
    state = state.copyWith(unlocked: newMap);
    _saveToPrefs();
  }
}

final themeUnlockProvider =
    NotifierProvider<ThemeUnlockNotifier, ThemeUnlockState>(
      ThemeUnlockNotifier.new,
    );
