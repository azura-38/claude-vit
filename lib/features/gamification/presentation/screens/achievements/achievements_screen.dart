import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/achievement_providers.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/domain/entities/achievement.dart';
import '../../../../../shared/providers/ad_skip_provider.dart';
import '../../../../../shared/providers/season_providers.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../widgets/achievements/achievement_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProvider);
    final seasonAsync = ref.watch(seasonProvider);
    final limitUnlockTokens = ref.watch(adSkipProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return achievementsAsync.when(
      data: (achievements) {
        if (achievements.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final unlockedCount = achievements.where((a) => a.unlocked).length;
        final totalXP = achievements.where((a) => a.unlocked).fold(0, (sum, a) => sum + a.xpReward);
        final seasonXp = seasonAsync.valueOrNull?.xp ?? totalXP;
        final xpRemaining = AppConfig.xpPerAdSkipToken <= 0 ? 0 : AppConfig.xpPerAdSkipToken - (seasonXp % AppConfig.xpPerAdSkipToken);

        final Map<AchievementCategory, List<Achievement>> grouped = {};
        for (var a in achievements) {
          grouped.putIfAbsent(a.category, () => []).add(a);
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.medicalBlue,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    context.tr('medals_trophies'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark ? [const Color(0xFF1E293B), const Color(0xFF334155)] : [AppColors.medicalBlue, const Color(0xFF1E40AF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                                  const SizedBox(width: 12),
                                  Text('$totalXP XP', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$unlockedCount / ${achievements.length} ${context.tr('unlocked')}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                  child: _LimitUnlockInfoCard(
                    isDark: isDark,
                    xp: seasonXp,
                    xpRemaining: xpRemaining == AppConfig.xpPerAdSkipToken ? 0 : xpRemaining,
                    tokens: limitUnlockTokens,
                  ),
                ),
              ),
              for (var category in AchievementCategory.values)
                if (grouped.containsKey(category)) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        children: [
                          Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.medicalBlue, borderRadius: BorderRadius.circular(4))),
                          const SizedBox(width: 12),
                          Text(
                            context.tr('cat_${category.name}').toUpperCase(),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: isDark ? Colors.white60 : Colors.blueGrey[800]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final a = grouped[category]![index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AchievementCard(achievement: a, isUnlocked: a.unlocked, currentSteps: a.progress),
                        );
                      }, childCount: grouped[category]!.length),
                    ),
                  ),
                ],
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text(err.toString()))),
    );
  }
}

class _LimitUnlockInfoCard extends StatelessWidget {
  const _LimitUnlockInfoCard({required this.isDark, required this.xp, required this.xpRemaining, required this.tokens});

  final bool isDark;
  final int xp;
  final int xpRemaining;
  final int tokens;

  @override
  Widget build(BuildContext context) {
    final enabled = AppConfig.adSkipRewardsEnabled;
    final title = context.l10n.limitUnlockTokenTitle;
    final status = enabled
        ? context.l10n.limitUnlockStatusActive
        : context.l10n.limitUnlockStatusComingSoon(AppConfig.adSkipRewardsTargetVersion);
    final description = enabled
        ? context.l10n.limitUnlockDescActive(AppConfig.xpPerAdSkipToken.toString())
        : context.l10n.limitUnlockDescInactive(AppConfig.adSkipRewardsTargetVersion, AppConfig.xpPerAdSkipToken.toString());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: enabled ? AppColors.medicalBlue.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: enabled ? AppColors.medicalBlue.withValues(alpha: 0.12) : Colors.amber.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16)),
            child: Icon(enabled ? Icons.lock_open_rounded : Icons.schedule_rounded, color: enabled ? AppColors.medicalBlue : Colors.amber.shade800),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: enabled ? AppColors.medicalBlue.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
                      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: enabled ? AppColors.medicalBlue : Colors.amber.shade900)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(description, style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.4, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniStat(label: context.l10n.limitUnlockStatTotalXp, value: xp.toString()),
                    _MiniStat(label: context.l10n.limitUnlockStatXpLeft, value: enabled ? xpRemaining.toString() : AppConfig.xpPerAdSkipToken.toString()),
                    _MiniStat(label: context.l10n.limitUnlockStatTokens, value: enabled ? tokens.toString() : '0'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
      child: Text('$label: $value', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}
