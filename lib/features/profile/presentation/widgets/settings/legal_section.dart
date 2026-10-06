import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
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
          icon: Icons.policy_rounded,
          iconColor: AppColors.brandBlue,
          title: context.tr('terms_and_privacy'),
          onTap: () => context.pushNamed('settingsTermsAndPrivacy'),
          isDark: isDark,
          isLast: true,
        ),
      ],
    );
  }
}

