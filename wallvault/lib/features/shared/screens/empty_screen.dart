import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/gradient_button.dart';

/// S37 — Empty state screen.
class EmptyScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyScreen({
    super.key,
    this.title = 'No wallpapers found',
    this.description = 'Try searching with another term or explore categories.',
    this.icon = Icons.wallpaper_rounded,
    this.actionLabel,
    this.onAction,
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
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.textMuted, size: 36),
              ),
              const SizedBox(height: 24),
              Text(title, style: AppTypography.h3, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 32),
                GradientButton(
                  label: actionLabel!,
                  onPressed: onAction!,
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
