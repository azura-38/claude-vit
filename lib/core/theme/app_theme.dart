import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  String localizedLabel(BuildContext context) => label;

  String get label {
    switch (this) {
      case AppThemeType.light:
        return 'Light';
      case AppThemeType.dark:
        return 'Dark';
      case AppThemeType.lavender:
        return 'Lavender';
      case AppThemeType.ocean:
        return 'Ocean';
      case AppThemeType.mint:
        return 'Mint';
      case AppThemeType.peach:
        return 'Peach';
      case AppThemeType.rose:
        return 'Rose';
      case AppThemeType.slate:
        return 'Slate';
      case AppThemeType.sand:
        return 'Sand';
      case AppThemeType.forest:
        return 'Forest';
      case AppThemeType.system:
        return 'System';
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        primary: AppColors.luxePrimary,
        background: const Color(0xFFF6F8FC),
        surface: Colors.white,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        primary: AppColors.neonPrimary,
        background: Colors.black,
        surface: const Color(0xFF111827),
        isAmoled: true,
      );

  static ThemeData getThemeByType(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return light;
      case AppThemeType.dark:
        return dark;
      case AppThemeType.lavender:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF8B5CF6),
          background: const Color(0xFFF7F3FF),
          surface: Colors.white,
        );
      case AppThemeType.ocean:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF0EA5E9),
          background: const Color(0xFFF0F9FF),
          surface: Colors.white,
        );
      case AppThemeType.mint:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF10B981),
          background: const Color(0xFFF0FDF4),
          surface: Colors.white,
        );
      case AppThemeType.peach:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFFFF8A65),
          background: const Color(0xFFFFF7ED),
          surface: Colors.white,
        );
      case AppThemeType.rose:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFFE11D48),
          background: const Color(0xFFFFF1F2),
          surface: Colors.white,
        );
      case AppThemeType.slate:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF475569),
          background: const Color(0xFFF8FAFC),
          surface: Colors.white,
        );
      case AppThemeType.sand:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFFD97706),
          background: const Color(0xFFFFFBEB),
          surface: Colors.white,
        );
      case AppThemeType.forest:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF15803D),
          background: const Color(0xFFF0FDF4),
          surface: Colors.white,
        );
      case AppThemeType.system:
        return light;
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

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primary,
            secondary: primary.withValues(alpha: 0.7),
            surface: isAmoled ? Colors.black : surface,
            onSurface: Colors.white,
            error: AppColors.error,
          )
        : ColorScheme.fromSeed(
            seedColor: primary,
            brightness: Brightness.light,
            surface: surface,
            primary: primary,
          );

    final baseTextTheme = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme;
    final googleTextTheme = GoogleFonts.interTextTheme(baseTextTheme);
    final textTheme = googleTextTheme.copyWith(
      titleLarge: googleTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : AppColors.textPrimary,
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
        color: isDark
            ? (isAmoled ? Colors.black : AppColors.cardDark)
            : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark
                ? (isAmoled ? Colors.white.withValues(alpha: 0.1) : AppColors.cardBorderDark)
                : AppColors.cardBorderLight,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? (isAmoled ? Colors.black : AppColors.cardDark) : const Color(0xFFF3F6FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? (isAmoled ? Colors.black : AppColors.cardDark) : Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: isDark ? Colors.white38 : AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        thickness: 1,
      ),
    );
  }
}
