import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class ProfileAppBar extends ConsumerWidget {
  const ProfileAppBar({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.person_pin_rounded, color: isDark ? Colors.white70 : AppColors.medicalBlue),
            const SizedBox(width: 16),
            Text(
              context.l10n.profile,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.medicalBlue,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.personalInfo),
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: Text(context.l10n.edit, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.blue.shade300 : AppColors.medicalBlue,
                backgroundColor: (isDark ? Colors.blue : AppColors.medicalBlue).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => context.push(AppRoutes.settings),
              icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : AppColors.medicalBlue),
              tooltip: context.l10n.appSettings,
            ),
          ],
        ),
      ],
    );
  }
}
