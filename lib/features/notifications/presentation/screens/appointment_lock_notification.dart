import 'package:flutter/material.dart';

import 'package:vitacase/core/constants/app_colors.dart';
import '../widgets/notification_glass_card.dart';
import 'package:go_router/go_router.dart';

class AppointmentLockNotificationScreen extends StatelessWidget {
  const AppointmentLockNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDDE8FF), Color(0xFFC9D8F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 120),
                const Icon(Icons.lock_outline, color: Colors.white, size: 30),
                const SizedBox(height: 18),
                const Text(
                  "Wednesday, October 25",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const Text(
                  "09:41",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 92,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: NotificationGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.medical_services,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "VITACASE",
                                style: TextStyle(
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              const Text("now"),
                            ],
                          ),
                          const SizedBox(height: 22),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Upcoming: Annual Checkup",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "In 30 minutes at City Medical Center",
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(Icons.directions),
                                  label: const Text("Get Directions"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(Icons.visibility),
                                  label: const Text("View Details"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
