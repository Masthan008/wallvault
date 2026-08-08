import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';
import '../../../providers/wallpaper_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/wallpaper_model.dart';
import '../../../core/widgets/wallpaper_card.dart';
import '../../../core/widgets/shimmer_loading.dart';

/// S08 — Home feed connected to real Firestore collection queries (exclusively prebuilt wallpapers).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categoriesList = categoriesAsync.value ?? [
      'All', 'Anime', 'Abstract', 'Nature', 'Space', 'Cars', 'Cyberpunk', '3D', 'Dark', 'Minimalist'
    ];

    final categoryFilter = (_selectedCategory != 'All' && _selectedCategory != 'Trending')
        ? _selectedCategory
        : null;

    final AsyncValue<List<WallpaperModel>> wallpapersAsync = categoryFilter != null
        ? ref.watch(categoryWallpapersProvider(categoryFilter))
        : ref.watch(trendingWallpapersProvider);

    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          // ── Header Bar (greeting, streak, search, profile avatar) ───────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.bgPrimary,
            elevation: 0,
            title: userAsync.when(
              data: (user) {
                final name = (user?.displayName.isNotEmpty == true) ? user!.displayName : 'Guest';
                final avatar = user?.avatarUrl;
                final streakVal = user?.streak.current ?? 0;

                final hour = DateTime.now().hour;
                String greeting;
                if (hour < 12) {
                  greeting = 'Good Morning';
                } else if (hour < 17) {
                  greeting = 'Good Afternoon';
                } else {
                  greeting = 'Good Evening';
                }

                return Row(
                  children: [
                    Hero(
                      tag: 'user-profile-avatar',
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.bgCard,
                        backgroundImage: (avatar != null && avatar.isNotEmpty)
                            ? NetworkImage(avatar)
                            : null,
                        child: (avatar == null || avatar.isEmpty)
                            ? Text(
                                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'G',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$greeting, $name', style: AppTypography.h4),
                        Row(
                          children: [
                            const Text('🔥 ', style: TextStyle(fontSize: 12)),
                            Text(
                              '$streakVal-day streak!',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orangeAccent.shade200,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),

          // ── Horizontal Featured Slides (Most Downloaded / Premium Highlights) ─────────
          SliverToBoxAdapter(
            child: wallpapersAsync.when(
              data: (wallpapers) {
                final featured = wallpapers.where((w) => w.isPremium).toList();
                final displayItems = featured.isNotEmpty ? featured : wallpapers.take(5).toList();
                if (displayItems.isEmpty) return const SizedBox.shrink();

                return SizedBox(
                  height: 320,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    itemCount: displayItems.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      return SizedBox(
                        width: 200,
                        child: WallpaperCard(
                          wallpaper: item,
                          height: 320 - AppSpacing.screenPadding,
                          entranceDelayMs: (index % 4) * 30,
                          onTap: () => context.push(AppRoutes.wallpaperDetailPath(item.id)),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (_, _) => const ShimmerBox(
                    width: 200,
                    height: 100,
                    borderRadius: 24,
                  ),
                ),
              ),
              error: (e, s) => const SizedBox.shrink(),
            ),
          ),

          // ── Categories List (Dynamic Firestore Pills) ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Explore Categories', style: AppTypography.h3),
                        Text('Swipe', style: TextStyle(fontSize: 11, color: AppColors.textMuted.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                      itemCount: categoriesList.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final catName = categoriesList[index];
                        final isActive = _selectedCategory.toLowerCase() == catName.toLowerCase();

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = catName;
                            });
                          },
                          child: AnimatedScale(
                            scale: isActive ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.accentPurple.withValues(alpha: 0.28)
                                    : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.accentPurple
                                      : Colors.white.withValues(alpha: 0.12),
                                  width: isActive ? 1.5 : 1.0,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accentPurple.withValues(alpha: 0.4),
                                          blurRadius: 16,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  catName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                                    color: isActive ? Colors.white : AppColors.textSecondary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Grid Section Header ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 32, AppSpacing.screenPadding, 12),
              child: Row(
                children: [
                  Text(
                    (_selectedCategory == 'All' || _selectedCategory == 'Trending')
                        ? 'Trending Wallpapers 🔥'
                        : '$_selectedCategory Wallpapers',
                    style: AppTypography.h3,
                  ),
                  const Spacer(),
                  const Text('See all', style: TextStyle(fontSize: 12, color: AppColors.accentCyan)),
                ],
              ),
            ),
          ),

          // ── S08: Masonry Grid of Wallpaper Cards from Database ───────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            sliver: wallpapersAsync.when(
              data: (wallpapers) {
                if (wallpapers.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Text(
                          'No prebuilt wallpapers found.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }

                return SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.gridSpacing,
                  crossAxisSpacing: AppSpacing.gridSpacing,
                  childCount: wallpapers.length,
                  itemBuilder: (context, index) {
                    final item = wallpapers[index];
                    final heights = [240.0, 290.0, 220.0, 270.0, 230.0, 280.0];
                    return WallpaperCard(
                      wallpaper: item,
                      height: heights[index % heights.length],
                      entranceDelayMs: (index % 8) * 30,
                      onTap: () => context.push(AppRoutes.wallpaperDetailPath(item.id)),
                    );
                  },
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: WallpaperGridShimmer(),
              ),
              error: (e, s) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ),
        ],
      ),
    );
  }
}
