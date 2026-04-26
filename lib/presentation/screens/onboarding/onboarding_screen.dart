import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../providers/onboarding_provider.dart';
import '../../../core/di/service_providers.dart';
import '../../../data/services/analytics_service.dart';
import '../../../core/types/runtime_types.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _disclaimerAccepted = false;

  Widget _buildMandatoryCheckbox(String label, bool value, ValueChanged<bool?> onChanged, VoidCallback onLink, bool isDark) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF005DA7),
            side: BorderSide(color: isDark ? Colors.white38 : Colors.black26),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onLink,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12, 
                  color: isDark ? Colors.white70 : Colors.blueGrey, 
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _goToProfileCreate() {
    context.go(AppRoutes.profileCreate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _OnboardingPage(
                    title: context.l10n('ob_1_title'),
                    subtitle: context.l10n('ob_1_subtitle'),
                    description: context.l10n('ob_1_desc'),
                    visual: _LogoMockup(isDark: isDark),
                    isDark: isDark,
                  ),
                  _OnboardingPage(
                    title: context.l10n('ob_2_title'),
                    description: context.l10n('ob_2_desc'),
                    visual: _FolderMockup(isDark: isDark),
                    isDark: isDark,
                  ),
                  _OnboardingPage(
                    title: context.l10n('ob_3_title'),
                    description: context.l10n('ob_3_desc'),
                    visual: _CalendarMockup(isDark: isDark),
                    isDark: isDark,
                  ),
                  _OnboardingPage(
                    title: context.l10n('ob_4_title'),
                    description: context.l10n('ob_4_desc'),
                    visual: _MedicineMockup(isDark: isDark),
                    isDark: isDark,
                  ),
                  _OnboardingPage(
                    title: context.l10n('ob_5_title'),
                    description: context.l10n('ob_5_desc'),
                    visual: _SummaryMockup(isDark: isDark),
                    isDark: isDark,
                    features: [
                      _FeatureItem(title: context.l10n('ob_feature_3_title'), desc: context.l10n('ob_feature_3_desc'), icon: Icons.cloud_done_rounded),
                    ],
                  ),
                  _buildChecklistPage(isDark),
                ],
              ),
            ),
            _buildNavigationScope(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationScope(BuildContext context, bool isDark) {
    final isLast = _currentPage == 5;
    final checklistDone = ref.watch(onboardingChecklistProvider).allDone;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLast) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (!(_termsAccepted && _privacyAccepted && _disclaimerAccepted && checklistDone)) ? null : () {
                  AnalyticsService.log(AnalyticsService.termsAccepted);
                  AnalyticsService.log(AnalyticsService.disclaimerAccepted);
                  AnalyticsService.log(AnalyticsService.privacyAccepted);
                  AnalyticsService.log(AnalyticsService.onboardingComplete, {'mode': 'free'});
                  _goToProfileCreate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "Start securely",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
          ] else
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005DA7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n('continue'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          if (isLast) ...[
            const SizedBox(height: 16),
            _buildMandatoryCheckbox(
              "I agree to Terms & Conditions", 
              _termsAccepted, 
              (v) => setState(() => _termsAccepted = v ?? false),
              () => context.pushNamed('settingsTerms'),
              isDark,
            ),
            _buildMandatoryCheckbox(
              "I agree to Privacy Policy", 
              _privacyAccepted, 
              (v) => setState(() => _privacyAccepted = v ?? false),
              () => context.pushNamed('settingsPrivacy'),
              isDark,
            ),
            _buildMandatoryCheckbox(
              "I agree to Medical Disclaimer", 
              _disclaimerAccepted, 
              (v) => setState(() => _disclaimerAccepted = v ?? false),
              () => context.pushNamed('settingsDisclaimer'),
              isDark,
            ),
          ],
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              6,
              (index) => AnimatedContainer(
                duration: 300.ms,
                width: _currentPage == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: _currentPage == index ? const Color(0xFF005DA7) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildChecklistPage(bool isDark) {
    final checklist = ref.watch(onboardingChecklistProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Ready to launch? 🚀",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 12),
          const Text(
            "Complete these steps to ensure the best experience.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 48),
          _checklistTile(
            "Create Your Profile",
            "Tell us about yourself for personalized health tracking.",
            checklist.profileCreated,
            () => ref.read(onboardingChecklistProvider.notifier).update((s) => s.copyWith(profileCreated: true)),
          ),
          _checklistTile(
            "Add First Document",
            "Securely upload your first report or prescription.",
            checklist.documentAdded,
            () => ref.read(onboardingChecklistProvider.notifier).update((s) => s.copyWith(documentAdded: true)),
          ),
          _checklistTile(
            "Enable Notifications",
            "Never miss an appointment or medication time.",
            checklist.notificationsEnabled,
            () async {
              final status = await ref.read(notificationServiceProvider).requestPermissions();
              if (status == NotificationPermissionState.granted) {
                ref.read(onboardingChecklistProvider.notifier).update((s) => s.copyWith(notificationsEnabled: true));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _checklistTile(String title, String desc, bool done, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: done ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: done ? Colors.green.withValues(alpha: 0.05) : Colors.blueGrey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: done ? Colors.green.withValues(alpha: 0.2) : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: done ? Colors.green : Colors.blueGrey,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(desc, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String description;
  final Widget visual;
  final List<_FeatureItem>? features;
  final bool isDark;

  const _OnboardingPage({
    required this.title,
    this.subtitle,
    required this.description,
    required this.visual,
    this.features,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: Center(child: visual)),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF001C39),
              fontFamily: 'Manrope',
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF005DA7),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
          ],
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.blueGrey,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          if (features != null) ...[
            const SizedBox(height: 32),
            ...features!.map((f) => _buildFeatureRow(f, isDark)),
          ],
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(_FeatureItem f, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF005DA7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(f.icon, color: const Color(0xFF005DA7), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                Text(f.desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1);
  }
}

class _FeatureItem {
  final String title;
  final String desc;
  final IconData icon;
  _FeatureItem({required this.title, required this.desc, required this.icon});
}

// Visual Mockups mimicking the provided image
class _LogoMockup extends StatelessWidget {
  final bool isDark;
  const _LogoMockup({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF005DA7),
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(color: const Color(0xFF005DA7).withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: const Center(
        child: Text(
          "V",
          style: TextStyle(fontSize: 100, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Manrope'),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds);
  }
}

class _FolderMockup extends StatelessWidget {
  final bool isDark;
  const _FolderMockup({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _buildDeviceFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mockupRow(Icons.picture_as_pdf_rounded, "Tahlil.pdf", Colors.red),
          _mockupRow(Icons.image_rounded, "Röntgen.jpg", Colors.blue),
          _mockupRow(Icons.article_rounded, "Reçete.pdf", Colors.green),
          _mockupRow(Icons.description_rounded, "Rapor.doc", Colors.teal),
        ],
      ),
    );
  }
}

class _CalendarMockup extends StatelessWidget {
  final bool isDark;
  const _CalendarMockup({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _buildDeviceFrame(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.calendar_today_rounded, color: Colors.blue, size: 40),
          ),
          const SizedBox(height: 16),
          _mockupRow(Icons.medical_services_rounded, "Diş Randevusu", Colors.orange),
          _mockupRow(Icons.health_and_safety_rounded, "Kontrol", Colors.blue),
        ],
      ),
    );
  }
}

class _MedicineMockup extends StatelessWidget {
  final bool isDark;
  const _MedicineMockup({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _buildDeviceFrame(
      child: Column(
        children: [
          _mockupRow(Icons.medication_rounded, "Aspirin - 08:00", Colors.blue),
          _mockupRow(Icons.medication_liquid_rounded, "Vitamin - 12:00", Colors.orange),
          _mockupRow(Icons.vaccines_rounded, "Antibiyotik - 20:00", Colors.red),
        ],
      ),
    );
  }
}

class _SummaryMockup extends StatelessWidget {
  final bool isDark;
  const _SummaryMockup({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(color: const Color(0xFF005DA7), borderRadius: BorderRadius.circular(40)),
          child: const Icon(Icons.lock_rounded, color: Colors.white, size: 64),
        ),
        Transform.translate(
          offset: const Offset(-50, 40),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
            child: const Icon(Icons.cloud_done_rounded, color: Colors.blue, size: 24),
          ),
        ),
        Transform.translate(
          offset: const Offset(50, -40),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.orange, size: 24),
          ),
        ),
      ],
    ).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(begin: 0, end: 0.1, duration: 3.seconds);
  }
}

Widget _buildDeviceFrame({required Widget child}) {
  return Container(
    width: 220,
    height: 320,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 15))],
      border: Border.all(color: Colors.black.withValues(alpha: 0.02), width: 1),
    ),
    child: child,
  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
}

Widget _mockupRow(IconData icon, String text, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 8, decoration: BoxDecoration(color: Colors.blueGrey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)))),
      ],
    ),
  );
}
