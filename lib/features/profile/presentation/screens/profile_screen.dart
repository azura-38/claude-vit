import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/external_launcher.dart';
import '../../../../shared/data/services/review_service.dart';
import '../../../../shared/data/services/wipe_service.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../providers/profile_provider.dart';

import '../widgets/profile_app_bar.dart';
import '../widgets/profile_hero.dart';
import '../widgets/emergency_card.dart';
import '../widgets/active_goals_section.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_visuals.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(profileProvider);
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    final hasPinAsync = ref.watch(hasPinProvider);
    final hasPin = hasPinAsync.valueOrNull ?? true;
    final prefs = ref.watch(sharedPreferencesProvider);
    final onboardingSkipped = prefs.getBool('profile_creation_skipped') ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              ProfileAppBar(isDark: isDark),
              const SizedBox(height: 32),
              ProfileHero(isDark: isDark),
              if (onboardingSkipped && !hasPin) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.12),
                        Colors.orange.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.gpp_maybe_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.dataSecurity,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('pin_not_set_desc'),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : AppColors.textSecondary,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.settings),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.l10n.settings,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: visuals.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: visuals.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
              ],
              if (profile.fullName.trim().isEmpty && !(onboardingSkipped && !hasPin)) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.brandBlue.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.brandBlue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('profile_incomplete_warning'),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 48),
              EmergencyCard(isDark: isDark),
              const SizedBox(height: 40),
              ActiveGoalsSection(isDark: isDark),
              const SizedBox(height: 40),
              _buildSectionTitle(context.l10n.personalHealthData, isDark),
              const SizedBox(height: 16),
              _buildNavigationItem(
                context,
                icon: Icons.person_outline_rounded,
                title: context.l10n.personalInfo,
                onTap: () => context.push(AppRoutes.personalInfo),
                isDark: isDark,
              ),
              _buildNavigationItem(
                context,
                icon: Icons.assignment_outlined,
                title: context.l10n.importantInfo,
                onTap: () => context.push(AppRoutes.medicalInfo),
                isDark: isDark,
              ),
              const SizedBox(height: 40),
              _buildSectionTitle(context.l10n.accountSettings, isDark),
              const SizedBox(height: 16),
              _buildNavigationItem(
                context,
                icon: Icons.settings_outlined,
                title: context.l10n.appSettings,
                onTap: () => context.push(AppRoutes.settings),
                isDark: isDark,
              ),
              _buildNavigationItem(
                context,
                icon: Icons.feedback_outlined,
                title: context.l10n.reportIssue,
                onTap: () => ExternalLauncher.launchEmail(
                  'limanexsoftware@outlook.com',
                  subject: 'VitaCase Feedback & Support',
                  body: '\n\n---\nDevice info: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
                ),
                isDark: isDark,
              ),
              _buildNavigationItem(
                context,
                icon: Icons.star_rate_rounded,
                title: context.tr('review_prompt_action'),
                onTap: () => ref.read(reviewServiceProvider).requestReviewOrOpenStore(),
                isDark: isDark,
              ),
              _buildNavigationItem(
                context,
                icon: Icons.delete_forever_rounded,
                title: context.l10n.deleteAllData,
                titleColor: AppColors.error,
                onTap: () => _showDeleteAllDialog(context, ref),
                isDark: isDark,
              ),
              const SizedBox(height: 124),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: titleColor ?? (isDark ? Colors.white70 : Colors.black87), size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: titleColor ?? (isDark ? Colors.white : Colors.black87),
            fontFamily: 'Manrope',
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: titleColor?.withValues(alpha: 0.5) ?? AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white70 : AppColors.textPrimary,
        fontFamily: 'Manrope',
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          dialogContext.l10n.deleteAllData,
          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        content: Text(dialogContext.l10n.wipeConfirm1),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
              await WipeService.fullWipe();
              if (context.mounted) {
                context.go(AppRoutes.onboarding);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(dialogContext.l10n.wipeBtnFinal, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
