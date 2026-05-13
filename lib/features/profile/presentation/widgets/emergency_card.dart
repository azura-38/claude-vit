import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/external_launcher.dart';
import '../providers/profile_controller.dart';
import '../../../../shared/providers/medical_info_providers.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class EmergencyCard extends ConsumerWidget {
  final bool isDark;
  
  const EmergencyCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicalRecords = ref.watch(medicalRecordListProvider).asData?.value ?? [];
    final profileController = ref.watch(profileControllerProvider.notifier);

    final rawBloodType = profileController.bloodType;
    final bloodType = rawBloodType == 'not_added' ? context.l10n.notAdded : rawBloodType;
    final emergencyContact = profileController.emergencyName;
    final emergencyPhone = profileController.emergencyPhone;

    final allergyRecords = medicalRecords.where((r) =>
        r.title.toLowerCase().contains('alerji') ||
        r.title.toLowerCase().contains('allergy')).toList();
    
    final allergies = allergyRecords.isNotEmpty
        ? allergyRecords.map((e) => e.title.split(' ').first).join(', ')
        : context.l10n.none;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context.l10n.emergencyCard, isDark),
            const Icon(Icons.favorite_rounded, color: AppColors.error, size: 18),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.error.withValues(alpha: 0.05) : const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildEmergencyInfo(context, context.l10n.bloodType, bloodType, AppColors.error, isDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEmergencyInfo(context, context.l10n.allergies, allergies, AppColors.error, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.contact_phone_rounded, color: AppColors.error, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.profileEdit),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.emergencyContact,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              emergencyContact,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.error),
                            ),
                            if (emergencyPhone.isNotEmpty)
                              Text(
                                emergencyPhone,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error.withValues(alpha: 0.7)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (emergencyPhone.isNotEmpty)
                      IconButton(
                        onPressed: () => ExternalLauncher.launchPhoneCall(emergencyPhone),
                        icon: const Icon(Icons.call_rounded, color: AppColors.error),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.error.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: () => context.push(AppRoutes.profileEdit),
                        icon: const Icon(Icons.edit_rounded, color: AppColors.error, size: 20),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
  }

  Widget _buildEmergencyInfo(BuildContext context, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color.withValues(alpha: 0.6), letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white70 : AppColors.textPrimary,
        fontFamily: 'Manrope',
      ),
    );
  }
}
