import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Controller-driven confetti burst for success moments.
///
/// Renders `count` particles that explode upward from the widget's center and
/// fall with gravity, self-dismissing when complete. One-shot by default.
class ConfettiBurst extends StatefulWidget {
  final bool active;
  final int count;
  final Duration duration;
  final List<Color> colors;
  final VoidCallback? onCompleted;

  const ConfettiBurst({
    super.key,
    this.active = true,
    this.count = 28,
    this.duration = const Duration(milliseconds: 1500),
    this.colors = const [
      AppColors.accentPurple,
      AppColors.accentCyan,
      AppColors.accentGold,
      AppColors.accentSuccess,
      Color(0xFFFF6B9D),
    ],
    this.onCompleted,
  });

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  List<_ConfettiParticle>? _particles;

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _burst());
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _burst();
  }

  void _burst() {
    final rng = math.Random();
    _particles = List.generate(
      widget.count,
      (_) => _ConfettiParticle.random(rng),
    );
    _controller.forward(from: 0).whenComplete(() => widget.onCompleted?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _ConfettiPainter(
              t: _controller.value,
              particles: _particles ?? const [],
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final Offset origin;
  final Offset velocity;
  final double gravity;
  final double rotation0;
  final double spin;
  final Color color;
  final double size;

  _ConfettiParticle({
    required this.origin,
    required this.velocity,
    required this.gravity,
    required this.rotation0,
    required this.spin,
    required this.color,
    required this.size,
  });

  factory _ConfettiParticle.random(math.Random rng) {
    final angle = rng.nextDouble() * math.pi;
    final speed = 200 + rng.nextDouble() * 260;
    return _ConfettiParticle(
      origin: Offset.zero,
      velocity: Offset(math.cos(angle) * speed, -math.sin(angle) * speed * 0.9),
      gravity: 420 + rng.nextDouble() * 160,
      rotation0: rng.nextDouble() * math.pi * 2,
      spin: (rng.nextDouble() - 0.5) * 12,
      color: _palette[rng.nextInt(_palette.length)],
      size: 4 + rng.nextDouble() * 5,
    );
  }

  static const _palette = [
    AppColors.accentPurple,
    AppColors.accentCyan,
    AppColors.accentGold,
    AppColors.accentSuccess,
    Color(0xFFFF6B9D),
    Colors.white,
  ];
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.t, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty || t >= 1) return;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final pos = center +
          p.origin +
          p.velocity * t +
          Offset(0, 0.5 * p.gravity * t * t);
      final rotation = p.rotation0 + p.spin * t;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rotation);
paint.color = p.color;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.62,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.particles != particles;
}