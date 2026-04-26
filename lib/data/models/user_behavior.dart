class UserBehavior {
  final int lastActiveDays;
  final int adsWatched;
  final int actionsCount;
  final DateTime lastActionTime;

  UserBehavior({
    required this.lastActiveDays,
    required this.adsWatched,
    required this.actionsCount,
    required this.lastActionTime,
  });

  Map<String, dynamic> toJson() => {
        'lastActiveDays': lastActiveDays,
        'adsWatched': adsWatched,
        'actionsCount': actionsCount,
        'lastActionTime': lastActionTime.toIso8601String(),
      };

  factory UserBehavior.fromJson(Map<String, dynamic> json) {
    return UserBehavior(
      lastActiveDays: json['lastActiveDays'] as int? ?? 0,
      adsWatched: json['adsWatched'] as int? ?? 0,
      actionsCount: json['actionsCount'] as int? ?? 0,
      lastActionTime: json['lastActionTime'] != null
          ? DateTime.parse(json['lastActionTime'] as String)
          : DateTime.now(),
    );
  }

  UserBehavior copyWith({
    int? lastActiveDays,
    int? adsWatched,
    int? actionsCount,
    DateTime? lastActionTime,
  }) {
    return UserBehavior(
      lastActiveDays: lastActiveDays ?? this.lastActiveDays,
      adsWatched: adsWatched ?? this.adsWatched,
      actionsCount: actionsCount ?? this.actionsCount,
      lastActionTime: lastActionTime ?? this.lastActionTime,
    );
  }
}
