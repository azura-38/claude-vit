import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';

class RadialBmiGauge extends StatelessWidget {
  final double bmi;
  final String category;

  const RadialBmiGauge({
    super.key,
    required this.bmi,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Normal range is 18.5 - 25.
    // We'll map BMI 15-40 to a gauge
    final double normalizedValue = ((bmi - 15) / (40 - 15)).clamp(0, 1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _BmiGaugePainter(
              value: normalizedValue,
              color: _getBmiColor(),
              isDark: isDark,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'BMI ${context.l10n('index').toUpperCase()}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white38 : AppColors.textTertiary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: _getBmiColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBmiColor() {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return const Color(0xFF10B981); // Success Green
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}

class _BmiGaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final bool isDark;

  _BmiGaugePainter({required this.value, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;
    const startAngle = 0.8 * math.pi;
    const sweepAngle = 1.4 * math.pi;

    // Background Arc
    final bgPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth/2),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Value Arc
    final valuePaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.7), color],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth/2),
      startAngle,
      sweepAngle * value,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
