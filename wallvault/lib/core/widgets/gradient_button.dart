import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'effects/glow_button.dart';

/// Gradient button with purple glow — CRED-style premium CTA.
///
/// Thin wrapper over [GlowButton] so existing call sites automatically gain
/// the press-scale, sheen sweep, and glow pulse micro-interactions.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient = AppColors.gradientHero,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GlowButton(
      label: label,
      onPressed: onPressed,
      gradient: gradient,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }
}