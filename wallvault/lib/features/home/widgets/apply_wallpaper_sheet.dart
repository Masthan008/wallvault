import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/gradient_button.dart';

/// S10 — Apply Wallpaper modal bottom sheet.
class ApplyWallpaperSheet extends StatefulWidget {
  final String wallpaperId;
  const ApplyWallpaperSheet({super.key, required this.wallpaperId});

  @override
  State<ApplyWallpaperSheet> createState() => _ApplyWallpaperSheetState();
}

class _ApplyWallpaperSheetState extends State<ApplyWallpaperSheet> {
  int _selectedScreen = 0; // 0: Home, 1: Lock, 2: Both

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
          Text('Preview & Apply', style: AppTypography.h3),
          const SizedBox(height: 16),

          // Side-by-side preview cards
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedScreen = 0),
                  child: _buildPreviewFrame(
                    title: 'Home Screen',
                    isSelected: _selectedScreen == 0,
                    icon: Icons.home_rounded,
                  ),
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
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Actions
          GradientButton(
            label: _selectedScreen == 0
                ? 'Apply to Home Screen'
                : _selectedScreen == 1
                    ? 'Apply to Lock Screen'
                    : 'Apply to Both',
            onPressed: () {
              // TODO: Apply wallpaper to device using wallpaper manager
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wallpaper applied successfully!'),
                  backgroundColor: AppColors.accentSuccess,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
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
          // Background placeholder gradient
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientHero,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.accentPurple : AppColors.textMuted, size: 32),
              const SizedBox(height: 8),
              Text(title, style: AppTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
