import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../widgets/notification_glass_card.dart';

class MedicationLockNotificationScreen extends StatelessWidget {
  const MedicationLockNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LockWallpaper(
            colors: [Color(0xFFFFD56B), Color(0xFF8EA7FF), Color(0xFF1E3A8A)],
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 70),
                const Text(
                  '9:41',
                  style: TextStyle(
                    fontSize: 88,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    height: 1,
                  ),
                ).animate().fadeIn().slideY(begin: -.08),
                const SizedBox(height: 8),
                Text(
                  context.l10n.mockDateWednesday,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate(delay: 120.ms).fadeIn(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: NotificationGlassCard(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AppBadge(icon: Icons.medication_rounded),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          context.l10n.appName.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          context.l10n.notificationNow,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      context.l10n.medReminderTimeForMed(
                                        med: 'Lisinopril',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.brandNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.l10n.medReminderDose(
                                        dose: '10mg',
                                        note: context.l10n.notificationDoseNote,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => context.pop(),
                                child: Text(context.l10n.remindIn10M),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 52,
                              color: Colors.black12,
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () => context.pop(),
                                child: Text(context.l10n.markAsTaken),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 650.ms).slideY(begin: .35),
                ),
                const SizedBox(height: 76),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockWallpaper extends StatelessWidget {
  final List<Color> colors;

  const _LockWallpaper({required this.colors});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _AppBadge extends StatelessWidget {
  final IconData icon;

  const _AppBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandBlue, AppColors.brandCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
