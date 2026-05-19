import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/external_launcher.dart';
import '../../../../shared/data/services/wipe_service.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../widgets/profile_app_bar.dart';
import '../widgets/profile_hero.dart';
import '../widgets/emergency_card.dart';
import '../widgets/active_goals_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              ProfileAppBar(isDark: isDark),
              const SizedBox(height: 32),
              ProfileHero(isDark: isDark),
              const SizedBox(height: 48),
              EmergencyCard(isDark: isDark),
              const SizedBox(height: 40),
              ActiveGoalsSection(isDark: isDark),
              const SizedBox(height: 40),
              _buildSectionTitle(context.l10n.personalHealthData, isDark),
              const SizedBox(height: 16),
              _buildNavigationItem(
                icon: Icons.person_outline_rounded,
                title: context.l10n.personalInfo,
                onTap: () => context.push(AppRoutes.personalInfo),
                isDark: isDark,
              ),
              _buildNavigationItem(
                icon: Icons.assignment_outlined,
                title: context.l10n.importantInfo,
                onTap: () => context.push(AppRoutes.medicalInfo),
                isDark: isDark,
              ),
              _buildNavigationItem(
                icon: Icons.emoji_events_outlined,
                title: context.l10n.medalsTrophies,
                onTap: () => context.push(AppRoutes.achievements),
                isDark: isDark,
              ),
              const SizedBox(height: 40),
              _buildSectionTitle(context.l10n.accountSettings, isDark),
              const SizedBox(height: 16),
              _buildNavigationItem(
                icon: Icons.settings_outlined,
                title: context.l10n.appSettings,
                onTap: () => context.push(AppRoutes.settings),
                isDark: isDark,
              ),
              _buildNavigationItem(
                icon: Icons.bug_report_outlined,
                title: context.l10n.reportIssue,
                onTap: () => ExternalLauncher.launchEmail(
                  'limanexsoftware@outlook.com',
                  subject: 'VitaCase Error Report',
                  body: '\n\n---\nDevice info: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
                ),
                isDark: isDark,
              ),
              _buildNavigationItem(
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

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
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
            color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9),
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
      builder: (_) => AlertDialog(
        title: Text(
          context.l10n.deleteAllData,
          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        content: Text(context.l10n.wipeConfirm1),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () async {
              context.pop();
              await WipeService.fullWipe();
              if (context.mounted) {
                context.go(AppRoutes.onboarding);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l10n.wipeBtnFinal, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
