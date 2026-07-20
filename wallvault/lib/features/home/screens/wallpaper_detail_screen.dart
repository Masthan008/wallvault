import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../widgets/apply_wallpaper_sheet.dart';

/// S09 — Wallpaper detail with full-screen preview and actions.
class WallpaperDetailScreen extends StatelessWidget {
  final String wallpaperId;
  const WallpaperDetailScreen({super.key, required this.wallpaperId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_rounded,
                  color: Colors.white, size: 20),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border_rounded,
                  color: Colors.white, size: 20),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen wallpaper preview (placeholder gradient)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentPurple.withValues(alpha: 0.4),
                  AppColors.bgPrimary,
                  AppColors.accentCyan.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: const Center(
              child: Icon(Icons.wallpaper_rounded,
                  color: AppColors.textMuted, size: 64),
            ),
          ),
          // Bottom info panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bgPrimary.withValues(alpha: 0.9),
                    AppColors.bgPrimary,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 60),
                    Text('Wallpaper Preview', style: AppTypography.h2),
                    const SizedBox(height: 4),
                    Text('by Creator Name',
                        style: AppTypography.creatorName),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoChip(Icons.photo_size_select_actual_rounded,
                            '4K'),
                        const SizedBox(width: 8),
                        _InfoChip(Icons.aspect_ratio_rounded, '9:16'),
                        const SizedBox(width: 8),
                        _InfoChip(Icons.download_rounded, '12.4K'),
                        const SizedBox(width: 8),
                        _InfoChip(Icons.star_rounded, '4.8'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: 'Apply Wallpaper',
                            icon: Icons.wallpaper_rounded,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => ApplyWallpaperSheet(
                                  wallpaperId: wallpaperId,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: AppSpacing.buttonHeight,
                          height: AppSpacing.buttonHeight,
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusButton),
                            border: Border.all(color: AppColors.bgElevated),
                          ),
                          child: const Icon(Icons.download_rounded,
                              color: AppColors.accentCyan),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
