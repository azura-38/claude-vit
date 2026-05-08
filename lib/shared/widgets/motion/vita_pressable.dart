import 'package:flutter/material.dart';
import '../../../../services/haptic_service.dart';

class VitaPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool enableHaptics;
  final double scaleDownTo;

  const VitaPressable({
    super.key,
    required this.child,
    required this.onPressed,
    this.enableHaptics = true,
    this.scaleDownTo = 0.95,
  });

  @override
  State<VitaPressable> createState() => _VitaPressableState();
}

class _VitaPressableState extends State<VitaPressable> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 250),
    );

    // Spring-like easing
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDownTo).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableHaptics) {
      HapticService.light();
    }
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableHaptics) {
      HapticService.medium();
    }
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
