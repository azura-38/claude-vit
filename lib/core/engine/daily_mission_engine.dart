import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/domain/entities/daily_mission.dart';

class DailyMissionEngine {
  final SharedPreferences prefs;

  DailyMissionEngine(this.prefs);

  static const _missionKey = 'daily_missions_data';
  static const _lastResetKey = 'daily_mission_last_reset';

  Future<List<DailyMission>> loadOrGenerate() async {
    final lastReset = prefs.getString(_lastResetKey);
    final today = _getTodayString();

    if (lastReset != today) {
      return _generateNewMissions(today);
    }

    final jsonStr = prefs.getString(_missionKey);
    if (jsonStr == null) return _generateNewMissions(today);

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      final loaded = list.map((e) => DailyMission.fromMap(e)).toList();
      return _ensureCurrentMissionSet(loaded, today);
    } catch (_) {
      return _generateNewMissions(today);
    }
  }

  Future<void> save(List<DailyMission> missions) async {
    final jsonStr = jsonEncode(missions.map((e) => e.toMap()).toList());
    await prefs.setString(_missionKey, jsonStr);
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<List<DailyMission>> _ensureCurrentMissionSet(List<DailyMission> loaded, String dateStr) async {
    final current = List<DailyMission>.from(loaded);
    final ids = current.map((m) => m.id).toSet();
    bool changed = false;

    for (final mission in _baseMissions()) {
      if (!ids.contains(mission.id)) {
        current.add(mission);
        changed = true;
      }
    }

    if (changed) {
      await save(current);
      await prefs.setString(_lastResetKey, dateStr);
    }

    return current;
  }

  Future<List<DailyMission>> _generateNewMissions(String dateStr) async {
    final missions = _baseMissions();
    await save(missions);
    await prefs.setString(_lastResetKey, dateStr);
    return missions;
  }

  List<DailyMission> _baseMissions() => const [
        DailyMission(
          id: 'doc_daily',
          title: 'mission_doc_daily',
          target: 1,
          progress: 0,
          isCompleted: false,
        ),
        DailyMission(
          id: 'app_daily',
          title: 'mission_app_daily',
          target: 1,
          progress: 0,
          isCompleted: false,
        ),
        DailyMission(
          id: 'med_daily',
          title: 'mission_med_daily',
          target: 1,
          progress: 0,
          isCompleted: false,
        ),
        DailyMission(
          id: 'health_daily',
          title: 'mission_health_daily',
          target: 1,
          progress: 0,
          isCompleted: false,
        ),
      ];
}
