class LeaderboardUser {
  final String uid;
  final int xp;
  final DateTime updatedAt;

  LeaderboardUser({
    required this.uid,
    required this.xp,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LeaderboardUser.fromMap(String id, Map<String, dynamic> map) {
    return LeaderboardUser(
      uid: id,
      xp: map['xp'] ?? 0,
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get displayName => uid.length > 6 ? "${uid.substring(0, 6)}..." : uid;
}
