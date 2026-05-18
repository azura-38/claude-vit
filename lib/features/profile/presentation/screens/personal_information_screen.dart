import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../../../../shared/widgets/premium_appbar.dart';
import '../../../../shared/widgets/vitacase_bottom_nav.dart';
import '../../domain/models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/bmi_card.dart';
import '../widgets/detail_section_card.dart';
import '../widgets/security_banner.dart';
import 'package:vitacase/core/constants/app_colors.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  bool _isTr(BuildContext context) => Localizations.localeOf(context).languageCode == 'tr';

  String _dateText(BuildContext context, DateTime? value) {
    if (value == null) return context.l10n.notAdded;
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, UserProfile profile) async {
    final nameController = TextEditingController(text: profile.fullName);
    final emailController = TextEditingController(text: profile.email);
    final phoneController = TextEditingController(text: profile.phone);
    final heightController = TextEditingController(text: profile.height > 0 ? profile.height.toStringAsFixed(0) : '');
    final weightController = TextEditingController(text: profile.weight > 0 ? profile.weight.toStringAsFixed(0) : '');
    DateTime? selectedBirthDate = profile.birthDate;

    final tr = _isTr(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickBirthDate() async {
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: selectedBirthDate ?? DateTime(1995),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) setDialogState(() => selectedBirthDate = picked);
            }

            return AlertDialog(
              title: Text(tr ? 'Kişisel bilgileri düzenle' : 'Edit personal information'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: context.l10n.fullName),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: context.l10n.emailAddress),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: context.l10n.phoneNumber),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: context.l10n.heightLabel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: context.tr('current_weight')),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cake_outlined),
                      title: Text(context.l10n.birthDate),
                      subtitle: Text(_dateText(context, selectedBirthDate)),
                      trailing: const Icon(Icons.edit_calendar_rounded),
                      onTap: pickBirthDate,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(context.l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final notifier = ref.read(profileProvider.notifier);
      notifier.updateName(nameController.text.trim());
      notifier.updateEmail(emailController.text.trim());
      notifier.updatePhone(phoneController.text.trim());
      final height = double.tryParse(heightController.text.trim().replaceAll(',', '.')) ?? 0;
      final weight = double.tryParse(weightController.text.trim().replaceAll(',', '.')) ?? 0;
      notifier.updateHeight(height);
      notifier.updateWeight(weight);
      if (selectedBirthDate != null) notifier.updateBirthDate(selectedBirthDate!);
      await notifier.saveToDatabase();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr ? 'Kişisel bilgiler güncellendi.' : 'Personal information updated.')),
        );
      }
    }

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    heightController.dispose();
    weightController.dispose();
  }

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
                  Text(
                    profile.name.isNotEmpty ? profile.name : context.tr('guest_user'),
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
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
                IconButton.filledTonal(
                  onPressed: () => _showEditDialog(context, ref, profile),
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: context.tr('edit'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            BmiCard(profile: profile).animate().fadeIn(delay: 100.ms).slideY(begin: .15),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(child: Text(context.l10n.personalInfo, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700))),
                TextButton.icon(
                  onPressed: () => _showEditDialog(context, ref, profile),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(context.tr('edit')),
                ),
              ],
            ),
            const SizedBox(height: 18),
            DetailSectionCard(
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.primary,
              title: context.l10n.identityContact,
              rows: [
                {'label': context.l10n.emailAddress, 'value': profile.email.isNotEmpty ? profile.email : context.l10n.notAdded},
                {'label': context.l10n.phoneNumber, 'value': profile.phone.isNotEmpty ? profile.phone : context.l10n.notAdded},
                {'label': context.l10n.birthDate, 'value': _dateText(context, profile.birthDate)},
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
