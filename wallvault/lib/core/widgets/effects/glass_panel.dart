import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_spacing.dart';

/// Reusable glass surface with optional top hairline highlight.
///
/// Single source for the glossy "CRED-style" panels used across the app:
/// tinted fill + hairline border + optional top gradient hairline + shadow.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color tintColor;
  final Color borderColor;
  final bool hairline;
  final List<BoxShadow>? shadows;
  final EdgeInsetsGeometry margin;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.radius = AppSpacing.radiusCard,
    this.tintColor = const Color(0xDD1A1A24),
    this.borderColor = const Color(0x14171224),
    this.hairline = true,
    this.shadows,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: tintColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: shadows ?? AppColors.cardShadow,
      ),
      child: Stack(
        children: [
          if (hairline)
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              height: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.glassHairline,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}