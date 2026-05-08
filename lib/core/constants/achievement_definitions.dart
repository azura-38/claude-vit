import '../../shared/domain/entities/achievement.dart';

class AchievementDefinitions {
  static List<Achievement> get all => [
        // 📅 STREAK (Seri)
        _ach("login_1", AchievementTier.bronze, AchievementDifficulty.easy, "🔥", category: AchievementCategory.streak, target: 1, xp: 50),
        _ach("login_3", AchievementTier.bronze, AchievementDifficulty.easy, "🌱", category: AchievementCategory.streak, target: 3, xp: 70),
        _ach("login_7", AchievementTier.bronze, AchievementDifficulty.easy, "🌿", category: AchievementCategory.streak, target: 7, xp: 110),
        _ach("login_14", AchievementTier.silver, AchievementDifficulty.medium, "🌲", category: AchievementCategory.streak, target: 14, xp: 270),
        _ach("login_30", AchievementTier.silver, AchievementDifficulty.medium, "⚡", category: AchievementCategory.streak, target: 30, xp: 510),
        _ach("login_60", AchievementTier.gold, AchievementDifficulty.hard, "💫", category: AchievementCategory.streak, target: 60, xp: 1920),
        _ach("login_100", AchievementTier.gold, AchievementDifficulty.hard, "🌟", category: AchievementCategory.streak, target: 100, xp: 3120),
        _ach("login_200", AchievementTier.platinum, AchievementDifficulty.hard, "👑", category: AchievementCategory.streak, target: 200, xp: 5000),
        _ach("login_365", AchievementTier.platinum, AchievementDifficulty.hard, "🦄", category: AchievementCategory.streak, target: 365, xp: 5000),

        // 📺 ADS (Reklam)
        _ach("ads_1", AchievementTier.bronze, AchievementDifficulty.easy, "📺", category: AchievementCategory.ads, target: 1, xp: 50),
        _ach("ads_5", AchievementTier.bronze, AchievementDifficulty.easy, "🍿", category: AchievementCategory.ads, target: 5, xp: 90),
        _ach("ads_15", AchievementTier.silver, AchievementDifficulty.medium, "🎬", category: AchievementCategory.ads, target: 15, xp: 290),
        _ach("ads_30", AchievementTier.silver, AchievementDifficulty.medium, "🪙", category: AchievementCategory.ads, target: 30, xp: 510),
        _ach("ads_50", AchievementTier.gold, AchievementDifficulty.hard, "💸", category: AchievementCategory.ads, target: 50, xp: 1620),
        _ach("ads_100", AchievementTier.gold, AchievementDifficulty.hard, "💰", category: AchievementCategory.ads, target: 100, xp: 3120),
        _ach("ads_250", AchievementTier.platinum, AchievementDifficulty.hard, "🤑", category: AchievementCategory.ads, target: 250, xp: 5000),
        _ach("ads_500", AchievementTier.platinum, AchievementDifficulty.hard, "💎", category: AchievementCategory.ads, target: 500, xp: 5000),

        // 📄 DOCUMENTS (Belgeler)
        _ach("doc_1", AchievementTier.bronze, AchievementDifficulty.easy, "📄", category: AchievementCategory.documents, target: 1, xp: 50),
        _ach("doc_5", AchievementTier.bronze, AchievementDifficulty.easy, "📁", category: AchievementCategory.documents, target: 5, xp: 90),
        _ach("doc_10", AchievementTier.bronze, AchievementDifficulty.medium, "📂", category: AchievementCategory.documents, target: 10, xp: 210),
        _ach("doc_25", AchievementTier.silver, AchievementDifficulty.medium, "🗂️", category: AchievementCategory.documents, target: 25, xp: 440),
        _ach("doc_50", AchievementTier.gold, AchievementDifficulty.hard, "📚", category: AchievementCategory.documents, target: 50, xp: 1620),
        _ach("doc_100", AchievementTier.gold, AchievementDifficulty.hard, "🗄️", category: AchievementCategory.documents, target: 100, xp: 3120),
        _ach("doc_250", AchievementTier.platinum, AchievementDifficulty.hard, "🧠", category: AchievementCategory.documents, target: 250, xp: 5000),
        _ach("doc_500", AchievementTier.platinum, AchievementDifficulty.hard, "🏛️", category: AchievementCategory.documents, target: 500, xp: 5000),

        // 💊 MEDICATIONS (İlaçlar)
        _ach("med_1", AchievementTier.bronze, AchievementDifficulty.easy, "💊", category: AchievementCategory.medications, target: 1, xp: 50),
        _ach("med_3", AchievementTier.bronze, AchievementDifficulty.easy, "💧", category: AchievementCategory.medications, target: 3, xp: 70),
        _ach("med_5", AchievementTier.bronze, AchievementDifficulty.easy, "🩺", category: AchievementCategory.medications, target: 5, xp: 90),
        _ach("med_10", AchievementTier.silver, AchievementDifficulty.medium, "🩸", category: AchievementCategory.medications, target: 10, xp: 210),
        _ach("med_25", AchievementTier.silver, AchievementDifficulty.medium, "🧪", category: AchievementCategory.medications, target: 25, xp: 440),
        _ach("med_50", AchievementTier.gold, AchievementDifficulty.hard, "🧬", category: AchievementCategory.medications, target: 50, xp: 1620),

        // 📅 APPOINTMENTS (Randevular)
        _ach("app_1", AchievementTier.bronze, AchievementDifficulty.easy, "📅", category: AchievementCategory.appointments, target: 1, xp: 50),
        _ach("app_3", AchievementTier.bronze, AchievementDifficulty.easy, "🗓️", category: AchievementCategory.appointments, target: 3, xp: 70),
        _ach("app_5", AchievementTier.bronze, AchievementDifficulty.easy, "⏰", category: AchievementCategory.appointments, target: 5, xp: 90),
        _ach("app_10", AchievementTier.silver, AchievementDifficulty.medium, "⏱️", category: AchievementCategory.appointments, target: 10, xp: 210),
        _ach("app_20", AchievementTier.silver, AchievementDifficulty.medium, "🚀", category: AchievementCategory.appointments, target: 20, xp: 440),
        _ach("app_30", AchievementTier.gold, AchievementDifficulty.hard, "🛸", category: AchievementCategory.appointments, target: 30, xp: 1620),

        // 👤 PROFILE (Profil)
        _ach("profile_created", AchievementTier.bronze, AchievementDifficulty.easy, "👶", category: AchievementCategory.profile, target: 1, xp: 50),
        _ach("profile_completed", AchievementTier.bronze, AchievementDifficulty.easy, "👦", category: AchievementCategory.profile, target: 1, xp: 50),
        _ach("profile_updated", AchievementTier.bronze, AchievementDifficulty.easy, "👨", category: AchievementCategory.profile, target: 1, xp: 50),
        _ach("profile_with_photo", AchievementTier.silver, AchievementDifficulty.medium, "📸", category: AchievementCategory.profile, target: 1, xp: 70),
        _ach("profile_master", AchievementTier.special, AchievementDifficulty.hard, "🦸‍♂️", category: AchievementCategory.profile, target: 1, xp: 1000),

        // 🚑 EMERGENCY (Acil Durum)
        _ach("emergency_added", AchievementTier.bronze, AchievementDifficulty.easy, "🚨", category: AchievementCategory.emergency, target: 1, xp: 50),
        _ach("emergency_contact", AchievementTier.bronze, AchievementDifficulty.easy, "📞", category: AchievementCategory.emergency, target: 1, xp: 50),
        _ach("emergency_complete", AchievementTier.bronze, AchievementDifficulty.easy, "🛡️", category: AchievementCategory.emergency, target: 1, xp: 50),
        _ach("emergency_ready", AchievementTier.silver, AchievementDifficulty.medium, "🆘", category: AchievementCategory.emergency, target: 1, xp: 70),
        _ach("emergency_master", AchievementTier.special, AchievementDifficulty.hard, "🚑", category: AchievementCategory.emergency, target: 1, xp: 1000),

        // 🩺 HEALTH (Sağlık)
        _ach("health_1", AchievementTier.bronze, AchievementDifficulty.easy, "🍎", category: AchievementCategory.health, target: 1, xp: 50),
        _ach("health_5", AchievementTier.bronze, AchievementDifficulty.easy, "🥦", category: AchievementCategory.health, target: 5, xp: 90),
        _ach("health_10", AchievementTier.silver, AchievementDifficulty.medium, "💪", category: AchievementCategory.health, target: 10, xp: 210),
        _ach("health_20", AchievementTier.silver, AchievementDifficulty.medium, "🏃‍♂️", category: AchievementCategory.health, target: 20, xp: 440),
        _ach("health_50", AchievementTier.gold, AchievementDifficulty.hard, "🧘‍♀️", category: AchievementCategory.health, target: 50, xp: 1620),
        _ach("health_master", AchievementTier.special, AchievementDifficulty.hard, "💖", category: AchievementCategory.health, target: 1, xp: 1000),

        // ⭐ ENGAGEMENT (Genel Etkileşim)
        _ach("first_login", AchievementTier.bronze, AchievementDifficulty.easy, "👋", category: AchievementCategory.engagement, target: 1, xp: 50),
        _ach("first_upload", AchievementTier.bronze, AchievementDifficulty.easy, "🌍", category: AchievementCategory.engagement, target: 1, xp: 50),
        _ach("first_ad", AchievementTier.bronze, AchievementDifficulty.easy, "🎈", category: AchievementCategory.engagement, target: 1, xp: 50),
        _ach("first_premium", AchievementTier.platinum, AchievementDifficulty.hard, "🎟️", category: AchievementCategory.engagement, target: 1, xp: 1000),
        _ach("active_3_days", AchievementTier.bronze, AchievementDifficulty.easy, "🔋", category: AchievementCategory.engagement, target: 3, xp: 70),
        _ach("active_7_days", AchievementTier.silver, AchievementDifficulty.medium, "🔌", category: AchievementCategory.engagement, target: 7, xp: 210),
        _ach("active_30_days", AchievementTier.gold, AchievementDifficulty.hard, "💡", category: AchievementCategory.engagement, target: 30, xp: 1620),

        // 🎁 SPECIAL (Seri kurtarma)
        _ach("streak_saved", AchievementTier.bronze, AchievementDifficulty.easy, "🛟", category: AchievementCategory.streak, target: 1, xp: 100),
        _ach("streak_saved_5", AchievementTier.silver, AchievementDifficulty.medium, "🛡️", category: AchievementCategory.streak, target: 5, xp: 300),
        _ach("streak_saved_10", AchievementTier.gold, AchievementDifficulty.hard, "🦾", category: AchievementCategory.streak, target: 10, xp: 1000),
        _ach("streak_perfect_30", AchievementTier.gold, AchievementDifficulty.hard, "🎯", category: AchievementCategory.streak, target: 30, xp: 2000),

        // 💎 PREMIUM (Premium Özel)
        _ach("premium_trial_used", AchievementTier.bronze, AchievementDifficulty.easy, "🎫", category: AchievementCategory.premium, target: 1, xp: 100),
        _ach("limit_breaker", AchievementTier.silver, AchievementDifficulty.medium, "💥", category: AchievementCategory.premium, target: 1, xp: 300),
        _ach("ad_skip_used", AchievementTier.bronze, AchievementDifficulty.easy, "⏭️", category: AchievementCategory.premium, target: 1, xp: 50),
        _ach("reward_collector", AchievementTier.gold, AchievementDifficulty.hard, "🎁", category: AchievementCategory.premium, target: 10, xp: 500),

        // 🧠 POWER USER (Güçlü Kullanıcı)
        _ach("multi_feature_user", AchievementTier.gold, AchievementDifficulty.medium, "🐙", category: AchievementCategory.powerUser, target: 1, xp: 1000),
        _ach("data_master", AchievementTier.platinum, AchievementDifficulty.hard, "🤓", category: AchievementCategory.powerUser, target: 1, xp: 2000),
        _ach("organized_master", AchievementTier.gold, AchievementDifficulty.medium, "🧮", category: AchievementCategory.powerUser, target: 1, xp: 1500),
        _ach("security_master", AchievementTier.platinum, AchievementDifficulty.hard, "🔐", category: AchievementCategory.powerUser, target: 1, xp: 2500),
        _ach("daily_master", AchievementTier.platinum, AchievementDifficulty.hard, "🌞", category: AchievementCategory.powerUser, target: 30, xp: 5000),
      ];

  static Achievement _ach(
    String id,
    AchievementTier tier,
    AchievementDifficulty difficulty,
    String emoji, {
    required AchievementCategory category,
    int? target,
    required int xp,
    bool hidden = false,
  }) {
    return Achievement(
      id: id,
      title: "ach_${id}_title",
      description: "ach_${id}_desc",
      tier: tier,
      difficulty: difficulty,
      emoji: emoji,
      totalSteps: target,
      xpReward: xp,
      category: category,
      isHidden: hidden,
      progress: 0,
      unlocked: false,
    );
  }
}
