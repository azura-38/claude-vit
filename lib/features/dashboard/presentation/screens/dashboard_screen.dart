import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/external_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/providers/health_providers.dart';
import '../../../appointments/presentation/providers/appointment_providers.dart';
import '../../../appointments/domain/entities/appointment.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/daily_mission_providers.dart';
import '../../../../shared/providers/season_providers.dart';
import '../../../../shared/widgets/dialogs/reward_dialog.dart';
import '../../../../shared/widgets/misc/app_empty_state.dart';
import 'package:vitacase/features/profile/presentation/providers/legacy_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = ref.watch(profileNameProvider);
    final isGuest = userName == null || userName.isEmpty;

    // 🏆 Reward & Level-up Listener
    ref.listen(seasonProvider, (previousAsync, nextAsync) {
      final previous = previousAsync?.asData?.value;
      final next = nextAsync.asData?.value;
      if (previous != null && next != null && next.level > previous.level) {
        RewardDialog.show(
          context,
          title: context.l10n.congratulations.toUpperCase(),
          description: context.l10n.levelUpDesc(level: next.level.toString()),
          icon: Icons.auto_awesome_rounded,
        );
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            _TopAppBar(
              userName: userName ?? context.l10n.guestUser,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            if (isGuest) ...[const _GuestBanner(), const SizedBox(height: 24)],
            const _CtaFeatureCard(),
            const SizedBox(height: 24),
            const _MetricsGrid(),
            const SizedBox(height: 32),
            const _SeasonProgressSection(),
            const SizedBox(height: 32),
            const _DailyMissionsSection(),
            const SizedBox(height: 32),
            const _QuickAccess(),

            const SizedBox(height: 32),
            const _UpcomingAppointments(),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class _TopAppBar extends ConsumerWidget {
  final String userName;
  final bool isDark;

  const _TopAppBar({required this.userName, required this.isDark});

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.goodMorning;
    if (hour < 17) return context.l10n.goodAfternoon;
    if (hour < 21) return context.l10n.goodEvening;
    return context.l10n.goodNight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(profilePhotoProvider);

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
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child:
                    photo != null && !photo.startsWith('http')
                        ? Image.file(
                          File(photo),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildAvatarPlaceholder(),
                        )
                        : _buildAvatarPlaceholder(),
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
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox.shrink(),
      ],
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.medicalBlue.withValues(alpha: 0.1),
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.medicalBlue,
        size: 28,
      ),
    );
  }
}

