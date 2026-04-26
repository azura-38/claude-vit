import 'package:flutter/material.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/achievement.dart';
import '../../presentation/providers/limit_providers.dart';
import '../../presentation/providers/shared_prefs_provider.dart';
import '../../presentation/widgets/achievements/achievement_celebration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/analytics_service.dart';

class ComboReward {
  final String id;
  final String title;
  final List<String> requiredAchievements;
  bool unlocked;

  ComboReward({
    required this.id,
    required this.title,
    required this.requiredAchievements,
    this.unlocked = false,
  });
}

class ComboEngine {
  static const String _prefKey = "unlocked_combos";

  static final List<ComboReward> combos = [
    ComboReward(
      id: "starter_combo",
      title: "🚀 Starter Health Bundle",
      requiredAchievements: ["doc_1", "login_1"], 
    ),
    ComboReward(
      id: "health_combo",
      title: "💊 Premium Medical Bundle",
      requiredAchievements: ["med_1", "health_1"],
    ),
    ComboReward(
      id: "power_combo",
      title: "⚡ Power User Bundle",
      requiredAchievements: ["doc_10", "login_7", "active_7_days"],
    ),
    ComboReward(
      id: "legend_combo",
      title: "👑 Legendary Status",
      requiredAchievements: ["login_30", "doc_50", "med_10", "health_10"],
    ),
    ComboReward(
      id: "security_combo",
      title: "🔐 Fortress Bundle",
      requiredAchievements: ["profile_completed", "emergency_complete", "security_master"],
    ),
  ];

  static Future<void> checkCombos(List<Achievement> activeAchievements, Ref ref) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final unlockedSet = prefs.getStringList(_prefKey)?.toSet() ?? {};

    final currentUnlockedIds = activeAchievements
        .where((a) => a.unlocked)
        .map((a) => a.id)
        .toSet();

    bool changed = false;

    for (var combo in combos) {
      if (unlockedSet.contains(combo.id)) continue;

      bool allDone = combo.requiredAchievements.every((id) => currentUnlockedIds.contains(id));

      if (allDone) {
        unlockedSet.add(combo.id);
        changed = true;
        _unlockCombo(combo, ref);
        AnalyticsService.log(AnalyticsService.comboUnlocked, {'combo_id': combo.id});
      }
    }

    if (changed) {
      await prefs.setStringList(_prefKey, unlockedSet.toList());
    }
  }

  static void _unlockCombo(ComboReward combo, Ref ref) {
    // Reward Logic
    int reward = 10;
    if (combo.id == "health_combo") reward = 20;
    if (combo.id == "power_combo") reward = 50;
    if (combo.id == "legend_combo") reward = 100;
    if (combo.id == "security_combo") reward = 30;

    ref.read(limitProvider.notifier).increaseExtraDocs(reward);

    // Show Custom Achievement-like Celebration
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      // Create a dummy achievement for the celebration UI to reuse it
      final comboAch = Achievement(
        id: combo.id,
        title: "COMBO: ${combo.title}",
        description: "You've unlocked a massive storage bonus by completing this achievement chain!",
        tier: AchievementTier.special,
        difficulty: AchievementDifficulty.hard,
        emoji: "🔥",
        totalSteps: 1,
        xpReward: reward * 10,
        category: AchievementCategory.engagement,
        imagePath: "assets/achievements/ach_multi_feature_user.png",
        progress: 1,
        unlocked: true,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (context) => AchievementCelebration(
          achievement: comboAch,
          onClose: () => Navigator.pop(context),
        ),
      );
    }
  }
}
