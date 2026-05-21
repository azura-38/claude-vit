import 'dart:io';
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

    InputDecoration buildInputDecoration(String label, IconData icon) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary.withValues(alpha: 0.7)),
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white60 : Colors.black54),
        floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.01),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            Future<void> pickBirthDate() async {
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: selectedBirthDate ?? DateTime(1995),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: isDark
                          ? const ColorScheme.dark(
                              primary: AppColors.primary,
                              onPrimary: Colors.white,
                              surface: Color(0xFF1E293B),
                              onSurface: Colors.white,
                            )
                          : const ColorScheme.light(
                              primary: AppColors.primary,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black87,
                            ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) setDialogState(() => selectedBirthDate = picked);
            }

            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('edit_personal_info'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            icon: const Icon(Icons.close_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: buildInputDecoration(context.l10n.fullName, Icons.person_rounded),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        keyboardType: TextInputType.emailAddress,
                        decoration: buildInputDecoration(context.l10n.emailAddress, Icons.email_rounded),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        keyboardType: TextInputType.phone,
                        decoration: buildInputDecoration(context.l10n.phoneNumber, Icons.phone_rounded),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: heightController,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              keyboardType: TextInputType.number,
                              decoration: buildInputDecoration(context.l10n.heightLabel, Icons.height_rounded),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: weightController,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              keyboardType: TextInputType.number,
                              decoration: buildInputDecoration(context.tr('current_weight'), Icons.fitness_center_rounded),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: pickBirthDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.01),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cake_rounded, color: AppColors.primary.withValues(alpha: 0.7)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.birthDate,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _dateText(context, selectedBirthDate),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.edit_calendar_rounded, color: AppColors.primary.withValues(alpha: 0.7), size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                              ),
                              child: Text(
                                context.l10n.cancel,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                backgroundColor: AppColors.primary,
                                elevation: 2,
                                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                              ),
                              child: Text(
                                context.l10n.save,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
          SnackBar(
            content: Text(context.tr('personal_info_updated')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.primary,
          ),
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
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 120),
          children: [
            const PremiumAppbar(),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: profile.photoPath != null && profile.photoPath!.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(File(profile.photoPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile.photoPath == null || profile.photoPath!.isEmpty
                        ? Center(
                            child: Text(
                              profile.name.isNotEmpty ? profile.name.trim().substring(0, 1).toUpperCase() : 'G',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name.isNotEmpty ? profile.name : context.tr('guest_user'),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      context.l10n.vitaBadge,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: .2),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('physical_metrics') != 'Physical Metrics' ? context.tr('physical_metrics') : 'Fiziksel Ölçümler',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
                ),
                IconButton.filledTonal(
                  onPressed: () => _showEditDialog(context, ref, profile),
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  tooltip: context.tr('edit'),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BmiCard(profile: profile).animate().fadeIn(delay: 100.ms).slideY(begin: .15),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.personalInfo,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
                ),
                TextButton.icon(
                  onPressed: () => _showEditDialog(context, ref, profile),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(context.tr('edit')),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
