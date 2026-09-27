import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ---------------------------------------------------------------------------
  // Typography Scale from Farmers App Design Specification
  // Heading font: Poppins, Body font: Inter
  // ---------------------------------------------------------------------------

  // displayLogo: 24px, Bold (700), primaryDark
  static TextStyle get displayLogo => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        letterSpacing: -0.5,
      );

  // screenTitle: 22px, Bold (700), primaryDark / textPrimary
  static TextStyle get screenTitle => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
      );

  // sectionHeading: 16px, SemiBold (600), textPrimary
  static TextStyle get sectionHeading => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // cardTitle: 14–15px, Medium (500), textPrimary
  static TextStyle get cardTitle => GoogleFonts.poppins(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  // priceText: 15px, Bold (700), textPrimary
  static TextStyle get priceText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // totalPriceText: 18px, Bold (700), success
  static TextStyle get totalPriceText => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.success,
      );

  // bodyText: 13–14px, Regular (400), textSecondary
  static TextStyle get bodyText => GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.35,
      );

  // caption: 12px, Medium (500), textSecondary
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // linkText: 13–14px, Medium (500), primaryDark
  static TextStyle get linkText => GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryDark,
      );

  // buttonText: 14–15px, SemiBold (600), white
  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  // chipLabel: 12px, Medium (500), textPrimary
  static TextStyle get chipLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  // navLabel: 11px, Medium (500)
  static TextStyle get navLabelActive => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get navLabelInactive => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // ---------------------------------------------------------------------------
  // Backwards compatibility aliases for existing codebase
  // ---------------------------------------------------------------------------
  static TextStyle get headlineLg => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMd => screenTitle;
  static TextStyle get headlineSm => sectionHeading;
  static TextStyle get titleLg => sectionHeading;
  static TextStyle get titleMd => cardTitle;
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );
  static TextStyle get bodyMd => bodyText;
  static TextStyle get bodySm => caption;
  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
  static TextStyle get priceLg => totalPriceText;
  static TextStyle get priceMd => priceText;
}
