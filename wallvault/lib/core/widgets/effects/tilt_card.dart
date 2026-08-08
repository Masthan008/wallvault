import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_animations.dart';
import '../../theme/app_colors.dart';

/// Pointer-driven 3D tilt card that rotates toward the touch point and
/// springs back on release. Pairs with a soft purple glow while tilted.
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTiltDeg;
  final double perspective;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTiltDeg = 6,
    this.perspective = 0.002,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: AppAnimations.fast,
  );

  double _tiltX = 0;
  double _tiltY = 0;
  bool _pressed = false;

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(details.globalPosition);
    final dx = ((local.dx / box.size.width) - 0.5) * 2;
    final dy = ((local.dy / box.size.height) - 0.5) * 2;

    setState(() {
      _tiltY = (dx * widget.maxTiltDeg).clamp(-widget.maxTiltDeg, widget.maxTiltDeg);
      _tiltX = (-dy * widget.maxTiltDeg).clamp(-widget.maxTiltDeg, widget.maxTiltDeg);
      _pressed = true;
      _settle.stop();
    });
  }

  void _release() {
    setState(() => _pressed = false);
    _settle.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settle,
      builder: (context, _) {
        final factor = _pressed ? 1.0 : 1 - _settle.value;

        final transform = Matrix4.identity()
          ..setEntry(3, 2, widget.perspective)
          ..rotateX(_tiltX * factor * math.pi / 180)
          ..rotateY(_tiltY * factor * math.pi / 180);

        return GestureDetector(
          onPanDown: (_) => _settle.stop(),
          onPanUpdate: _onPanUpdate,
          onPanEnd: (_) => _release(),
          onPanCancel: _release,
          child: Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Stack(
              children: [
                widget.child,
                if (_pressed)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.18),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}