import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class RewardDialog extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const RewardDialog({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.emoji_events_rounded,
    this.color = Colors.amber,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    IconData icon = Icons.emoji_events_rounded,
    Color color = Colors.amber,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: false,
      builder:
          (_) => RewardDialog(
            title: title,
            description: description,
            icon: icon,
            color: color,
          ),
    );
  }

  @override
  State<RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 4.5 seconds to keep level ups frictionless
    _dismissTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double topSafeArea = MediaQuery.of(context).padding.top;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background Light Blur & Dim (Non-intrusive)
          GestureDetector(
            onTap: () => context.pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
              ),
            ),
          ),

          // Sliding floating top-center toast card
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: topSafeArea + 16, left: 16, right: 16),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 350),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Floating 3D-style badge
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [widget.color, widget.color.withValues(alpha: 0.5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glossy overlay
                            Positioned(
                              top: 2,
                              left: 6,
                              right: 6,
                              height: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.45),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .slideY(begin: 0, end: 0.08, duration: 1.5.seconds, curve: Curves.easeInOut)
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.elasticOut),

                      const SizedBox(width: 14),

                      // Text details
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Upper tag label
                            Text(
                              "SEVİYE ATLADIN!",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: widget.color,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white60 : Colors.black54,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Tiny Close Icon
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .animate()
          .slideY(begin: -0.15, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
          .fadeIn(duration: 250.ms),
        ],
      ),
    );
  }
}
