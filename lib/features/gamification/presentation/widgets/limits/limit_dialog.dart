import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/types/runtime_types.dart';
import '../../../../../shared/data/services/ad_service.dart';
import '../../../../../shared/data/services/analytics_service.dart';

class LimitDialog extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final VoidCallback onRewardEarned;

  const LimitDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onRewardEarned,
  });

  @override
  ConsumerState<LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends ConsumerState<LimitDialog> {
  bool _isLoadingReward = false;

  Future<void> _handleRewardedAd() async {
    if (_isLoadingReward) return;

    setState(() => _isLoadingReward = true);
    final messenger = ScaffoldMessenger.of(context);
    final result = await AdService.showRewardedForResult();

    if (!mounted) {
      return;
    }

    setState(() => _isLoadingReward = false);

    switch (result) {
      case RewardAdResult.shownRewarded:
        widget.onRewardEarned();
        AnalyticsService.log(AnalyticsService.rewardAdRewarded, {
          'origin': 'limit_dialog',
        });
        if (mounted) {
          Navigator.of(context).pop();
        }
        break;
      case RewardAdResult.shownNoReward:
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.adRewardNotEarned)),
        );
        break;
      case RewardAdResult.unavailable:
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.adUnavailable)),
        );
        break;
      case RewardAdResult.failed:
        messenger.showSnackBar(SnackBar(content: Text(context.l10n.adFailed)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 32,
                  ),
                ).animate(onPlay: (c) => c.repeat()).shake(duration: 2.seconds),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Manrope',
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoadingReward ? null : _handleRewardedAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoadingReward
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            context.l10n.adWatchBtn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed:
                      _isLoadingReward
                          ? null
                          : () => Navigator.of(context).pop(),
                  child: Text(context.l10n.btnNotNow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showLimitDialog(
  BuildContext context, {
  required String title,
  required String description,
  required VoidCallback onRewardEarned,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder:
        (context) => LimitDialog(
          title: title,
          description: description,
          onRewardEarned: onRewardEarned,
        ),
  );
}
