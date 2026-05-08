import 'package:flutter/material.dart';

class BmiSummaryCard extends StatelessWidget {
  final double bmi;
  final String status;

  const BmiSummaryCard({
    super.key,
    required this.bmi,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case 'Healthy':
        return const Color(0xFF005DA7);
      case 'Overweight':
        return Colors.orange;
      case 'High BMI':
        return Colors.red;
      default:
        return Colors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor,
            statusColor.withValues(alpha: .8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: .25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT BMI',
                  style: TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
          const Icon(
            Icons.favorite_outline_rounded,
            color: Colors.white,
            size: 38,
          )
        ],
      ),
    );
  }
}
