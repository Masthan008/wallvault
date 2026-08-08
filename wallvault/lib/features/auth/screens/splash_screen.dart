import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/effects/animated_text_gradient.dart';
import '../../../core/widgets/effects/aurora_background.dart';
import '../../../core/widgets/effects/entrance.dart';
import '../../../providers/auth_provider.dart';

/// Splash screen with stroke-drawn logo, typewriter tagline and a
/// particle burst. Tap anywhere to skip the animation.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const _tagline = 'Premium wallpapers, curated for you';

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppAnimations.epic,
  );

  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: AppAnimations.medium,
  );

  late final AnimationController _cursor = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..repeat();

  bool _navigated = false;

  // stroke draw: 0 → 1 (first 35% of timeline)
  late final Animation<double> _draw = _interval(0, 0.35);

  // gradient fill: 0 → 1 (35% → 55%)
  late final Animation<double> _fill = _interval(0.35, 0.55);

  // typewriter: 0 → 1 (55% → 80%)
  late final Animation<double> _type = _interval(0.55, 0.80);

  // particle burst: 0 → 1 (80% → 100%)
  late final Animation<double> _burst = _interval(0.80, 1.0);

  Animation<double> _interval(double start, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: AppAnimations.easeOutExpo),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(_goNext);
  }

  @override
  void dispose() {
    _controller.dispose();
    _exit.dispose();
    _cursor.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    HapticFeedback.lightImpact();
    _exit.forward().whenComplete(_navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final user = ref.read(authStateProvider).value;
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    if (!mounted) return;
    if (user != null) {
      context.go(AppRoutes.home);
    } else if (seenOnboarding) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typed = (_tagline.length * _type.value).round();
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _controller.isAnimating ? _goNext : null,
        child: AuroraBackground(
          intensity: 0.55,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: FadeTransition(
                    opacity: _exit.drive(Tween(begin: 1.0, end: 0.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LogoMark(
                          drawProgress: _draw.value,
                          fillOpacity: _fill.value,
                          burstProgress: _burst.value,
                        ),
                        const SizedBox(height: 28),
                        AnimatedGradientText(
                          'WallVault',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 22,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _tagline.substring(0, typed),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _cursor,
                                builder: (context, _) => Text(
                                  '|',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.accentCyan,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 36,
                  child: Entrance.fadeUp(
                    Center(
                      child: Text(
                        'Tap anywhere to skip',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    delayMs: 900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stroke-drawn shield logo with gradient fill and particle burst.
class _LogoMark extends StatelessWidget {
  final double drawProgress;
  final double fillOpacity;
  final double burstProgress;

  const _LogoMark({
    required this.drawProgress,
    required this.fillOpacity,
    required this.burstProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 148,
      child: CustomPaint(
        painter: _LogoPainter(
          drawProgress: drawProgress,
          fillOpacity: fillOpacity,
          burstProgress: burstProgress,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double drawProgress;
  final double fillOpacity;
  final double burstProgress;

  _LogoPainter({
    required this.drawProgress,
    required this.fillOpacity,
    required this.burstProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final shield = _shieldPath(center, radius);

    // gradient fill, revealed after stroke
    if (fillOpacity > 0) {
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..shader = AppColors.gradientHero.createShader(
          Rect.fromCircle(center: center, radius: radius),
        );
      canvas.saveLayer(
        Rect.fromCircle(center: center, radius: radius),
        Paint()..color = Colors.white.withValues(alpha: fillOpacity),
      );
      canvas.drawPath(shield, fill);
      canvas.restore();
    }

    // stroke draw
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    if (drawProgress > 0) {
      final metrics = shield.computeMetrics();
      for (final m in metrics) {
        canvas.drawPath(
          m.extractPath(0, m.length * drawProgress),
          stroke,
        );
      }
    }

    // inner "V" stroke, drawn slightly after the shield
    final v = _letterVPath(center, radius);
    final vProgress =
        ((drawProgress - 0.35) / 0.30).clamp(0.0, 1.0).toDouble();
    if (vProgress > 0) {
      final vStroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = AppGradients.glassHairline.createShader(
          Rect.fromCircle(center: center, radius: radius),
        );
      final vMetrics = v.computeMetrics();
      for (final m in vMetrics) {
        canvas.drawPath(
          m.extractPath(0, m.length * vProgress),
          vStroke,
        );
      }
    }

    // particle burst
    if (burstProgress > 0) {
      _paintBurst(canvas, center, radius);
    }
  }

  Path _shieldPath(Offset center, double radius) {
    final w = radius * 2;
    return Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + w * 0.62, center.dy - radius * 0.45)
      ..lineTo(center.dx + w * 0.62, center.dy + radius * 0.10)
      ..quadraticBezierTo(
        center.dx + w * 0.62,
        center.dy + radius * 0.62,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - w * 0.62,
        center.dy + radius * 0.62,
        center.dx - w * 0.62,
        center.dy + radius * 0.10,
      )
      ..lineTo(center.dx - w * 0.62, center.dy - radius * 0.45)
      ..close();
  }

  Path _letterVPath(Offset center, double radius) {
    return Path()
      ..moveTo(center.dx - radius * 0.36, center.dy - radius * 0.32)
      ..lineTo(center.dx, center.dy + radius * 0.36)
      ..lineTo(center.dx + radius * 0.36, center.dy - radius * 0.32);
  }

  void _paintBurst(Canvas canvas, Offset center, double radius) {
    final rnd = math.Random(7);
    for (var i = 0; i < 26; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 90 + rnd.nextDouble() * 260;
      final progress = Curves.easeOutCubic.transform(burstProgress);
      final distance = speed * progress;
      final px = center.dx + math.cos(angle) * distance;
      final py = center.dy + math.sin(angle) * distance;
      final alpha = (1 - progress).clamp(0.0, 1.0);
      final color = i.isEven ? AppColors.accentPurple : AppColors.accentCyan;
      canvas.drawCircle(
        Offset(px, py),
        1.6 + rnd.nextDouble() * 1.8,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
    // soft ring shockwave
    final ringProgress = Curves.easeOutCubic.transform(burstProgress);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.accentCyan.withValues(
        alpha: (1 - ringProgress) * 0.7,
      );
    canvas.drawCircle(center, radius + ringProgress * 90, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.drawProgress != drawProgress ||
      oldDelegate.fillOpacity != fillOpacity ||
      oldDelegate.burstProgress != burstProgress;
}