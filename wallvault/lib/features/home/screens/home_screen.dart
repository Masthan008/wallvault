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

/// S08 — Home feed connected to real Firestore collection queries (exclusively prebuilt wallpapers).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _activeTab = 0;
  final List<String> _tabs = ['Trending'];
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    // Dynamic categories from Firestore StreamProvider (includes Admin and Creator created categories)
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categoriesList = categoriesAsync.value ?? [
      'All', 'Anime', 'Abstract', 'Nature', 'Space', 'Cars', 'Cyberpunk', '3D', 'Dark', 'Minimalist'
    ];

    // Filter by selected category or fetch top trending wallpapers sorted by downloads
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

          // ── Top Tab Bar (Trending filter tab) ──────────────────
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppColors.gradientHero,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppColors.glowPurple,
                              ),
                              child: const Text(
                                'WALLVAULT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('PRO', style: TextStyle(fontSize: 10, color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Curated Wallpapers', style: AppTypography.h1),
                      ],
                    ),

                    Row(
                      children: [
                        // Search Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.bgElevated),
                            ),
                            child: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 20),
                          ),
                          onPressed: () => context.push(AppRoutes.search),
                        ),
                        const SizedBox(width: 8),
                        // Saved / Favorites Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.bgElevated),
                            ),
                            child: const Icon(Icons.favorite_rounded, color: AppColors.accentPurple, size: 20),
                          ),
                          onPressed: () => context.push(AppRoutes.profile),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Top Navigation Tabs Row (Trending, Fresh, Popular) ─────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final isActive = _selectedTabIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Text('🔥 ', style: TextStyle(fontSize: 14)),
                                Text(
                                  _tabs[index],
                                  style: TextStyle(
                                    color: isActive ? AppColors.textPrimary : AppColors.textMuted,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Indicator bar
                            Container(
                              height: 3,
                              width: 36,
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
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final item = displayItems[index];
                        return GestureDetector(
                          onTap: () => context.push(AppRoutes.wallpaperDetailPath(item.id)),
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: AppCachedImage(
                                      imageUrl: item.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
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
                                        color: item.isPremium ? AppColors.accentGold : AppColors.accentPurple,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        item.isPremium ? 'PREMIUM' : 'TRENDING',
                                        style: const TextStyle(
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
                      return GestureDetector(
                        onTap: () => context.push(AppRoutes.wallpaperDetailPath(item.id)),
                        child: Container(
                          height: heights[index % heights.length],
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: AppCachedImage(
                                    imageUrl: item.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.isPremium ? 'PREMIUM' : 'FREE',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: AppTypography.h4,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'by ${item.creatorName}',
                                        style: AppTypography.creatorName.copyWith(fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                    return GestureDetector(
                      onTap: () => context.push(AppRoutes.wallpaperDetailPath(item.id)),
                      child: Container(
                        height: heights[index % heights.length],
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                          image: DecorationImage(
                            image: item.imageUrl.startsWith('assets/')
                                ? AssetImage(item.imageUrl) as ImageProvider
                                : NetworkImage(item.imageUrl) as ImageProvider,
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
                                  item.isPremium ? '₹${item.price.toInt()}' : 'FREE',
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
                                      CircleAvatar(
                                        radius: 7,
                                        backgroundColor: AppColors.bgElevated,
                                        backgroundImage: item.creatorAvatarUrl.isNotEmpty
                                            ? NetworkImage(item.creatorAvatarUrl)
                                            : null,
                                        child: item.creatorAvatarUrl.isEmpty
                                            ? Text(
                                                item.creatorName.isNotEmpty ? item.creatorName[0].toUpperCase() : 'C',
                                                style: const TextStyle(fontSize: 8, color: Colors.white),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                item.creatorName,
                                                style: AppTypography.creatorName.copyWith(fontSize: 10),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (item.isCreatorVerified) ...[
                                              const SizedBox(width: 2),
                                              const Icon(Icons.verified_rounded, color: AppColors.accentCyan, size: 10),
                                            ],
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
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
