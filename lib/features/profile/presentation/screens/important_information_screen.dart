import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../../../../shared/widgets/vitacase_bottom_nav.dart';
import '../../domain/models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/detail_section_card.dart';
import '../widgets/security_banner.dart';

class ImportantInformationScreen extends ConsumerWidget {
  const ImportantInformationScreen({super.key});



  List<String> _splitList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, UserProfile profile) async {

    final bloodController = TextEditingController(text: profile.bloodType);
    final allergiesController = TextEditingController(text: profile.allergies.join(', '));
    final medsController = TextEditingController(text: profile.medications.join(', '));
    final emergencyNameController = TextEditingController(text: profile.emergencyName);
    final emergencyPhoneController = TextEditingController(text: profile.emergencyPhone);
    final emergencyRelationController = TextEditingController(text: profile.emergencyRelation);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('edit_important_info')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bloodController,
                  decoration: InputDecoration(labelText: context.tr('blood_type'), hintText: 'A+, B-, 0+'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: allergiesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.tr('allergies'),
                    hintText: context.tr('hint_allergies'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: medsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.tr('medicines'),
                    hintText: context.tr('hint_medications'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emergencyNameController,
                  decoration: InputDecoration(labelText: context.tr('emergency_contact_name')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emergencyPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: context.tr('phone_number')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emergencyRelationController,
                  decoration: InputDecoration(
                    labelText: context.tr('relationship'),
                    hintText: context.tr('hint_relationship'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.tr('cancel'))),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(context.tr('save'))),
          ],
        );
      },
    );

    if (result == true) {
      final notifier = ref.read(profileProvider.notifier);
      notifier.updateBlood(bloodController.text.trim());
      notifier.updateAllergies(_splitList(allergiesController.text));
      notifier.updateMedications(_splitList(medsController.text));
      notifier.updateEmergencyName(emergencyNameController.text.trim());
      notifier.updateEmergencyPhone(emergencyPhoneController.text.trim());
      notifier.updateEmergencyRelation(emergencyRelationController.text.trim());
      await notifier.saveToDatabase();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('important_info_updated'))),
        );
      }
    }

    bloodController.dispose();
    allergiesController.dispose();
    medsController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    emergencyRelationController.dispose();
  }

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
                IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                Expanded(
                  child: Text(context.tr('important_info'), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                ),
                IconButton.filledTonal(
                  onPressed: () => _showEditDialog(context, ref, profile),
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: context.tr('edit'),
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
                      style: TextStyle(height: 1.45, color: isDark ? Colors.white70 : AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 80.ms).slideY(begin: .12),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Text(context.tr('important_info'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
                TextButton.icon(
                  onPressed: () => _showEditDialog(context, ref, profile),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(context.tr('edit')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DetailSectionCard(
              icon: Icons.medical_services_outlined,
              iconColor: AppColors.primary,
              title: context.tr('important_info'),
              rows: [
                {'label': context.tr('blood_type'), 'value': profile.bloodType.isNotEmpty ? profile.bloodType : context.tr('not_added')},
                {'label': context.tr('allergies'), 'value': profile.allergies.isNotEmpty ? profile.allergies.join(', ') : context.tr('none')},
                {'label': context.tr('medicines'), 'value': profile.medications.isNotEmpty ? profile.medications.join(', ') : context.tr('none')},
              ],
            ).animate().fadeIn(delay: 160.ms).slideY(begin: .12),
            const SizedBox(height: 20),
            DetailSectionCard(
              icon: Icons.emergency_rounded,
              iconColor: Colors.red,
              title: context.tr('emergency_contact'),
              rows: [
                {'label': context.tr('emergency_contact_name'), 'value': profile.emergencyName.isNotEmpty ? profile.emergencyName : context.tr('not_added')},
                {'label': context.tr('phone_number'), 'value': profile.emergencyPhone.isNotEmpty ? profile.emergencyPhone : context.tr('not_added')},
                {'label': context.tr('relationship'), 'value': profile.emergencyRelation.isNotEmpty ? profile.emergencyRelation : context.tr('not_added')},
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
