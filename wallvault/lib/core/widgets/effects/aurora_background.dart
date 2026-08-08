import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Ambient drifting aurora blobs that float behind screen content.
///
/// Paints 3 soft radial glows that slowly orbit the canvas. Cheap enough to
/// run under every auth + shell screen. Wrap children in the `child` slot so
/// content renders above the glow.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    this.child,
    this.intensity = 0.8,
    this.colors,
  });

  /// Blob opacity multiplier (0.0 → invisible, 1.0 → max).
  final double intensity;
  final List<Color>? colors;
  final Widget? child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 9))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        const [
          AppColors.accentPurple,
          AppColors.accentCyan,
          Color(0xFF22D3EE),
        ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _AuroraPainter(
              controller: _controller.value,
              colors: colors,
              intensity: widget.intensity,
            ),
            child: const SizedBox.expand(),
          ),
          if (child != null) child,
        ],
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double controller;
  final List<Color> colors;
  final double intensity;

  _AuroraPainter({
    required this.controller,
    required this.colors,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = controller * math.pi * 2;

    const blobRadius = 0.9;
    final bg = Paint();

    for (var i = 0; i < colors.length; i++) {
      final c = colors[i];
      final phase = (i / colors.length) * math.pi * 2;
      final cx = 0.5 + 0.28 * math.sin(t * 0.5 + phase);
      final cy = 0.5 + 0.24 * math.cos(t * 0.42 + phase * 1.3);

      final grad = RadialGradient(
        center: Alignment(cx * 2 - 1, cy * 2 - 1),
        radius: blobRadius,
        colors: [
          c.withValues(alpha: 0.20 * intensity),
          c.withValues(alpha: 0.05 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);

      bg.shader = grad;
      canvas.drawRect(Offset.zero & size, bg);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) =>
      oldDelegate.controller != controller ||
      oldDelegate.colors != colors ||
      oldDelegate.intensity != intensity;
}