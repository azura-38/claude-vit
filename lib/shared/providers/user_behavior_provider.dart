import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_behavior.dart';
import 'shared_prefs_provider.dart';

final userBehaviorProvider =
    NotifierProvider<UserBehaviorNotifier, UserBehavior>(
      UserBehaviorNotifier.new,
    );

class UserBehaviorNotifier extends Notifier<UserBehavior> {
  static const _key = 'user_behavior_v1';

  @override
  UserBehavior build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      try {
        return UserBehavior.fromJson(json.decode(jsonStr));
      } catch (_) {}
    }
    return UserBehavior(
      lastActiveDays: 0,
      adsWatched: 0,
      actionsCount: 0,
      lastActionTime: DateTime.now(),
    );
  }

  Future<void> _save(UserBehavior behavior) async {
    state = behavior;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, json.encode(behavior.toJson()));
  }

  void trackAction() {
    _save(
      state.copyWith(
        actionsCount: state.actionsCount + 1,
        lastActionTime: DateTime.now(),
      ),
    );
  }

  void trackAdWatched() {
    _save(state.copyWith(adsWatched: state.adsWatched + 1));
  }

  void updateActiveDays(int days) {
    _save(state.copyWith(lastActiveDays: days));
  }
}
