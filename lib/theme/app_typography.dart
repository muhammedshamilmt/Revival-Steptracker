import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Quicksand';
  static const String fontFamilyQuicksand = 'Quicksand';
  static const String fontFamilyFredoka = 'Fredoka';
  static const String fontFamilyNunito = 'Nunito';

  // Base font style using Quicksand Medium (700) for all text
  static const TextStyle base = TextStyle(
    fontFamily: fontFamilyQuicksand,
    fontWeight: FontWeight.w700,
  );

  // Auth Button text using Fredoka Bold 700
  static const TextStyle authButton = TextStyle(
    fontFamily: fontFamilyFredoka,
    // fontWeight: FontWeight.w600,
    fontSize: 1,
    letterSpacing: 0.2,
  );

  // Login headline styles with Quicksand Bold 700
  static TextStyle loginHeadlineMuted = base.copyWith(
    fontSize: 27,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF8E8E93),
    letterSpacing: -0.4,
    height: 1.22,
  );

  static TextStyle loginHeadlineBold = base.copyWith(
    fontSize: 27,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.4,
    height: 1.22,
  );

  static TextStyle loginDisclaimer = base.copyWith(
    fontSize: 12.5,
    fontFamily: fontFamilyQuicksand,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF73737A),
    height: 1.45,
  );

  static TextStyle heroTitle = base.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle heroYear = base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static TextStyle chipText = base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle chipRating = base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle sectionTitle = base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle sectionAction = base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle tabActive = const TextStyle(
    fontFamily: fontFamilyFredoka,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle tabInactive = const TextStyle(
    fontFamily: fontFamilyFredoka,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle cardTitle = base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle cardSubtitle = base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
}
