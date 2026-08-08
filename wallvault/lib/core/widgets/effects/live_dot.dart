import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Pulsing presence/status dot with expanding halo ring.
class LiveDot extends StatefulWidget {
  final Color color;
  final double size;

  const LiveDot({
    super.key,
    this.color = AppColors.accentSuccess,
    this.size = 8,
  });

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

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
        final t = _controller.value;
        final ringSize = widget.size * (0.8 + 0.8 * t);
        final ringOpacity = (1 - t) * 0.8;

        return SizedBox(
          width: widget.size * 2.2,
          height: widget.size * 2.2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: ringOpacity),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: widget.size * 0.65,
                height: widget.size * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.5),
                      blurRadius: widget.size,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}