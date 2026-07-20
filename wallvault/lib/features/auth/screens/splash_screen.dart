import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/routes.dart';

/// S01 — Splash screen with custom animated W-stroke, typing tagline, and particle bursts.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _fillController;
  late AnimationController _textController;
  late AnimationController _cursorController;
  
  final List<Particle> _particles = [];
  bool _burstTriggered = false;

  final String _tagline = "Your Walls, Your Story";
  String _typedText = "";

  @override
  void initState() {
    super.initState();
    
    // 1. Draw W stroke over 1.2s
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 2. Fill logo gradient over 600ms
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 3. Typing animation over 1s
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 4. Blinking cursor loop
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _drawController.addListener(() {
      setState(() {});
    });

    _fillController.addListener(() {
      setState(() {});
    });

    _drawController.forward().then((_) {
      _fillController.forward();
      // Start typing tagline
      _textController.forward();
    });

    _textController.addListener(() {
      final index = (_textController.value * _tagline.length).round();
      if (index <= _tagline.length) {
        setState(() {
          _typedText = _tagline.substring(0, index);
        });
      }
    });

    // Handle particle burst at 1.8 seconds and navigation at 2.5 seconds
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _triggerParticleBurst();
      }
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    });
  }


  void _triggerParticleBurst() {
    final rand = Random();
    setState(() {
      _burstTriggered = true;
      for (int i = 0; i < 40; i++) {
        _particles.add(
          Particle(
            angle: rand.nextDouble() * 2 * pi,
            speed: rand.nextDouble() * 4 + 2,
            size: rand.nextDouble() * 4 + 2,
            color: rand.nextBool() ? AppColors.accentPurple : AppColors.accentCyan,
          ),
        );
      }
    });

    // Particle update animation loop
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) return false;
      setState(() {
        for (var p in _particles) {
          p.update();
        }
      });
      return _burstTriggered;
    });
  }

  @override
  void dispose() {
    _drawController.dispose();
    _fillController.dispose();
    _textController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Logo & Text Centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo paint slot
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 100),
                      painter: LogoPainter(
                        drawProgress: _drawController.value,
                        fillOpacity: _fillController.value,
                      ),
                    ),
                    // Optional burst particles
                    if (_particles.isNotEmpty)
                      ..._particles.map((p) => Positioned(
                            left: 60 + p.x,
                            top: 50 + p.y,
                            child: Container(
                              width: p.size,
                              height: p.size,
                              decoration: BoxDecoration(
                                color: p.color.withOpacity(p.alpha),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: p.color,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
                const SizedBox(height: 36),
                
                // Title
                Text(
                  'WallVault',
                  style: AppTypography.h1.copyWith(
                    fontSize: 38,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Typing Tagline with Cursor
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _typedText,
                      style: AppTypography.caption.copyWith(
                        letterSpacing: 2,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _cursorController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _cursorController.value > 0.5 ? 1.0 : 0.0,
                          child: Container(
                            width: 2,
                            height: 14,
                            color: AppColors.accentCyan,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  
  double x = 0;
  double y = 0;
  double alpha = 1.0;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  void update() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;
    alpha = (alpha - 0.02).clamp(0.0, 1.0);
  }
}

class LogoPainter extends CustomPainter {
  final double drawProgress;
  final double fillOpacity;
  LogoPainter({required this.drawProgress, required this.fillOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..lineTo(size.width * 0.35, size.height * 0.85)
      ..lineTo(size.width * 0.5, size.height * 0.45)
      ..lineTo(size.width * 0.65, size.height * 0.85)
      ..lineTo(size.width * 0.9, size.height * 0.2);

    // Animate stroke draw progress using path metrics
    for (final metric in path.computeMetrics()) {
      final extractPath = metric.extractPath(0.0, metric.length * drawProgress);
      canvas.drawPath(extractPath, paint);
    }

    // Paint full-gradient fill once stroke completes
    if (fillOpacity > 0.0) {
      final rect = Offset.zero & size;
      final fillPaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.accentPurple, AppColors.accentCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect)
        ..style = PaintingStyle.fill;
      
      canvas.saveLayer(rect, Paint()..color = Colors.white.withOpacity(fillOpacity * 0.3));
      canvas.drawPath(path, fillPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) {
    return oldDelegate.drawProgress != drawProgress || oldDelegate.fillOpacity != fillOpacity;
  }
}
