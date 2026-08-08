import 'package:flutter/material.dart';

import '../../data/models/wallpaper_model.dart';
import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_cached_image.dart';
import 'effects/entrance.dart';

/// Premium wallpaper card with Hero flight, gradient premium border,
/// price badge, creator row and a pulsing like micro-interaction.
class WallpaperCard extends StatefulWidget {
  final WallpaperModel wallpaper;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;
  final int entranceDelayMs;
  final double height;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    this.onTap,
    this.onLike,
    this.isLiked = false,
    this.entranceDelayMs = 0,
    this.height = 240,
  });

  @override
  State<WallpaperCard> createState() => _WallpaperCardState();
}

class _WallpaperCardState extends State<WallpaperCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.wallpaper;
    final premium = w.isPremium;

    return Entrance.pop(
      AnimatedScale(
        scale: _pressed ? 0.965 : 1,
        duration: AppAnimations.micro,
        curve: AppAnimations.easeOutExpo,
        child: SizedBox(
        height: widget.height,
        child: Hero(
        tag: 'wallpaper-image-${w.id}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  gradient: premium
                      ? AppGradients.premiumBorder
                      : AppGradients.glassHairline,
                  boxShadow: premium
                      ? [
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.22),
                            blurRadius: 24,
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.all(premium ? 1.6 : 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusCard - (premium ? 1.6 : 1),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppCachedImage(
                          imageUrl: w.thumbnailTransformed,
                          fit: BoxFit.cover,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusCard),
                        ),
                        // gradient veil for legibility
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Color(0xCC000000),
                              ],
                              stops: [0.35, 0.6, 1.0],
                            ),
                          ),
                        ),
                        // price badge
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusPill),
                              color: premium
                                  ? AppColors.accentGold.withValues(alpha: 0.18)
                                  : Colors.black.withValues(alpha: 0.42),
                              border: Border.all(
                                color: premium
                                    ? AppColors.accentGold.withValues(alpha: 0.55)
                                    : Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Text(
                              premium ? '₹${w.price.toInt()}' : 'FREE',
                              style: AppTypography.caption.copyWith(
                                color: premium
                                    ? AppColors.accentGold
                                    : Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                        // bottom info row
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 8,
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.gradientPremium,
                                ),
                                child: Center(
                                  child: Text(
                                    (w.creatorName.isNotEmpty
                                            ? w.creatorName[0]
                                            : 'W')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  w.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.creatorName.copyWith(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                              _LikeButton(
                                isLiked: widget.isLiked,
                                onTap: widget.onLike,
                              ),
                            ],
                          ),
                        ),
],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
      delayMs: widget.entranceDelayMs,
    );
  }
}

/// Pulse-scaling heart button for the card's like action.
class _LikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback? onTap;

  const _LikeButton({required this.isLiked, this.onTap});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  @override
  Widget build(BuildContext context) {
    final liked = widget.isLiked;
    return GestureDetector(
      onTap: widget.onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: liked ? 1.18 : 1),
        duration: AppAnimations.fast,
        curve: Curves.elasticOut,
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
            ),
            child: Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 15,
              color: liked ? AppColors.accentPurple : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}