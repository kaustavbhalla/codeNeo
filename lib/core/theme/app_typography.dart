import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system pairing Space Grotesk (headlines/labels) with Inter (body).
/// Space Grotesk: utilitarian, technical, dot-matrix aesthetic.
/// Inter: neutral clarity, maximum readability.
class AppTypography {
  AppTypography._();

  // ─── Display (Space Grotesk) ───
  static TextStyle displayLarge = GoogleFonts.spaceGrotesk(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.12,
    height: 1.1,
    color: AppColors.primary,
  );

  static TextStyle displayMedium = GoogleFonts.spaceGrotesk(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.88,
    height: 1.1,
    color: AppColors.primary,
  );

  static TextStyle displaySmall = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.72,
    height: 1.15,
    color: AppColors.primary,
  );

  // ─── Headline (Space Grotesk) ───
  static TextStyle headlineLarge = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    height: 1.2,
    color: AppColors.primary,
  );

  static TextStyle headlineMedium = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.56,
    height: 1.25,
    color: AppColors.primary,
  );

  static TextStyle headlineSmall = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48,
    height: 1.3,
    color: AppColors.primary,
  );

  // ─── Title (Space Grotesk) ───
  static TextStyle titleLarge = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.onSurface,
  );

  static TextStyle titleMedium = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle titleSmall = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.onSurface,
  );

  // ─── Label (Space Grotesk — Dot-Matrix Aesthetic) ───
  static TextStyle labelLarge = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle labelMedium = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelSmall = GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.1,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );

  // ─── Body (Inter — Readability) ───
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
    color: AppColors.onSurfaceVariant,
  );

  // ─── Specialized Styles ───

  /// Giant number display (e.g., "742 SOLVED", "2,482")
  static TextStyle statNumber = GoogleFonts.spaceGrotesk(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.96,
    height: 1.0,
    color: AppColors.primary,
  );

  /// Medium stat number (e.g., "1,204" in cards)
  static TextStyle statNumberMedium = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    height: 1.1,
    color: AppColors.primary,
  );

  /// Small stat label (e.g., "MAX RATING", "GLOBAL RANK")
  static TextStyle statLabel = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );

  /// Navigation bar label
  static TextStyle navLabel = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.2,
    color: AppColors.outline,
  );

  /// Version/footer text
  static TextStyle versionText = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    height: 1.4,
    color: AppColors.outlineVariant,
  );
}
