import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'setting_tile.dart';
import 'settings_section_card.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class LegalSection extends ConsumerWidget {
  final bool isDark;
  const LegalSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSectionCard(
      title: context.l10n.legal,
      isDark: isDark,
      children: [
        SettingTile(
          icon: Icons.article_outlined,
          iconColor: Colors.grey,
          title: context.l10n.privacyPolicy,
          onTap: () => context.pushNamed('settingsPrivacy'),
          isDark: isDark,
        ),
        SettingTile(
          icon: Icons.gavel_rounded,
          iconColor: Colors.grey,
          title: context.l10n.termsConditions,
          onTap: () => context.pushNamed('settingsTerms'),
          isDark: isDark,
        ),
        SettingTile(
          icon: Icons.info_outline_rounded,
          iconColor: Colors.grey,
          title: context.l10n.legalDisclaimer,
          onTap: () => context.pushNamed('settingsDisclaimer'),
          isDark: isDark,
          isLast: true,
        ),
      ],
    );
  }
}
