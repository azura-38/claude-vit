import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../widgets/notification_glass_card.dart';

class AppointmentLockNotificationScreen extends StatelessWidget {
  const AppointmentLockNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDDEBFF), Color(0xFF94A3B8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 90),
                const Icon(Icons.lock_outline, color: Colors.white, size: 28),
                const SizedBox(height: 18),
                Text(
                  context.l10n.mockDateWednesday,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ).animate().fadeIn(),
                const Text(
                  '09:41',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 88,
                    fontWeight: FontWeight.w200,
                    height: 1.05,
                  ),
                ).animate(delay: 80.ms).fadeIn().slideY(begin: -.08),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: NotificationGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.brandBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                context.l10n.appName.toUpperCase(),
                                style: const TextStyle(
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                context.l10n.notificationNow,
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              context.l10n.upcomingAppointment,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.brandBlue,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              context.l10n.notificationAppointmentTitle,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: AppColors.brandNavy,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              context.l10n.notificationAppointmentLocation,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(Icons.directions_rounded),
                                  label: Text(context.l10n.getDirections),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(Icons.visibility_rounded),
                                  label: Text(context.l10n.viewDetails),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 650.ms).slideY(begin: .35),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
