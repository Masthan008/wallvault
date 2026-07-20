import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';

/// Creator public profile screen.
class CreatorProfileScreen extends StatelessWidget {
  final String creatorId;
  const CreatorProfileScreen({super.key, required this.creatorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.bgSecondary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientHero),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  // Avatar
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.bgPrimary,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.bgCard,
                        child: const Icon(Icons.person_rounded,
                            size: 36, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      children: [
                        Text('Creator Name', style: AppTypography.h2),
                        const SizedBox(height: 4),
                        Text('🌸 Level 3 — Bloom', style: AppTypography.creatorName),
                        const SizedBox(height: 8),
                        Text('Digital artist specializing in abstract and space art.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatColumn('47', 'Walls'),
                            _StatColumn('892', 'Followers'),
                            _StatColumn('12.4K', 'Downloads'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: GradientButton(
                              label: 'Follow', height: 44, onPressed: () {},
                            )),
                            const SizedBox(width: 12),
                            Container(
                              height: 44, width: 44,
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.bgElevated),
                              ),
                              child: const Icon(Icons.volunteer_activism_rounded,
                                  color: AppColors.accentGold, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('Wallpapers', style: AppTypography.h3),
                  const SizedBox(height: 12),
                  // Grid placeholder
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12, crossAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, i) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.h3),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
