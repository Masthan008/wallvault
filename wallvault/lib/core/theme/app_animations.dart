import 'package:flutter/material.dart';

/// WallVault animation constants — CRED-inspired motion system.
/// Reference: PRD Section 9.4
class AppAnimations {
  AppAnimations._();

  // ── Easing Curves ────────────────────────────────────────
  static const Curve spring = Curves.elasticOut;
  static const Curve springIn = Cubic(0.34, 1.56, 0.64, 1);
  static const Curve smooth = Curves.easeInOut;
  static const Curve dramatic = Cubic(0.87, 0, 0.13, 1);
  static const Curve bounce = Cubic(0.68, -0.55, 0.265, 1.55);
  static const Curve decelerate = Curves.decelerate;

  // ── Signature Easing (matches the web `[0.16, 1, 0.3, 1]`) ──
  /// Fast start, slow long settle — used for entrances & hero motion.
  static const Curve easeOutExpo = Cubic(0.16, 1, 0.3, 1);
  static const Curve emphasizedDecelerate = Cubic(0.16, 1, 0.3, 1);
  /// Slow start, fast finish — used for exits & dismissals.
  static const Curve easeInExpo = Cubic(0.3, 0, 1, 1);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0, 1, 1);

  // ── Durations ────────────────────────────────────────────
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 700);
  static const Duration epic = Duration(milliseconds: 1200);

  // ── Stagger Delays ───────────────────────────────────────
  static const Duration staggerSmall = Duration(milliseconds: 50);
  static const Duration staggerMedium = Duration(milliseconds: 100);
  static const Duration staggerLarge = Duration(milliseconds: 150);

  /// Stagger delay for the n-th item in an entrance choreography.
  static Duration staggerDelay(int index, {int stepMs = 60}) =>
      Duration(milliseconds: stepMs * index);

  // ── Spring Physics ───────────────────────────────────────
  static const SpringDescription defaultSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );

  static const SpringDescription bouncySpring = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 15.0,
  );

  static const SpringDescription gentleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 25.0,
  );

  // ── Button Press Scale ───────────────────────────────────
  static const double buttonPressScale = 0.95;
  static const double cardHoverScale = 1.02;
  static const double cardTiltDegrees = 5.0;
}
