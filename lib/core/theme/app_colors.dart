import 'package:flutter/material.dart';

/// Tech-Noir Precision color system from Stitch design system.
/// Monochrome palette leveraging OLED blacks and luminance hierarchy.
class AppColors {
  AppColors._();

  // ─── Base Surfaces ───
  static const Color background = Color(0xFF131313);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceDim = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF393939);

  // ─── Surface Container Hierarchy ───
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1B1B1B);
  static const Color surfaceContainer = Color(0xFF1F1F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353535);
  static const Color surfaceVariant = Color(0xFF353535);

  // ─── Primary ───
  static const Color primary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD4D4D4);
  static const Color onPrimary = Color(0xFF1A1C1C);
  static const Color onPrimaryContainer = Color(0xFF000000);

  // ─── Secondary ───
  static const Color secondary = Color(0xFFC8C6C5);
  static const Color secondaryContainer = Color(0xFF474746);
  static const Color onSecondary = Color(0xFF1B1C1C);
  static const Color onSecondaryContainer = Color(0xFFE5E2E1);

  // ─── Tertiary ───
  static const Color tertiary = Color(0xFFE2E2E2);
  static const Color tertiaryContainer = Color(0xFF919191);

  // ─── On Surface ───
  static const Color onBackground = Color(0xFFE2E2E2);
  static const Color onSurface = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFFC6C6C6);

  // ─── Outline ───
  static const Color outline = Color(0xFF919191);
  static const Color outlineVariant = Color(0xFF474747);

  // ─── Error ───
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);

  // ─── Inverse ───
  static const Color inverseSurface = Color(0xFFE2E2E2);
  static const Color inverseOnSurface = Color(0xFF303030);
  static const Color inversePrimary = Color(0xFF5D5F5F);

  // ─── Surface Tint ───
  static const Color surfaceTint = Color(0xFFC6C6C7);

  // ─── Platform Accent Colors (subtle monochrome variations) ───
  static const Color leetcodeAccent = Color(0xFFFFA116);
  static const Color codeforcesAccent = Color(0xFF1A8FFF);
  static const Color codechefAccent = Color(0xFF5B4638);

  // ─── Functional ───
  static const Color success = Color(0xFF4CAF50);
  static const Color ratingUp = Color(0xFF66BB6A);
  static const Color ratingDown = Color(0xFFEF5350);

  // ─── Ghost Border ───
  static Color ghostBorder = outlineVariant.withValues(alpha: 0.15);
}
