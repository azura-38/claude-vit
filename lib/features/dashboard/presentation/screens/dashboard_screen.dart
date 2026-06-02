import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_visuals.dart';
import '../../../../core/utils/external_launcher.dart';
import '../../../../shared/providers/daily_mission_providers.dart';
import '../../../../shared/providers/health_providers.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/providers/season_providers.dart';
import '../../../../shared/widgets/dialogs/reward_dialog.dart';
import '../../../../shared/widgets/misc/app_empty_state.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/presentation/providers/appointment_providers.dart';
import '../../../profile/presentation/providers/legacy_providers.dart';
import '../../../profile/presentation/providers/settings_controller.dart';
import '../../../gamification/presentation/providers/achievement_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(achievementProvider.notifier).showPendingNotifications();
      
      final prefs = ref.read(sharedPreferencesProvider);
      if (prefs.getBool('db_corruption_recovery_triggered') == true) {
        await prefs.remove('db_corruption_recovery_triggered');
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  const Text('Sistem Kurtarma', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                'Veriler kurtarılamadı / uygulama güvenli başlatıldı',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      }
    });

    final userName = ref.watch(profileNameProvider);
    final isGuest = userName == null || userName.isEmpty;

    final hasPinAsync = ref.watch(hasPinProvider);
    final hasPin = hasPinAsync.valueOrNull ?? true;
    final prefs = ref.watch(sharedPreferencesProvider);
    final onboardingSkipped = prefs.getBool('profile_creation_skipped') ?? false;

    ref.listen(seasonProvider, (previousAsync, nextAsync) {
      final previous = previousAsync?.asData?.value;
      final next = nextAsync.asData?.value;
      if (previous != null && next != null && next.level > previous.level) {
        RewardDialog.show(
          context,
          title: context.l10n.congratulations.toUpperCase(),
          description: context.l10n.levelUpDesc(next.level),
          icon: Icons.auto_awesome_rounded,
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            _TopAppBar(userName: userName ?? context.l10n.guestUser),
            const SizedBox(height: 24),
            if (onboardingSkipped && !hasPin) ...[
              const _SecuritySetupWarningBanner(),
              const SizedBox(height: 24),
            ],
            if (isGuest && !(onboardingSkipped && !hasPin)) ...[
              const _GuestBanner(),
              const SizedBox(height: 24),
            ],
            const _CtaFeatureCard(),
            const SizedBox(height: 24),
            const _MetricsGrid(),
            const SizedBox(height: 32),
            const _SeasonProgressSection(),
            const SizedBox(height: 32),
            const _DailyMissionsSection(),
            const SizedBox(height: 32),
            const _ConditionalQuickAccess(),
            const _UpcomingAppointments(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _TopAppBar extends ConsumerWidget {
  const _TopAppBar({required this.userName});

  final String userName;
  static const _brandLogoAsset = 'assets/images/vitacase_brand_logo.png';

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.goodMorning;
    if (hour < 17) return context.l10n.goodAfternoon;
    if (hour < 21) return context.l10n.goodEvening;
    return context.l10n.goodNight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photo = ref.watch(profilePhotoProvider);
    final selectedTheme = ref.watch(themeTypeProvider);
    final visuals = ThemeVisuals.of(selectedTheme);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: visuals.primary.withValues(alpha: 0.16), blurRadius: 14),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildAvatar(photo, selectedTheme),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(context),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.cardBorderLight,
            ),
          ),
          child: Image.asset(_brandLogoAsset, fit: BoxFit.contain),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildAvatar(String? value, dynamic selectedTheme) {
    final bytes = _decodeDataUri(value);
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    return ThemePlaceholder(type: selectedTheme, size: 48, iconSize: 22, radius: 24);
  }

  static Uint8List? _decodeDataUri(String? value) {
    if (value == null || !value.startsWith('data:image/')) return null;
    final marker = 'base64,';
    final index = value.indexOf(marker);
    if (index == -1) return null;
    try {
      return base64Decode(value.substring(index + marker.length));
    } catch (_) {
      return null;
    }
  }
}

class _GuestBanner extends ConsumerWidget {
  const _GuestBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: visuals.softGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : visuals.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_rounded, color: visuals.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.guestMode,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: visuals.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.guestDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
  }
}

class _CtaFeatureCard extends ConsumerWidget {
  const _CtaFeatureCard();
  static const _featureOverviewAsset = 'assets/images/vitacase_feature_overview.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return GestureDetector(
      onTap: () => ref.read(navigationProvider.notifier).setIndex(1),
      child: Container(
        height: 232,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          boxShadow: [
            if (!isDark)
              BoxShadow(color: visuals.primary.withValues(alpha: 0.12), blurRadius: 28, offset: const Offset(0, 16)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, height: 126, child: Image.asset(_featureOverviewAsset, fit: BoxFit.cover)),
            Positioned(
              top: 82,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0),
                      isDark ? AppColors.surfaceDark : Colors.white,
                      isDark ? AppColors.surfaceDark : Colors.white,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 130, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.allRecords,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.brandNavy),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: visuals.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Icon(Icons.chevron_right_rounded, color: visuals.primary),
                      ),
                    ],
                  ),
                  Text(
                    context.l10n.vaultDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.35),
                  ),
                  Row(
                    children: [
                      _HeroChip(icon: Icons.folder_rounded, label: context.l10n.vault),
                      const SizedBox(width: 8),
                      _HeroChip(icon: Icons.calendar_today_rounded, label: context.l10n.appointments),
                      const SizedBox(width: 8),
                      _HeroChip(icon: Icons.medication_rounded, label: context.l10n.medicines),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }
}

