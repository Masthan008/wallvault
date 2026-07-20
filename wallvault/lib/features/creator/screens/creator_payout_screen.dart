import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';

/// S23 — Creator payout request screen.
class CreatorPayoutScreen extends StatelessWidget {
  const CreatorPayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('Payouts')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientGold,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Balance',
                        style: AppTypography.caption.copyWith(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('₹2,450', style: AppTypography.h1.copyWith(
                      color: Colors.black, fontSize: 36,
                    )),
                    const SizedBox(height: 12),
                    Text('Min. payout: ₹500',
                        style: AppTypography.bodySmall.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Payout method
              Text('Payout Method', style: AppTypography.h3),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                  border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_rounded, color: AppColors.accentPurple),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UPI', style: AppTypography.h4),
                        Text('creator@upi', style: AppTypography.caption),
                      ],
                    )),
                    const Icon(Icons.check_circle_rounded, color: AppColors.accentSuccess),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Request Payout',
                gradient: AppColors.gradientGold,
                icon: Icons.payments_rounded,
                onPressed: () {
                  // TODO: Request payout via RazorpayX
                },
              ),
              const SizedBox(height: 32),
              // Payout history
              Text('Payout History', style: AppTypography.h3),
              const SizedBox(height: 12),
              ...List.generate(3, (i) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                ),
                child: Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${1500 - i * 400}', style: AppTypography.h4),
                        Text('July ${15 - i * 5}, 2026', style: AppTypography.caption),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentSuccess.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Text('Completed', style: TextStyle(
                        color: AppColors.accentSuccess, fontSize: 11, fontWeight: FontWeight.w600,
                      )),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
