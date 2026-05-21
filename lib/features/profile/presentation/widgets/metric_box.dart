import 'package:flutter/material.dart';

class MetricBox extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const MetricBox({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxBgColor = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F5FB);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: boxBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(width: 4),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(unit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
