import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';
import '../../../providers/wallpaper_provider.dart';
import '../../../data/models/wallpaper_model.dart';

/// S08 — Home feed connected to real Firestore collection queries (exclusively prebuilt wallpapers).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _activeTab = 0;
  final List<String> _tabs = ['For You', 'Trending', 'Nature', 'Anime', 'Abstract'];
  
  // Maps tab names directly to database query parameters
  String? get _currentCategoryFilter {
    if (_activeTab == 2) return 'nature';
    if (_activeTab == 3) return 'anime';
    if (_activeTab == 4) return 'abstract';
    return null;
  }

  static const _categories = [
    (Icons.forest_rounded, 'Nature'),
    (Icons.palette_rounded, 'Abstract'),
    (Icons.directions_car_rounded, 'Cars'),
    (Icons.rocket_launch_rounded, 'Space'),
    (Icons.face_rounded, 'Anime'),
    (Icons.dark_mode_rounded, 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    // Read category parameter dynamically from active tab selection
    final categoryFilter = _currentCategoryFilter;
    final AsyncValue<List<WallpaperModel>> wallpapersAsync = categoryFilter != null
        ? ref.watch(categoryWallpapersProvider(categoryFilter))
        : ref.watch(trendingWallpapersProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          // ── Header Bar (S08: greeting, streak, search, profile avatar) ───────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.bgPrimary,
            elevation: 0,
            title: Row(
              children: [
                const Hero(
                  tag: 'user-profile-avatar',
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.bgCard,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100'),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good Morning, Alex', style: AppTypography.h4),
                    Row(
                      children: [
                        const Text('🔥 ', style: TextStyle(fontSize: 12)),
                        Text(
                          '7-day streak!',
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
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
                onPressed: () => context.push(AppRoutes.search),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),

          // ── Horizontal Tabs (S08: tab bar with morph purple indicator) ──────────────────
          SliverToBoxAdapter(
            child: Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isActive = _activeTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => _activeTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isActive ? AppColors.textPrimary : AppColors.textMuted,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Indicator bar
                          Container(
                            height: 3,
                            width: 30,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.accentPurple : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: isActive ? AppColors.glowPurple : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── S08: Horizontal Featured Slides (from Firestore database collection query) ─────────
          SliverToBoxAdapter(
            child: wallpapersAsync.when(
              data: (wallpapers) {
                final featured = wallpapers.where((w) => w.isPremium).toList();
                if (featured.isEmpty) return const SizedBox.shrink();
                
                return SizedBox(
                  height: 320,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    itemCount: featured.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final item = featured[index];
                      return GestureDetector(
                        onTap: () => context.push(AppRoutes.wallpaperDetailPath('featured_$index')),
                        child: Container(
                          width: 200,
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                            image: DecorationImage(
                              image: AssetImage(item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: const LinearGradient(
                                      colors: [Colors.transparent, Colors.black87],
                                      begin: Alignment.center,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGold,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'PREMIUM',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: AppTypography.h3),
                                    Text('by ${item.creatorName}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, s) => const SizedBox.shrink(),
            ),
          ),

          // ── S08: Categories List ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    child: Text('Popular Categories', style: AppTypography.h3),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return GestureDetector(
                          onTap: () {
                            // Find category index matching the active tab list
                            final tabIndex = _tabs.indexWhere((t) => t.toLowerCase() == cat.$2.toLowerCase());
                            if (tabIndex != -1) {
                              setState(() {
                                _activeTab = tabIndex;
                              });
                            } else {
                              // If not in tabs, trigger query search screen
                              context.push(AppRoutes.search);
                            }
                          },
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.bgElevated),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(cat.$1, color: AppColors.accentCyan, size: 24),
                                const SizedBox(height: 6),
                                Text(cat.$2, style: AppTypography.caption.copyWith(fontSize: 10)),
                              ],
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
                  Text(_activeTab == 0 ? 'Trending Wallpapers' : '${_tabs[_activeTab]} Wallpapers', style: AppTypography.h3),
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
                    return GestureDetector(
                      onTap: () => context.push(AppRoutes.wallpaperDetailPath('grid_$index')),
                      child: Container(
                        height: heights[index % heights.length],
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                          image: DecorationImage(
                            image: AssetImage(item.imageUrl),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                                  gradient: const LinearGradient(
                                    colors: [Colors.transparent, Colors.black87],
                                    begin: Alignment.center,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: item.isPremium ? AppColors.accentGold : AppColors.accentSuccess,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                                ),
                                child: Text(
                                  item.isPremium ? '₹49' : 'FREE',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: AppTypography.h4),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 7,
                                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=50'),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              item.creatorName,
                                              style: AppTypography.creatorName.copyWith(fontSize: 10),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(Icons.verified, color: AppColors.accentCyan, size: 10),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
              ),
              error: (e, s) => SliverToBoxAdapter(
                child: Center(child: Padding(padding: const EdgeInsets.all(48), child: Text('Failed to load database: $e'))),
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.creatorUpload),
        backgroundColor: AppColors.accentPurple,
        shape: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple,
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
