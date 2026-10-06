import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// VitaCase Cyber Radar Splash Screen.
/// Adapted from the Cyber Radar design reference for Light & Dark modes.
class CyberRadarSplash extends StatefulWidget {
  final bool isDarkMode;
  final String? logoAsset;

  const CyberRadarSplash({
    super.key,
    required this.isDarkMode,
    this.logoAsset = 'assets/images/vitacase_brand_logo.png',
  });

  @override
  State<CyberRadarSplash> createState() => _CyberRadarSplashState();
}

class _CyberRadarSplashState extends State<CyberRadarSplash> with TickerProviderStateMixin {
  late final AnimationController _sweepController;
  late final AnimationController _spinSlowController;
  late final AnimationController _spinReverseController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      widget.isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _spinSlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _spinReverseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: false);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _spinSlowController.dispose();
    _spinReverseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF090F15) : const Color(0xFFF4F7FB);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Cyber Grid & Ambient Glow
          _buildBackgroundElements(isDark),

          // 2. Centered Branding & Radar Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 12),
                  _buildCentralBranding(isDark),
                  _buildBottomFooter(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements(bool isDark) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _CyberGridPainter(
              gridColor: isDark
                  ? const Color(0xFF00D2FF).withValues(alpha: 0.05)
                  : const Color(0xFF0066FF).withValues(alpha: 0.04),
              spacing: 32,
            ),
          ),
        ),
        Positioned(
          top: -50,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF0066FF).withValues(alpha: 0.15)
                    : const Color(0xFF00D2FF).withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCentralBranding(bool isDark) {
    final badgeText = isDark ? 'VAULT ACTIVE' : 'YOUR VAULT';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RadarScanner(
          size: 250,
          isDarkMode: isDark,
          sweepAnimation: _sweepController,
          spinSlowAnimation: _spinSlowController,
          spinReverseAnimation: _spinReverseController,
          floatAnimation: _floatController,
          child: _CyberLogo(
            size: 124,
            imageAssetPath: widget.logoAsset,
            badgeText: badgeText,
            isDarkMode: isDark,
          ),
        ),
        const SizedBox(height: 32),
        _buildTitleText(isDark),
        const SizedBox(height: 8),
        Text(
          '—  TÜM DOSYALARINIZ GÜVENDE  —',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
            letterSpacing: 2.2,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildTitleText(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vita',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -1.0,
            fontFamily: 'Manrope',
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF0066FF),
              Color(0xFF0088FF),
              Color(0xFF00D2FF),
            ],
          ).createShader(bounds),
          child: const Text(
            'Case',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.0,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFooter(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDark) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDarkTelemetryChip('• AES-256 GCM'),
              const SizedBox(width: 8),
              _buildDarkTelemetryChip('✓ Hardware Enclave'),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 14,
              color: isDark ? const Color(0xFF00D2FF) : const Color(0xFF0066FF),
            ),
            const SizedBox(width: 6),
            Text(
              'Zero-Knowledge Şifreleme • VitaCase Enclave',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: 100,
          height: 3,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : const Color(0xFF0F172A)).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildDarkTelemetryChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2236).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x4D00D2FF), width: 0.8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF00D2FF),
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Radar Scanner Widget
// ─────────────────────────────────────────────────────────────────────────────

class _RadarScanner extends StatelessWidget {
  final double size;
  final bool isDarkMode;
  final Animation<double> sweepAnimation;
  final Animation<double> spinSlowAnimation;
  final Animation<double> spinReverseAnimation;
  final Animation<double> floatAnimation;
  final Widget? child;

