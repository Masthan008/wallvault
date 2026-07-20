import 'package:flutter/material.dart';

/// WallVault color palette — CRED-inspired dark premium theme.
/// Reference: PRD Section 9.1
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────
  static const Color bgPrimary = Color(0xFF0A0A0F);
  static const Color bgSecondary = Color(0xFF12121A);
  static const Color bgCard = Color(0xFF1A1A24);
  static const Color bgElevated = Color(0xFF22222E);

  // ── Accents ──────────────────────────────────────────────
  static const Color accentPurple = Color(0xFFB829DD);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentSuccess = Color(0xFF00E676);
  static const Color accentError = Color(0xFFFF1744);
  static const Color accentWarning = Color(0xFFFF9100);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B8B9E);
  static const Color textMuted = Color(0xFF5A5A6E);

  // ── Gradients ────────────────────────────────────────────
  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPurple, accentCyan],
  );

  static const LinearGradient gradientPremium = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgCard, bgPrimary],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGold, accentWarning],
  );

  static const LinearGradient gradientSuccess = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accentSuccess, accentCyan],
  );

  // ── Shadows ──────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: accentPurple.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowPurple = [
    BoxShadow(
      color: accentPurple.withValues(alpha: 0.4),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> glowGold = [
    BoxShadow(
      color: accentGold.withValues(alpha: 0.4),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];
}
