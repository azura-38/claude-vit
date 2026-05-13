import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'setting_tile.dart';
import 'settings_section_card.dart';
import '../../providers/settings_controller.dart';
import '../../../../../shared/providers/locale_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class AppearanceSection extends ConsumerWidget {
  final bool isDark;
  const AppearanceSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.watch(settingsControllerProvider.notifier);

    return SettingsSectionCard(
      title: context.l10n.appearance,
      isDark: isDark,
      children: [
        SettingTile(
          icon: Icons.palette_rounded,
          iconColor: Colors.purple,
          title: context.l10n.themeSettings,
          subtitle: settings.themeMode.localizedLabel(context),
          onTap: () => context.pushNamed('settingsTheme'),
          isDark: isDark,
        ),
        SettingTile(
          icon: Icons.language_rounded,
          iconColor: Colors.teal,
          title: context.l10n.selectLanguage,
          subtitle: _getLanguageName(settings.locale),
          onTap: () => _showLanguageSelector(context, ref, controller),
          isDark: isDark,
        ),
        SettingTile(
          icon: Icons.restore_rounded,
          iconColor: Colors.indigo,
          title: context.l10n.backupRestore,
          subtitle: context.l10n.backupDescSettings,
          onTap: () => _showBackupSelector(context),
          isDark: isDark,
          isLast: true,
        ),
      ],
    );
  }

  String _getLanguageName(String code) {
    return supportedLanguages
        .firstWhere(
          (language) => language.code == code,
          orElse: () => const SupportedLanguage('en', 'English'),
        )
        .name;
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref, SettingsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(
                ctx.l10n.selectLanguage,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              ...supportedLanguages.map((language) {
                final currentLocale = ref.read(settingsControllerProvider).locale;
                return ListTile(
                  title: Text(language.name, style: TextStyle(fontWeight: currentLocale == language.code ? FontWeight.w900 : FontWeight.w500)),
                  trailing: currentLocale == language.code ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryIndigo) : null,
                  onTap: () {
                    controller.setLocale(language.code);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.backupRestore, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(context.l10n.backupRestoreDesc, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              _buildActionTile(
                context: context,
                icon: Icons.cloud_upload_rounded,
                color: Colors.blue,
                title: context.l10n.backupExport,
                subtitle: context.l10n.backupExportDesc,
                isComingSoon: true,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.comingSoon))),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                context: context,
                icon: Icons.cloud_download_rounded,
                color: Colors.green,
                title: context.l10n.backupImport,
                subtitle: context.l10n.backupImportDesc,
                isComingSoon: true,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.comingSoon))),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      if (isComingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: Text(context.l10n.comingSoon.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                      ],
                    ],
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
