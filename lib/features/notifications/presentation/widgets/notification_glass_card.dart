import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:vitacase/core/constants/app_colors.dart';

class NotificationGlassCard extends StatelessWidget {
  final Widget child;

  const NotificationGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                spreadRadius: 0,
                color: Colors.black.withValues(alpha: .08),
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
