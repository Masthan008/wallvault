import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/router/routes.dart';

/// S02-S04 — Onboarding screen with parallax stacked cards, falling coins, and key-unlock transitions.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            // Visuals & Descriptions Carousel
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),

            // Pagination Indicator & CTA Row
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      activeDotColor: _currentPage == 2 ? AppColors.accentGold : AppColors.accentPurple,
                      dotColor: AppColors.bgElevated,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: _currentPage == 2 ? 'Get Started' : 'Next',
                    gradient: _currentPage == 2
                        ? AppColors.gradientGold
                        : AppColors.gradientHero,
                    icon: _currentPage == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_currentPage < 2) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go(AppRoutes.login);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide 1 (S02): Discover Stunning Walls
  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding * 1.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D Tilted floating wallpaper cards
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back card (left skewed)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY(-0.3)
                    ..rotateX(0.1)
                    ..translate(-50.0, 0.0, -20.0),
                  child: _buildMockCard('https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=150'),
                ),
                // Back card (right skewed)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY(0.3)
                    ..rotateX(0.1)
                    ..translate(50.0, 0.0, -20.0),
                  child: _buildMockCard('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150'),
                ),
                // Center main card
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(0.1),
                  child: _buildMockCard('https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=180', isGlow: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Discover Stunning Walls',
            style: AppTypography.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Explore thousands of 4K wallpapers curated just for you with premium dark theme designs.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Slide 2 (S03): Support Creators (Coins & Avatars)
  Widget _buildPage2() {
    return _OnboardingSlide2();
  }

  // Slide 3 (S04): Go Premium (Golden key & lock)
  Widget _buildPage3() {
    return _OnboardingSlide3();
  }

  Widget _buildMockCard(String imageUrl, {bool isGlow = false}) {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isGlow ? AppColors.accentPurple : AppColors.bgElevated, width: isGlow ? 2 : 1),
        boxShadow: isGlow ? AppColors.glowPurple : null,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Stateful slide with falling coins loop
class _OnboardingSlide2 extends StatefulWidget {
  @override
  State<_OnboardingSlide2> createState() => _OnboardingSlide2State();
}

class _OnboardingSlide2State extends State<_OnboardingSlide2> with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  final List<_Coin> _coins = [];

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _ticker.addListener(() {
      if (mounted) {
        setState(() {
          // Add new coin occasionally
          if (_coins.length < 15 && Random().nextDouble() < 0.08) {
            _coins.add(_Coin());
          }
          // Update coins
          for (var coin in _coins) {
            coin.y += coin.speed;
            coin.rotation += 0.05;
          }
          // Remove off-screen coins
          _coins.removeWhere((c) => c.y > 220);
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding * 1.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Coins and Avatars stack
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Avatars circles pop-in row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAvatarCircle('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100'),
                    _buildAvatarCircle('https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=100'),
                    _buildAvatarCircle('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100'),
                  ],
                ),
                // Falling gold coins
                ..._coins.map((coin) => Positioned(
                      left: coin.x,
                      top: coin.y,
                      child: Transform.rotate(
                        angle: coin.rotation,
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.accentGold,
                          size: 24,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Support Creators',
            style: AppTypography.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Buy wallpapers directly from independent artists and tip your favorites in one tap.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCircle(String url) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: AppColors.accentPurple,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(url),
      ),
    );
  }
}

class _Coin {
  double x = Random().nextDouble() * 280 + 20;
  double y = -20;
  double speed = Random().nextDouble() * 3 + 2;
  double rotation = Random().nextDouble() * pi;
}

// Stateful slide with padlock key unlock animation
class _OnboardingSlide3 extends StatefulWidget {
  @override
  State<_OnboardingSlide3> createState() => _OnboardingSlide3State();
}

class _OnboardingSlide3State extends State<_OnboardingSlide3> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _keyRotation;
  late Animation<double> _lockOffset;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _keyRotation = Tween<double>(begin: 0, end: pi / 2).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.1, 0.4, curve: Curves.easeIn)),
    );

    _lockOffset = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.5, 0.8, curve: Curves.elasticOut)),
    );

    _animController.forward().then((_) {
      setState(() => _isUnlocked = true);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding * 1.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Golden lock animation
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer golden ring glow
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold.withOpacity(0.15),
                            blurRadius: 32,
                            spreadRadius: 8,
                          )
                        ],
                      ),
                    ),
                    // Padlock body
                    Positioned(
                      top: 70 + _lockOffset.value,
                      child: Container(
                        width: 72,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGold.withOpacity(0.3),
                              blurRadius: 12,
                            )
                          ],
                        ),
                        child: Center(
                          // Keyhole
                          child: Container(
                            width: 10,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Padlock loop (arch)
                    Positioned(
                      top: 40,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.accentGold, width: 8),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                        ),
                      ),
                    ),
                    // Key
                    if (!_isUnlocked)
                      Positioned(
                        top: 80,
                        child: Transform.rotate(
                          angle: _keyRotation.value,
                          child: const Icon(
                            Icons.key_rounded,
                            color: Colors.black87,
                            size: 32,
                          ),
                        ),
                      ),
                    // Unlock success status overlay
                    if (_isUnlocked)
                      const Positioned(
                        top: 20,
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.accentSuccess,
                          size: 36,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          Text(
            'Go Premium',
            style: AppTypography.h1.copyWith(color: AppColors.accentGold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock exclusive 8K wallpapers, remove all ads, and support the design community.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
