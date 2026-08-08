import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/effects/app_toast.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import '../../../providers/wallpaper_provider.dart';
import '../../../providers/auth_provider.dart';

/// S10 — Apply Wallpaper & Live Phone Mockup Preview Modal
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

  void _openFullScreenLivePreview(BuildContext context, int mode) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Stack(
          children: [
            // Full screen image
            Positioned.fill(
              child: widget.imageUrl.startsWith('assets/')
                  ? Image.asset(widget.imageUrl, fit: BoxFit.cover)
                  : Image.network(widget.imageUrl, fit: BoxFit.cover),
            ),

            // Simulated OS Overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: mode == 1 || mode == 2
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('9:41', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Row(
                                    children: [
                                      Icon(Icons.wifi_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Icon(Icons.battery_full_rounded, color: Colors.white, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 60),
                              const Icon(Icons.lock_rounded, color: Colors.white70, size: 22),
                              const SizedBox(height: 8),
                              const Text('Monday, July 27', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              const Text('09:41', style: TextStyle(color: Colors.white, fontSize: 68, fontWeight: FontWeight.w200, letterSpacing: -2)),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                                    child: const Icon(Icons.flashlight_on_rounded, color: Colors.white, size: 20),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                        : Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('9:41', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Row(
                                    children: [
                                      Icon(Icons.wifi_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Icon(Icons.battery_full_rounded, color: Colors.white, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 60),
                              // Mock App Icons Grid
                              GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 4,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                children: List.generate(8, (i) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: Icon([
                                      Icons.phone_rounded,
                                      Icons.message_rounded,
                                      Icons.camera_rounded,
                                      Icons.settings_rounded,
                                      Icons.photo_library_rounded,
                                      Icons.music_note_rounded,
                                      Icons.map_rounded,
                                      Icons.star_rounded,
                                    ][i], color: Colors.white, size: 24),
                                  );
                                }),
                              ),
                              const Spacer(),
                              // Bottom Dock
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Icons.phone_rounded,
                                    Icons.message_rounded,
                                    Icons.public_rounded,
                                    Icons.camera_alt_rounded,
                                  ].map((ic) => Icon(ic, color: Colors.white, size: 24)).toList(),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            // Top Close Button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Preview & Apply', style: AppTypography.h3)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: -0.1),
              TextButton.icon(
                onPressed: () => _openFullScreenLivePreview(context, _selectedScreen),
                icon: const Icon(Icons.remove_red_eye_rounded, size: 16, color: AppColors.accentCyan),
                label: const Text('Live Mockup', style: TextStyle(fontSize: 12, color: AppColors.accentCyan, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Side-by-side phone mockup frames
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedScreen = 0),
                  child: _buildPreviewFrame(
                    title: 'Home Screen',
                    isSelected: _selectedScreen == 0,
                    icon: Icons.home_rounded,
                    isLock: false,
                  )
                      .animate()
                      .scale(begin: const Offset(0.85, 0.85), duration: 350.ms, curve: Curves.easeOutCubic)
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
                    isLock: true,
                  )
                      .animate(delay: 100.ms)
                      .scale(begin: const Offset(0.85, 0.85), duration: 350.ms, curve: Curves.easeOutCubic)
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
                    isLock: false,
                  )
                      .animate(delay: 200.ms)
                      .scale(begin: const Offset(0.85, 0.85), duration: 350.ms, curve: Curves.easeOutCubic)
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
                          : 'Apply to Both Screens',
                  onPressed: () async {
                    setState(() => _isApplying = true);
                    
                    try {
                      var target = WallpaperTarget.home;
                      if (_selectedScreen == 1) target = WallpaperTarget.lock;
                      if (_selectedScreen == 2) target = WallpaperTarget.both;
                      
                      if (widget.imageUrl.startsWith('assets/')) {
                        final byteData = await rootBundle.load(widget.imageUrl);
                        final tempDir = await getTemporaryDirectory();
                        final tempFile = File('${tempDir.path}/${widget.wallpaperId}.png');
                        await tempFile.writeAsBytes(byteData.buffer.asUint8List());

                        await AsyncWallpaper.setWallpaper(
                          WallpaperRequest(
                            source: tempFile.path,
                            sourceType: WallpaperSourceType.file,
                            target: target,
                            goToHome: false,
                          ),
                        );
                      } else {
                        await AsyncWallpaper.setWallpaper(
                          WallpaperRequest(
                            source: widget.imageUrl,
                            sourceType: WallpaperSourceType.url,
                            target: target,
                            goToHome: false,
                          ),
                        );
                      }
                      
                      // Track metric (increment downloads/applies)
                      await ref.read(wallpaperRepositoryProvider).incrementDownloads(widget.wallpaperId);
                      
                      // Update user downloads history
                      final user = ref.read(userProfileProvider).value;
                      if (user != null) {
                        final userRepo = ref.read(userRepositoryProvider);
                        if (!user.downloads.contains(widget.wallpaperId)) {
                          final updatedDownloads = List<String>.from(user.downloads)..add(widget.wallpaperId);
                          await userRepo.updateUser(user.uid, {'downloads': updatedDownloads});
                          ref.invalidate(userProfileProvider);
                        }
                      }
                      
                      ref.invalidate(wallpaperDetailProvider(widget.wallpaperId));

                      if (context.mounted) {
                        Navigator.pop(context);
                        showAppToast(context, 'Wallpaper applied successfully!', type: ToastType.success);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        showAppToast(context, 'Failed to apply wallpaper: $e', type: ToastType.error);
                      }
                    }
                  },
                ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
          
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ).animate(delay: 350.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildPreviewFrame({
    required String title,
    required bool isSelected,
    required IconData icon,
    required bool isLock,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.accentPurple : AppColors.bgElevated,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppColors.glowPurple : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Actual Wallpaper Image Mockup
            Positioned.fill(
              child: widget.imageUrl.startsWith('assets/')
                  ? Image.asset(widget.imageUrl, fit: BoxFit.cover)
                  : Image.network(widget.imageUrl, fit: BoxFit.cover),
            ),

            // Mock Phone UI Overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: isSelected ? 0.25 : 0.45),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Mock Phone Notch / Time
                    Text('09:41', style: TextStyle(fontSize: isLock ? 18 : 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    if (isLock) ...[
                      const SizedBox(height: 2),
                      const Text('Mon, Jul 27', style: TextStyle(fontSize: 8, color: Colors.white70)),
                    ],
                    const Spacer(),
                    if (!isLock) ...[
                      // Mock mini app dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (_) => Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(2)),
                        )),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ),

            // Selection Checkmark Banner
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.accentPurple,
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 12),
                ),
              ),

            Positioned(
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
