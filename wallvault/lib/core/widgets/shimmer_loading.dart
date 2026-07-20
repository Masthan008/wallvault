import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shimmer placeholder box — used as loading skeleton.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.radiusCard,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.bgElevated,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the wallpaper masonry grid.
class WallpaperGridShimmer extends StatelessWidget {
  final int itemCount;

  const WallpaperGridShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Wrap(
        spacing: AppSpacing.gridSpacing,
        runSpacing: AppSpacing.gridSpacing,
        children: List.generate(itemCount, (index) {
          final heights = [220.0, 280.0, 200.0, 260.0, 240.0, 300.0];
          return SizedBox(
            width: (MediaQuery.of(context).size.width -
                    AppSpacing.screenPadding * 2 -
                    AppSpacing.gridSpacing) /
                2,
            height: heights[index % heights.length],
            child: const ShimmerBox(),
          );
        }),
      ),
    );
  }
}

/// Shimmer skeleton for a list item row.
class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: 8,
      ),
      child: Row(
        children: [
          const ShimmerBox(
            width: 48,
            height: 48,
            borderRadius: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(height: 14, borderRadius: 4),
                SizedBox(height: 8),
                ShimmerBox(height: 10, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
