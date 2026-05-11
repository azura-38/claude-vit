import '../../shared/domain/entities/achievement.dart';
import '../../shared/domain/repositories/achievement_repository.dart';
import '../constants/achievement_definitions.dart';

class AchievementEngine {
  final AchievementRepository repo;

  AchievementEngine(this.repo);

  Future<List<Achievement>> load() async {
    final stored = await repo.getAll();
    final Map<String, Achievement> storedMap = {for (var a in stored) a.id: a};

    final List<Achievement> integrated =
        AchievementDefinitions.all.map((def) {
          final existing = storedMap[def.id];

          return def.copyWith(
            progress: existing?.progress ?? 0,
            unlocked: existing?.unlocked ?? false,
          );
        }).toList();

    // Save back if there are new items or schema changed
    if (stored.length != integrated.length) {
      await repo.saveAll(integrated);
    }

    return integrated;
  }

  /// Increments progress for a specific achievement.
  /// Returns the updated list and the achievement that was JUST unlocked (if any).
  Future<(List<Achievement>, Achievement?)> track(
    List<Achievement> current,
    String id,
    int? value, {
    int? setAbsolute,
  }) async {
    Achievement? newlyUnlocked;

    final updated =
        current.map((a) {
          if (a.id != id) return a;
          if (a.unlocked) return a; // Already done

          int newProgress =
              (setAbsolute != null) ? setAbsolute : (a.progress + (value ?? 0));

          // If totalSteps is null, it's a one-shot achievement (target is handled by value >= 1)
          final int target = a.totalSteps ?? 1;
          final isUnlocked = newProgress >= target;

          final updatedA = a.copyWith(
            progress: newProgress,
            unlocked: isUnlocked,
          );

          if (isUnlocked && !a.unlocked) {
            newlyUnlocked = updatedA;
          }

          return updatedA;
        }).toList();

    await repo.saveAll(updated);

    return (updated, newlyUnlocked);
  }
}
