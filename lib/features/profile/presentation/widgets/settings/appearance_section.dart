import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/providers/locale_provider.dart';
import '../../providers/settings_controller.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'setting_tile.dart';
import 'settings_section_card.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key, required this.isDark});

  final bool isDark;

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
                  title: Text(
                    language.name,
                    style: TextStyle(fontWeight: currentLocale == language.code ? FontWeight.w900 : FontWeight.w500),
                  ),
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
}
