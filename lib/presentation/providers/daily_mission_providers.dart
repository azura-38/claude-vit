import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/daily_mission.dart';
import '../../core/engine/daily_mission_engine.dart';
import '../providers/shared_prefs_provider.dart';
import '../providers/limit_providers.dart';
import '../providers/season_providers.dart';
import '../../data/services/analytics_service.dart';


final dailyMissionProvider =
    AsyncNotifierProvider<DailyMissionNotifier, List<DailyMission>>(DailyMissionNotifier.new);

class DailyMissionNotifier extends AsyncNotifier<List<DailyMission>> {
  late DailyMissionEngine _engine;

  @override
  Future<List<DailyMission>> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    _engine = DailyMissionEngine(prefs);
    return _engine.loadOrGenerate();
  }

  Future<void> track(String id) async {
    if (!state.hasValue) return;
    
    bool newlyCompleted = false;
    final updated = state.requireValue.map((m) {
      if (m.id != id || m.isCompleted) return m;

      final newProgress = m.progress + 1;
      final isDone = newProgress >= m.target;
      
      if (isDone) newlyCompleted = true;

      return m.copyWith(
        progress: newProgress,
        isCompleted: isDone,
      );
    }).toList();

    state = AsyncData(updated);
    await _engine.save(updated);

    if (newlyCompleted) {
      _applyReward(id);
      AnalyticsService.log(AnalyticsService.missionCompleted, {'mission_id': id});
      // Daily missions also contribute to XP
      ref.read(seasonProvider.notifier).addXP(15);
    }
  }

  void _applyReward(String id) {
    final limitNotifier = ref.read(limitProvider.notifier);
    
    switch (id) {
      case 'doc_daily':
        limitNotifier.increaseExtraDocs(5);
        break;
      case 'ad_daily':
        limitNotifier.increaseExtraDocs(3);
        break;
      case 'med_daily':
        limitNotifier.increaseExtraMedicine(2);
        break;
    }
  }
}
