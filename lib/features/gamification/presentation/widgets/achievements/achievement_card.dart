import 'package:flutter/material.dart';
import '../../../../../shared/domain/entities/achievement.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class AchievementCard extends StatefulWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final int currentSteps;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.currentSteps = 0,
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _setupAnimation(0, widget.currentSteps.toDouble());
  }

  void _setupAnimation(double begin, double end) {
    double maxVal = widget.achievement.totalSteps?.toDouble() ?? 1.0;
    double endPerc = (end / maxVal).clamp(0.0, 1.0);

    _progressAnimation = Tween<double>(begin: begin, end: endPerc).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutQuart),
    );
    _progressController.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant AchievementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSteps != widget.currentSteps) {
      double maxVal = widget.achievement.totalSteps?.toDouble() ?? 1.0;
      double beginPerc = (oldWidget.currentSteps / maxVal).clamp(0.0, 1.0);
      _setupAnimation(beginPerc, widget.currentSteps.toDouble());
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  List<Color> _getTierGradient() {
    switch (widget.achievement.tier) {
      case AchievementTier.bronze:
        return [const Color(0xFFD97706), const Color(0xFF78350F)];
      case AchievementTier.silver:
        return [const Color(0xFFCBD5E1), const Color(0xFF475569)];
      case AchievementTier.gold:
        return [const Color(0xFFFBBF24), const Color(0xFFB45309)];
      case AchievementTier.platinum:
        return [const Color(0xFF22D3EE), const Color(0xFF0369A1)];
      case AchievementTier.special:
        return [const Color(0xFFE879F9), const Color(0xFF701A75)];
    }
  }

  Color _getBadgeColor() {
    switch (widget.achievement.tier) {
      case AchievementTier.bronze:
        return const Color(0xFFD97706);
      case AchievementTier.silver:
        return const Color(0xFF94A3B8);
      case AchievementTier.gold:
        return const Color(0xFFFBBF24);
      case AchievementTier.platinum:
        return const Color(0xFF22D3EE);
      case AchievementTier.special:
        return const Color(0xFFE879F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool showHidden = widget.achievement.isHidden && !widget.isUnlocked;

    // Using localization keys or fallback to the key itself
    final displayTitle =
        showHidden ? "???" : context.tr(widget.achievement.title);
    final displayDesc =
        showHidden
            ? context.tr("ach_hidden_desc")
            : context.tr(widget.achievement.description);

    return Container(
      decoration: BoxDecoration(
        color:
            widget.isUnlocked
                ? _getBadgeColor().withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              widget.isUnlocked
                  ? _getBadgeColor().withValues(alpha: 0.3)
                  : (isDark ? const Color(0xFF334155) : Colors.grey[200]!),
          width: 2,
        ),
        boxShadow: [
          if (!isDark && !widget.isUnlocked)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3D Ödül Rozeti
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      widget.isUnlocked
                          ? LinearGradient(
                            colors: _getTierGradient(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                  color:
                      widget.isUnlocked
                          ? null
                          : (isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[100]),
                  boxShadow: [
                    if (widget.isUnlocked) ...[
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(-2, -2),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(4, 4),
                        spreadRadius: -2,
                      ),
                    ],
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Back glow
                    if (widget.isUnlocked)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getBadgeColor().withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                    // Glossy highlight
                    if (widget.isUnlocked)
                      Positioned(
                        top: 4,
                        left: 12,
                        right: 12,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),

                    if (showHidden)
                      Icon(
                        Icons.lock_rounded,
                        color: isDark ? Colors.white24 : Colors.grey[400],
                        size: 32,
                      )
                    else
                      Text(
                        widget.achievement.emoji,
                        style: TextStyle(
                          fontSize: 36,
                          shadows: [
                            if (widget.isUnlocked)
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // İsim & Açıklama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayDesc,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Alt Metadata
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildPill(
                    showHidden
                        ? context.tr("unknown")
                        : widget.achievement.tier.name.toUpperCase(),
                    widget.isUnlocked ? _getBadgeColor() : Colors.grey,
                    isDark,
                  ),
                  const SizedBox(width: 10),
                  if (!showHidden)
                    _buildPill(
                      widget.achievement.difficulty.name.toUpperCase(),
                      widget.achievement.difficulty ==
                              AchievementDifficulty.hard
                          ? Colors.red
                          : widget.achievement.difficulty ==
                              AchievementDifficulty.medium
                          ? Colors.orange
                          : Colors.green,
                      isDark,
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (widget.isUnlocked ? _getBadgeColor() : Colors.grey)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "+${widget.achievement.xpReward} XP",
                  style: TextStyle(
                    color:
                        widget.isUnlocked
                            ? _getTierGradient().first
                            : Colors.grey,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          // Progress Bar
          if (!widget.isUnlocked &&
              widget.achievement.totalSteps != null &&
              !showHidden)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr("progress").toUpperCase(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        "${widget.currentSteps} / ${widget.achievement.totalSteps}",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            height: 10,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? const Color(0xFF0F172A)
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width:
                                  constraints.maxWidth *
                                  _progressAnimation.value,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: _getTierGradient(),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getTierGradient().first.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(2, 0),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
