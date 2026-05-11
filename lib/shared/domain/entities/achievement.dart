enum AchievementTier { bronze, silver, gold, platinum, special }

enum AchievementDifficulty { easy, medium, hard }

enum AchievementCategory {
  streak,
  ads,
  documents,
  medications,
  appointments,
  profile,
  emergency,
  health,
  engagement,
  premium,
  powerUser,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementTier tier;
  final AchievementDifficulty difficulty;
  final String emoji;
  final int? totalSteps;
  final int progress;
  final bool unlocked;
  final bool isHidden;
  final int xpReward;
  final AchievementCategory category;
  final Map<String, dynamic>? reward;
  final String? imagePath;

  bool get isUnlocked => unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
    required this.difficulty,
    required this.emoji,
    this.totalSteps,
    required this.progress,
    required this.unlocked,
    this.isHidden = false,
    required this.xpReward,
    required this.category,
    this.reward,
    this.imagePath,
  });

  Achievement copyWith({int? progress, bool? unlocked}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      tier: tier,
      difficulty: difficulty,
      emoji: emoji,
      totalSteps: totalSteps,
      progress: progress ?? this.progress,
      unlocked: unlocked ?? this.unlocked,
      isHidden: isHidden,
      xpReward: xpReward,
      category: category,
      reward: reward,
      imagePath: imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tier': tier.name,
      'difficulty': difficulty.name,
      'emoji': emoji,
      'totalSteps': totalSteps,
      'progress': progress,
      'unlocked': unlocked,
      'isHidden': isHidden,
      'xpReward': xpReward,
      'category': category.name,
      'reward': reward,
      'imagePath': imagePath,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      tier: AchievementTier.values.firstWhere(
        (e) => e.name == map['tier'],
        orElse: () => AchievementTier.bronze,
      ),
      difficulty: AchievementDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => AchievementDifficulty.easy,
      ),
      emoji: map['emoji'] ?? '🏆',
      totalSteps: map['totalSteps'],
      progress: map['progress'] ?? 0,
      unlocked: map['unlocked'] ?? false,
      isHidden: map['isHidden'] ?? false,
      xpReward: map['xpReward'] ?? 0,
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AchievementCategory.streak,
      ),
      reward:
          map['reward'] != null
              ? Map<String, dynamic>.from(map['reward'])
              : null,
      imagePath: map['imagePath'],
    );
  }
}
