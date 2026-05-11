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
      return list.map((e) => DailyMission.fromMap(e)).toList();
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

  Future<List<DailyMission>> _generateNewMissions(String dateStr) async {
    final missions = [
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
    ];

    await save(missions);
    await prefs.setString(_lastResetKey, dateStr);
    return missions;
  }
}
