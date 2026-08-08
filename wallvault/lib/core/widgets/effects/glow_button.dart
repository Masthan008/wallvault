import 'package:flutter/material.dart';
import '../../theme/app_animations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Premium CTA with press-scale, glow pulse, and a light sheen sweep.
///
/// Upgraded from `GradientButton`: same API, adds a directional sheen that
/// sweeps across the gradient on press + a stronger glow while held.
class GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const GlowButton({
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
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with TickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: AppAnimations.micro,
  );
  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  @override
  void dispose() {
    _press.dispose();
    _sheen.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    _press.forward();
    _sheen.forward(from: 0);
  }

  void _onTapUp(TapUpDetails _) => _press.reverse();
  void _onTapCancel() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _press,
      builder: (context, _) {
        final scale = 1 - (1 - AppAnimations.buttonPressScale) * _press.value;
        final glow = BoxShadow.lerp(
          AppColors.buttonShadow.first,
          AppColors.glowPurple.first,
          _press.value,
        );

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _onTapDown : null,
            onTapUp: widget.onPressed != null ? _onTapUp : null,
            onTapCancel: widget.onPressed != null ? _onTapCancel : null,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: enabled ? widget.gradient : null,
                color: enabled ? null : AppColors.bgElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                boxShadow: enabled ? [glow ?? AppColors.buttonShadow.first] : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (enabled) _SheenSweep(controller: _sheen),
                    Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(widget.icon,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                ],
                                Text(widget.label, style: AppTypography.button),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Diagonal white highlight that sweeps left→right once per press.
class _SheenSweep extends StatelessWidget {
  final Animation<double> controller;

  const _SheenSweep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final v = controller.value;
        if (v <= 0.001 || v >= 0.999) return const SizedBox.shrink();
        final c = Curves.easeInOut.transform(v);
        final opacity =
            (1 - (c - 0.5).abs() * 2).clamp(0.0, 1.0).toDouble();

        return Align(
          alignment: Alignment(-1 + 2 * c, 0),
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 72,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Color(0x24FFFFFF),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}