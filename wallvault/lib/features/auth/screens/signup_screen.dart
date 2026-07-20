import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/glow_input.dart';
import '../../../core/router/routes.dart';
import '../../../providers/auth_provider.dart';

/// S06 — Sign Up screen with full fields and social Google/Apple sign-in buttons.
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    ref.read(authRepositoryProvider).signInWithPhone(
      phone,
      (credential) async {
        // Verification completed automatically
        await ref.read(authRepositoryProvider).signInWithCredential(credential);
        if (mounted) context.go(AppRoutes.home);
      },
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Verification failed.')),
        );
      },
      (verificationId, forceResendingToken) {
        setState(() => _isLoading = false);
        // Push verification ID to OtpScreen
        context.push(AppRoutes.otp, extra: {
          'phone': phone,
          'verificationId': verificationId,
        });
      },
      (verificationId) {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Join WallVault', style: AppTypography.h2),
              const SizedBox(height: 8),
              Text(
                'Create your account to start discovering amazing wallpapers.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GlowInput(
                controller: _nameController,
                hintText: 'Full Name',
                prefixIcon: Icons.person_rounded,
              ),
              const SizedBox(height: 12),
              GlowInput(
                controller: _emailController,
                hintText: 'Email Address',
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              GlowInput(
                controller: _phoneController,
                hintText: 'Phone Number',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              GlowInput(
                controller: _passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_rounded,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Create Account',
                onPressed: _onCreateAccount,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 32),
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.bgElevated)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or create with', style: AppTypography.caption),
                  ),
                  Expanded(child: Divider(color: AppColors.bgElevated)),
                ],
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),
              
              // Social buttons
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Google',
                      onTap: () {
                        // Google account creation
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.apple_rounded,
                      label: 'Apple',
                      onTap: () {
                        // Apple account creation
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
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