class _HeroChip extends ConsumerWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : visuals.softBackground.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : visuals.primary.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: visuals.primary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : AppColors.brandNavy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends ConsumerWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyHealthProgressProvider);
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _MetricCard(
          title: context.l10n.steps,
          value: progress['steps']?.toInt().toString() ?? '0',
          unit: context.l10n.steps,
          icon: Icons.directions_walk_rounded,
          gradient: [visuals.primary, visuals.secondary],
          delay: 400.ms,
          onTap: () => context.pushNamed('healthStats'),
        ),
        _MetricCard(
          title: context.l10n.heart,
          value: progress['heartRate']?.toInt().toString() ?? '0',
          unit: context.l10n.bpm,
          icon: Icons.favorite_rounded,
          gradient: [const Color(0xFFEF4444), visuals.primary],
          delay: 500.ms,
          onTap: () => context.pushNamed('healthStats'),
        ),
        _MetricCard(
          title: context.l10n.sleep,
          value: progress['sleep']?.toInt().toString() ?? '0',
          unit: context.l10n.hours,
          icon: Icons.dark_mode_rounded,
          gradient: [visuals.secondary, const Color(0xFF111827)],
          delay: 600.ms,
          onTap: () => context.pushNamed('healthStats'),
        ),
        _MetricCard(
          title: context.l10n.water,
          value: progress['water']?.toInt().toString() ?? '0',
          unit: context.l10n.ml,
          icon: Icons.water_drop_rounded,
          gradient: [visuals.primary, const Color(0xFF22D3EE)],
          delay: 700.ms,
          onTap: () => context.pushNamed('healthDataAdd'),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.gradient,
    required this.delay,
    this.onTap,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final List<Color> gradient;
  final Duration delay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: gradient[0].withValues(alpha: 0.20), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(icon, size: 100, color: Colors.white.withValues(alpha: 0.15))
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds)
                  .rotate(begin: 0, end: 0.05, duration: 2.seconds),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
                    Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.8), letterSpacing: 0.5)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text(unit, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.2);
  }
}

class _QuickAccess extends ConsumerWidget {
  const _QuickAccess();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showQuickActionsMenu(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.quickAccess,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isDark ? Colors.white38 : Colors.black38, letterSpacing: 1.5),
                ),
                Icon(Icons.add_rounded, size: 20, color: visuals.primary),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 800.ms),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Row(
            children: [
              _QuickActionItem(label: context.l10n.vault, icon: Icons.description_rounded, onTap: () => ref.read(navigationProvider.notifier).setIndex(1), delay: 900.ms),
              const SizedBox(width: 20),
              _QuickActionItem(label: context.l10n.pharmacies, icon: Icons.location_on_rounded, onTap: () => ExternalLauncher.launchMapSearch(context.l10n.pharmacies), delay: 1000.ms),
              const SizedBox(width: 20),
              _QuickActionItem(label: context.l10n.medicines, icon: Icons.medication_rounded, onTap: () => context.pushNamed('medicines'), delay: 1100.ms),
              const SizedBox(width: 20),
              _QuickActionItem(label: context.l10n.appointments, icon: Icons.calendar_today_rounded, onTap: () => ref.read(navigationProvider.notifier).setIndex(3), delay: 1200.ms),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConditionalQuickAccess extends ConsumerWidget {
  const _ConditionalQuickAccess();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickActionsEnabled = ref.watch(
      settingsControllerProvider.select((s) => s.quickActionsEnabled),
    );
    if (!quickActionsEnabled) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: _QuickAccess(),
    );
  }
}

class _QuickActionItem extends ConsumerWidget {
  const _QuickActionItem({required this.label, required this.icon, required this.onTap, required this.delay});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Duration delay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTheme = ref.watch(themeTypeProvider);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ThemePlaceholder(type: selectedTheme, size: 64, iconSize: 28, radius: 24, icon: icon),
          const SizedBox(height: 12),
          SizedBox(
            width: 78,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).scale(begin: const Offset(0.8, 0.8));
  }
}

