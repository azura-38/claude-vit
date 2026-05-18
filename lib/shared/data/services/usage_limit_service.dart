import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/shared_prefs_provider.dart';

final usageLimitServiceProvider = Provider<UsageLimitService>((ref) {
  return UsageLimitService(ref.watch(sharedPreferencesProvider));
});

class UsageLimitExceededException implements Exception {
  const UsageLimitExceededException(this.limit);

  final int limit;

  @override
  String toString() => 'Daily create limit reached ($limit).';
}

class UsageLimitResult {
  const UsageLimitResult({required this.allowed, required this.used, required this.limit});

  final bool allowed;
  final int used;
  final int limit;

  int get remaining => (limit - used).clamp(0, limit);
}

class UsageLimitService {
  UsageLimitService(this._prefs);

  final SharedPreferences _prefs;

  static const int dailyCreateLimit = 30;
  static const String _dateKey = 'usage_limit_date';
  static const String _createCountKey = 'usage_limit_create_count';

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _ensureToday() async {
    final today = _todayKey();
    final stored = _prefs.getString(_dateKey);
    if (stored == today) return;
    await _prefs.setString(_dateKey, today);
    await _prefs.setInt(_createCountKey, 0);
  }

  Future<UsageLimitResult> canCreate() async {
    await _ensureToday();
    final used = _prefs.getInt(_createCountKey) ?? 0;
    return UsageLimitResult(
      allowed: used < dailyCreateLimit,
      used: used,
      limit: dailyCreateLimit,
    );
  }

  Future<UsageLimitResult> consumeCreate() async {
    await _ensureToday();
    final current = _prefs.getInt(_createCountKey) ?? 0;
    if (current >= dailyCreateLimit) {
      return UsageLimitResult(allowed: false, used: current, limit: dailyCreateLimit);
    }
    final next = current + 1;
    await _prefs.setInt(_createCountKey, next);
    return UsageLimitResult(allowed: true, used: next, limit: dailyCreateLimit);
  }

  Future<void> resetTodayForDebug() async {
    await _prefs.remove(_dateKey);
    await _prefs.remove(_createCountKey);
  }
}
