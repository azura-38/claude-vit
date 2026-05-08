import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/vitacase_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../widgets/notification_glass_card.dart';
import 'package:go_router/go_router.dart';

class MedicationLockNotificationScreen extends StatelessWidget {
  const MedicationLockNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFE08A),
                  Color(0xFFB39DDB),
                  Color(0xFF90CAF9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Text(
                  "9:41",
                  style: TextStyle(
                    fontSize: 92,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n('mock_date_wednesday'), // Fallback for UI mockup
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: RepaintBoundary(
                    child: Semantics(
                      label: 'Medication Notification',
                      hint: 'Tap to view medication details',
                      child: NotificationGlassCard(
                        child: Column(
                          children: [
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: VitaColors.primary.withValues(alpha: .12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.medication,
                                  color: VitaColors.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n('med_reminder_time_for_med', extra: {'med': 'Lisinopril'}),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.l10n('med_reminder_dose', extra: {'dose': '10mg', 'note': 'Take with food'}),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: VitaColors.secondary,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                button: true,
                                label: 'Remind me in 10 minutes',
                                child: TextButton(
                                  onPressed: () => context.pop(),
                                  child: Text(
                                    context.l10n('remind_in_10m'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: VitaColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(width: 1, height: 54, color: Colors.white),
                            Expanded(
                              child: Semantics(
                                button: true,
                                label: 'Mark medication as taken',
                                child: TextButton(
                                  onPressed: () => context.pop(),
                                  child: Text(
                                    context.l10n('mark_as_taken'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: VitaColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 700.ms).slideY(begin: .4, end: 0),
            ),
            const SizedBox(height: 80),
              ],
            ),
          )
        ],
      ),
    );
  }
}
