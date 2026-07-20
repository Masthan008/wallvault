import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../widgets/apply_wallpaper_sheet.dart';
import '../../../providers/wallpaper_provider.dart';

/// S09 — Wallpaper detail with full-screen preview, spring animation overlays, and animated morphing download CTA.
class WallpaperDetailScreen extends ConsumerWidget {
  final String wallpaperId;
  const WallpaperDetailScreen({super.key, required this.wallpaperId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpaperAsync = ref.watch(wallpaperDetailProvider(wallpaperId));

    return wallpaperAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentPurple),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Text('Error loading details: $err', style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (wallpaper) {
        if (wallpaper == null) {
          return const Scaffold(
            backgroundColor: AppColors.bgPrimary,
            body: Center(
              child: Text('Wallpaper not found.', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        final imagePath = wallpaper.imageUrl;

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
              // Full-screen image preview
              Positioned.fill(
                child: imagePath.startsWith('assets/')
                    ? Image.asset(imagePath, fit: BoxFit.cover)
                    : Image.network(imagePath, fit: BoxFit.cover),
              ),

              // Bottom Vignette overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 340,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: 24,
                  ),
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
                        Text(wallpaper.name, style: AppTypography.h2),
                        const SizedBox(height: 4),
                        Text('by ${wallpaper.creatorName}',
                            style: AppTypography.creatorName),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _InfoChip(Icons.photo_size_select_actual_rounded,
                                wallpaper.resolution),
                            const SizedBox(width: 8),
                            _InfoChip(Icons.aspect_ratio_rounded, '9:16'),
                            const SizedBox(width: 8),
                            _InfoChip(Icons.download_rounded, '${wallpaper.downloads}'),
                            const SizedBox(width: 8),
                            _InfoChip(Icons.star_rounded, '${wallpaper.rating}'),
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
                            
                            // S09: Morphing download button with confetti burst simulator
                            AnimatedDownloadButton(wallpaperId: wallpaperId),
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
      },
    );
  }
}


class AnimatedDownloadButton extends StatefulWidget {
  final String wallpaperId;
  const AnimatedDownloadButton({super.key, required this.wallpaperId});

  @override
  State<AnimatedDownloadButton> createState() => _AnimatedDownloadButtonState();
}

class _AnimatedDownloadButtonState extends State<AnimatedDownloadButton> with SingleTickerProviderStateMixin {
  int _downloadState = 0; // 0: Idle, 1: Loading, 2: Complete
  double _loadProgress = 0.0;
  final List<_Confetti> _confetti = [];
  bool _burstRunning = false;

  void _triggerDownload() {
    if (_downloadState != 0) return;
    
    setState(() {
      _downloadState = 1;
      _loadProgress = 0.0;
    });

    // Simulate downloading progress over 2s
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      setState(() {
        _loadProgress += 0.05;
      });
      if (_loadProgress >= 1.0) {
        _onDownloadComplete();
        return false;
      }
      return true;
    });
  }

  void _onDownloadComplete() {
    setState(() {
      _downloadState = 2;
    });

    // Fire confetti particles
    final rand = Random();
    setState(() {
      _burstRunning = true;
      for (int i = 0; i < 30; i++) {
        _confetti.add(
          _Confetti(
            x: 0,
            y: 0,
            angle: rand.nextDouble() * 2 * pi,
            speed: rand.nextDouble() * 5 + 3,
            size: rand.nextDouble() * 6 + 3,
            color: [AppColors.accentPurple, AppColors.accentCyan, AppColors.accentGold][rand.nextInt(3)],
          ),
        );
      }
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) return false;
      setState(() {
        for (var p in _confetti) {
          p.update();
        }
      });
      return _burstRunning;
    });

    // Reset back to idle after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _downloadState = 0;
          _confetti.clear();
          _burstRunning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Confetti burst particles
        if (_confetti.isNotEmpty)
          ..._confetti.map((c) => Positioned(
                left: c.x,
                top: c.y,
                child: Container(
                  width: c.size,
                  height: c.size,
                  decoration: BoxDecoration(
                    color: c.color.withOpacity(c.alpha),
                    shape: BoxShape.circle,
                  ),
                ),
              )),

        // Main action container button
        GestureDetector(
          onTap: _triggerDownload,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: AppSpacing.buttonHeight,
            height: AppSpacing.buttonHeight,
            decoration: BoxDecoration(
              color: _downloadState == 2 ? AppColors.accentSuccess.withOpacity(0.2) : AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              border: Border.all(
                color: _downloadState == 2 ? AppColors.accentSuccess : AppColors.bgElevated,
                width: _downloadState == 2 ? 2 : 1,
              ),
            ),
            child: Center(
              child: _buildButtonContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonContent() {
    if (_downloadState == 0) {
      return const Icon(Icons.download_rounded, color: AppColors.accentCyan);
    } else if (_downloadState == 1) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          value: _loadProgress,
          strokeWidth: 2,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
        ),
      );
    } else {
      return const Icon(Icons.check_circle_rounded, color: AppColors.accentSuccess);
    }
  }
}

class _Confetti {
  double x;
  double y;
  final double angle;
  final double speed;
  final double size;
  final Color color;
  double alpha = 1.0;

  _Confetti({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  void update() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;
    alpha = (alpha - 0.04).clamp(0.0, 1.0);
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
