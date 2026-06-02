import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../constants/app_colors.dart';

enum AppThemeType {
  light,
  dark,
  lavender,
  ocean,
  mint,
  peach,
  rose,
  slate,
  sand,
  forest,

  /// Kept only for backward compatibility with older saved preferences.
  /// It is not shown in theme selection.
  system;

  static const selectableThemes = [
    AppThemeType.light,
    AppThemeType.dark,
    AppThemeType.lavender,
    AppThemeType.ocean,
    AppThemeType.mint,
    AppThemeType.peach,
    AppThemeType.rose,
    AppThemeType.slate,
    AppThemeType.sand,
    AppThemeType.forest,
  ];

  static const freeThemes = [
    AppThemeType.light,
    AppThemeType.dark,
  ];

  static const rewardThemes = [
    AppThemeType.lavender,
    AppThemeType.ocean,
    AppThemeType.mint,
    AppThemeType.peach,
    AppThemeType.rose,
    AppThemeType.slate,
    AppThemeType.sand,
    AppThemeType.forest,
  ];

  bool get isRewardTheme => rewardThemes.contains(this);

  String localizedLabel(BuildContext context) {
    switch (this) {
      case AppThemeType.light:
        return context.tr('theme_light');
      case AppThemeType.dark:
        return context.tr('theme_dark');
      case AppThemeType.lavender:
        return context.tr('theme_amethyst_aura');
      case AppThemeType.ocean:
        return context.tr('theme_ocean_serenity');
      case AppThemeType.mint:
        return context.tr('theme_emerald_garden');
      case AppThemeType.peach:
        return context.tr('theme_amber_glow');
      case AppThemeType.rose:
        return context.tr('theme_boutique');
      case AppThemeType.slate:
        return context.tr('theme_luxe_sanctuary');
      case AppThemeType.sand:
        return context.tr('theme_midnight_neon');
      case AppThemeType.forest:
        return context.tr('theme_forest_sanctuary');
      case AppThemeType.system:
        return context.tr('theme_system');
    }
  }

  String get label {
    switch (this) {
      case AppThemeType.light:
        return 'Digital Sanctuary';
      case AppThemeType.dark:
        return 'Midnight Sanctuary';
      case AppThemeType.lavender:
        return 'Amethyst Calm';
      case AppThemeType.ocean:
        return 'Abyssal Calm';
      case AppThemeType.mint:
        return 'Clinical Clarity';
      case AppThemeType.peach:
        return 'Sunrise Wellness';
      case AppThemeType.rose:
        return 'Vitality Bloom';
      case AppThemeType.slate:
        return 'Nordic Health';
      case AppThemeType.sand:
        return 'Golden Vitality';
      case AppThemeType.forest:
        return 'Forest Sanctuary';
      case AppThemeType.system:
        return 'System';
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        primary: const Color(0xFF005DA7),
        secondary: const Color(0xFF2976C7),
        background: const Color(0xFFF7F9FC),
        surface: Colors.white,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        primary: const Color(0xFF4A90E2),
        secondary: const Color(0xFF1C252E),
        background: const Color(0xFF0B1117),
        surface: const Color(0xFF1C252E),
        isAmoled: false,
      );

  static ThemeData getThemeByType(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return light;
      case AppThemeType.dark:
        return dark;
      case AppThemeType.lavender:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF7C3AED),
          secondary: const Color(0xFFBAABF3),
          background: const Color(0xFF020617),
          surface: const Color(0xFF131B2E),
        );
      case AppThemeType.ocean:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF00E5FF),
          secondary: const Color(0xFF415A77),
          background: const Color(0xFF0D1B2A),
          surface: const Color(0xFF17324D),
        );
      case AppThemeType.mint:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF005DA7),
          secondary: const Color(0xFF006A6A),
          background: Colors.white,
          surface: Colors.white,
        );
      case AppThemeType.peach:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF7DA395),
          secondary: const Color(0xFFE67E6E),
          background: const Color(0xFFFDF8F3),
          surface: Colors.white,
        );
      case AppThemeType.rose:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFFFF7043),
          secondary: const Color(0xFF8E244D),
          background: const Color(0xFFFCE4EC),
          surface: const Color(0xFFFFF8F8),
        );
      case AppThemeType.slate:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF9A8C98),
          secondary: const Color(0xFF4A4E69),
          background: const Color(0xFF22223B),
          surface: const Color(0xFF2B2F48),
        );
      case AppThemeType.sand:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFFD4AF37),
          secondary: const Color(0xFF1A1A1A),
          background: const Color(0xFFF9F8F3),
          surface: Colors.white,
        );
      case AppThemeType.forest:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFFA3B18A),
          secondary: const Color(0xFF4F6357),
          background: const Color(0xFF080F0A),
          surface: const Color(0xFF22342A),
        );
      case AppThemeType.system:
        return light;
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    bool isAmoled = false,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primary,
            secondary: secondary,
            surface: isAmoled ? Colors.black : surface,
            onSurface: Colors.white,
            error: AppColors.error,
          )
        : ColorScheme.fromSeed(
            seedColor: primary,
            brightness: Brightness.light,
            surface: surface,
            primary: primary,
            secondary: secondary,
          );

    TextTheme applyFontFeatures(TextTheme theme) {
      const features = [FontFeature.disable('liga'), FontFeature.disable('calt')];
      return theme.copyWith(
        displayLarge: theme.displayLarge?.copyWith(fontFeatures: features),
        displayMedium: theme.displayMedium?.copyWith(fontFeatures: features),
        displaySmall: theme.displaySmall?.copyWith(fontFeatures: features),
        headlineLarge: theme.headlineLarge?.copyWith(fontFeatures: features),
        headlineMedium: theme.headlineMedium?.copyWith(fontFeatures: features),
        headlineSmall: theme.headlineSmall?.copyWith(fontFeatures: features),
        titleLarge: theme.titleLarge?.copyWith(fontFeatures: features),
        titleMedium: theme.titleMedium?.copyWith(fontFeatures: features),
        titleSmall: theme.titleSmall?.copyWith(fontFeatures: features),
        bodyLarge: theme.bodyLarge?.copyWith(fontFeatures: features),
        bodyMedium: theme.bodyMedium?.copyWith(fontFeatures: features),
        bodySmall: theme.bodySmall?.copyWith(fontFeatures: features),
        labelLarge: theme.labelLarge?.copyWith(fontFeatures: features),
        labelMedium: theme.labelMedium?.copyWith(fontFeatures: features),
        labelSmall: theme.labelSmall?.copyWith(fontFeatures: features),
      );
    }

    final baseTextTheme = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme;
    final googleTextTheme = applyFontFeatures(GoogleFonts.interTextTheme(baseTextTheme));
    final textTheme = googleTextTheme.copyWith(
      titleLarge: googleTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      bodyMedium: googleTextTheme.bodyMedium?.copyWith(
        color: isDark ? Colors.white.withValues(alpha: 0.86) : AppColors.textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isAmoled ? Colors.black : background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: isDark ? (isAmoled ? Colors.black : surface) : surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : AppColors.cardBorderLight,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surface.withValues(alpha: 0.82) : const Color(0xFFF3F6FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.cardBorderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.cardBorderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? surface : Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: isDark ? Colors.white38 : AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white.withValues(alpha: 0.10) : AppColors.cardBorderLight,
        thickness: 1,
      ),
    );
  }
}
