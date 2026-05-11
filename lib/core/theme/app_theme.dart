import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

import 'package:vitacase/core/extensions/l10n_extension.dart';

enum AppThemeType {
  light,
  dark,
  purple,
  nature,
  ocean,
  amber;

  String localizedLabel(BuildContext context) {
    switch (this) {
      case AppThemeType.light:
        return context.l10n.themeLuxeSanctuary;
      case AppThemeType.dark:
        return context.l10n.themeMidnightNeon;
      case AppThemeType.purple:
        return context.l10n.themeAmethystAura;
      case AppThemeType.nature:
        return context.l10n.themeEmeraldGarden;
      case AppThemeType.ocean:
        return context.l10n.themeOceanSerenity;
      case AppThemeType.amber:
        return context.l10n.themeAmberGlow;
    }
  }

  String get label {
    switch (this) {
      case AppThemeType.light:
        return 'Luxe Sanctuary';
      case AppThemeType.dark:
        return 'Midnight Neon';
      case AppThemeType.purple:
        return 'Amethyst Aura';
      case AppThemeType.nature:
        return 'Emerald Garden';
      case AppThemeType.ocean:
        return 'Ocean Serenity';
      case AppThemeType.amber:
        return 'Amber Glow';
    }
  }
}

/// App-wide ThemeData for light and dark modes — matching the React app.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryIndigo,
        brightness: Brightness.light,
        surface: AppColors.surfaceLight,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.cardBorderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.medicalBlue, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.medicalBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.medicalBlue,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.navActive,
        unselectedItemColor: AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorderLight,
        thickness: 1,
      ),
    );
  }

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    primary: AppColors.medicalBlue,
    background: AppColors.bgDark,
    surface: AppColors.surfaceDark,
    isAmoled: false,
  );

  static ThemeData getThemeByType(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return light;
      case AppThemeType.dark:
        return dark;
      case AppThemeType.purple:
        return _buildTheme(
          brightness: Brightness.light,
          primary: AppColors.purplePrimary,
          background: AppColors.purpleBg,
          surface: Colors.white,
        );
      case AppThemeType.nature:
        return _buildTheme(
          brightness: Brightness.light,
          primary: AppColors.naturePrimary,
          background: AppColors.natureBg,
          surface: Colors.white,
        );
      case AppThemeType.ocean:
        return _buildTheme(
          brightness: Brightness.light,
          primary: AppColors.oceanPrimary,
          background: AppColors.oceanBg,
          surface: AppColors.oceanBg,
        );
      case AppThemeType.amber:
        return _buildTheme(
          brightness: Brightness.light,
          primary: AppColors.amberPrimary,
          background: AppColors.amberBg,
          surface: Colors.white,
        );
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    bool isAmoled = false,
  }) {
    final isDark = brightness == Brightness.dark;
    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme:
          isDark
              ? ColorScheme.dark(
                primary: primary,
                secondary: primary.withValues(alpha: 0.8),
                surface: surface,
                onSurface: Colors.white,
                error: AppColors.error,
              )
              : ColorScheme.fromSeed(
                seedColor: primary,
                brightness: Brightness.light,
                surface: surface,
                primary: primary,
              ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        titleLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color:
            isDark
                ? (isAmoled ? Colors.black : AppColors.glassBg)
                : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? AppColors.glassBorder : AppColors.cardBorderLight,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.glassBg : AppColors.bgLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.glassBorder : AppColors.cardBorderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.glassBorder : AppColors.cardBorderLight,
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
          foregroundColor:
              isDark && !isAmoled
                  ? Colors.white
                  : (isAmoled ? Colors.black : Colors.white),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: isDark && isAmoled ? Colors.black : Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.glassNav : Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: isDark ? Colors.white38 : AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.glassBorder : AppColors.cardBorderLight,
        thickness: 1,
      ),
    );
  }
}
