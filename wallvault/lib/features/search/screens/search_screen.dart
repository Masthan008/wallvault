import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glow_input.dart';

/// S11 — Search screen with filters and recent searches.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const _trendingTags = [
    'Dark AMOLED', 'Cyberpunk', 'Minimal', 'Nature 4K', 'Anime',
    'Gradient', 'Space', 'Abstract', 'Cars', 'Neon'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search', style: AppTypography.h1)
                        .animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 16),
                    const GlowInput(
                      hintText: 'Search wallpapers, creators, tags...',
                      prefixIcon: Icons.search_rounded,
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 24),
                    // Filter chips
                    Row(
                      children: [
                        _FilterChip(label: 'All', isSelected: true),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'Free'),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'Premium'),
                        const SizedBox(width: 8),
                        _FilterChip(label: '4K+'),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'OLED'),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 32),
                    Text('Trending Tags', style: AppTypography.h3)
                        .animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _trendingTags.asMap().entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusPill),
                            border: Border.all(
                                color: AppColors.bgElevated, width: 0.5),
                          ),
                          child: Text(
                            '#${entry.value}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accentCyan,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                            .animate(delay: (50 * entry.key).ms)
                            .fadeIn()
                            .scale(begin: const Offset(0.9, 0.9));
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    Text('Recent Searches', style: AppTypography.h3)
                        .animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 12),
                    ...['Sunset Mountains', 'AMOLED Black', 'Anime Girl'].map(
                      (query) => ListTile(
                        leading: const Icon(Icons.history_rounded,
                            color: AppColors.textMuted, size: 20),
                        title: Text(query, style: AppTypography.bodyMedium),
                        trailing: const Icon(Icons.north_west_rounded,
                            color: AppColors.textMuted, size: 16),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentPurple : AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: isSelected
            ? null
            : Border.all(color: AppColors.bgElevated, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
