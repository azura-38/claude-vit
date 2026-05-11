import 'package:flutter/material.dart';

/// VitaCase color palette — extracted from the React app's Tailwind config.
class AppColors {
  AppColors._();

  // ── Primary (Classic Theme) ──
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryIndigoDark = Color(0xFF4338CA);
  static const Color primaryViolet = Color(0xFF818CF8);
  static const Color primaryGreen = Color(
    0xFF4CAF50,
  ); // Kept for feature-specific uses

  // ── Medical Blue (used in appointments/nav active) ──

  // ── Teal (doctors accent) ──
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color teal50 = Color(0xFFF0FDFA);

  // ── Orange (medicines accent) ──
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange50 = Color(0xFFFFF7ED);

  // ── Health Metric Gradient Start/End Colors ──
  // Steps: orange-400 → rose-500
  static const Color stepsStart = Color(0xFFFB923C);
  static const Color stepsEnd = Color(0xFFF43F5E);

  // Heart: red-500 → pink-600
  static const Color heartStart = Color(0xFFEF4444);
  static const Color heartEnd = Color(0xFFDB2777);

  // Sleep: indigo-600 → slate-900
  static const Color sleepStart = Color(0xFF4F46E5);
  static const Color sleepEnd = Color(0xFF0F172A);

  // Water: blue-400 → indigo-600
  static const Color waterStart = Color(0xFF60A5FA);
  static const Color waterEnd = Color(0xFF4F46E5);

  // ── Hero Card Gradient (Dashboard) ──
  static const Color heroStart = primaryIndigo;
  static const Color heroEnd = primaryViolet;

  // ── Backgrounds ──
  static const Color bgLight = Color(0xFFF7F9FC);
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(
    0xFF0F172A,
  ); // Matching background for dark mode

  // ── Glassmorphism & Translucency ──
  static const Color glassBg = Color(0x801E293B); // rgba(30, 41, 59, 0.5)
  static const Color glassBorder = Color(
    0x3394A3B8,
  ); // slate-400 with 0.2 opacity
  static const Color glassNav = Color(0xCC0F172A); // rgba(15, 23, 42, 0.8)

  // ── Cards ──
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1F2937);
  static const Color cardBorderLight = Color(0xFFF3F4F6);
  static const Color cardBorderDark = Color(0xFF374151);

  // ── Text ──
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // ── Status ──
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Medical Blue (Professional Palette) ──
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color blue50 = Color(0xFFEFF6FF);

  static const Color medicalBlue = blue600;

  // Semantic aliases used by older feature screens during the rebuild.
  static const Color primary = medicalBlue;
  static const Color primaryLight = blue50;
  static const Color secondary = textSecondary;
  static const Color surface = surfaceLight;
  static const Color border = cardBorderLight;
  static const Color outline = cardBorderLight;
  static const Color danger = error;
  static const Color softBlue = blue50;
  static const Color chipBlue = blue50;
  static const Color glass = glassBg;

  // ── Tag Colors ──
  static const Color tagLabBg = Color(0xFFEFF6FF);
  static const Color tagLabText = Color(0xFF1D4ED8);
  static const Color tagRadiologyBg = Color(0xFFF5F3FF);
  static const Color tagRadiologyText = Color(0xFF6D28D9);
  static const Color tagPrescriptionBg = Color(0xFFF0FDF4);
  static const Color tagPrescriptionText = Color(0xFF15803D);
  static const Color tagReportBg = Color(0xFFFFF7ED);
  static const Color tagReportText = Color(0xFFC2410C);
  static const Color tagOperationBg = Color(0xFFFEF2F2);
  static const Color tagOperationText = Color(0xFFB91C1C);
  static const Color tagVaccinationBg = Color(0xFFECFDF5);
  static const Color tagVaccinationText = Color(0xFF047857);
  static const Color tagOtherBg = Color(0xFFF9FAFB);
  static const Color tagOtherText = Color(0xFF374151);

  // ── Nav ──
  static const Color navInactive = Color(0xFF9CA3AF);
  static const Color navActive = Color(0xFF2563EB);

  // ── Keşfet FAB Gradient ──
  static const Color exploreFabStart = Color(0xFF4F46E5);
  static const Color exploreFabEnd = Color(0xFF8B5CF6);

  // ── Misc ──
  static const Color guestBannerBg = Color(0xFFFEF9C3);
  static const Color guestBannerText = Color(0xFF92400E);
  static const Color noteMarqueeBg = Color(0xFFFFFBEB);
  static const Color noteMarqueeText = Color(0xFFB45309);

  // ── Dashboard Redesign Gradients ──
  static const Color gradBlueStart = Color(0xFF6A5AE0);
  static const Color gradBlueEnd = Color(0xFF4A90E2);
  static const Color gradOrangeStart = Color(0xFFFF9D6C);
  static const Color gradOrangeEnd = Color(0xFFFF5F6D);
  static const Color gradPinkStart = Color(0xFFFF416C);
  static const Color gradPinkEnd = Color(0xFFFF4B2B);
  static const Color gradNavyStart = Color(0xFF1E3C72);
  static const Color gradNavyEnd = Color(0xFF2A5298);
  static const Color gradWaterStart = Color(0xFF56CCF2);
  static const Color gradWaterEnd = Color(0xFF2F80ED);

  // ── Theme Specific Palettes ──
  // Luxe Sanctuary (Default)
  static const Color luxePrimary = Color(0xFF005DA7);
  static const Color luxeBg = Color(0xFFF7F9FC);

  // Amethyst Aura (Purple)
  static const Color purplePrimary = Color(0xFF7E57C2);
  static const Color purpleBg = Color(0xFFF3E5F5);

  // Emerald Garden (Nature)
  static const Color naturePrimary = Color(0xFF66BB6A);
  static const Color natureBg = Color(0xFFF1F8E9);

  // Midnight Neon (Black)
  static const Color neonPrimary = Color(0xFF00E5FF);
  static const Color neonBg = Color(0xFF000000);

  // Ocean Serenity (Soft Blue)
  static const Color oceanPrimary = Color(0xFF005DA7);
  static const Color oceanBg = Color(0xFFF1F6FA);

  // Amber Glow (Warm)
  static const Color amberPrimary = Color(0xFFFFA726);
  static const Color amberBg = Color(0xFFFFF3E0);
}
