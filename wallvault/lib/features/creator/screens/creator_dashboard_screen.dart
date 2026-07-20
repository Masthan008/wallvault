import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_counter.dart';

/// S20 — Creator Dashboard with KPIs and recent uploads.
class CreatorDashboardScreen extends StatelessWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.bgPrimary,
              title: Text('Creator Studio', style: AppTypography.h2),
              actions: [
                IconButton(
                  icon: const Icon(Icons.analytics_rounded,
                      color: AppColors.accentCyan),
                  onPressed: () {},
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Level badge
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientHero,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusCard),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text('🌿', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Level 2 — Sprout',
                                  style: AppTypography.h4),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.6,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  valueColor:
                                      const AlwaysStoppedAnimation(Colors.white),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('600 / 1000 XP',
                                  style: AppTypography.caption
                                      .copyWith(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // KPI Grid
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Total Earnings',
                          value: 12500,
                          prefix: '₹',
                          icon: Icons.currency_rupee_rounded,
                          accentColor: AppColors.accentGold,
                          trend: 23.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Downloads',
                          value: 3420,
                          icon: Icons.download_rounded,
                          accentColor: AppColors.accentCyan,
                          trend: 12.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Wallpapers',
                          value: 47,
                          icon: Icons.photo_library_rounded,
                          accentColor: AppColors.accentPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Followers',
                          value: 892,
                          icon: Icons.people_rounded,
                          accentColor: AppColors.accentSuccess,
                          trend: 8.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Recent Uploads', style: AppTypography.h3),
                  const SizedBox(height: 12),
                  // Placeholder upload items
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusInput),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.bgElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.image_rounded,
                                color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Wallpaper ${index + 1}',
                                    style: AppTypography.h4),
                                const SizedBox(height: 2),
                                Text('${120 + index * 30} downloads',
                                    style: AppTypography.caption),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentSuccess
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            child: Text(
                              'Approved',
                              style: TextStyle(
                                  color: AppColors.accentSuccess,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
