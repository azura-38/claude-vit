import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/domain/entities/doctor.dart';
import '../../../../shared/providers/doctor_providers.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/misc/app_header.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DoctorDetailScreen extends ConsumerWidget {
  const DoctorDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final doctorsAsync = ref.watch(doctorListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.error)),
        data: (doctors) {
          final contact = doctors.where((d) => d.id == id).firstOrNull;
          if (contact == null) {
            return Center(child: Text(context.l10n.pageNotFound));
          }

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppHeader(title: context.l10n.contactDetailTitle, showBack: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildHero(context, contact, isDark),
                        const SizedBox(height: 32),
                        _buildSection(
                          context,
                          label: context.l10n.basicInfo,
                          isDark: isDark,
                          children: [
                            _infoTile(
                              context,
                              Icons.business_rounded,
                              context.l10n.institutionSource,
                              contact.hospital,
                              isDark,
                            ),
                            _infoTile(
                              context,
                              Icons.category_rounded,
                              context.l10n.categoryArea,
                              contact.department,
                              isDark,
                            ),
                            if (contact.subSpecialty != null)
                              _infoTile(
                                context,
                                Icons.stars_rounded,
                                context.l10n.subArea,
                                contact.subSpecialty!,
                                isDark,
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSection(
                          context,
                          label: context.l10n.contactInfo,
                          isDark: isDark,
                          children: [
                            if (contact.phone != null)
                              _infoTile(
                                context,
                                Icons.phone_rounded,
                                context.l10n.phone,
                                contact.phone!,
                                isDark,
                                trailing: IconButton(
                                  icon: const Icon(Icons.call, color: AppColors.primaryIndigo, size: 20),
                                  onPressed: () => _launchCaller(contact.phone!),
                                ),
                              ),
                            if (contact.email != null)
                              _infoTile(
                                context,
                                Icons.email_rounded,
                                context.l10n.email,
                                contact.email!,
                                isDark,
                                trailing: IconButton(
                                  icon: const Icon(Icons.mail_rounded, color: AppColors.medicalBlue, size: 20),
                                  onPressed: () => _launchEmail(contact.email!),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (contact.notes != null && contact.notes!.isNotEmpty)
                          _buildSection(
                            context,
                            label: context.l10n.docsAddNote,
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
                                  contact.notes!,
                                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.5),
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

  Widget _buildHero(BuildContext context, Doctor contact, bool isDark) {
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
            child: Icon(Icons.contact_phone_rounded, size: 50, color: AppColors.medicalBlue.withValues(alpha: 0.5)),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                contact.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (contact.isVerified) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified_rounded, color: AppColors.primaryIndigo, size: 20),
            ],
          ],
        ),
        Text(
          contact.department,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white38 : AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String label,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: isDark ? Colors.white38 : AppColors.textTertiary),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.medicalBlue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: AppColors.medicalBlue),
      ),
      title: Text(
        label,
        style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.textTertiary, fontWeight: FontWeight.w600),
      ),
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
