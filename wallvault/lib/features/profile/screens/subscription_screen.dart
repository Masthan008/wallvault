import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/services/razorpay_service.dart';

/// S24 — Subscription plans screen.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final RazorpayService _razorpayService = RazorpayService();
  String? _selectedPlanTitle;

  @override
  void initState() {
    super.initState();
    _razorpayService.init(
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentError,
      onExternalWallet: _onExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    final title = _selectedPlanTitle;
    final user = ref.read(userProfileProvider).value;
    if (user == null || title == null) return;

    final days = title.toLowerCase() == 'monthly'
        ? 30
        : title.toLowerCase() == 'yearly'
            ? 365
            : 99999;

    try {
      await ref.read(userRepositoryProvider).updateUser(user.uid, {
        'subscription': {
          'plan': title.toLowerCase(),
          'startDate': Timestamp.fromDate(DateTime.now()),
          'endDate': Timestamp.fromDate(DateTime.now().add(Duration(days: days))),
          'autoRenew': true,
        }
      });

      ref.invalidate(userProfileProvider);

      if (mounted) {
        showDialog(
          context: context,
          builder: (successCtx) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.accentSuccess),
                SizedBox(width: 8),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update subscription in database: $e')),
        );
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: [${response.code}] ${response.message}')),
      );
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External Wallet: ${response.walletName}')),
      );
    }
  }

  void _handleSubscription(String title, String price) {
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    setState(() {
      _selectedPlanTitle = title;
    });

    double amt = 99.0;
    if (title.toLowerCase() == 'yearly') amt = 799.0;
    if (title.toLowerCase() == 'lifetime') amt = 1999.0;

    _razorpayService.openCheckout(
      amount: amt,
      name: 'WallVault Pro',
      description: '$title Membership',
      email: user.email.isNotEmpty ? user.email : 'user@example.com',
      contact: user.phone.isNotEmpty ? user.phone : '9999999999',
    );
  }

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
              onSubscribe: () => _handleSubscription('Monthly', '₹99'),
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Yearly',
              price: '₹799',
              period: '/year',
              features: const ['Everything in Monthly', 'Save 33%', 'Exclusive badges'],
              isPopular: true,
              onSubscribe: () => _handleSubscription('Yearly', '₹799'),
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Lifetime',
              price: '₹1,999',
              period: 'one-time',
              features: const ['Everything in Yearly', 'Forever access', 'Founder badge'],
              isPopular: false,
              onSubscribe: () => _handleSubscription('Lifetime', '₹1,999'),
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
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isPopular,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
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
            onPressed: onSubscribe,
          ),
        ],
      ),
    );
  }
}
