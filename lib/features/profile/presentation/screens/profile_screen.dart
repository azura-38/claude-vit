import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/legacy_providers.dart';
import '../../data/services/mock_profile_service.dart';
import '../../../../shared/providers/health_providers.dart';
import '../../../../shared/providers/medical_info_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/data/services/wipe_service.dart';
import '../../../../core/utils/external_launcher.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = ref.watch(profileNameProvider) ?? context.l10n('guest_user');
    final gender = ref.watch(profileGenderProvider) ?? context.l10n('not_set');
    final age = ref.watch(profileAgeProvider);
    final photo = ref.watch(profilePhotoProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildAppBar(context, ref, isDark),
              const SizedBox(height: 32),
              _buildUserHero(name, gender, age, photo, isDark, context, ref),
              const SizedBox(height: 48),
              _buildEmergencyCard(context, ref, isDark),
              const SizedBox(height: 40),
              _buildActiveGoals(context, ref, isDark),
              const SizedBox(height: 40),
              _buildSectionTitle(context.l10n('personal_health_data'), isDark),
              const SizedBox(height: 16),
              _buildNavigationItem(
                icon: Icons.person_outline_rounded,
                title: context.l10n('personal_info'),
                onTap: () => context.push(AppRoutes.personalInfo),
                isDark: isDark,
              ),
              _buildNavigationItem(
                 icon: Icons.assignment_outlined,
                title: context.l10n('important_info'),
                onTap: () => context.push(AppRoutes.medicalInfo),
                isDark: isDark,
              ),
              _buildNavigationItem(
                icon: Icons.emoji_events_outlined,
                title: context.l10n('medals_trophies'),
                onTap: () => context.push(AppRoutes.achievements),
                isDark: isDark,
              ),
              const SizedBox(height: 40),
              _buildSectionTitle(context.l10n('account_settings'), isDark),

              const SizedBox(height: 16),
              _buildNavigationItem(
                icon: Icons.settings_outlined,
                title: context.l10n('app_settings'),
                onTap: () => context.push(AppRoutes.settings),
                isDark: isDark,
              ),
              _buildNavigationItem(
                icon: Icons.bug_report_outlined,
                title: context.l10n('report_issue'),
                onTap: () => ExternalLauncher.launchEmail(
                  'limanexsoftware@outlook.com',
                  subject: 'VitaCase Error Report',
                  body: '\n\n---\nDevice info: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
                ),
                isDark: isDark,
              ),
              _buildNavigationItem(
                icon: Icons.delete_forever_rounded,
                title: context.l10n('delete_all_data'),
                titleColor: AppColors.error,
                onTap: () => _showDeleteAllDialog(context, ref),
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              if (kDebugMode)
                ElevatedButton(
                  onPressed: () => throw StateError('Sentry Integration Test - VitaCase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    foregroundColor: AppColors.error,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(context.l10n('verify_sentry'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.person_pin_rounded, color: isDark ? Colors.white70 : AppColors.medicalBlue),
            const SizedBox(width: 16),
            Text(
              context.l10n('profile'),
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
              onPressed: () {
                final profile = ref.read(profileDataProvider).asData?.value;
                context.push(AppRoutes.profileEdit, extra: profile);
              },
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: Text(context.l10n('edit'), style: const TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.blue.shade300 : AppColors.medicalBlue,
                backgroundColor: (isDark ? Colors.blue : AppColors.medicalBlue).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push(AppRoutes.settings),
              child: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : AppColors.medicalBlue),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickAndSavePhoto(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      await ref.read(profileServiceProvider).updateProfilePhoto(result.files.single.path!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n('success'))),
        );
      }
    }
  }

  Widget _buildUserHero(String name, String gender, int? age, String? photo, bool isDark, BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickAndSavePhoto(context, ref),
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                 child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: photo != null && !photo.startsWith('http')
                      ? Image.file(
                          File(photo),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildAvatarPlaceholder(),
                        )
                      : _buildAvatarPlaceholder(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.medicalBlue, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Manrope')),
        const SizedBox(height: 4),
          Text(
            '$gender • ${age ?? "?"} ${context.l10n('years_old')}',
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildEmergencyCard(BuildContext context, WidgetRef ref, bool isDark) {
    final medicalRecords = ref.watch(medicalRecordListProvider).asData?.value ?? [];
    
    // 🧠 Bind directly to profile providers for consistency
    final bloodType = ref.watch(profileBloodTypeProvider);
    final emergencyContact = ref.watch(profileEmergencyContactProvider);
    final emergencyPhone = ref.watch(profileEmergencyPhoneProvider);
    
    final allergyRecords = medicalRecords.where((r) => r.title.toLowerCase().contains('alerji') || r.title.toLowerCase().contains('allergy')).toList();
    final allergies = allergyRecords.isNotEmpty ? allergyRecords.map((e) => e.title.split(' ').first).join(', ') : context.l10n('none');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context.l10n('emergency_card'), isDark),
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
                  Expanded(child: _buildEmergencyInfo(context, context.l10n('blood_type'), bloodType, AppColors.error, isDark)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildEmergencyInfo(context, context.l10n('allergies'), allergies, AppColors.error, isDark)),
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
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.contact_phone_rounded, color: AppColors.error, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.profileEdit),
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.l10n('emergency_contact'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(emergencyContact, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.error)),
                            if (emergencyPhone.isNotEmpty)
                              Text(emergencyPhone, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error.withValues(alpha: 0.7))),
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
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8), borderRadius: BorderRadius.circular(20)),
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

  Widget _buildActiveGoals(BuildContext context, WidgetRef ref, bool isDark) {
    final progress = ref.watch(dailyHealthProgressProvider);
    final stepGoal = ref.watch(stepGoalProvider);
    final waterGoal = ref.watch(waterGoalProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context.l10n('active_goals'), isDark),
            const Icon(Icons.bolt_rounded, color: AppColors.medicalBlue, size: 18),
          ],
        ),
        const SizedBox(height: 16),
        _buildGoalProgress(
          context: context,
          icon: Icons.directions_walk_rounded,
          title: context.l10n('daily_steps'),
          current: progress['steps']!.toInt(),
          target: stepGoal,
          unit: context.l10n('steps'),
          accentColor: AppColors.medicalBlue,
          actionLabel: context.l10n('speed_up'),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildGoalProgress(
          context: context,
          icon: Icons.water_drop_rounded,
          title: context.l10n('water_intake'),
          current: (progress['water']! / 1000).toInt(),
          target: (waterGoal / 1000).toInt(),
          unit: context.l10n('liter_unit'),
          accentColor: const Color(0xFF00B4D8),
          actionLabel: context.l10n('stay_fresh'),
          isDark: isDark,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildGoalProgress({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int current,
    required int target,
    required String unit,
    required Color accentColor,
    required String actionLabel,
    required bool isDark,
  }) {
    final percent = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Manrope')),
                    Text('${context.l10n('target_label')}: $target $unit',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: accentColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$current / $target $unit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              Text(actionLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: titleColor ?? (isDark ? Colors.white70 : Colors.black87), size: 24),
        ),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: titleColor ?? (isDark ? Colors.white : Colors.black87), fontFamily: 'Manrope')),
        trailing: Icon(Icons.chevron_right_rounded, size: 20, color: titleColor?.withValues(alpha: 0.5) ?? AppColors.textTertiary),
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
  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n('delete_all_data'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
        content: Text(
          context.l10n('wipe_confirm_1'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.l10n('cancel')),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await WipeService.fullWipe();
              if (context.mounted) {
                context.go(AppRoutes.onboarding);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              context.l10n('wipe_btn_final'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.primaryIndigo.withValues(alpha: 0.1),
      child: const Icon(Icons.person_rounded, color: AppColors.primaryIndigo, size: 40),
    );
  }
}