  const _RadarScanner({
    required this.size,
    required this.isDarkMode,
    required this.sweepAnimation,
    required this.spinSlowAnimation,
    required this.spinReverseAnimation,
    required this.floatAnimation,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cyanColor = isDarkMode ? const Color(0xFF00D2FF) : const Color(0xFF0066FF);
    final softCyan = isDarkMode ? const Color(0x3300D2FF) : const Color(0x330066FF);

    return AnimatedBuilder(
      animation: Listenable.merge([
        sweepAnimation,
        spinSlowAnimation,
        spinReverseAnimation,
        floatAnimation,
      ]),
      builder: (context, _) {
        final floatOffset = math.sin(floatAnimation.value * math.pi) * 4.0;

        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Radar Sweep Beam
                CustomPaint(
                  size: Size(size * 0.88, size * 0.88),
                  painter: _RadarBeamPainter(
                    angle: sweepAnimation.value * 2 * math.pi,
                    isDark: isDarkMode,
                  ),
                ),
                // 2. Rotating Outer Ticking Ring
                Transform.rotate(
                  angle: spinSlowAnimation.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _OuterTickingRingPainter(
                      color: cyanColor,
                      accentColor: isDarkMode ? Colors.cyanAccent : const Color(0xFF00D2FF),
                    ),
                  ),
                ),
                // 3. Counter-rotating Dashed Ring
                Transform.rotate(
                  angle: -spinReverseAnimation.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(size * 0.82, size * 0.82),
                    painter: _DashedRingPainter(
                      color: softCyan,
                    ),
                  ),
                ),
                // 4. Glow Ring
                Container(
                  width: size * 0.68,
                  height: size * 0.68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cyanColor.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cyanColor.withValues(alpha: isDarkMode ? 0.2 : 0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // 5. Reticle Corner Brackets
                SizedBox(
                  width: size * 0.76,
                  height: size * 0.76,
                  child: CustomPaint(
                    painter: _ReticleCornersPainter(
                      color: cyanColor,
                      cornerLength: 12,
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
                // 6. Centered Content (Logo)
                if (child != null) child!,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo & Badge
// ─────────────────────────────────────────────────────────────────────────────

class _CyberLogo extends StatelessWidget {
  final double size;
  final String? imageAssetPath;
  final String badgeText;
  final bool isDarkMode;

  const _CyberLogo({
    required this.size,
    this.imageAssetPath,
    required this.badgeText,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: size * 1.05,
          height: size * 1.05,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066FF).withValues(alpha: isDarkMode ? 0.35 : 0.18),
                blurRadius: 36,
                spreadRadius: 6,
              ),
            ],
          ),
        ),
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF101C2B).withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(size * 0.26),
            border: Border.all(
              color: isDarkMode ? const Color(0x3300D2FF) : const Color(0xFFBAE6FD),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.2),
            child: _buildLogoContent(),
          ),
        ),
        Positioned(
          bottom: -11,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF0A1726) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF00D2FF).withValues(alpha: 0.5)
                    : const Color(0xFF7DD3FC),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00D2FF),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? const Color(0xFF00D2FF) : const Color(0xFF0050CB),
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoContent() {
    if (imageAssetPath != null && imageAssetPath!.isNotEmpty) {
      return Image.asset(
        imageAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackVectorLogo(),
      );
    }
    return _buildFallbackVectorLogo();
  }

  Widget _buildFallbackVectorLogo() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0066FF),
            Color(0xFF0044BB),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        'V',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontFamily: 'Manrope',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painters
// ─────────────────────────────────────────────────────────────────────────────

class _CyberGridPainter extends CustomPainter {
  final Color gridColor;
  final double spacing;

  _CyberGridPainter({required this.gridColor, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) => false;
}

class _RadarBeamPainter extends CustomPainter {
  final double angle;
  final bool isDark;

  _RadarBeamPainter({required this.angle, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi / 2.5,
        colors: [
          (isDark ? const Color(0xFF00D2FF) : const Color(0xFF0066FF)).withValues(alpha: 0.28),
          Colors.transparent,
        ],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RadarBeamPainter oldDelegate) => oldDelegate.angle != angle;
}

class _OuterTickingRingPainter extends CustomPainter {
  final Color color;
  final Color accentColor;

  _OuterTickingRingPainter({required this.color, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, linePaint);

    final dotPaint = Paint()..style = PaintingStyle.fill;

    dotPaint.color = color;
    canvas.drawCircle(Offset(center.dx, center.dy - radius), 4, dotPaint);

    dotPaint.color = accentColor;
    canvas.drawCircle(Offset(center.dx, center.dy + radius), 3, dotPaint);

    dotPaint.color = color.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(center.dx - radius, center.dy), 2.5, dotPaint);
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _OuterTickingRingPainter oldDelegate) => false;
}

class _DashedRingPainter extends CustomPainter {
  final Color color;

  _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const int totalDashes = 48;
    const double dashAngle = (2 * math.pi) / totalDashes;

    for (int i = 0; i < totalDashes; i++) {
      if (i % 2 == 0) {
        final start = i * dashAngle;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          dashAngle * 0.55,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter oldDelegate) => false;
}

class _ReticleCornersPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  _ReticleCornersPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerLength), paint);

    canvas.drawLine(Offset(w, 0), Offset(w - cornerLength, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLength), paint);

    canvas.drawLine(Offset(0, h), Offset(cornerLength, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - cornerLength), paint);

    canvas.drawLine(Offset(w, h), Offset(w - cornerLength, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant _ReticleCornersPainter oldDelegate) => false;
}
