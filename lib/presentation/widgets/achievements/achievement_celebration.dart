import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:ui';
import '../../../domain/entities/achievement.dart';
import '../../../core/l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
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

  Color _getDifficultyColor() {
    switch (widget.achievement.difficulty) {
      case AchievementDifficulty.hard:
        return Colors.redAccent;
      case AchievementDifficulty.medium:
        return Colors.orangeAccent;
      case AchievementDifficulty.easy:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tierColor = _getTierColor();
    final gradient = _getTierGradient();

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Blur
          GestureDetector(
            onTap: widget.onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [tierColor, Colors.white, Colors.yellow, Colors.blue],
              numberOfParticles: 50,
              gravity: 0.2,
            ),
          ),

          // Content Card
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: tierColor.withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
                border: Border.all(
                  color: tierColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Label
                  Text(
                    "ACHIEVEMENT UNLOCKED!",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: tierColor,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.5),

                  const SizedBox(height: 24),

                  // 3D Reddit-style Badge
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tierColor.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Inner gloss reflection (3D effect)
                        Positioned(
                          top: 6,
                          left: 16,
                          right: 16,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.white54, Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        // Achievement icon or emoji
                        Text(
                          widget.achievement.emoji,
                          style: TextStyle(
                            fontSize: 56,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2.seconds, color: Colors.white24)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    context.l10n(widget.achievement.title),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fadeIn(delay: 300.ms).scale(),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    context.l10n(widget.achievement.description),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  // Tier + Difficulty pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPill(
                        widget.achievement.tier.name.toUpperCase(),
                        tierColor,
                      ),
                      const SizedBox(width: 8),
                      _buildPill(
                        widget.achievement.difficulty.name.toUpperCase(),
                        _getDifficultyColor(),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 20),

                  // XP Reward
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tierColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: tierColor),
                        const SizedBox(width: 8),
                        Text(
                          "+${widget.achievement.xpReward} XP",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: tierColor,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 1),

                  const SizedBox(height: 32),

                  // Close Button
                  ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tierColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "AWESOME!",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
