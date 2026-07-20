import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glow_input.dart';
import '../../../core/router/routes.dart';
import '../../../providers/wallpaper_provider.dart';

/// S11 — Search screen with real Firestore query filters.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";

  static const _trendingTags = [
    'Nature', 'Anime', 'Abstract', 'Space', 'Cars', 'Sunset', 'Cyberpunk', 'Minimalist'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchWallpapersProvider(_searchQuery));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search Input Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search Catalog', style: AppTypography.h1)
                        .animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 16),
                    GlowInput(
                      controller: _searchController,
                      hintText: 'Search wallpapers or tags...',
                      prefixIcon: Icons.search_rounded,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 16),
                    
                    // Filter row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Free', 'Premium'].map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = filter),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accentPurple : AppColors.bgCard,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected ? null : Border.all(color: AppColors.bgElevated),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ),

            // Dynamic Search Grid Results or Popular Tags
            _searchQuery.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text('Trending Tags', style: AppTypography.h3),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _trendingTags.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () {
                                  _searchController.text = entry.value;
                                  setState(() {
                                    _searchQuery = entry.value;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgCard,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                                    border: Border.all(color: AppColors.bgElevated, width: 0.5),
                                  ),
                                  child: Text(
                                    '#${entry.value}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.accentCyan,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                                  .animate(delay: (50 * entry.key).ms)
                                  .fadeIn()
                                  .scale(begin: const Offset(0.9, 0.9));
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          Text('Recent Searches', style: AppTypography.h3),
                          const SizedBox(height: 12),
                          ...['Sunset', 'AMOLED', 'Madara'].map(
                            (query) => ListTile(
                              leading: const Icon(Icons.history_rounded,
                                  color: AppColors.textMuted, size: 20),
                              title: Text(query, style: AppTypography.bodyMedium),
                              trailing: const Icon(Icons.north_west_rounded,
                                  color: AppColors.textMuted, size: 16),
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                _searchController.text = query;
                                setState(() {
                                  _searchQuery = query;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : searchResults.when(
                    data: (wallpapers) {
                      // Apply client-side Premium/Free filters on top of query results
                      final filteredList = wallpapers.where((w) {
                        if (_selectedFilter == 'Free') return !w.isPremium;
                        if (_selectedFilter == 'Premium') return w.isPremium;
                        return true;
                      }).toList();

                      if (filteredList.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(48.0),
                              child: Text(
                                'No prebuilt wallpapers match this search.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.gridSpacing,
                          crossAxisSpacing: AppSpacing.gridSpacing,
                          childCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final w = filteredList[index];
                            final heights = [240.0, 290.0, 220.0, 270.0];
                            return GestureDetector(
                              onTap: () => context.push(AppRoutes.wallpaperDetailPath('grid_$index')),
                              child: Container(
                                height: heights[index % heights.length],
                                decoration: BoxDecoration(
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: AssetImage(w.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                          gradient: LinearGradient(
                                            colors: [Colors.transparent, Colors.black87],
                                            begin: Alignment.center,
                                            end: Alignment.bottomCenter,
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
                                          Text(w.name, style: AppTypography.h4),
                                          Text('by ${w.creatorName}', style: AppTypography.creatorName.copyWith(fontSize: 10)),
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
                    loading: () => const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: CircularProgressIndicator(
                            color: AppColors.accentPurple,
                          ),
                        ),
                      ),
                    ),
                    error: (e, s) => const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Text('Search failed to complete.'),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
