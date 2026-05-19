import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/engine/xp_engine.dart';
import '../../core/utils/uid_manager.dart';
import '../data/repositories/leaderboard_repository_impl.dart';
import '../data/services/analytics_service.dart';
import '../domain/entities/season_pass.dart';
import 'ad_skip_provider.dart';
import 'limit_providers.dart';
import 'shared_prefs_provider.dart';

final seasonProvider = AsyncNotifierProvider<SeasonNotifier, UserSeasonProgress>(
  SeasonNotifier.new,
);

class SeasonNotifier extends AsyncNotifier<UserSeasonProgress> {
  static const _lastAdSkipXpMilestoneKey = 'last_ad_skip_xp_milestone';

  late XPEngine _engine;
  final _leaderboardRepo = LeaderboardRepository();

  @override
  Future<UserSeasonProgress> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    _engine = XPEngine(prefs);
    return _engine.loadProgress();
  }

  Future<void> addXP(int amount) async {
    final current = state.valueOrNull ?? await future;

    final (updated, leveledUp) = _engine.addXP(current, amount);
    state = AsyncData(updated);
    await _engine.saveProgress(updated);
    await _grantAdSkipTokensForXp(updated.xp);

    if (AppConfig.isLeaderboardEnabled) {
      final uid = await UIDManager.getUID();
      _leaderboardRepo.syncXP(uid, updated.xp);
    }

    if (leveledUp) {
      AnalyticsService.log(AnalyticsService.seasonLevelUp, {'level': updated.level});
    }
  }

  Future<void> _grantAdSkipTokensForXp(int totalXp) async {
    if (!AppConfig.adSkipRewardsEnabled) return;
    if (AppConfig.xpPerAdSkipToken <= 0) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final currentMilestone = totalXp ~/ AppConfig.xpPerAdSkipToken;
    final lastMilestone = prefs.getInt(_lastAdSkipXpMilestoneKey) ?? 0;
    final tokensToGrant = currentMilestone - lastMilestone;
    if (tokensToGrant <= 0) return;

    await ref.read(adSkipProvider.notifier).addTokens(tokensToGrant, source: 'xp_milestone');
    await prefs.setInt(_lastAdSkipXpMilestoneKey, currentMilestone);
    AnalyticsService.log('xp_ad_skip_token_granted', {
      'total_xp': totalXp,
      'tokens': tokensToGrant,
      'milestone': currentMilestone,
    });
  }

  Future<void> claimReward(SeasonReward reward) async {
    final curState = state.valueOrNull ?? await future;
    if (reward.isPremiumOnly) return;

    final alreadyClaimed = reward.isPremiumOnly
        ? curState.claimedPremiumRewards.contains(reward.level)
        : curState.claimedFreeRewards.contains(reward.level);

    if (alreadyClaimed || curState.level < reward.level) return;

    _applySeasonReward(reward);

    if (reward.isPremiumOnly) {
      state = AsyncData(
        curState.copyWith(
          claimedPremiumRewards: [...curState.claimedPremiumRewards, reward.level],
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
