import 'package:flutter/material.dart';
import '../../theme/app_animations.dart';
import '../../theme/app_gradients.dart';

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.offset);

  final Offset offset;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(offset.dx, offset.dy, 0);
}

/// Hero title with a slowly shimmering gradient sweep.
class AnimatedGradientText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final LinearGradient gradient;
  final TextAlign textAlign;

  const AnimatedGradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = AppGradients.textGlow,
    this.textAlign = TextAlign.left,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppAnimations.epic)
        ..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shift = _controller.value * 0.35;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: widget.gradient.begin,
            end: widget.gradient.end,
            colors: widget.gradient.colors,
            stops: widget.gradient.stops,
            tileMode: widget.gradient.tileMode,
            transform: _SlidingGradientTransform(
              Offset(shift * bounds.width, 0),
            ),
          ).createShader(bounds),
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
          ),
        );
      },
    );
  }
}