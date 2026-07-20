import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/gradient_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import '../../../providers/wallpaper_provider.dart';

/// S10 — Apply Wallpaper modal bottom sheet with spring animations and staggered preview entry.
class ApplyWallpaperSheet extends ConsumerStatefulWidget {
  final String wallpaperId;
  final String imageUrl;
  const ApplyWallpaperSheet({super.key, required this.wallpaperId, required this.imageUrl});

  @override
  ConsumerState<ApplyWallpaperSheet> createState() => _ApplyWallpaperSheetState();
}

class _ApplyWallpaperSheetState extends ConsumerState<ApplyWallpaperSheet> {
  int _selectedScreen = 0; // 0: Home, 1: Lock, 2: Both
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Preview & Apply', style: AppTypography.h3)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.1),
          const SizedBox(height: 16),

          // Side-by-side preview cards with 150ms stagger scale animation (S10)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedScreen = 0),
                  child: _buildPreviewFrame(
                    title: 'Home Screen',
                    isSelected: _selectedScreen == 0,
                    icon: Icons.home_rounded,
                  )
                      .animate()
                      .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 300.ms),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedScreen = 1),
                  child: _buildPreviewFrame(
                    title: 'Lock Screen',
                    isSelected: _selectedScreen == 1,
                    icon: Icons.lock_rounded,
                  )
                      .animate(delay: 150.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 300.ms),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedScreen = 2),
                  child: _buildPreviewFrame(
                    title: 'Both',
                    isSelected: _selectedScreen == 2,
                    icon: Icons.phonelink_setup_rounded,
                  )
                      .animate(delay: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 300.ms),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action button
          _isApplying
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
              : GradientButton(
                  label: _selectedScreen == 0
                      ? 'Apply to Home Screen'
                      : _selectedScreen == 1
                          ? 'Apply to Lock Screen'
                          : 'Apply to Both',
                  onPressed: () async {
                    setState(() => _isApplying = true);
                    
                    try {
                      var target = WallpaperTarget.home;
                      if (_selectedScreen == 1) target = WallpaperTarget.lock;
                      if (_selectedScreen == 2) target = WallpaperTarget.both;
                      
                      await AsyncWallpaper.setWallpaper(
                        WallpaperRequest(
                          source: widget.imageUrl,
                          sourceType: WallpaperSourceType.url,
                          target: target,
                          goToHome: false,
                        )
                      );
                      
                      // Track metric (treat as a download/apply)
                      await ref.read(wallpaperRepositoryProvider).incrementDownloads(widget.wallpaperId);
                      ref.invalidate(wallpaperDetailProvider(widget.wallpaperId));

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wallpaper applied successfully!'),
                            backgroundColor: AppColors.accentSuccess,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to apply wallpaper: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
          
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ).animate(delay: 400.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildPreviewFrame({
    required String title,
    required bool isSelected,
    required IconData icon,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.accentPurple : AppColors.bgElevated,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppColors.glowPurple : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blurred wallpaper background mockup
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=150',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.accentPurple : AppColors.textMuted, size: 36),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          // Checkmark overlay for selection
          if (isSelected)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.check_circle_rounded, color: AppColors.accentPurple, size: 20),
            ),
        ],
      ),
    );
  }
}
