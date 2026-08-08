import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_animations.dart';

/// Single-source entrance helpers built on `flutter_animate`.
///
/// Screens should use these (or `StaggerChildren`) instead of hand-rolled
/// `FadeTransition`/`SlideTransition`/`ScaleTransition` so the motion language
/// stays consistent.
class Entrance {
  Entrance._();

  /// Fade + subtle upward slide + photo (!) ease.
  static Widget fadeUp(
    Widget child, {
    int delayMs = 0,
    Duration? duration,
  }) {
    return child.animate(
      delay: Duration(milliseconds: delayMs),
    ).fade(
      duration: duration ?? AppAnimations.medium,
      curve: AppAnimations.easeOutExpo,
    ).slideY(
      begin: 0.08,
      duration: duration ?? AppAnimations.medium,
      curve: AppAnimations.easeOutExpo,
    );
  }

  /// Pure fade-in.
  static Widget fadeIn(
    Widget child, {
    int delayMs = 0,
    Duration? duration,
  }) {
    return child.animate(
      delay: Duration(milliseconds: delayMs),
    ).fade(
      duration: duration ?? AppAnimations.medium,
      curve: AppAnimations.easeOutExpo,
    );
  }

  /// Springy pop-in (scale from 0.85).
  static Widget pop(
    Widget child, {
    int delayMs = 0,
    Duration? duration,
  }) {
    return child.animate(
      delay: Duration(milliseconds: delayMs),
    ).scale(
      begin: const Offset(0.85, 0.85),
      duration: duration ?? AppAnimations.medium,
      curve: Curves.easeOutBack,
    ).fadeIn(
      duration: duration ?? AppAnimations.micro,
    );
  }

  /// Slide in from the given direction.
  static Widget slide(
    Widget child, {
    required Offset begin,
    int delayMs = 0,
    Duration? duration,
  }) {
    return child.animate(
      delay: Duration(milliseconds: delayMs),
    ).fade(
      duration: duration ?? AppAnimations.fast,
      curve: AppAnimations.easeOutExpo,
    ).slide(
      begin: begin,
      duration: duration ?? AppAnimations.medium,
      curve: AppAnimations.easeOutExpo,
    );
  }
}