import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_provider.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import 'package:vitacase/shared/widgets/misc/app_empty_state.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/presentation/providers/appointment_providers.dart';

class UpcomingAppointments extends ConsumerWidget {
  const UpcomingAppointments({super.key});

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

            return Column(children: upcoming.take(2).map((a) => AppointmentCard(a, isDark)).toList());
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class AppointmentCard extends ConsumerWidget {
  const AppointmentCard(this.appointment, this.isDark, {super.key});

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
