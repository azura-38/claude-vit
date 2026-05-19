import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/daily_mission_engine.dart';
import '../../features/gamification/presentation/providers/achievement_providers.dart';
import '../data/services/analytics_service.dart';
import '../domain/entities/daily_mission.dart';
import 'limit_providers.dart';
import 'season_providers.dart';
import 'shared_prefs_provider.dart';

final dailyMissionProvider = AsyncNotifierProvider<DailyMissionNotifier, List<DailyMission>>(
  DailyMissionNotifier.new,
);

class DailyMissionNotifier extends AsyncNotifier<List<DailyMission>> {
  static const _dailyMasterCountKey = 'achievement_daily_master_count';

  late DailyMissionEngine _engine;

  @override
  Future<List<DailyMission>> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    _engine = DailyMissionEngine(prefs);
    return _engine.loadOrGenerate();
  }

  Future<void> track(String id) async {
    final current = state.valueOrNull ?? await future;

    bool newlyCompleted = false;
    final updated = current.map((m) {
      if (m.id != id || m.isCompleted) return m;

      final newProgress = m.progress + 1;
      final isDone = newProgress >= m.target;
      if (isDone) newlyCompleted = true;

      return m.copyWith(progress: newProgress, isCompleted: isDone);
    }).toList();

    state = AsyncData(updated);
    await _engine.save(updated);

    if (newlyCompleted) {
      _applyReward(id);
      AnalyticsService.log(AnalyticsService.missionCompleted, {'mission_id': id});
      await ref.read(seasonProvider.notifier).addXP(15);
      await _trackDailyMaster();
    }
  }

  Future<void> _trackDailyMaster() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final nextCount = (prefs.getInt(_dailyMasterCountKey) ?? 0) + 1;
    await prefs.setInt(_dailyMasterCountKey, nextCount);
    await ref.read(achievementProvider.notifier).track('daily_master', setAbsolute: nextCount);
  }

  void _applyReward(String id) {
    final limitNotifier = ref.read(limitProvider.notifier);

    switch (id) {
      case 'doc_daily':
        limitNotifier.increaseExtraDocs(5);
        break;
      case 'app_daily':
        limitNotifier.increaseExtraDocs(2);
        break;
      case 'med_daily':
        limitNotifier.increaseExtraMedicine(2);
        break;
      case 'health_daily':
        limitNotifier.increaseExtraDocs(1);
        break;
    }
  }
}
