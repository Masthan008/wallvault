import 'package:flutter/material.dart';
import '../../theme/app_animations.dart';
import '../../theme/app_colors.dart';

/// Animated linear progress bar with gradient fill + optional shimmer sweep.
class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final double height;
  final Color color;
  final bool shimmer;

  const AnimatedProgressBar({
    super.key,
    this.value = 0,
    this.height = 6,
    this.color = AppColors.accentPurple,
    this.shimmer = true,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clamped = widget.value.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: clamped),
      duration: AppAnimations.slow,
      curve: AppAnimations.easeOutExpo,
      builder: (context, t, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.height),
          child: Container(
            height: widget.height,
            color: AppColors.bgElevated,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: t,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.height),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color,
                            Color.lerp(
                                widget.color, AppColors.accentCyan, 0.6)!,
                          ],
                        ),
                      ),
                    ),
                    if (widget.shimmer)
                      AnimatedBuilder(
                        animation: _sweep,
                        builder: (context, _) {
                          final x =
                              (_sweep.value * 2 - 1) * 2; // -2 → 2
                          return Align(
                            alignment: Alignment(x.clamp(-1, 1).toDouble(), 0),
                            child: Container(
                              width: 40,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0x30FFFFFF),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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