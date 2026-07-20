import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// S22 — Creator analytics screen (charts placeholder).
class CreatorAnalyticsScreen extends StatelessWidget {
  const CreatorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time range selector
              Row(
                children: ['7D', '30D', '90D', 'All'].map((label) {
                  final isSelected = label == '30D';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentPurple : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Text(label, style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 13, fontWeight: FontWeight.w600,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Downloads chart placeholder
              Text('Downloads Over Time', style: AppTypography.h3),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Center(
                  child: Text('📊 Chart placeholder', style: AppTypography.caption),
                ),
              ),
              const SizedBox(height: 24),
              // Revenue chart placeholder
              Text('Revenue', style: AppTypography.h3),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Center(
                  child: Text('💰 Revenue chart placeholder', style: AppTypography.caption),
                ),
              ),
              const SizedBox(height: 24),
              // Top wallpapers
              Text('Top Performers', style: AppTypography.h3),
              const SizedBox(height: 12),
              ...List.generate(5, (i) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                ),
                child: Row(
                  children: [
                    Text('#${i + 1}', style: AppTypography.h3.copyWith(
                      color: i == 0 ? AppColors.accentGold : AppColors.textMuted,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Wallpaper ${i + 1}', style: AppTypography.h4)),
                    Text('${500 - i * 80} DL', style: AppTypography.caption),
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
