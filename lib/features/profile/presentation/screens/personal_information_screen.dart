import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_provider.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import '../widgets/bmi_card.dart';
import '../widgets/detail_section_card.dart';
import '../../../../shared/widgets/premium_appbar.dart';
import '../widgets/security_banner.dart';
import '../../../../shared/widgets/vitacase_bottom_nav.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      bottomNavigationBar: const VitaCaseBottomNav(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            const PremiumAppbar(),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Text(profile.name, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(context.l10n.vitaBadge, style: const TextStyle(color: AppColors.secondary)),
                ],
              ),
            ).animate().fadeIn().slideY(begin: .2),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.heightLabel, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                Text(
                  context.tr('personal_info'),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 18),
            BmiCard(profile: profile).animate().fadeIn(delay: 100.ms).slideY(begin: .15),
            const SizedBox(height: 36),
            Text(context.l10n.personalInfo, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            DetailSectionCard(
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.primary,
              title: context.l10n.identityContact,
              rows: [
                {'label': context.l10n.emailAddress, 'value': profile.email.isNotEmpty ? profile.email : context.l10n.notAdded},
                {'label': context.l10n.phoneNumber, 'value': profile.phone.isNotEmpty ? profile.phone : context.l10n.notAdded},
                {
                  'label': context.l10n.birthDate,
                  'value': profile.birthDate != null
                      ? '${profile.birthDate!.day.toString().padLeft(2, '0')}.${profile.birthDate!.month.toString().padLeft(2, '0')}.${profile.birthDate!.year}'
                      : context.l10n.notAdded,
                },
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 28),
            const SecurityBanner().animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
