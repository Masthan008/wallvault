import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/routes.dart';

/// S01 — Splash screen with animated WallVault logo.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      // TODO: Check auth state and navigate accordingly
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.gradientHero,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppColors.glowPurple,
              ),
              child: const Icon(
                Icons.wallpaper_rounded,
                color: Colors.white,
                size: 48,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            // App name
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.gradientHero.createShader(bounds),
              child: Text(
                'WallVault',
                style: AppTypography.h1.copyWith(
                  fontSize: 36,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Premium Wallpapers',
              style: AppTypography.caption.copyWith(
                letterSpacing: 4,
                fontSize: 11,
              ),
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
