import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/glow_input.dart';
import '../../../core/router/routes.dart';

/// S05 — Login screen with blurred wallpaper background and phone + password inputs.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_phoneController.text.length >= 10 && _passwordController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      // Trigger OTP verification navigation
      context.push(AppRoutes.otp, extra: _phoneController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // 1. Subtle blurred wallpaper background (20% opacity)
          Positioned.fill(
            child: Opacity(
              opacity: 0.20,
              child: Image.network(
                'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=600',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient shadow overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    AppColors.bgPrimary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Content body
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientHero,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppColors.glowPurple,
                    ),
                    child: const Icon(Icons.wallpaper_rounded,
                        color: Colors.white, size: 32),
                  ).animate().fadeIn(duration: 400.ms).scale(),
                  const SizedBox(height: 32),
                  Text('Welcome to', style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  )).animate().fadeIn(delay: 100.ms),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.gradientHero.createShader(bounds),
                    child: Text('WallVault',
                        style: AppTypography.h1.copyWith(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access premium wallpapers and unlock the creator economy.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 40),
                  
                  // Inputs
                  GlowInput(
                    controller: _phoneController,
                    hintText: 'Phone Number',
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 12),
                  GlowInput(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_rounded,
                    obscureText: true,
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),
                  
                  // Submit
                  GradientButton(
                    label: 'Continue',
                    onPressed: _onLogin,
                    isLoading: _isLoading,
                    icon: Icons.arrow_forward_rounded,
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 32),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.bgElevated)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or continue with',
                            style: AppTypography.caption),
                      ),
                      Expanded(child: Divider(color: AppColors.bgElevated)),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 24),
                  
                  // Social buttons
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google',
                          onTap: () {
                            // Google sign-in trigger
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          icon: Icons.apple_rounded,
                          label: 'Apple',
                          onTap: () {
                            // Apple sign-in trigger
                          },
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: 32),
                  
                  // Sign up link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.signup),
                      child: RichText(
                        text: TextSpan(
                          text: 'New here? ',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Create account',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.accentCyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ],
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
          border: Border.all(color: AppColors.bgElevated),
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
