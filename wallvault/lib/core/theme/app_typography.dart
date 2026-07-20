import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// WallVault typography system.
/// Reference: PRD Section 9.2
class AppTypography {
  AppTypography._();

  static String? _fontFamily;

  static String get fontFamily {
    _fontFamily ??= GoogleFonts.inter().fontFamily;
    return _fontFamily!;
  }

  // ── Headings ─────────────────────────────────────────────
  static TextStyle get h1 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: Colors.white,
      );

  static TextStyle get h2 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.25,
        color: Colors.white,
      );

  static TextStyle get h3 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: Colors.white,
      );

  static TextStyle get h4 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.35,
        color: Colors.white,
      );

  // ── Body ─────────────────────────────────────────────────
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: Colors.white,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: Colors.white,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: Colors.white,
      );

  // ── Special ──────────────────────────────────────────────
  static TextStyle get priceTag => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFFFD700),
      );

  static TextStyle get creatorName => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF00D4FF),
      );

  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF8B8B9E),
      );

  static TextStyle get button => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.white,
      );
}
