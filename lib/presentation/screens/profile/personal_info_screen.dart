import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/medical_info_providers.dart';
import '../../widgets/profile/radial_bmi_gauge.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/banner_ad_container.dart';

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = ref.watch(profileNameProvider) ?? context.l10n('guest_user');
    final job = ref.watch(profileJobProvider) ?? context.l10n('default_job');
    final photo = ref.watch(profilePhotoProvider);
    final height = ref.watch(profileHeightProvider) ?? 174.0;
    final weight = ref.watch(profileWeightProvider) ?? 68.0;
    final age = ref.watch(profileAgeProvider) ?? 28;
    final bmiData = ref.watch(bmiResultProvider) ?? {
      'score': 22.4,
      'category': context.l10n('bmi_ideal'),
    };

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: isDark ? Colors.white : AppColors.medicalBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n('personal_info'),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.medicalBlue,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
// ...
      body: Column(
        children: [
          const BannerAdContainer(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  _buildUserHero(context, name, job, photo, isDark),
            const SizedBox(height: 32),
            _buildBmiSection(bmiData['score'] as double, bmiData['category'] as String, isDark),
            const SizedBox(height: 32),
            _buildMetricsGrid(context, ref, height, weight, age, isDark),
            const SizedBox(height: 40),
            _buildContactSection(context, ref, isDark),
            const SizedBox(height: 48),
            _buildUpdateButton(context, ref),
            const SizedBox(height: 100),
          ],
        ),
      ),
    ),
        ],
      ),
    );
  }

  Widget _buildUserHero(BuildContext context, String name, String job, String? photo, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.medicalBlue, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
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
                  decoration: const BoxDecoration(color: AppColors.medicalBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 4),
          Text(
            job,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(context.l10n('active').toUpperCase(), const Color(0xFFEEF2FF), const Color(0xFF6366F1)),
              const SizedBox(width: 8),
              _buildBadge(context.l10n('verified').toUpperCase(), const Color(0xFFECFDF5), const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: text, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildBmiSection(double score, String category, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: RadialBmiGauge(bmi: score, category: category),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildMetricsGrid(BuildContext context, WidgetRef ref, double height, double weight, int age, bool isDark) {
    final medicalRecords = ref.watch(medicalRecordListProvider).asData?.value ?? [];
    final bloodType = medicalRecords.isNotEmpty 
        ? (medicalRecords.where((r) => r.title.toLowerCase().contains(context.l10n('blood_type').toLowerCase())).firstOrNull?.description ?? context.l10n('blood_type_val'))
        : context.l10n('blood_type_val');

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _MetricCard(icon: Icons.unfold_more_rounded, value: '${height.toInt()} cm', label: context.l10n('height_label').toUpperCase(), color: AppColors.medicalBlue),
        _MetricCard(icon: Icons.work_history_rounded, value: '${weight.toInt()} kg', label: context.l10n('weight_label').toUpperCase(), color: const Color(0xFF6366F1)),
        _MetricCard(icon: Icons.bloodtype_rounded, value: bloodType, label: context.l10n('blood_type').toUpperCase(), color: AppColors.error),
        _MetricCard(icon: Icons.cake_rounded, value: '$age ${context.l10n('age_label')}', label: context.l10n('age_label').toUpperCase(), color: const Color(0xFF14B8A6)),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildContactSection(BuildContext context, WidgetRef ref, bool isDark) {
    final phone = ref.watch(profilePhoneProvider) ?? '+90 5XX XXX XX XX';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n('identity_contact'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              _InfoRow(icon: Icons.badge_outlined, label: context.l10n('id_number').toUpperCase(), value: ref.watch(profileIdNumberProvider) ?? '123******89'),
              const Divider(height: 32),
              _InfoRow(icon: Icons.email_outlined, label: context.l10n('email').toUpperCase(), value: ref.watch(profileEmailProvider) ?? 'user@vitacase.app'),
              const Divider(height: 32),
              _InfoRow(icon: Icons.phone_outlined, label: context.l10n('phone').toUpperCase(), value: phone),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildUpdateButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () => _showEditSheet(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.medicalBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(
          context.l10n('update_info'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    context.push(AppRoutes.profileEdit);
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.medicalBlue.withValues(alpha: 0.1),
      child: const Icon(Icons.person_rounded, color: AppColors.medicalBlue, size: 40),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textTertiary, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.medicalBlue.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: isDark ? AppColors.medicalBlue : AppColors.textPrimary, size: 22),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textTertiary, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}