class _UpcomingAppointments extends ConsumerWidget {
  const _UpcomingAppointments();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appointmentsAsync = ref.watch(appointmentListProvider);
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.upcomingAppointment,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isDark ? Colors.white38 : Colors.black38, letterSpacing: 1.5),
            ),
            GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).setIndex(3),
              child: Text(context.l10n.allRecordsTitle.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: visuals.primary)),
            ),
          ],
        ).animate().fadeIn(delay: 1300.ms),
        const SizedBox(height: 16),
        appointmentsAsync.when(
          data: (list) {
            final now = DateTime.now();
            final upcoming = list.where((a) {
              try {
                final dt = DateTime.parse('${a.date} ${a.time}');
                return dt.isAfter(now);
              } catch (_) {
                return false;
              }
            }).toList()
              ..sort((a, b) {
                try {
                  return DateTime.parse('${a.date} ${a.time}').compareTo(DateTime.parse('${b.date} ${b.time}'));
                } catch (_) {
                  return 0;
                }
              });

            if (upcoming.isEmpty) {
              return AppEmptyState(
                icon: Icons.calendar_today_rounded,
                title: context.l10n.noMoreAppointments,
                subtitle: context.l10n.noMoreAppointments,
                actionLabel: context.l10n.addNewAppointment,
                onAction: () => ref.read(navigationProvider.notifier).setIndex(3),
              );
            }

            return Column(children: upcoming.take(2).map((a) => _AppointmentCard(a, isDark)).toList());
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard(this.appointment, this.isDark);

  final Appointment appointment;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: visuals.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.calendar_today_rounded, color: visuals.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.hospital, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                Text('${appointment.department} • ${appointment.doctor}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(appointment.time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              _dateText(context, visuals),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  Widget _dateText(BuildContext context, ThemeVisuals visuals) {
    try {
      return Text(
        DateFormat('dd/MM').format(DateTime.parse(appointment.date)),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: visuals.primary),
      );
    } catch (_) {
      return const Text('N/A', style: TextStyle(fontSize: 10, color: AppColors.error));
    }
  }
}

class _SeasonProgressSection extends ConsumerWidget {
  const _SeasonProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(seasonProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return progressAsync.when(
      data: (progress) {
        final progressInLevel = (progress.xp % 100) / 100;
        return GestureDetector(
          onTap: () => context.pushNamed('achievements'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [if (!isDark) BoxShadow(color: visuals.primary.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [const Icon(Icons.stars_rounded, color: Colors.amber, size: 20), const SizedBox(width: 8), Text('Level ${progress.level}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))]),
                    Text('${progress.xp % 100} / 100 XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressInLevel.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(visuals.primary),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 750.ms).slideX(begin: 0.1);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _DailyMissionsSection extends ConsumerWidget {
  const _DailyMissionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(dailyMissionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return missionsAsync.when(
      data: (missions) {
        if (missions.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.dailyMissions.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isDark ? Colors.white38 : Colors.black38, letterSpacing: 1.5),
            ).animate().fadeIn(delay: 800.ms),
            const SizedBox(height: 16),
            ...missions.map((m) => _MissionCard(m, isDark)),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MissionCard extends ConsumerWidget {
  const _MissionCard(this.mission, this.isDark);

  final dynamic mission;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = mission.progress / mission.target;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (mission.isCompleted ? Colors.green : visuals.primary).withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(mission.isCompleted ? Icons.check_circle_rounded : Icons.task_alt_rounded, color: mission.isCompleted ? Colors.green : visuals.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr(mission.title.toString()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(mission.isCompleted ? Colors.green : visuals.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text('${mission.progress}/${mission.target}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }
}

void _showQuickActionsMenu(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final visuals = ThemeVisuals.of(ref.read(themeTypeProvider));

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 32),
          Text(context.l10n.quickActions, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _MenuActionItem(label: context.l10n.addMedicine, icon: Icons.medication_rounded, visuals: visuals, onTap: () { Navigator.pop(ctx); context.push(AppRoutes.medicineAdd); }),
              _MenuActionItem(label: context.l10n.addAppointment, icon: Icons.calendar_today_rounded, visuals: visuals, onTap: () { Navigator.pop(ctx); context.push(AppRoutes.appointmentAdd); }),
              _MenuActionItem(label: context.l10n.addDoctor, icon: Icons.person_add_rounded, visuals: visuals, onTap: () { Navigator.pop(ctx); context.push(AppRoutes.doctorAdd); }),
              _MenuActionItem(label: context.l10n.addDocument, icon: Icons.upload_file_rounded, visuals: visuals, onTap: () { Navigator.pop(ctx); context.push(AppRoutes.documentAdd); }),
              _MenuActionItem(label: context.l10n.addData, icon: Icons.analytics_rounded, visuals: visuals, onTap: () { Navigator.pop(ctx); context.push(AppRoutes.healthDataAdd); }),
              _MenuActionItem(label: context.l10n.settings, icon: Icons.settings_rounded, visuals: visuals, onTap: () { Navigator.pop(ctx); context.push(AppRoutes.settings); }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

class _MenuActionItem extends StatelessWidget {
  const _MenuActionItem({required this.label, required this.icon, required this.visuals, required this.onTap});

  final String label;
  final IconData icon;
  final ThemeVisuals visuals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(gradient: visuals.gradient, borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SecuritySetupWarningBanner extends ConsumerWidget {
  const _SecuritySetupWarningBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.12),
            Colors.orange.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gpp_maybe_rounded,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Güvenlik Kurulumu Eksik',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Güvenlik kurulumu tamamlanmadı. Uygulama kilidi (PIN) ekleyerek verilerinizi güvende tutun.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.settings),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Şimdi Kurulum Yap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: visuals.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: visuals.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
  }
}
