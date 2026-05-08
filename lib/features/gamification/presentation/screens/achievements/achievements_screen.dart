import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/achievement_providers.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/domain/entities/achievement.dart';
import '../../../../../core/l10n/app_localizations.dart';
import '../../widgets/achievements/achievement_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return achievementsAsync.when(
      data: (achievements) {
        if (achievements.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Stats Calculation
        final unlockedCount = achievements.where((a) => a.unlocked).length;
        final totalXP = achievements.where((a) => a.unlocked).fold(0, (sum, a) => sum + a.xpReward);
        
        // Grouping items by category
        final Map<AchievementCategory, List<Achievement>> grouped = {};
        for (var a in achievements) {
          grouped.putIfAbsent(a.category, () => []).add(a);
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Header
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.medicalBlue,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    context.l10n("medals_trophies"),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient Background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                              ? [const Color(0xFF1E293B), const Color(0xFF334155)] 
                              : [AppColors.medicalBlue, const Color(0xFF1E40AF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      
                      // Stats Overlay
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
                                  Text(
                                    "$totalXP XP",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "$unlockedCount / ${achievements.length} ${context.l10n("unlocked")}",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories and Achievement Lists
              for (var category in AchievementCategory.values)
                if (grouped.containsKey(category)) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.medicalBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.l10n("cat_${category.name}").toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: isDark ? Colors.white60 : Colors.blueGrey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final a = grouped[category]![index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AchievementCard(
                              achievement: a,
                              isUnlocked: a.unlocked,
                              currentSteps: a.progress,
                            ),
                          );
                        },
                        childCount: grouped[category]!.length,
                      ),
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
