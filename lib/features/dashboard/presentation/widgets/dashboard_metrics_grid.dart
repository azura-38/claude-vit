import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_provider.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import '../../../../shared/providers/health_providers.dart';

class MetricsGrid extends ConsumerWidget {
  const MetricsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyHealthProgressProvider);
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        MetricCard(
          title: context.l10n.steps,
          value: progress['steps']?.toInt().toString() ?? '0',
          unit: context.l10n.steps,
          icon: Icons.directions_walk_rounded,
          gradient: [visuals.primary, visuals.secondary],
          delay: 400.ms,
          onTap: () => context.pushNamed('healthStats'),
        ),
        MetricCard(
          title: context.l10n.heart,
          value: progress['heartRate']?.toInt().toString() ?? '0',
          unit: context.l10n.bpm,
          icon: Icons.favorite_rounded,
          gradient: [const Color(0xFFEF4444), visuals.primary],
          delay: 500.ms,
          onTap: () => context.pushNamed('healthStats'),
        ),
        MetricCard(
          title: context.l10n.sleep,
          value: progress['sleep']?.toInt().toString() ?? '0',
          unit: context.l10n.hours,
          icon: Icons.dark_mode_rounded,
          gradient: [visuals.secondary, const Color(0xFF111827)],
          delay: 600.ms,
          onTap: () => context.pushNamed('healthStats'),
        ),
        MetricCard(
          title: context.l10n.water,
          value: progress['water']?.toInt().toString() ?? '0',
          unit: context.l10n.ml,
          icon: Icons.water_drop_rounded,
          gradient: [visuals.primary, const Color(0xFF22D3EE)],
          delay: 700.ms,
          onTap: () => context.pushNamed('healthDataAdd'),
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.gradient,
    required this.delay,
    this.onTap,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final List<Color> gradient;
  final Duration delay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: gradient[0].withValues(alpha: 0.20), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(icon, size: 100, color: Colors.white.withValues(alpha: 0.15))
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds)
                  .rotate(begin: 0, end: 0.05, duration: 2.seconds),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
                    Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.8), letterSpacing: 0.5)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text(unit, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.2);
  }
}
