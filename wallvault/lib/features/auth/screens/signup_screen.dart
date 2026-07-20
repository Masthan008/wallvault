import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/glow_input.dart';
import '../../../core/router/routes.dart';

/// S06 — Sign Up screen.
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
              const SizedBox(height: 32),
              const GlowInput(
                hintText: 'Full Name',
                prefixIcon: Icons.person_rounded,
              ),
              const SizedBox(height: 16),
              const GlowInput(
                hintText: 'Email Address',
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const GlowInput(
                hintText: 'Phone Number',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Create Account',
                onPressed: () {
                  // TODO: Create account and send OTP
                  context.push(AppRoutes.otp, extra: '');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
