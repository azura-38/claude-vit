import 'package:flutter/material.dart';

import 'app_theme.dart';

class ThemeVisuals {
  const ThemeVisuals({
    required this.type,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.softBackground,
    required this.icon,
    required this.placeholderIcon,
    required this.assetHint,
  });

  final AppThemeType type;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color softBackground;
  final IconData icon;
  final IconData placeholderIcon;

  /// Optional future asset hook. When final generated assets are added, keep the
  /// file naming stable and point each theme to its real illustration here.
  final String assetHint;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, secondary],
      );

  LinearGradient get softGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [softBackground, background],
      );

  static ThemeVisuals of(AppThemeType type) => _items[type] ?? _items[AppThemeType.light]!;

  static const Map<AppThemeType, ThemeVisuals> _items = {
    AppThemeType.light: ThemeVisuals(
      type: AppThemeType.light,
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF60A5FA),
      background: Color(0xFFF6F8FC),
      softBackground: Color(0xFFEFF6FF),
      icon: Icons.wb_sunny_rounded,
      placeholderIcon: Icons.auto_awesome_rounded,
      assetHint: 'assets/placeholders/theme_light.png',
    ),
    AppThemeType.dark: ThemeVisuals(
      type: AppThemeType.dark,
      primary: Color(0xFF38BDF8),
      secondary: Color(0xFF818CF8),
      background: Color(0xFF020617),
      softBackground: Color(0xFF0F172A),
      icon: Icons.dark_mode_rounded,
      placeholderIcon: Icons.nightlight_round,
      assetHint: 'assets/placeholders/theme_dark.png',
    ),
    AppThemeType.lavender: ThemeVisuals(
      type: AppThemeType.lavender,
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFC084FC),
      background: Color(0xFFF7F3FF),
      softBackground: Color(0xFFF3E8FF),
      icon: Icons.spa_rounded,
      placeholderIcon: Icons.auto_awesome_rounded,
      assetHint: 'assets/placeholders/theme_lavender.png',
    ),
    AppThemeType.ocean: ThemeVisuals(
      type: AppThemeType.ocean,
      primary: Color(0xFF0EA5E9),
      secondary: Color(0xFF22D3EE),
      background: Color(0xFFF0F9FF),
      softBackground: Color(0xFFE0F2FE),
      icon: Icons.water_drop_rounded,
      placeholderIcon: Icons.waves_rounded,
      assetHint: 'assets/placeholders/theme_ocean.png',
    ),
    AppThemeType.mint: ThemeVisuals(
      type: AppThemeType.mint,
      primary: Color(0xFF10B981),
      secondary: Color(0xFF6EE7B7),
      background: Color(0xFFF0FDF4),
      softBackground: Color(0xFFD1FAE5),
      icon: Icons.eco_rounded,
      placeholderIcon: Icons.local_florist_rounded,
      assetHint: 'assets/placeholders/theme_mint.png',
    ),
    AppThemeType.peach: ThemeVisuals(
      type: AppThemeType.peach,
      primary: Color(0xFFFF8A65),
      secondary: Color(0xFFFFB199),
      background: Color(0xFFFFF7ED),
      softBackground: Color(0xFFFFEDD5),
      icon: Icons.local_fire_department_rounded,
      placeholderIcon: Icons.favorite_rounded,
      assetHint: 'assets/placeholders/theme_peach.png',
    ),
    AppThemeType.rose: ThemeVisuals(
      type: AppThemeType.rose,
      primary: Color(0xFFE11D48),
      secondary: Color(0xFFFB7185),
      background: Color(0xFFFFF1F2),
      softBackground: Color(0xFFFFE4E6),
      icon: Icons.favorite_rounded,
      placeholderIcon: Icons.bubble_chart_rounded,
      assetHint: 'assets/placeholders/theme_rose.png',
    ),
    AppThemeType.slate: ThemeVisuals(
      type: AppThemeType.slate,
      primary: Color(0xFF475569),
      secondary: Color(0xFF94A3B8),
      background: Color(0xFFF8FAFC),
      softBackground: Color(0xFFE2E8F0),
      icon: Icons.dashboard_customize_rounded,
      placeholderIcon: Icons.grid_view_rounded,
      assetHint: 'assets/placeholders/theme_slate.png',
    ),
    AppThemeType.sand: ThemeVisuals(
      type: AppThemeType.sand,
      primary: Color(0xFFD97706),
      secondary: Color(0xFFFBBF24),
      background: Color(0xFFFFFBEB),
      softBackground: Color(0xFFFEF3C7),
      icon: Icons.landscape_rounded,
      placeholderIcon: Icons.wb_twilight_rounded,
      assetHint: 'assets/placeholders/theme_sand.png',
    ),
    AppThemeType.forest: ThemeVisuals(
      type: AppThemeType.forest,
      primary: Color(0xFF15803D),
      secondary: Color(0xFF4ADE80),
      background: Color(0xFFF0FDF4),
      softBackground: Color(0xFFDCFCE7),
      icon: Icons.forest_rounded,
      placeholderIcon: Icons.park_rounded,
      assetHint: 'assets/placeholders/theme_forest.png',
    ),
  };
}

class ThemePlaceholder extends StatelessWidget {
  const ThemePlaceholder({
    super.key,
    required this.type,
    this.size = 64,
    this.iconSize = 30,
    this.radius = 22,
    this.icon,
  });

  final AppThemeType type;
  final double size;
  final double iconSize;
  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final visuals = ThemeVisuals.of(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: visuals.gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: visuals.primary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon ?? visuals.placeholderIcon, color: Colors.white, size: iconSize),
    );
  }
}
