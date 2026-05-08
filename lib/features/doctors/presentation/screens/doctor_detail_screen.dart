import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/domain/entities/doctor.dart';
import '../../../../shared/providers/doctor_providers.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/misc/app_header.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/misc/banner_ad_container.dart';

class DoctorDetailScreen extends ConsumerWidget {
  final String id;
  const DoctorDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final doctorsAsync = ref.watch(doctorListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n('error'))),
        data: (doctors) {
          final doctor = doctors.where((d) => d.id == id).firstOrNull;
          if (doctor == null) {
            return Center(child: Text(context.l10n('page_not_found')));
          }

// ...
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                const BannerAdContainer(),
                AppHeader(
                  title: '${doctor.localizedTitle(context)} ${doctor.name}',
                  showBack: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildHero(context, doctor, isDark),
                        const SizedBox(height: 32),
                        _buildSection(
                          context,
                          label: context.l10n('basic_info'),
                          isDark: isDark,
                          children: [
                            _infoTile(context, Icons.local_hospital_rounded, context.l10n('doctors_add_hospital'), doctor.hospital, isDark),
                            _infoTile(context, Icons.category_rounded, context.l10n('doctors_add_dept'), doctor.department, isDark),
                            if (doctor.subSpecialty != null)
                              _infoTile(context, Icons.stars_rounded, context.l10n('doctors_add_sub'), doctor.subSpecialty!, isDark),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSection(
                          context,
                          label: context.l10n('contact_info'),
                          isDark: isDark,
                          children: [
                            if (doctor.phone != null)
                              _infoTile(
                                context, 
                                Icons.phone_rounded, 
                                context.l10n('phone'), 
                                doctor.phone!, 
                                isDark,
                                trailing: IconButton(
                                  icon: const Icon(Icons.call, color: AppColors.primaryIndigo, size: 20),
                                  onPressed: () => _launchCaller(doctor.phone!),
                                ),
                              ),
                            if (doctor.email != null)
                              _infoTile(
                                context, 
                                Icons.email_rounded, 
                                context.l10n('email'), 
                                doctor.email!, 
                                isDark,
                                trailing: IconButton(
                                  icon: const Icon(Icons.mail_rounded, color: AppColors.medicalBlue, size: 20),
                                  onPressed: () => _launchEmail(doctor.email!),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (doctor.notes != null && doctor.notes!.isNotEmpty)
                          _buildSection(
                            context,
                            label: context.l10n('docs_add_note'),
                            isDark: isDark,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                                ),
                                child: Text(
                                  doctor.notes!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context, Doctor doctor, bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.medicalBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.medicalBlue.withValues(alpha: 0.2), width: 4),
          ),
          child: Center(
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: AppColors.medicalBlue.withValues(alpha: 0.5),
            ),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${doctor.localizedTitle(context)} ${doctor.name}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
            ),
            if (doctor.isVerified) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified_rounded, color: AppColors.primaryIndigo, size: 20),
            ],
          ],
        ),
        Text(
          doctor.department,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white38 : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String label, required List<Widget> children, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isDark ? Colors.white38 : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _infoTile(BuildContext context, IconData icon, String label, String value, bool isDark, {Widget? trailing}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.medicalBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.medicalBlue),
      ),
      title: Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.textTertiary, fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      trailing: trailing,
    );
  }

  Future<void> _launchCaller(String p) async {
    final url = Uri.parse('tel:$p');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _launchEmail(String e) async {
    final url = Uri.parse('mailto:$e');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }
}
