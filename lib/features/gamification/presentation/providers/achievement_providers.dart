import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/achievements/achievement_celebration.dart';
import '../../../../shared/data/repositories/achievement_repository_impl.dart';
import '../../../../shared/domain/entities/achievement.dart';
import '../../../../shared/domain/repositories/achievement_repository.dart';
import '../../../../core/engine/achievement_engine.dart';
import '../../../../shared/providers/season_providers.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';
import '../../../../shared/providers/limit_providers.dart';
import '../../../../shared/providers/premium_provider.dart';
import '../../../../shared/providers/ad_skip_provider.dart';
import '../../data/services/combo_engine.dart';
import '../../../../shared/data/services/analytics_service.dart';
import 'package:go_router/go_router.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AchievementRepositoryImpl(prefs);
});

final achievementProvider =
    AsyncNotifierProvider<AchievementNotifier, List<Achievement>>(
      AchievementNotifier.new,
    );

class AchievementNotifier extends AsyncNotifier<List<Achievement>> {
  late AchievementEngine _engine;

  @override
  Future<List<Achievement>> build() async {
    final repo = ref.watch(achievementRepositoryProvider);
    _engine = AchievementEngine(repo);
    return _engine.load();
  }

  Future<void> track(String id, {int value = 1, int? setAbsolute}) async {
    if (!state.hasValue) return;

    final (updatedList, newlyUnlocked) = await _engine.track(
      state.requireValue,
      id,
      value,
      setAbsolute: setAbsolute,
    );
    state = AsyncData(updatedList);

    if (newlyUnlocked != null) {
      _applyReward(newlyUnlocked);
      _notifyUnlock(newlyUnlocked);

      // Add dynamic XP Reward from achievement
      if (newlyUnlocked.xpReward > 0) {
        ref.read(seasonProvider.notifier).addXP(newlyUnlocked.xpReward);
      }

      // Trigger Combo check
      ComboEngine.checkCombos(state.requireValue, ref);
    }
  }

  void _applyReward(Achievement achievement) {
    final reward = achievement.reward;
    if (reward == null) return;

    final type = reward['type'];
    final dynamic value = reward['value'];

    switch (type) {
      case 'doc_slots':
        if (value is int) {
          ref.read(limitProvider.notifier).increaseExtraDocs(value);
        }
        break;
      case 'premium_trial':
        if (value is int) {
          ref.read(premiumProvider.notifier).addTemporaryPremium(value);
        }
        break;
      case 'ad_skip':
        if (value is int) {
          ref.read(adSkipProvider.notifier).addTokens(value);
        }
        break;
      case 'unlimited_slots':
        // Setting an extremely high number for extra slots.
        ref.read(limitProvider.notifier).increaseExtraDocs(99999);
        break;
      case 'lifetime_premium':
        // Grant premium until the year 2099.
        ref.read(premiumProvider.notifier).addTemporaryPremium(365 * 75);
        break;
    }
  }

  final List<Achievement> _notificationQueue = [];
  bool _isShowingNotification = false;

  void _notifyUnlock(Achievement achievement) {
    AnalyticsService.log(AnalyticsService.achievementUnlocked, {
      'id': achievement.id,
      'tier': achievement.tier.name,
    });
    _notificationQueue.add(achievement);
    _showNextNotification();
  }

  void _showNextNotification() {
    if (_isShowingNotification || _notificationQueue.isEmpty) return;

    _isShowingNotification = true;
    final achievement = _notificationQueue.removeAt(0);

    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) {
      _isShowingNotification = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder:
          (context) => AchievementCelebration(
            achievement: achievement,
            onClose: () {
              context.pop();
              _isShowingNotification = false;
              // Delay next show to allow popup animation to complete
              Future.delayed(
                const Duration(milliseconds: 300),
                _showNextNotification,
              );
            },
          ),
    );
  }
}
