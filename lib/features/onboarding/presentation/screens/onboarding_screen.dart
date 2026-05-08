import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/l10n/app_localizations.dart';
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

  void _goToProfileCreate() {
    ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    AnalyticsService.log(AnalyticsService.onboardingComplete, {'mode': 'free'});
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
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  // Page 1: Welcome
                  _ModernPage(
                    visual: _AnimatedLogo(isDark: isDark),
                    title: context.l10n('ob_1_title'),
                    subtitle: context.l10n('ob_1_subtitle'),
                    description: context.l10n('ob_1_desc'),
                    isDark: isDark,
                  ),
                  // Page 2: Documents
                  _ModernPage(
                    visual: _FeatureVisual(
                      icon: Icons.folder_rounded,
                      color: const Color(0xFF3B82F6),
                      isDark: isDark,
                    ),
                    title: context.l10n('ob_2_title'),
                    description: context.l10n('ob_2_desc'),
                    isDark: isDark,
                  ),
                  // Page 3: Appointments
                  _ModernPage(
                    visual: _FeatureVisual(
                      icon: Icons.calendar_today_rounded,
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                    title: context.l10n('ob_3_title'),
                    description: context.l10n('ob_3_desc'),
                    isDark: isDark,
                  ),
                  // Page 4: Medicines
                  _ModernPage(
                    visual: _FeatureVisual(
                      icon: Icons.medication_rounded,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                    title: context.l10n('ob_4_title'),
                    description: context.l10n('ob_4_desc'),
                    isDark: isDark,
                  ),
                  // Page 5: Security & Privacy
                  _ModernPage(
                    visual: _SecurityVisual(isDark: isDark),
                    title: context.l10n('ob_5_title'),
                    description: context.l10n('ob_5_desc'),
                    isDark: isDark,
                    features: [
                      _FeatureRow(
                        icon: Icons.lock_rounded,
                        title: context.l10n('ob_feature_1_title'),
                        desc: context.l10n('ob_feature_1_desc'),
                      ),
                      _FeatureRow(
                        icon: Icons.notifications_active_rounded,
                        title: context.l10n('ob_feature_2_title'),
                        desc: context.l10n('ob_feature_2_desc'),
                      ),
                      _FeatureRow(
                        icon: Icons.cloud_done_rounded,
                        title: context.l10n('ob_feature_3_title'),
                        desc: context.l10n('ob_feature_3_desc'),
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
                  const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _notificationsGranted
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_outlined,
              size: 64,
              color: _notificationsGranted
                  ? const Color(0xFF10B981)
                  : const Color(0xFF3B82F6),
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
                ? context.l10n('notifications_active_msg')
                : context.l10n('ob_feature_2_title'),
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
            context.l10n('ob_feature_2_desc'),
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
                  context.l10n('ob_feature_2_title'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
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
                    color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF10B981)),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n('notifications_active_msg'),
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
                backgroundColor: isLast
                    ? AppColors.primaryIndigo
                    : const Color(0xFF005DA7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast
                        ? context.l10n('let_start')
                        : context.l10n('continue'),
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
                      size: 20),
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
                  color: _currentPage == index
                      ? const Color(0xFF005DA7)
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
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontFamily: 'Manrope',
              letterSpacing: -0.5,
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
                color: Color(0xFF3B82F6),
              ),
            ).animate().fadeIn(delay: 100.ms),
          ],
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.blueGrey,
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
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(f.icon, color: const Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                Text(f.desc,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
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

class _AnimatedLogo extends StatelessWidget {
  final bool isDark;
  const _AnimatedLogo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56DB).withValues(alpha: 0.35),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "V",
          style: TextStyle(
            fontSize: 88,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: 'Manrope',
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.04, 1.04),
            duration: 2500.ms);
  }
}

class _FeatureVisual extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  const _FeatureVisual(
      {required this.icon, required this.color, required this.isDark});

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
    )
        .animate()
        .fadeIn()
        .scale(begin: const Offset(0.85, 0.85), duration: 600.ms);
  }
}

class _SecurityVisual extends StatelessWidget {
  final bool isDark;
  const _SecurityVisual({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A56DB).withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 64),
        ),
        Transform.translate(
          offset: const Offset(-55, 45),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12)
              ],
            ),
            child:
                const Icon(Icons.lock_rounded, color: Color(0xFF10B981), size: 22),
          ),
        ),
        Transform.translate(
          offset: const Offset(55, -45),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12)
              ],
            ),
            child: const Icon(Icons.verified_user_rounded,
                color: Color(0xFF3B82F6), size: 22),
          ),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .slideY(begin: 0, end: 0.08, duration: 3.seconds);
  }
}
