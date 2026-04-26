import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final SharedPreferences prefs;

  AchievementRepositoryImpl(this.prefs);

  static const _key = "achievements_data";

  @override
  Future<List<Achievement>> getAll() async {
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => Achievement.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAll(List<Achievement> list) async {
    final jsonStr = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_key, jsonStr);
  }
}
