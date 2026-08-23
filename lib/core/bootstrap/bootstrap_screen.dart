import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_bootstrap_controller.dart';
import '../constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

/// Root entry widget for the app.
/// 
/// Shows an animated splash while bootstrap is running,
/// transitions to the real app when done, and shows an error
/// screen with retry if an unrecoverable failure occurs.
class BootstrapScreen extends ConsumerWidget {
  final Widget child;

  const BootstrapScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);

    return bootstrap.when(
      loading: () => const _SplashLoadingScreen(),
      error: (error, _) => _StartupErrorScreen(
        error: error,
        onRetry: () => ref.invalidate(appBootstrapProvider),
      ),
      data: (_) => child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Animated Splash Screen
// ─────────────────────────────────────────────────────────────────────────────

class _SplashLoadingScreen extends StatefulWidget {
  const _SplashLoadingScreen();

  @override
  State<_SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<_SplashLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _brandController;
  late final AnimationController _detailController;

  late final Animation<double> _brandScale;
  late final Animation<double> _brandOpacity;
  late final Animation<double> _dividerWidth;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    // ── Brand entrance (VitaCase text) ──────────────────────────────────────
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _brandScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandController,
        curve: Curves.easeOutBack,
      ),
    );

    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    // ── Detail entrance (divider, tagline, loader) ──────────────────────────
    _detailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _dividerWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _detailController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _detailController,
        curve: const Interval(0.15, 0.6, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _detailController,
        curve: const Interval(0.15, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _detailController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Staggered start ────────────────────────────────────────────────────
    _brandController.forward();
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _detailController.forward();
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagline = context.l10n.splashTagline;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Brand Text ─────────────────────────────────────────────
              ScaleTransition(
                scale: _brandScale,
                child: FadeTransition(
                  opacity: _brandOpacity,
                  child: Text(
                    'VitaCase',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF071D49),
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Gradient Accent Line ───────────────────────────────────
              AnimatedBuilder(
                animation: _dividerWidth,
                builder: (context, _) => Container(
                  width: 44 * _dividerWidth.value,
                  height: 2.5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Tagline ────────────────────────────────────────────────
              SlideTransition(
                position: _taglineSlide,
                child: FadeTransition(
                  opacity: _taglineOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      tagline,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.15,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 56),

              // ── Loader ─────────────────────────────────────────────────
              FadeTransition(
                opacity: _loaderOpacity,
                child: const _ThreeDotLoader(
                  color: Color(0xFF6366F1),
                  size: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Startup Error Screen (Matching Light Theme)
// ─────────────────────────────────────────────────────────────────────────────

class _StartupErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _StartupErrorScreen({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Startup Failed',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'VitaCase encountered an issue while starting up.\n'
                'Your data is safe.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Three-Dot Pulsing Loader
// ─────────────────────────────────────────────────────────────────────────────

class _ThreeDotLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _ThreeDotLoader({
    this.color = const Color(0xFF6366F1),
    this.size = 8,
  });

  @override
  State<_ThreeDotLoader> createState() => _ThreeDotLoaderState();
}

class _ThreeDotLoaderState extends State<_ThreeDotLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Stagger each dot by 0.15 phase offset
            final phase = (_controller.value + index * 0.15) % 1.0;
            // Smooth sine-wave pulse for natural feel
            final pulse = sin(phase * pi).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * pulse;
            final opacity = 0.3 + 0.7 * pulse;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.6),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
