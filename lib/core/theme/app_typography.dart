import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Mobile / Tablet Font Styles
  static TextStyle get displayLarge => GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.fredoka(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      );

  static TextStyle get headlineLarge => GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  static TextStyle get headlineMedium => GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  static TextStyle get titleLarge => GoogleFonts.fredoka(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  static TextStyle get titleMedium => GoogleFonts.fredoka(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      );

  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.fredoka(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  // TV 10-ft Viewing Distance Typography (larger, high contrast)
  static TextStyle get tvDisplay => GoogleFonts.fredoka(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.tvText,
        letterSpacing: -0.5,
      );

  static TextStyle get tvHeadline => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.tvText,
      );

  static TextStyle get tvTitle => GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.tvText,
      );

  static TextStyle get tvBody => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.tvTextSecondary,
      );

  static TextStyle get tvBadge => GoogleFonts.fredoka(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.tvText,
      );
}