class _GuestBanner extends StatelessWidget {
  const _GuestBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.guestBannerBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.guestBannerBg,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_rounded, color: Color(0xFFCA8A04), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.guestMode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.guestDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark
                            ? Colors.white70
                            : AppColors.guestBannerText.withValues(alpha: 0.9),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(navigationProvider.notifier).setIndex(1),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [AppColors.gradBlueStart, AppColors.gradBlueEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gradBlueStart.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                    Icons.filter_none_rounded,
                    size: 150,
                    color: Colors.white.withValues(alpha: 0.1),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 5.seconds,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.filter_none_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.allRecords,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.vaultDesc,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

class _MetricsGrid extends ConsumerWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyHealthProgressProvider);

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
          value: progress['steps']?.toInt().toString() ?? "0",
          unit: context.l10n.steps,
          icon: Icons.directions_walk_rounded,
          gradient: const [AppColors.gradOrangeStart, AppColors.gradOrangeEnd],
          delay: 400.ms,
          onTap: () => context.pushNamed('healthStats'),
        ),
        _MetricCard(
          title: context.l10n.heart,
          value: progress['heartRate']?.toInt().toString() ?? "0",
          unit: context.l10n.bpm,
          icon: Icons.favorite_rounded,
          gradient: const [AppColors.gradPinkStart, AppColors.gradPinkEnd],
          delay: 500.ms,
          onTap: () => context.pushNamed('healthStats'),
        ),
        _MetricCard(
          title: context.l10n.sleep,
          value: progress['sleep']?.toInt().toString() ?? "0",
          unit: context.l10n.hours,
          icon: Icons.dark_mode_rounded,
          gradient: const [AppColors.gradNavyStart, AppColors.gradNavyEnd],
          delay: 600.ms,
          onTap: () => context.pushNamed('healthStats'),
        ),
        _MetricCard(
          title: context.l10n.water,
          value: progress['water']?.toInt().toString() ?? "0",
          unit: context.l10n.ml,
          icon: Icons.water_drop_rounded,
          gradient: const [AppColors.gradWaterStart, AppColors.gradWaterEnd],
          delay: 700.ms,
          onTap: () => context.pushNamed('healthAdd'),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final List<Color> gradient;
  final Duration delay;

  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.gradient,
    required this.delay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                    icon,
                    size: 100,
                    color: Colors.white.withValues(alpha: 0.15),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 2.seconds,
                  )
                  .rotate(begin: 0, end: 0.05, duration: 2.seconds),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 18,
                    ),
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
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
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 1.5,
                  ),
                ),
                Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 800.ms),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickActionItem(
                label: context.l10n.vault,
                icon: Icons.description_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () => ref.read(navigationProvider.notifier).setIndex(1),
                delay: 900.ms,
              ),
              const SizedBox(width: 20),
              _QuickActionItem(
                label: context.l10n.pharmacies,
                icon: Icons.location_on_rounded,
                color: const Color(0xFF10B981),
                onTap:
                    () => ExternalLauncher.launchMapSearch(
                      context.l10n.pharmacies,
                    ),
                delay: 1000.ms,
              ),
              const SizedBox(width: 20),
              _QuickActionItem(
                label: context.l10n.medicines,
                icon: Icons.medication_rounded,
                color: const Color(0xFFF97316),
                onTap: () => context.pushNamed('medicines'),
                delay: 1100.ms,
              ),
              const SizedBox(width: 20),
              _QuickActionItem(
                label: context.l10n.appointments,
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFFA855F7),
                onTap: () => ref.read(navigationProvider.notifier).setIndex(3),
                delay: 1200.ms,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Duration delay;

  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : AppColors.textPrimary,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.upcomingAppointment,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white38 : Colors.black38,
                letterSpacing: 1.5,
              ),
            ),
            GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).setIndex(3),
              child: Text(
                context.l10n.allRecordsTitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.medicalBlue,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 1300.ms),
        const SizedBox(height: 16),
        appointmentsAsync.when(
          data: (list) {
            final now = DateTime.now();
            final upcoming =
                list.where((a) {
                  try {
                    final dt = DateTime.parse("${a.date} ${a.time}");
                    return dt.isAfter(now);
                  } catch (e) {
                    debugPrint(
                      "🚨 [CRASH_PREVENTION] Malformed appointment date: ${a.date}",
                    );
                    return false;
                  }
                }).toList();

            upcoming.sort((a, b) {
              try {
                final da = DateTime.parse("${a.date} ${a.time}");
                final db = DateTime.parse("${b.date} ${b.time}");
                return da.compareTo(db);
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
                onAction:
                    () => ref.read(navigationProvider.notifier).setIndex(3),
              );
            }

            return Column(
              children:
                  upcoming
                      .take(2)
                      .map((a) => _AppointmentCard(a, isDark))
                      .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isDark;

  const _AppointmentCard(this.appointment, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.medicalBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.medicalBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.hospital,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "${appointment.department} • ${appointment.doctor}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                appointment.time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Inter',
                ),
              ),
              () {
                try {
                  return Text(
                    DateFormat(
                      'dd/MM',
                    ).format(DateTime.parse(appointment.date)),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.medicalBlue,
                    ),
                  );
                } catch (_) {
                  return const Text(
                    "N/A",
                    style: TextStyle(fontSize: 10, color: AppColors.error),
                  );
                }
              }(),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }
}

class _SeasonProgressSection extends ConsumerWidget {
  const _SeasonProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(seasonProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Level ${progress.level}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${progress.xp % 100} / 100 XP",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressInLevel.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.medicalBlue,
                    ),
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
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white38 : Colors.black38,
                letterSpacing: 1.5,
              ),
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

class _MissionCard extends StatelessWidget {
  final dynamic mission;
  final bool isDark;

  const _MissionCard(this.mission, this.isDark);

  @override
  Widget build(BuildContext context) {
    final progress = mission.progress / mission.target;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  mission.isCompleted
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppColors.medicalBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              mission.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.task_alt_rounded,
              color: mission.isCompleted ? Colors.green : AppColors.medicalBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n(mission.title),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      mission.isCompleted
                          ? Colors.green
                          : AppColors.medicalBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "${mission.progress}/${mission.target}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }
}

void _showQuickActionsMenu(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder:
        (ctx) => Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                context.l10n.quickActions,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 32),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _MenuActionItem(
                    label: context.l10n.addMedicine,
                    icon: Icons.medication_rounded,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/medicines/add');
                    },
                  ),
                  _MenuActionItem(
                    label: context.l10n.addAppointment,
                    icon: Icons.calendar_today_rounded,
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/appointments/add');
                    },
                  ),
                  _MenuActionItem(
                    label: context.l10n.addDoctor,
                    icon: Icons.person_add_rounded,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/doctors/add');
                    },
                  ),
                  _MenuActionItem(
                    label: context.l10n.addDocument,
                    icon: Icons.upload_file_rounded,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(ctx);
                      ref.read(navigationProvider.notifier).setIndex(1);
                    },
                  ),
                  _MenuActionItem(
                    label: context.l10n.addData,
                    icon: Icons.analytics_rounded,
                    color: Colors.pink,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/health/add');
                    },
                  ),
                  _MenuActionItem(
                    label: context.l10n.settings,
                    icon: Icons.settings_rounded,
                    color: Colors.grey,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/settings');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
  );
}

class _MenuActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
