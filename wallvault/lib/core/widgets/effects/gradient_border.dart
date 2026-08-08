import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Animated conic gradient border that slowly rotates around its child.
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  final double borderWidth;
  final List<Color> colors;
  final EdgeInsetsGeometry padding;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.radius = 20,
    this.borderWidth = 1.5,
    this.colors = const [
      AppColors.accentPurple,
      AppColors.accentCyan,
      AppColors.accentPurple,
    ],
    this.padding = const EdgeInsets.all(14),
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _GradientBorderPainter(
              progress: _controller.value,
              radius: widget.radius,
              borderWidth: widget.borderWidth,
              colors: widget.colors,
            ),
            child: const SizedBox.shrink(),
          ),
        ),
        Padding(
          padding: widget.padding,
          child: widget.child,
        ),
      ],
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double radius;
  final double borderWidth;
  final List<Color> colors;

  _GradientBorderPainter({
    required this.progress,
    required this.radius,
    required this.borderWidth,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(radius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
        transform: GradientRotation(progress * 2 * 3.141592653589793),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}