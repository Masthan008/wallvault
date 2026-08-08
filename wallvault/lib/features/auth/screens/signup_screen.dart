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
import '../../../core/widgets/effects/app_toast.dart';
import '../../../core/router/routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

/// S03 — 3D Glassmorphic Sign Up Screen with Lottie Golden Coins Animation & Perspective Tilt
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCreateAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      showAppToast(context, 'Please enter your full name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      showAppToast(context, 'Please enter a valid email.');
      return;
    }
    if (password.length < 6) {
      showAppToast(context, 'Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      final userCredential = await authRepo.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception('User creation failed.');

      final now = DateTime.now();
      final newUser = UserModel(
        uid: firebaseUser.uid,
        phone: _phoneController.text.trim(),
        email: email,
        displayName: name,
        createdAt: now,
        updatedAt: now,
      );
      await userRepo.createUser(newUser);

      if (mounted) context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAppToast(context, e.message ?? 'Account creation failed.', type: ToastType.error);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAppToast(context, 'Error: $e', type: ToastType.error);
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
          showAppToast(context, e.message ?? 'Google sign-in failed.', type: ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAppToast(context, 'Google sign-in failed: $e', type: ToastType.error);
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
          showAppToast(context, e.message ?? 'Apple sign-in failed.', type: ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAppToast(context, 'Apple sign-in failed: $e', type: ToastType.error);
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
            // Dark Gradient Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F1A2E), Color(0xFF0A0A0F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Lottie Golden Coins & Sparkle Background Animations
            Positioned(
              top: 20,
              right: -30,
              width: 240,
              height: 240,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.45,
                  child: Lottie.asset('assets/lottie/golden_coins.json', fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: -20,
              width: 180,
              height: 180,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.35,
                  child: Lottie.asset('assets/lottie/sparkle_stars.json', fit: BoxFit.contain),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button & header
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          ),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 12),
                        Text('Create Account', style: AppTypography.h2),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3D Glassmorphic Signup Form Card
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
                            color: AppColors.accentCyan.withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentCyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.person_add_rounded, color: AppColors.accentCyan, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Text('Join WallVault Community', style: AppTypography.h3.copyWith(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Unlock free HD downloads, join the creator marketplace, and track your streaks.', style: AppTypography.caption),
                          const SizedBox(height: 24),

                          GlowInput(
                            controller: _nameController,
                            hintText: 'Full Name',
                            prefixIcon: Icons.person_rounded,
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 14),
                          GlowInput(
                            controller: _emailController,
                            hintText: 'Email Address',
                            prefixIcon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 14),
                          GlowInput(
                            controller: _phoneController,
                            hintText: 'Phone Number (optional)',
                            prefixIcon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                          const SizedBox(height: 14),
                          GlowInput(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_rounded,
                            obscureText: true,
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          const SizedBox(height: 24),

                          GradientButton(
                            label: 'Create Free Account',
                            onPressed: _onCreateAccount,
                            isLoading: _isLoading,
                          ).animate().fadeIn(delay: 500.ms),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR CREATE WITH', style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 20),

                    // 3D Social Buttons
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
                    ).animate().fadeIn(delay: 700.ms),
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
