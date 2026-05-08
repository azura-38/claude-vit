import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/domain/entities/season_pass.dart';

class XPEngine {
  final SharedPreferences prefs;

  XPEngine(this.prefs);

  static const _progressKey = 'season_progress_data';
  static const int xpPerLevel = 100;

  Future<UserSeasonProgress> loadProgress() async {
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return UserSeasonProgress(xp: 0, level: 0, claimedFreeRewards: [], claimedPremiumRewards: []);

    try {
      return UserSeasonProgress.fromMap(jsonDecode(jsonStr));
    } catch (_) {
      return UserSeasonProgress(xp: 0, level: 0, claimedFreeRewards: [], claimedPremiumRewards: []);
    }
  }

  Future<void> saveProgress(UserSeasonProgress progress) async {
    await prefs.setString(_progressKey, jsonEncode(progress.toMap()));
  }

  (UserSeasonProgress, bool) addXP(UserSeasonProgress current, int amount) {
    final newXP = current.xp + amount;
    final newLevel = newXP ~/ xpPerLevel;
    final leveledUp = newLevel > current.level;

    return (
      current.copyWith(
        xp: newXP,
        level: newLevel,
      ),
      leveledUp
    );
  }

  List<SeasonReward> getRewards() {
    return [
      SeasonReward(level: 1, titleKey: 'reward_doc_slots', rewardType: 'doc_slots', value: 5),
      SeasonReward(level: 5, titleKey: 'reward_doc_slots', rewardType: 'doc_slots', value: 10),
      SeasonReward(level: 10, titleKey: 'reward_doc_slots', rewardType: 'doc_slots', value: 15),
      SeasonReward(level: 20, titleKey: 'reward_doc_slots', rewardType: 'doc_slots', value: 25),
    ];
  }
}
