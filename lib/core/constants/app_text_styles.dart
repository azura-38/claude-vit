import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system matching the React app's font choices.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter();

  // ─── Headings ───
  static TextStyle heading1 = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  // ─── Labels ───
  static TextStyle labelLg = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMd = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.textSecondary,
  );

  static TextStyle labelSm = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  static TextStyle labelXs = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: AppColors.textTertiary,
  );

  // ─── Section header (uppercase tiny) ───
  static TextStyle sectionHeader = _base.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
    color: AppColors.textTertiary,
  );

  // ─── Body ───
  static TextStyle body = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ─── Button ───
  static TextStyle button = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  // ─── Metric value (large number on health cards) ───
  static TextStyle metricValue = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: Colors.white,
  );

  static TextStyle metricUnit = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Colors.white70,
  );

  // ─── Nav ───
  static TextStyle navLabel = _base.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: AppColors.navInactive,
  );

  static TextStyle navLabelActive = _base.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: AppColors.navActive,
  );
}
