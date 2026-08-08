import 'package:flutter/material.dart';
import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Stylized social sign-in button (Google / Apple) with press
/// micro-interaction and loading state.
class SocialButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.iconColor,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: AppAnimations.micro,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: enabled ? (_) => _press.forward() : null,
      onTapUp: enabled ? (_) => _press.reverse() : null,
      onTapCancel: enabled ? () => _press.reverse() : null,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, _) {
          final scale = 1 - 0.04 * _press.value;
          return Transform.scale(
            scale: scale,
            child: Container(
              height: AppSpacing.buttonHeight,
              decoration: BoxDecoration(
                color: AppColors.bgElevated.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                border: Border.all(
                  color: _press.value > 0
                      ? AppColors.accentPurple.withValues(alpha: 0.5)
                      : const Color(0x1FFFFFFF),
                ),
                boxShadow: AppColors.buttonShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: widget.iconColor ?? Colors.white,
                      ),
                    )
                  else
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.iconColor ?? Colors.white,
                    ),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}