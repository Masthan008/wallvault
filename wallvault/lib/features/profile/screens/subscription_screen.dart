import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';

/// S24 — Subscription plans screen.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('Pro Membership')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Hero
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.gradientHero.createShader(bounds),
              child: Text('Go Pro', style: AppTypography.h1.copyWith(
                fontSize: 40, color: Colors.white,
              )),
            ),
            const SizedBox(height: 8),
            Text('Unlock unlimited premium wallpapers',
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            // Plans
            _PlanCard(
              title: 'Monthly',
              price: '₹99',
              period: '/month',
              features: const ['Unlimited premium', 'No ads', 'Early access'],
              isPopular: false,
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Yearly',
              price: '₹799',
              period: '/year',
              features: const ['Everything in Monthly', 'Save 33%', 'Exclusive badges'],
              isPopular: true,
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Lifetime',
              price: '₹1,999',
              period: 'one-time',
              features: const ['Everything in Yearly', 'Forever access', 'Founder badge'],
              isPopular: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isPopular,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: isPopular
            ? Border.all(color: AppColors.accentPurple, width: 2)
            : Border.all(color: AppColors.bgElevated),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTypography.h3),
              const Spacer(),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientHero,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: const Text('POPULAR', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white,
                  )),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: AppTypography.h1.copyWith(
                color: isPopular ? AppColors.accentPurple : AppColors.textPrimary,
              )),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(period, style: AppTypography.caption),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 16, color: AppColors.accentSuccess),
                const SizedBox(width: 8),
                Text(f, style: AppTypography.bodySmall),
              ],
            ),
          )),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Subscribe',
            gradient: isPopular ? AppColors.gradientHero : AppColors.gradientPremium,
            height: 44,
            onPressed: () {
              // TODO: Razorpay subscription
            },
          ),
        ],
      ),
    );
  }
}
