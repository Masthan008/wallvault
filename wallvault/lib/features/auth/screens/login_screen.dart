import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/glow_input.dart';
import '../../../core/router/routes.dart';
import '../../../providers/auth_provider.dart';

/// S02 — 3D Glassmorphic Login Screen with Lottie Animations & Perspective Tilt
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign-in failed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (e.code != 'CANCELED') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Google sign-in failed.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: $e')),
        );
      }
    }
  }

  void _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
      if (mounted) context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (e.code != 'CANCELED') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Apple sign-in failed.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple sign-in failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _tiltY += details.delta.dx * 0.001;
            _tiltX -= details.delta.dy * 0.001;
            _tiltX = _tiltX.clamp(-0.1, 0.1);
            _tiltY = _tiltY.clamp(-0.1, 0.1);
          });
        },
        onPanEnd: (_) {
          setState(() {
            _tiltX = 0.0;
            _tiltY = 0.0;
          });
        },
        child: Stack(
          children: [
            // Ambient Dark Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF140D26), Color(0xFF0A0A0F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Lottie Sparkles & Crown Animation Background
            Positioned(
              top: 40,
              right: -20,
              width: 220,
              height: 220,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.5,
                  child: Lottie.asset('assets/lottie/sparkle_stars.json', fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: 20,
              width: 140,
              height: 140,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.35,
                  child: Lottie.asset('assets/lottie/premium_crown.json', fit: BoxFit.contain),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // 3D Animated Floating Logo
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_tiltX)
                        ..rotateY(_tiltY),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientHero,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPurple.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: const Icon(Icons.wallpaper_rounded, color: Colors.white, size: 32),
                          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('WallVault', style: AppTypography.h1.copyWith(fontSize: 28, color: Colors.white)),
                              const Text('3D Creator Portal', style: TextStyle(color: AppColors.accentCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3D Glassmorphic Interactive Form Card
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_tiltX)
                        ..rotateY(_tiltY),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome Back', style: AppTypography.h2),
                          const SizedBox(height: 6),
                          Text('Enter your credentials to access 4K wallpapers and creator tools.', style: AppTypography.caption),
                          const SizedBox(height: 24),

                          GlowInput(
                            controller: _emailController,
                            hintText: 'Email Address',
                            prefixIcon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),
                          GlowInput(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_rounded,
                            obscureText: true,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 24),

                          GradientButton(
                            label: 'Sign In to WallVault',
                            onPressed: _onLogin,
                            isLoading: _isLoading,
                            icon: Icons.arrow_forward_rounded,
                          ).animate().fadeIn(delay: 300.ms),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR CONTINUE WITH', style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 24),

                    // 3D Social Sign-In Row
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google',
                            onTap: _handleGoogleSignIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.apple_rounded,
                            label: 'Apple',
                            onTap: _handleAppleSignIn,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 32),

                    Center(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.signup),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: 'Create Account',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.accentCyan,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.h4),
          ],
        ),
      ),
    );
  }
}
