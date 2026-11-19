import 'package:flutter/material.dart';

/// AppColors represents design tokens:
/// Brand Red: #FF0050
/// Brand Black: #000000
class AppColors {
  AppColors._();

  // Backgrounds - Pure Black #000000 Atmosphere
  static const Color background = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFF0C0D0E);
  static const Color backgroundGradientTop = Color(0xFF141416);
  static const Color backgroundGradientBottom = Color(0xFF000000);

  // Surfaces & Cards (matching the activity card #1E1F24)
  static const Color surface = Color(0xFF1E1F24);
  static const Color surfaceLight = Color(0xFF28292F);
  static const Color cardBorder = Color(0x1FFFFFFF);

  // Brand Red Tokens (#FF0050)
  static const Color primary = Color(0xFFFF0050);
  static const Color primaryLight = Color(0xFFFF3373);
  static const Color primaryDark = Color(0xFFD60043);
  static const Color primaryGlow = Color(0x66FF0050);

  // Chips, Buttons & Badges
  static const Color chipBackground = Color(0xFF2A2B31);
  static const Color chipBorder = Color(0x2AFFFFFF);
  static const Color starGold = Color(0xFFFFB800);

  // Typography Tokens
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD0D1D6);
  static const Color textMuted = Color(0xFF8E8F96);
  static const Color textDisabled = Color(0xFF55565C);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF3373),
      Color(0xFFFF0050),
      Color(0xFFC7003E),
    ],
  );

  // Activity Button Radiant Gradient (#FF0050 with neon rose glow)
  static const RadialGradient actionButtonGradient = RadialGradient(
    center: Alignment(0.0, -0.2),
    radius: 0.95,
    colors: [
      Color(0xFFFF3373), // neon bright red top
      Color(0xFFFF0050), // brand red center
      Color(0xFFE00047), // deep red
      Color(0xFFFF80AB), // soft peach/rose rim
    ],
    stops: [0.0, 0.55, 0.85, 1.0],
  );

  // Red to Black Background Gradient (FF0050 -> 000000)
  static const LinearGradient redToBlackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF0050),
      Color(0xFF8A002B),
      Color(0xFF2D000E),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.28, 0.58, 1.0],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F0F12),
      Color(0xFF050506),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient posterCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x44000000),
      Color(0xDD000000),
    ],
    stops: [0.5, 0.75, 1.0],
  );
}

/// ThemeExtension to enable `Theme.of(context).extension<AppThemeColors>()`
/// or the convenient `context.colors` shortcut.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color primary;
  final Color chipBackground;
  final Color chipBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color starGold;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.primary,
    required this.chipBackground,
    required this.chipBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.starGold,
  });

  factory AppThemeColors.dark() => const AppThemeColors(
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceLight: AppColors.surfaceLight,
        primary: AppColors.primary,
        chipBackground: AppColors.chipBackground,
        chipBorder: AppColors.chipBorder,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textMuted: AppColors.textMuted,
        starGold: AppColors.starGold,
      );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? primary,
    Color? chipBackground,
    Color? chipBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? starGold,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      primary: primary ?? this.primary,
      chipBackground: chipBackground ?? this.chipBackground,
      chipBorder: chipBorder ?? this.chipBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      starGold: starGold ?? this.starGold,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipBorder: Color.lerp(chipBorder, other.chipBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      starGold: Color.lerp(starGold, other.starGold, t)!,
    );
  }
}

/// Extension on BuildContext for quick CSS-like color access: `context.colors.primary`
extension BuildContextColors on BuildContext {
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.dark();
}
