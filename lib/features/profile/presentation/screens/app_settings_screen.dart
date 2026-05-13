import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/app_info_provider.dart';
import '../../../../shared/widgets/misc/banner_ad_container.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../widgets/settings/appearance_section.dart';
import '../widgets/settings/app_logic_section.dart';
import '../widgets/settings/security_section.dart';
import '../widgets/settings/legal_section.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          context.l10n.appSettings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const BannerAdContainer(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTrustCard(context, isDark),
                  const SizedBox(height: 32),
                  AppearanceSection(isDark: isDark),
                  const SizedBox(height: 32),
                  AppLogicSection(isDark: isDark),
                  const SizedBox(height: 32),
                  SecuritySection(isDark: isDark),
                  const SizedBox(height: 32),
                  LegalSection(isDark: isDark),
                  const SizedBox(height: 40),
                  _buildVersionFooter(context, ref, isDark),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [AppColors.medicalBlue.withValues(alpha: 0.1), Colors.transparent]
              : [AppColors.medicalBlue.withValues(alpha: 0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.medicalBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: AppColors.medicalBlue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.privacyGuaranteedTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text(context.l10n.privacyGuaranteedDesc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionFooter(BuildContext context, WidgetRef ref, bool isDark) {
    final appInfo = ref.watch(packageInfoProvider).asData?.value;
    return Center(
      child: Column(
        children: [
          Text(
            'VitaCase ${appInfo?.version ?? '1.0.0'} (${appInfo?.buildNumber ?? '1'})',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          const Text(
            '© 2026 Limanex Software',
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
