import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/providers/onboarding_provider.dart';
import '../../../../core/di/service_providers.dart';
import '../../../../shared/data/services/analytics_service.dart';
import '../../../../core/types/runtime_types.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _notificationsGranted = false;

  static const _totalPages = 6;
  static const _brandLogoAsset = 'assets/images/vitacase_brand_logo.png';
  static const _featureOverviewAsset =
      'assets/images/vitacase_feature_overview.png';

  void _goToProfileCreate() {
    ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    AnalyticsService.log(AnalyticsService.onboardingComplete, {'mode': 'free'});
    context.go(AppRoutes.profileCreate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7FAFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  // Page 1: Welcome
                  _ModernPage(
                    visual: const _BrandLogoVisual(assetPath: _brandLogoAsset),
                    title: context.l10n.ob1Title,
                    subtitle: context.l10n.ob1Subtitle,
                    description: context.l10n.ob1Desc,
                    isDark: isDark,
                  ),
                  // Page 2: Documents
                  _ModernPage(
                    visual: const _FeatureOverviewVisual(
                      assetPath: _featureOverviewAsset,
                    ),
                    title: context.l10n.ob2Title,
                    description: context.l10n.ob2Desc,
                    isDark: isDark,
                  ),
                  // Page 3: Appointments
                  _ModernPage(
                    visual: _FeatureVisual(
                      icon: Icons.calendar_today_rounded,
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                    title: context.l10n.ob3Title,
                    description: context.l10n.ob3Desc,
                    isDark: isDark,
                  ),
                  // Page 4: Medicines
                  _ModernPage(
                    visual: _FeatureVisual(
                      icon: Icons.medication_rounded,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                    title: context.l10n.ob4Title,
                    description: context.l10n.ob4Desc,
                    isDark: isDark,
                  ),
                  // Page 5: Security & Privacy
                  _ModernPage(
                    visual: const _BrandLogoVisual(
                      assetPath: _brandLogoAsset,
                      compact: true,
                    ),
                    title: context.l10n.ob5Title,
                    description: context.l10n.ob5Desc,
                    isDark: isDark,
                    features: [
                      _FeatureRow(
                        icon: Icons.lock_rounded,
                        title: context.l10n.obFeature1Title,
                        desc: context.l10n.obFeature1Desc,
                      ),
                      _FeatureRow(
                        icon: Icons.notifications_active_rounded,
                        title: context.l10n.obFeature2Title,
                        desc: context.l10n.obFeature2Desc,
                      ),
                      _FeatureRow(
                        icon: Icons.cloud_done_rounded,
                        title: context.l10n.obFeature3Title,
                        desc: context.l10n.obFeature3Desc,
                      ),
                    ],
                  ),
                  // Page 6: Notifications & Get Started
                  _buildNotificationPage(isDark),
                ],
              ),
            ),
            _buildBottomNavigation(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandBlue.withValues(alpha: 0.12),
                  AppColors.brandCyan.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _notificationsGranted
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_outlined,
              size: 64,
              color:
                  _notificationsGranted
                      ? const Color(0xFF10B981)
                      : AppColors.brandBlue,
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 500.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 32),
          Text(
            _notificationsGranted ? '🎉' : '🔔',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 16),
          Text(
            _notificationsGranted
                ? context.l10n.notificationsActiveMsg
                : context.l10n.obFeature2Title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontFamily: 'Manrope',
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            context.l10n.obFeature2Desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.blueGrey,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 40),
          if (!_notificationsGranted)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final status = await ref
                      .read(notificationServiceProvider)
                      .requestPermissions(requestExactAlarm: true);
                  if (status == NotificationPermissionState.granted) {
                    setState(() => _notificationsGranted = true);
                  }
                },
                icon: const Icon(Icons.notifications_active_rounded),
                label: Text(
                  context.l10n.obFeature2Title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms)
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.notificationsActiveMsg,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(bool isDark) {
    final isLast = _currentPage == _totalPages - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (isLast) {
                  _goToProfileCreate();
                } else {
                  _pageController.nextPage(
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLast ? AppColors.brandNavy : AppColors.brandBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? context.l10n.letStart : context.l10n.continue_btn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLast
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Page dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalPages,
              (index) => AnimatedContainer(
                duration: 300.ms,
                width: _currentPage == index ? 28 : 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color:
                      _currentPage == index
                          ? AppColors.brandBlue
                          : (isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15);
  }
}

// --- Modern Page Widget ---
class _ModernPage extends StatelessWidget {
  final Widget visual;
  final String title;
  final String? subtitle;
  final String description;
  final bool isDark;
  final List<_FeatureRow>? features;

  const _ModernPage({
    required this.visual,
    required this.title,
    this.subtitle,
    required this.description,
    required this.isDark,
    this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: Center(child: visual)),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.brandNavy,
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
                color: AppColors.brandBlue,
              ),
            ).animate().fadeIn(delay: 100.ms),
          ],
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : const Color(0xFF546179),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 200.ms),
          if (features != null) ...[
            const SizedBox(height: 28),
            ...features!.map((f) => _buildFeatureRow(f)),
          ],
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(_FeatureRow f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(f.icon, color: AppColors.brandBlue, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  f.desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1);
  }
}

class _FeatureRow {
  final IconData icon;
  final String title;
  final String desc;
  _FeatureRow({required this.icon, required this.title, required this.desc});
}

// --- Visual Widgets ---

class _BrandLogoVisual extends StatelessWidget {
  final String assetPath;
  final bool compact;

  const _BrandLogoVisual({required this.assetPath, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: compact ? 190 : 230,
          height: compact ? 190 : 230,
          padding: EdgeInsets.all(compact ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 42 : 52),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBlue.withValues(alpha: 0.16),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.03, 1.03),
          duration: 2600.ms,
        );
  }
}

class _FeatureOverviewVisual extends StatelessWidget {
  final String assetPath;

  const _FeatureOverviewVisual({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBlue.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AspectRatio(
              aspectRatio: 1.75,
              child: Image.asset(assetPath, fit: BoxFit.cover),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.96, 0.96), duration: 600.ms);
  }
}

class _FeatureVisual extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  const _FeatureVisual({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Center(child: Icon(icon, size: 72, color: Colors.white)),
    ).animate().fadeIn().scale(
      begin: const Offset(0.85, 0.85),
      duration: 600.ms,
    );
  }
}
