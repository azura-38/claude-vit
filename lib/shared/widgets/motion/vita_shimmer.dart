import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vitacase/core/constants/app_colors.dart';

class VitaShimmer extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const VitaShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: duration,
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          angle: 0.5,
          size: 2,
        );
  }
}

class VitaBreathingLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const VitaBreathingLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(
          begin: 0.4,
          end: 1.0,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
        );
  }
}
