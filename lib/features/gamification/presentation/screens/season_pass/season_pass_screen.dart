import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../../shared/providers/season_providers.dart';
import '../../../../../shared/providers/premium_provider.dart';
import '../../../../../shared/domain/entities/season_pass.dart';

class SeasonPassScreen extends ConsumerWidget {
  const SeasonPassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(seasonProvider);
    final isPremium = ref.watch(premiumProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rewards = ref.read(seasonProvider.notifier).getAvailableRewards();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          context.l10n.seasonPass,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: progressAsync.when(
        data:
            (progress) => Column(
              children: [
                // 📊 Progress Header
                _buildProgressHeader(context, progress, isDark),

                const SizedBox(height: 24),

                // 🎁 Rewards List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final r = rewards[index];
                      return _buildRewardItem(
                        context,
                        r,
                        progress,
                        isPremium,
                        isDark,
                        ref,
                      );
                    },
                  ),
                ),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    UserSeasonProgress progress,
    bool isDark,
  ) {
    final currentLevelXP = progress.level * 100;
    final progressInLevel = (progress.xp - currentLevelXP) / 100;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradBlueStart, AppColors.gradBlueEnd],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.levelLabel(progress.level),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "${progress.xp % 100} / 100 XP",
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressInLevel.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(
    BuildContext context,
    SeasonReward reward,
    UserSeasonProgress progress,
    bool isPremium,
    bool isDark,
    WidgetRef ref,
  ) {
    final isUnlocked = progress.level >= reward.level;
    final isClaimed =
        reward.isPremiumOnly
            ? progress.claimedPremiumRewards.contains(reward.level)
            : progress.claimedFreeRewards.contains(reward.level);

    final canClaim =
        isUnlocked && !isClaimed && (!reward.isPremiumOnly || isPremium);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              reward.isPremiumOnly
                  ? Colors.amber.withValues(alpha: 0.3)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  isUnlocked
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${reward.level}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isUnlocked ? AppColors.medicalBlue : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.localizedTitle(context),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  reward.isPremiumOnly
                      ? context.l10n.premiumReward
                      : context.l10n.freeReward,
                  style: TextStyle(
                    fontSize: 12,
                    color: reward.isPremiumOnly ? Colors.amber : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isClaimed)
            const Icon(Icons.check_circle, color: Colors.green)
          else if (canClaim)
            ElevatedButton(
              onPressed:
                  () => ref.read(seasonProvider.notifier).claimReward(reward),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.medicalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(context.l10n.claim),
            )
          else
            const Icon(Icons.lock_clock_outlined, color: Colors.grey),
        ],
      ),
    );
  }
}
