import 'package:flutter/material.dart';
import 'package:vitacase/core/constants/app_colors.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;

  const PremiumCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 93, 167, 0.04),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
