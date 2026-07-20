import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';

/// S08 — Home feed with categories, tabs, featured carousel, and masonry grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;
  final List<String> _tabs = ['For You', 'Trending', 'Categories', 'Creators'];

  static const _categories = [
    ('🌊', 'Nature'),
    ('🎨', 'Abstract'),
    ('🚗', 'Cars'),
    ('🌌', 'Space'),
    ('🎭', 'Anime'),
    ('🌑', 'Dark'),
  ];

  static const _featuredWallpapers = [
    ('assets/images/japan_sunset_street.png', 'Japan Sunset Street', 'NEW'),
    ('assets/images/uchiha_madara_shadow.png', 'Uchiha Madara Shadow', 'PREMIUM'),
    ('assets/images/neon_cyber_temple.png', 'Neon Cyber Temple', 'PREMIUM'),
  ];

  static const _gridWallpapers = [
    ('assets/images/japan_sunset_street.png', 'Japan Sunset Street', 'Satoshi', 450, false, 4.9),
    ('assets/images/uchiha_madara_shadow.png', 'Uchiha Madara Shadow', 'OtakuArt', 1200, true, 4.8),
    ('assets/images/neon_cyber_temple.png', 'Neon Cyber Temple', 'Matrix', 850, true, 4.7),
    ('assets/images/cosmic_nebula_ocean.png', 'Cosmic Nebula Ocean', 'Luna', 2300, false, 4.9),
    ('assets/images/cyberpunk_car_drift.png', 'Cyberpunk Car Drift', 'Speedy', 940, true, 4.6),
    ('assets/images/minimalist_mountain_lake.png', 'Minimalist Mountain Lake', 'ZenDesign', 1600, false, 4.8),
  ];

  @override
  Widget build(BuildContext context) {
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
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.bgCard,
                  backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100'),
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

          // ── S08: Horizontal Carousel of Large Wallpaper Cards ───────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    itemCount: _featuredWallpapers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final item = _featuredWallpapers[index];
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
                               image: item.$1.startsWith('assets/')
                                   ? AssetImage(item.$1) as ImageProvider
                                   : NetworkImage(item.$1),
                               fit: BoxFit.cover,
                             ),
                          ),
                          child: Stack(
                            children: [
                              // Vignette Gradient overlay
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
                              // Badge
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.$3 == 'PREMIUM' ? AppColors.accentGold : AppColors.accentPurple,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item.$3,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Name
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.$2, style: AppTypography.h3),
                                    const Text('Tap to view details', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
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

          // ── S08: Categories Horizontal list ─────────────────────────────────────
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
                          onTap: () => context.push(AppRoutes.categoryDetailPath(cat.$2.toLowerCase())),
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
                                Text(cat.$1, style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
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

          // ── Masonry Grid Section Header ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 32, AppSpacing.screenPadding, 12),
              child: Row(
                children: [
                  Text('Trending Wallpapers', style: AppTypography.h3),
                  const Spacer(),
                  const Text('See all', style: TextStyle(fontSize: 12, color: AppColors.accentCyan)),
                ],
              ),
            ),
          ),

          // ── S08: 2-column Masonry Grid of Wallpaper Cards ───────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.gridSpacing,
              crossAxisSpacing: AppSpacing.gridSpacing,
              childCount: _gridWallpapers.length,
              itemBuilder: (context, index) {
                final item = _gridWallpapers[index];
                final heights = [240.0, 290.0, 220.0, 270.0, 230.0, 280.0];
                return GestureDetector(
                  onTap: () => context.push(AppRoutes.wallpaperDetailPath('grid_$index')),
                  child: Container(
                    height: heights[index % heights.length],
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                       image: DecorationImage(
                         image: item.$1.startsWith('assets/')
                             ? AssetImage(item.$1) as ImageProvider
                             : NetworkImage(item.$1),
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
                        // Soft dark fade
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
                        // Price tag
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.$5 ? AppColors.accentGold : AppColors.accentSuccess,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            child: Text(
                              item.$5 ? '₹49' : 'FREE',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        // Creator Row Details
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.$2, style: AppTypography.h4),
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
                                          item.$3,
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
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      // Circular Purple FAB upload button
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
