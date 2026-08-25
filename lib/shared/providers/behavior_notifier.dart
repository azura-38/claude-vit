import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';
import 'daily_mission_providers.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

final behaviorProvider = Provider((ref) => BehaviorNotifier(ref));

class BehaviorNotifier {
  final Ref ref;
  bool _initialized = false;

  BehaviorNotifier(this.ref);

  static const String _lastLoginKey = 'user_last_login_date';

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();

    // Update last login
    await prefs.setString(_lastLoginKey, now.toIso8601String());

    // Listen for mission changes and preferences
    _listenToMissions();
    _listenToReminderPreference();
  }

  void _listenToMissions() {
    ref.listen(dailyMissionProvider, (previous, next) {});
  }

  void _listenToReminderPreference() {
    ref.listen(engagementRemindersProvider, (previous, next) {});
  }

  void notifyLimitReached() {}
}
