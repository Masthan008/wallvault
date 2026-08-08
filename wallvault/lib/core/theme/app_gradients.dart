import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extended gradient tokens for the motion-first redesign.
class AppGradients {
  AppGradients._();

  // ── Ambient Backgrounds ──────────────────────────────────
  static const LinearGradient nightMesh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF170B2F), AppColors.bgPrimary, Color(0xFF06121C)],
  );

  static const LinearGradient cyanMesh = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF072A38), AppColors.bgPrimary, Color(0xFF10142A)],
  );

  // ── Hero / Text ──────────────────────────────────────────
  static const LinearGradient textGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentPurple, AppColors.accentCyan],
  );

  static const LinearGradient textGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentGold, Color(0xFFFF8A00)],
  );

  // ── Glass Surfaces ───────────────────────────────────────
  /// Top hairline highlight used on glass panels/cards.
  static const LinearGradient glassHairline = LinearGradient(
    colors: [Colors.transparent, Color(0x33FFFFFF), Colors.transparent],
  );

  // ── Shimmer Sweep ────────────────────────────────────────
  /// Reusable shimmer sweep used across all skeleton loaders.
  static const LinearGradient shimmerSweep = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.bgCard, AppColors.bgElevated, AppColors.bgCard],
    stops: [0.25, 0.5, 0.75],
  );

  // ── Card / Premium Accents ───────────────────────────────
  static const LinearGradient premiumBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x66C77DFF),
      Color(0x22FFFFFF),
      Color(0x6600D4FF),
    ],
  );

  /// Soft success-to-cyan sweep for positive states.
  static const LinearGradient successSweep = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.accentSuccess, AppColors.accentCyan],
  );
}