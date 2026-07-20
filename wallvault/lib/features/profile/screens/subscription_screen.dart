import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../providers/auth_provider.dart';

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
            const _PlanCard(
              title: 'Monthly',
              price: '₹99',
              period: '/month',
              features: ['Unlimited premium', 'No ads', 'Early access'],
              isPopular: false,
            ),
            const SizedBox(height: 12),
            const _PlanCard(
              title: 'Yearly',
              price: '₹799',
              period: '/year',
              features: ['Everything in Monthly', 'Save 33%', 'Exclusive badges'],
              isPopular: true,
            ),
            const SizedBox(height: 12),
            const _PlanCard(
              title: 'Lifetime',
              price: '₹1,999',
              period: 'one-time',
              features: ['Everything in Yearly', 'Forever access', 'Founder badge'],
              isPopular: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
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

  void _handleSubscription(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    // Show simulated Razorpay dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Row(
          children: [
            const Icon(Icons.payment_rounded, color: AppColors.accentPurple),
            const SizedBox(width: 8),
            Text('Razorpay checkout', style: AppTypography.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WallVault Pro - $title Plan', style: AppTypography.bodyMedium),
            const SizedBox(height: 4),
            Text('Amount: $price', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(color: AppColors.accentPurple),
            ),
            const SizedBox(height: 12),
            const Text(
              'Simulating secure payment gateway transaction...',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Close checkout dialog
    if (context.mounted) Navigator.pop(context);

    // Write premium status to Firestore
    try {
      final days = title.toLowerCase() == 'monthly'
          ? 30
          : title.toLowerCase() == 'yearly'
              ? 365
              : 99999;
      await ref.read(userRepositoryProvider).updateUser(user.uid, {
        'subscription': {
          'plan': title.toLowerCase(),
          'startDate': Timestamp.fromDate(DateTime.now()),
          'endDate': Timestamp.fromDate(DateTime.now().add(Duration(days: days))),
          'autoRenew': true,
        }
      });

      ref.invalidate(userProfileProvider);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (successCtx) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.accentSuccess),
                const SizedBox(width: 8),
                Text('Payment Successful', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              'Thank you! You have successfully subscribed to the $title plan. Welcome to WallVault PRO!',
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(successCtx),
                child: const Text('Great!', style: TextStyle(color: AppColors.accentPurple)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verification failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPopular ? AppColors.bgCard : AppColors.bgCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: isPopular
            ? Border.all(color: AppColors.accentPurple, width: 2)
            : Border.all(color: AppColors.bgElevated),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : null,
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
                const Icon(Icons.check_circle_rounded,
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
            onPressed: () => _handleSubscription(context, ref),
          ),
        ],
      ),
    );
  }
}
