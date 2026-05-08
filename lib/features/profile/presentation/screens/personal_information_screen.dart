import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_provider.dart';
import '../../../../core/theme/vitacase_theme.dart';
import '../widgets/bmi_card.dart';
import '../widgets/detail_section_card.dart';
import '../../../../shared/widgets/premium_appbar.dart';
import '../widgets/security_banner.dart';
import '../../../../shared/widgets/vitacase_bottom_nav.dart';
import '../../../../core/l10n/app_localizations.dart';

class PersonalInformationScreen
    extends ConsumerWidget {
  const PersonalInformationScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final profile =
        ref.watch(profileProvider);

    return Scaffold(
      bottomNavigationBar:
          const VitaCaseBottomNav(),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            120,
          ),
          children: [
            const PremiumAppbar(),

            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    context.l10n('vita_badge'),
                    style: const TextStyle(
                      color:
                          VitaColors.secondary,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn()
                .slideY(begin: .2),

            const SizedBox(height: 36),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  context.l10n('height_label'),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const Text(
                  "Last sync: 2h ago",
                  style: TextStyle(
                    color:
                        VitaColors.primary,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            BmiCard(profile: profile)
                .animate()
                .fadeIn(
                  delay: 100.ms,
                )
                .slideY(begin: .15),

            const SizedBox(height: 36),

            Text(
              context.l10n('personal_info'),
              style: const TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 18),

            DetailSectionCard(
              icon:
                  Icons.person_outline_rounded,
              iconColor:
                  VitaColors.primary,
              title:
                  context.l10n('identity_contact'),
              rows: [
                {
                  "label": context.l10n('email_address'),
                  "value": profile.email.isNotEmpty ? profile.email : context.l10n('not_added'),
                },
                {
                  "label": context.l10n('phone_number'),
                  "value": profile.phone.isNotEmpty ? profile.phone : context.l10n('not_added'),
                },
                {
                  "label": context.l10n('birth_date'),
                  "value": profile.birthDate != null
                      ? "${profile.birthDate!.day.toString().padLeft(2, '0')}.${profile.birthDate!.month.toString().padLeft(2, '0')}.${profile.birthDate!.year}"
                      : context.l10n('not_added'),
                },
              ],
            ).animate().fadeIn(
                  delay: 200.ms,
                ),

            const SizedBox(height: 20),

            DetailSectionCard(
              icon:
                  Icons.medical_services_outlined,
              iconColor:
                  VitaColors.primary,
              title:
                  context.l10n('important_info'),
              rows: [
                {
                  "label": context.l10n('blood_type'),
                  "value":
                      profile.bloodType,
                },
                {
                  "label": context.l10n('allergies'),
                  "value":
                      profile.allergies.isNotEmpty
                          ? profile.allergies.join(", ")
                          : context.l10n('none'),
                },
                {
                  "label": context.l10n('medicines'),
                  "value":
                      profile.medications.isNotEmpty
                          ? profile.medications.join(", ")
                          : context.l10n('none'),
                },
              ],
            ).animate().fadeIn(
                  delay: 300.ms,
                ),

            const SizedBox(height: 20),

            DetailSectionCard(
              icon: Icons.emergency,
              iconColor: Colors.red,
              title:
                  context.l10n('emergency_contact'),
              rows: [
                {
                  "label": context.l10n('emergency_contact_name'),
                  "value":
                      profile.emergencyName.isNotEmpty ? profile.emergencyName : context.l10n('not_added'),
                },
                {
                  "label": context.l10n('phone_number'),
                  "value": profile.emergencyPhone.isNotEmpty ? profile.emergencyPhone : context.l10n('not_added'),
                },
              ],
            ).animate().fadeIn(
                  delay: 400.ms,
                ),

            const SizedBox(height: 28),

            const SecurityBanner()
                .animate()
                .fadeIn(
                  delay: 500.ms,
                ),
          ],
        ),
      ),
    );
  }
}
