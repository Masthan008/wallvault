import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/wallpaper_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'shimmer_loading.dart';

/// Premium wallpaper card with gradient overlay, price badge, and creator info.
class WallpaperCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    this.onTap,
    this.onLike,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          boxShadow: AppColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Image ──────────────────────────────────────
              CachedNetworkImage(
                imageUrl: wallpaper.thumbnailTransformed,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerBox(),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.bgCard,
                  child: const Icon(Icons.broken_image_rounded,
                      color: AppColors.textMuted, size: 32),
                ),
              ),

              // ── Gradient overlay ───────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Price Badge ────────────────────────────────
              if (wallpaper.isPremium)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientGold,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      '₹${wallpaper.price.toInt()}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentSuccess.withValues(alpha: 0.9),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: const Text(
                      'FREE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

              // ── Like Button ────────────────────────────────
              if (onLike != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: GestureDetector(
                    onTap: onLike,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isLiked
                            ? AppColors.accentError
                            : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

              // ── Bottom Info ────────────────────────────────
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallpaper.name,
                      style: AppTypography.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 7,
                          backgroundColor: AppColors.bgElevated,
                          backgroundImage: wallpaper.creatorAvatarUrl.isNotEmpty
                              ? NetworkImage(wallpaper.creatorAvatarUrl)
                              : null,
                          child: wallpaper.creatorAvatarUrl.isEmpty
                              ? Text(
                                  wallpaper.creatorName.isNotEmpty ? wallpaper.creatorName[0].toUpperCase() : 'C',
                                  style: const TextStyle(fontSize: 8, color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            wallpaper.creatorName,
                            style: AppTypography.creatorName.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (wallpaper.isCreatorVerified) ...[
                          const SizedBox(width: 2),
                          const Icon(Icons.verified_rounded, color: AppColors.accentCyan, size: 10),
                        ],
                        const Spacer(),
                        Icon(Icons.download_rounded,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          _formatCount(wallpaper.downloads),
                          style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
