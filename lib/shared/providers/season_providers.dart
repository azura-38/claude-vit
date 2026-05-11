import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/season_pass.dart';
import '../../core/engine/xp_engine.dart';
import 'shared_prefs_provider.dart';
import 'limit_providers.dart';
import '../../core/utils/uid_manager.dart';
import '../data/repositories/leaderboard_repository_impl.dart';
import '../data/services/analytics_service.dart';
import '../../core/config/app_config.dart';

final seasonProvider =
    AsyncNotifierProvider<SeasonNotifier, UserSeasonProgress>(
      SeasonNotifier.new,
    );

class SeasonNotifier extends AsyncNotifier<UserSeasonProgress> {
  late XPEngine _engine;
  final _leaderboardRepo = LeaderboardRepository();

  @override
  Future<UserSeasonProgress> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    _engine = XPEngine(prefs);
    return _engine.loadProgress();
  }

  Future<void> addXP(int amount) async {
    if (!state.hasValue) return;

    final (updated, leveledUp) = _engine.addXP(state.requireValue, amount);
    state = AsyncData(updated);
    await _engine.saveProgress(updated);

    // Sync with Global Leaderboard if enabled
    if (AppConfig.isLeaderboardEnabled) {
      final uid = await UIDManager.getUID();
      _leaderboardRepo.syncXP(uid, updated.xp);
    }

    if (leveledUp) {
      AnalyticsService.log(AnalyticsService.seasonLevelUp, {
        'level': updated.level,
      });
    }
  }

  Future<void> claimReward(SeasonReward reward) async {
    if (!state.hasValue || reward.isPremiumOnly) return;

    final curState = state.requireValue;

    final alreadyClaimed =
        reward.isPremiumOnly
            ? curState.claimedPremiumRewards.contains(reward.level)
            : curState.claimedFreeRewards.contains(reward.level);

    if (alreadyClaimed || curState.level < reward.level) return;

    // Apply Reward Logic
    _applySeasonReward(reward);

    // Update State
    if (reward.isPremiumOnly) {
      state = AsyncData(
        curState.copyWith(
          claimedPremiumRewards: [
            ...curState.claimedPremiumRewards,
            reward.level,
          ],
        ),
      );
    } else {
      state = AsyncData(
        curState.copyWith(
          claimedFreeRewards: [...curState.claimedFreeRewards, reward.level],
        ),
      );
    }

    await _engine.saveProgress(state.requireValue);
  }

  void _applySeasonReward(SeasonReward reward) {
    final limitNotifier = ref.read(limitProvider.notifier);

    switch (reward.rewardType) {
      case 'doc_slots':
        limitNotifier.increaseExtraDocs(reward.value);
        break;
    }
  }

  List<SeasonReward> getAvailableRewards() => _engine.getRewards();
}
