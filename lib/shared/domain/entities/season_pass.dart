import 'package:flutter/material.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class SeasonReward {
  final int level;
  final String titleKey;
  final String rewardType; // 'doc_slots', 'premium_days', 'ad_free_hours'
  final int value;
  final bool isPremiumOnly;

  SeasonReward({
    required this.level,
    required this.titleKey,
    required this.rewardType,
    required this.value,
    this.isPremiumOnly = false,
  });

  String localizedTitle(BuildContext context) {
    return context.tr(titleKey, extra: {'value': value.toString()});
  }
}

class UserSeasonProgress {
  final int xp;
  final int level;
  final List<int> claimedFreeRewards;
  final List<int> claimedPremiumRewards;

  UserSeasonProgress({
    required this.xp,
    required this.level,
    required this.claimedFreeRewards,
    required this.claimedPremiumRewards,
  });

  UserSeasonProgress copyWith({
    int? xp,
    int? level,
    List<int>? claimedFreeRewards,
    List<int>? claimedPremiumRewards,
  }) {
    return UserSeasonProgress(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      claimedFreeRewards: claimedFreeRewards ?? this.claimedFreeRewards,
      claimedPremiumRewards:
          claimedPremiumRewards ?? this.claimedPremiumRewards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'level': level,
      'claimedFreeRewards': claimedFreeRewards,
      'claimedPremiumRewards': claimedPremiumRewards,
    };
  }

  factory UserSeasonProgress.fromMap(Map<String, dynamic> map) {
    return UserSeasonProgress(
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 0,
      claimedFreeRewards: List<int>.from(map['claimedFreeRewards'] ?? []),
      claimedPremiumRewards: List<int>.from(map['claimedPremiumRewards'] ?? []),
    );
  }
}
