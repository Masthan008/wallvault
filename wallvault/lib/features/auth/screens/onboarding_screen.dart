import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';

/// S02-S04 — Next-Gen Onboarding Screen matching attached specifications & animated prompts.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Slide 1: Floating Text & Parallax Tilt Animation Controllers
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _parallaxController;
  late Animation<double> _parallaxAnimation;

  // Slide 2: Raining Golden Coins Animation Controller
  late AnimationController _coinsController;
  late List<_FallingCoin> _coins;

  // Slide 2: Staggered Avatar Animation Controller
  late AnimationController _avatarController;

  // Slide 3: Lock Unlock, Key Turning & Confetti Animation Controller
  late AnimationController _lockController;
  late Animation<double> _keyRotationAnimation;
  late Animation<double> _lockScaleAnimation;
  bool _isLockOpen = false;
  late List<_ConfettiParticle> _confettiParticles;

  @override
  void initState() {
    super.initState();

    // Slide 1: Floating text & Parallax tilt
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _parallaxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _parallaxAnimation = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _parallaxController, curve: Curves.easeInOut),
    );

    // Slide 2: Raining coins
    _coinsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateCoins);
    _coinsController.repeat();

    _initCoins();

    // Slide 2: Avatar staggered pop-in
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Slide 3: Lock unlock & key turning
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _keyRotationAnimation = Tween<double>(begin: 0.0, end: pi * 1.5).animate(
      CurvedAnimation(
        parent: _lockController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _lockScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 60),
    ]).animate(
      CurvedAnimation(
        parent: _lockController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _initConfetti();

    _lockController.addListener(() {
      if (_lockController.value >= 0.4 && !_isLockOpen) {
        setState(() => _isLockOpen = true);
      }
    });

    _avatarController.forward();
  }

  void _initCoins() {
    final rand = Random();
    _coins = List.generate(24, (i) {
      return _FallingCoin(
        x: rand.nextDouble() * 340,
        y: rand.nextDouble() * -400,
        speed: 2.5 + rand.nextDouble() * 3.5,
        size: 14 + rand.nextDouble() * 14,
        rotation: rand.nextDouble() * pi * 2,
        rotationSpeed: 0.02 + rand.nextDouble() * 0.05,
      );
    });
  }

  void _updateCoins() {
    if (_currentPage == 1 && mounted) {
      setState(() {
        for (var coin in _coins) {
          coin.y += coin.speed;
          coin.rotation += coin.rotationSpeed;
          if (coin.y > 450) {
            coin.y = -30 - Random().nextDouble() * 100;
            coin.x = Random().nextDouble() * 340;
          }
        }
      });
    }
  }

  void _initConfetti() {
    final rand = Random();
    _confettiParticles = List.generate(40, (i) {
      final angle = rand.nextDouble() * pi * 2;
      final speed = 3.0 + rand.nextDouble() * 6.0;
      return _ConfettiParticle(
        x: 0,
        y: 0,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 2.0,
        size: 6 + rand.nextDouble() * 6,
        color: [
          const Color(0xFFFFD700),
          const Color(0xFFFF4081),
          const Color(0xFF00E676),
          const Color(0xFF00B0FF),
          const Color(0xFFAA00FF),
        ][rand.nextInt(5)],
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _parallaxController.dispose();
    _coinsController.dispose();
    _avatarController.dispose();
    _lockController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _onPageChanged(int idx) {
    setState(() => _currentPage = idx);
    if (idx == 1) {
      _avatarController.reset();
      _avatarController.forward();
    } else if (idx == 2) {
      _lockController.reset();
      setState(() => _isLockOpen = false);
      _lockController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header Navigation Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top progress bar line
                  Container(
                    width: 100,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 100 * ((_currentPage + 1) / 3),
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _currentPage == 2
                                ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                                : [const Color(0xFF9D4EDD), const Color(0xFFC77DFF)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Skip Glass Pill Button
                  GestureDetector(
                    onTap: _completeOnboarding,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Carousel Content ──────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),

            // ── Bottom Pagination Dots & Swipe Button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 8),
              child: Column(
                children: [
                  // 3 Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = _currentPage == index;
                      final activeColor = _currentPage == 2 ? const Color(0xFFFFD700) : const Color(0xFF9D4EDD);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 12 : 7,
                        height: isActive ? 12 : 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? activeColor : Colors.white24,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: activeColor.withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ]
                              : [],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Swipe to explore interactive capsule slider / CTA Button
                  GestureDetector(
                    onTap: _nextPage,
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                        _nextPage();
                      }
                    },
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10091D).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: _currentPage == 2
                              ? const Color(0xFFFFD700).withOpacity(0.5)
                              : const Color(0xFF3B1D5C).withOpacity(0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _currentPage == 2
                                ? const Color(0xFFFFD700).withOpacity(0.2)
                                : const Color(0xFF9D4EDD).withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Glowing Action Circle Button with Arrow
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _currentPage == 2
                                    ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                                    : [const Color(0xFF7B2CBF), const Color(0xFF9D4EDD)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _currentPage == 2
                                      ? const Color(0xFFFFD700).withOpacity(0.6)
                                      : const Color(0xFF9D4EDD).withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Icon(
                              _currentPage == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                              color: _currentPage == 2 ? Colors.black : Colors.white,
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _currentPage == 2 ? 'Get Started' : 'Swipe to explore',
                            style: TextStyle(
                              color: _currentPage == 2 ? const Color(0xFFFFD700) : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: _currentPage == 2 ? const Color(0xFFFFD700) : const Color(0xFF9D4EDD),
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SLIDE 1 (S02): Discover Stunning Walls with Parallax 3D Tilt ───────────────
  Widget _buildPage1() {
    return Column(
      children: [
        const SizedBox(height: 12),

        // Floating Header Text
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: 'Discover\nStunning '),
                      WidgetSpan(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFD8B4FE), Color(0xFFC77DFF), Color(0xFF9D4EDD)],
                          ).createShader(bounds),
                          child: const Text(
                            'Walls',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Explore thousands of 4K wallpapers\ncurated just for you',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // 3D Floating Parallax Tilt Phone Cards
        AnimatedBuilder(
          animation: _parallaxAnimation,
          builder: (context, child) {
            final pVal = _parallaxAnimation.value;
            return SizedBox(
              height: 380,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // LEFT PERSPECTIVE CARD (Tilted Left + Parallax Motion)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(-0.30 + pVal * 0.5)
                      ..rotateZ(-0.05 + pVal * 0.2)
                      ..translate(-115.0 + (pVal * 15), 30.0 + (pVal * 10), -10.0),
                    child: _buildPhoneCard(
                      'assets/images/prebuilt_03.png',
                      width: 145,
                      height: 270,
                    ),
                  ),

                  // RIGHT PERSPECTIVE CARD (Tilted Right + Parallax Motion)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(0.30 - pVal * 0.5)
                      ..rotateZ(0.05 - pVal * 0.2)
                      ..translate(115.0 - (pVal * 15), 40.0 - (pVal * 10), -10.0),
                    child: _buildPhoneCard(
                      'assets/images/prebuilt_20.png',
                      width: 145,
                      height: 270,
                    ),
                  ),

                  // CENTER HERO CARD (PREBUILT_34.PNG)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX(0.04 + pVal * 0.3)
                      ..translate(0.0, -15.0 + (pVal * 8), 30.0),
                    child: _buildPhoneCard(
                      'assets/images/prebuilt_34.png',
                      width: 185,
                      height: 340,
                      isHero: true,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const Spacer(),
      ],
    );
  }

  // ── SLIDE 2 (S03): Support Creators with Raining Golden Coins & Staggered Avatars ──
  Widget _buildPage2() {
    final creatorsList = [
      ('Satoshi', 'assets/images/prebuilt_03.png', '🎨 Satoshi'),
      ('OtakuArt', 'assets/images/prebuilt_34.png', '⚡ OtakuArt'),
      ('Matrix', 'assets/images/prebuilt_20.png', '🌀 Matrix'),
      ('Luna', 'assets/images/prebuilt_03.png', '✨ Luna'),
      ('Speedy', 'assets/images/prebuilt_34.png', '🏎️ Speedy'),
    ];

    return Stack(
      children: [
        // Raining Golden Coins Canvas Background
        Positioned.fill(
          child: CustomPaint(
            painter: _CoinRainPainter(coins: _coins),
          ),
        ),

        Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Support '),
                        WidgetSpan(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ).createShader(bounds),
                            child: const Text(
                              'Creators',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Buy wallpapers directly from independent artists and tip your favorites',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6), height: 1.4),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Staggered Creator Avatar Circles Pop-In
            AnimatedBuilder(
              animation: _avatarController,
              builder: (context, child) {
                return SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(creatorsList.length, (idx) {
                      final delay = idx * 0.15;
                      final progress = ((_avatarController.value - delay) / 0.4).clamp(0.0, 1.0);
                      final scale = Curves.elasticOut.transform(progress);
                      final opacity = progress.clamp(0.0, 1.0);

                      final offsets = [
                        const Offset(-110, -60),
                        const Offset(110, -50),
                        const Offset(0, 0),
                        const Offset(-90, 80),
                        const Offset(95, 75),
                      ];

                      final item = creatorsList[idx];

                      return Transform.translate(
                        offset: offsets[idx],
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161122),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: idx == 2 ? const Color(0xFFFFD700) : const Color(0xFF9D4EDD),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (idx == 2 ? const Color(0xFFFFD700) : const Color(0xFF9D4EDD)).withOpacity(0.4),
                                    blurRadius: 16,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: idx == 2 ? 24 : 18,
                                    backgroundImage: AssetImage(item.$2),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.$3,
                                    style: TextStyle(
                                      fontSize: idx == 2 ? 14 : 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),

            const Spacer(),
          ],
        ),
      ],
    );
  }

  // ── SLIDE 3 (S04): Go Premium with Lock Unlock, Key Turn & Confetti Burst ────
  Widget _buildPage3() {
    return Stack(
      children: [
        // Confetti particles overlay
        if (_isLockOpen)
          Positioned.fill(
            child: _ConfettiPainterWidget(particles: _confettiParticles),
          ),

        Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Go '),
                        WidgetSpan(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ).createShader(bounds),
                            child: const Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Unlock exclusive wallpapers, remove ads, and support the community',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6), height: 1.4),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Golden Padlock with Key Turning Animation
            AnimatedBuilder(
              animation: _lockController,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: _lockScaleAnimation.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: _keyRotationAnimation.value,
                            child: Icon(
                              _isLockOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                              size: 70,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isLockOpen ? 1.0 : 0.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD700)),
                        ),
                        child: const Text(
                          '⭐ VIP Premium Unlocked ⭐',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const Spacer(),
          ],
        ),
      ],
    );
  }

  // Helper widget to construct phone frame card matching Attached UI
  Widget _buildPhoneCard(String imagePath, {required double width, required double height, bool isHero = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF14101E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHero ? const Color(0xFFC77DFF) : Colors.white.withOpacity(0.18),
          width: isHero ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isHero ? const Color(0xFF9D4EDD).withOpacity(0.55) : Colors.black.withOpacity(0.5),
            blurRadius: isHero ? 32 : 16,
            spreadRadius: isHero ? 2 : 0,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Wallpaper Image
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),

            // Top-Left 4K Glass Pill Badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Text(
                  '4K',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Inner Phone Reflection Highlight
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Coin Rain Particle System ───────────────────────────────────────────
class _FallingCoin {
  double x;
  double y;
  double speed;
  double size;
  double rotation;
  double rotationSpeed;

  _FallingCoin({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _CoinRainPainter extends CustomPainter {
  final List<_FallingCoin> coins;
  _CoinRainPainter({required this.coins});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFD700);

    for (var coin in coins) {
      canvas.save();
      canvas.translate(coin.x, coin.y);
      canvas.rotate(coin.rotation);

      // Gold Coin Circle
      canvas.drawCircle(Offset.zero, coin.size / 2, paint);

      // Coin Rim highlight
      final rimPaint = Paint()
        ..color = const Color(0xFFFFA500)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset.zero, coin.size / 2 - 1, rimPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Custom Confetti Burst System ──────────────────────────────────────────────
class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  });
}

class _ConfettiPainterWidget extends StatefulWidget {
  final List<_ConfettiParticle> particles;
  const _ConfettiPainterWidget({required this.particles});

  @override
  State<_ConfettiPainterWidget> createState() => _ConfettiPainterWidgetState();
}

class _ConfettiPainterWidgetState extends State<_ConfettiPainterWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          for (var p in widget.particles) {
            p.x += p.vx;
            p.y += p.vy;
            p.vy += 0.15; // Gravity
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConfettiPainter(particles: widget.particles),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var p in particles) {
      final paint = Paint()..color = p.color;
      canvas.drawCircle(Offset(center.dx + p.x, center.dy + p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
