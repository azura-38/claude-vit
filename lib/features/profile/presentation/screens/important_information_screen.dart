import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../../../../shared/widgets/vitacase_bottom_nav.dart';
import '../providers/profile_provider.dart';
import '../widgets/detail_section_card.dart';
import '../widgets/security_banner.dart';

class ImportantInformationScreen extends ConsumerWidget {
  const ImportantInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const VitaCaseBottomNav(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                Expanded(
                  child: Text(
                    context.tr('important_info'),
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -.12),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.medicalBlue.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isDark ? Colors.white10 : AppColors.medicalBlue.withValues(alpha: 0.12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.health_and_safety_rounded, color: AppColors.medicalBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('privacy_box_warning'),
                      style: TextStyle(
                        height: 1.45,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 80.ms).slideY(begin: .12),
            const SizedBox(height: 24),
            DetailSectionCard(
              icon: Icons.medical_services_outlined,
              iconColor: AppColors.primary,
              title: context.tr('important_info'),
              rows: [
                {'label': context.tr('blood_type'), 'value': profile.bloodType.isNotEmpty ? profile.bloodType : context.tr('not_added')},
                {
                  'label': context.tr('allergies'),
                  'value': profile.allergies.isNotEmpty ? profile.allergies.join(', ') : context.tr('none'),
                },
                {
                  'label': context.tr('medicines'),
                  'value': profile.medications.isNotEmpty ? profile.medications.join(', ') : context.tr('none'),
                },
              ],
            ).animate().fadeIn(delay: 160.ms).slideY(begin: .12),
            const SizedBox(height: 20),
            DetailSectionCard(
              icon: Icons.emergency_rounded,
              iconColor: Colors.red,
              title: context.tr('emergency_contact'),
              rows: [
                {
                  'label': context.tr('emergency_contact_name'),
                  'value': profile.emergencyName.isNotEmpty ? profile.emergencyName : context.tr('not_added'),
                },
                {
                  'label': context.tr('phone_number'),
                  'value': profile.emergencyPhone.isNotEmpty ? profile.emergencyPhone : context.tr('not_added'),
                },
              ],
            ).animate().fadeIn(delay: 240.ms).slideY(begin: .12),
            const SizedBox(height: 28),
            const SecurityBanner().animate().fadeIn(delay: 320.ms),
          ],
        ),
      ),
    );
  }
}
