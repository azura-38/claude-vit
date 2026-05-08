import '../entities/achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAll();
  Future<void> saveAll(List<Achievement> list);
}
