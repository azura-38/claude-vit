import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:ui';
import 'dart:async';
import '../../../../../shared/domain/entities/achievement.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class AchievementCelebration extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onClose;

  const AchievementCelebration({
    super.key,
    required this.achievement,
    required this.onClose,
  });

  @override
  State<AchievementCelebration> createState() => _AchievementCelebrationState();
}

class _AchievementCelebrationState extends State<AchievementCelebration> {
  late ConfettiController _confettiController;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();

    // Auto-dismiss after 4.5 seconds to keep interaction frictionless
    _dismissTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  List<Color> _getTierGradient() {
    switch (widget.achievement.tier) {
      case AchievementTier.platinum:
        return [const Color(0xFF22D3EE), const Color(0xFF0369A1)];
      case AchievementTier.special:
        return [const Color(0xFFE879F9), const Color(0xFF701A75)];
      case AchievementTier.gold:
        return [const Color(0xFFFBBF24), const Color(0xFFB45309)];
      case AchievementTier.silver:
        return [const Color(0xFFCBD5E1), const Color(0xFF475569)];
      case AchievementTier.bronze:
        return [const Color(0xFFD97706), const Color(0xFF78350F)];
    }
  }

  Color _getTierColor() {
    switch (widget.achievement.tier) {
      case AchievementTier.platinum:
        return const Color(0xFF22D3EE);
      case AchievementTier.special:
        return const Color(0xFFE879F9);
      case AchievementTier.gold:
        return const Color(0xFFFBBF24);
      case AchievementTier.silver:
        return const Color(0xFFCBD5E1);
      case AchievementTier.bronze:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tierColor = _getTierColor();
    final gradient = _getTierGradient();

    final double topSafeArea = MediaQuery.of(context).padding.top;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background Light Blur & Dim (Non-intrusive)
          GestureDetector(
            onTap: widget.onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
              ),
            ),
          ),

          // Refined local confetti burst
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: topSafeArea + 12),
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [tierColor, Colors.white, Colors.amber, Colors.cyan],
                numberOfParticles: 24,
                gravity: 0.15,
              ),
            ),
          ),

          // Sliding floating top-center toast card
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: topSafeArea + 16, left: 16, right: 16),
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 350),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: tierColor.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tierColor.withValues(alpha: 0.2),
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
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: tierColor.withValues(alpha: 0.3),
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
                            Text(
                              widget.achievement.emoji,
                              style: const TextStyle(fontSize: 26),
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
                            // Upper tag row
                            Row(
                              children: [
                                Text(
                                  Localizations.localeOf(context).languageCode == 'tr' ? "BAŞARI KAZANILDI" : "ACHIEVEMENT UNLOCKED",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: tierColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "•",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isDark ? Colors.white30 : Colors.black26,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bolt_rounded,
                                      color: Colors.amber,
                                      size: 11,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "+${widget.achievement.xpReward} XP",
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              context.tr(widget.achievement.title),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr(widget.achievement.description),
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
                        onPressed: widget.onClose,
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
