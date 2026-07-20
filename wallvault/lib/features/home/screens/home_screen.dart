import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';

/// S08 — Home feed with categories, featured carousel, and masonry grid.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _categories = [
    ('🌊', 'Nature'),
    ('🎨', 'Abstract'),
    ('🚗', 'Cars'),
    ('🌌', 'Space'),
    ('🎭', 'Anime'),
    ('🌑', 'Dark'),
    ('🏙️', 'City'),
    ('🎵', 'Music'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.bgPrimary,
            title: ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.gradientHero.createShader(bounds),
              child: Text(
                'WallVault',
                style: AppTypography.h2.copyWith(color: Colors.white),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textSecondary),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),

          // ── Streak Banner ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientHero,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('7 Day Streak!',
                              style: AppTypography.h4),
                          Text('Download daily to keep it going',
                              style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Text('+50 XP',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            ),
          ),

          // ── Categories ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    child: Text('Categories', style: AppTypography.h3),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding),
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return GestureDetector(
                          onTap: () => context.push(
                            AppRoutes.categoryDetailPath(
                                cat.$2.toLowerCase()),
                          ),
                          child: Container(
                            width: 72,
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.bgElevated,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(cat.$1,
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(cat.$2,
                                    style: AppTypography.caption
                                        .copyWith(fontSize: 10)),
                              ],
                            ),
                          )
                              .animate(delay: (50 * index).ms)
                              .fadeIn()
                              .slideX(begin: 0.2),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Trending Section Header ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 12),
              child: Row(
                children: [
                  Text('Trending', style: AppTypography.h3),
                  const Spacer(),
                  Text('See all',
                      style: AppTypography.creatorName
                          .copyWith(fontSize: 13)),
                ],
              ),
            ),
          ),

          // ── Wallpaper Grid (Placeholder) ───────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.gridSpacing,
              crossAxisSpacing: AppSpacing.gridSpacing,
              childCount: 8,
              itemBuilder: (context, index) {
                final heights = [220.0, 280.0, 200.0, 260.0,
                    240.0, 300.0, 180.0, 250.0];
                return GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.wallpaperDetailPath('placeholder_$index'),
                  ),
                  child: Container(
                    height: heights[index % heights.length],
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusCard),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          [
                            AppColors.accentPurple,
                            AppColors.accentCyan,
                            AppColors.accentGold,
                            AppColors.accentSuccess,
                          ][index % 4]
                              .withValues(alpha: 0.3),
                          AppColors.bgCard,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Wallpaper ${index + 1}',
                                  style: AppTypography.h4),
                              const SizedBox(height: 2),
                              Text('by Creator',
                                  style: AppTypography.creatorName
                                      .copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentSuccess
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill),
                            ),
                            child: const Text('FREE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                )),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: (80 * index).ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),
                );
              },
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
