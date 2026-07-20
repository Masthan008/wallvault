import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/gradient_button.dart';

/// S38 — Error state screen.
class ErrorScreen extends StatelessWidget {
  final String title;
  final String error;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.title = 'Something went wrong',
    this.error = 'Unable to connect to the server. Please check your internet connection.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding * 2),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: AppColors.accentError, size: 36),
              ),
              const SizedBox(height: 24),
              Text(title, style: AppTypography.h3, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Try Again',
                  onPressed: onRetry!,
                  width: 200,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
