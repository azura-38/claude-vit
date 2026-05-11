import 'dart:convert';

class AIUserProfile {
  int adsWatched;
  int appOpens;
  int actions;
  int sessions;
  int paywallClicks;
  DateTime? creationDate;

  AIUserProfile({
    this.adsWatched = 0,
    this.appOpens = 0,
    this.actions = 0,
    this.sessions = 0,
    this.paywallClicks = 0,
    this.creationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'adsWatched': adsWatched,
      'appOpens': appOpens,
      'actions': actions,
      'sessions': sessions,
      'paywallClicks': paywallClicks,
      'creationDate': creationDate?.toIso8601String(),
    };
  }

  factory AIUserProfile.fromMap(Map<String, dynamic> map) {
    return AIUserProfile(
      adsWatched: map['adsWatched'] ?? 0,
      appOpens: map['appOpens'] ?? 0,
      actions: map['actions'] ?? 0,
      sessions: map['sessions'] ?? 0,
      paywallClicks: map['paywallClicks'] ?? 0,
      creationDate:
          map['creationDate'] != null
              ? DateTime.tryParse(map['creationDate'])
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AIUserProfile.fromJson(String source) =>
      AIUserProfile.fromMap(json.decode(source));
}
