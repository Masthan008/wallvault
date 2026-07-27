import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:typed_data';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../widgets/apply_wallpaper_sheet.dart';
import '../../../core/router/routes.dart';
import '../../../providers/wallpaper_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/review_provider.dart';
import '../../../data/models/review_model.dart';
import '../../../data/services/razorpay_service.dart';
import '../../../data/models/wallpaper_model.dart';
import '../../../core/widgets/app_cached_image.dart';

/// S09 — Wallpaper detail with full-screen preview, spring animation overlays, and animated morphing download CTA.
class WallpaperDetailScreen extends ConsumerStatefulWidget {
  final String wallpaperId;
  const WallpaperDetailScreen({super.key, required this.wallpaperId});

  @override
  ConsumerState<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends ConsumerState<WallpaperDetailScreen> {
  bool _isFullView = false;

  @override
  Widget build(BuildContext context) {
    final wallpaperAsync = ref.watch(wallpaperDetailProvider(widget.wallpaperId));
    final userAsync = ref.watch(userProfileProvider);

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

        return userAsync.when(
          loading: () => const Scaffold(
            backgroundColor: AppColors.bgPrimary,
            body: Center(child: CircularProgressIndicator(color: AppColors.accentPurple)),
          ),
          error: (err, stack) => Scaffold(
            backgroundColor: AppColors.bgPrimary,
            body: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
          ),
          data: (user) {
            final isSaved = user?.favorites.contains(widget.wallpaperId) ?? false;

            return Scaffold(
              backgroundColor: AppColors.bgPrimary,
              extendBodyBehindAppBar: true,
              appBar: _isFullView
                  ? null
                  : AppBar(
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
                        // Toggle Full View Clean Wallpaper Mode
                        IconButton(
                          tooltip: 'Toggle Clean Image View',
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFullView ? Icons.visibility_off_rounded : Icons.remove_red_eye_rounded,
                              color: AppColors.accentCyan,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            setState(() => _isFullView = !_isFullView);
                          },
                        ),
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
                          onPressed: () {
                            Share.share('Check out this amazing wallpaper: ${wallpaper.name} on WallVault!\n\n${wallpaper.imageUrl}');
                          },
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isSaved ? AppColors.accentPurple : Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            if (user != null) {
                              final userRepo = ref.read(userRepositoryProvider);
                              final wallpaperRepo = ref.read(wallpaperRepositoryProvider);
                              final updatedFavorites = List<String>.from(user.favorites);
                              final willBeSaved = !isSaved;

                              if (isSaved) {
                                updatedFavorites.remove(widget.wallpaperId);
                              } else {
                                updatedFavorites.add(widget.wallpaperId);
                              }

                              // Immediate feedback Toast
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    willBeSaved ? 'Saved to collection ❤️' : 'Removed from Saved',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );

                              // Fire and forget asynchronous background updates
                              Future.microtask(() async {
                                if (isSaved) {
                                  await wallpaperRepo.decrementLikes(widget.wallpaperId);
                                } else {
                                  await wallpaperRepo.incrementLikes(widget.wallpaperId);
                                }
                                await userRepo.updateUser(user.uid, {'favorites': updatedFavorites});
                                ref.invalidate(userProfileProvider);
                                ref.invalidate(savedWallpapersProvider);
                                ref.invalidate(wallpaperDetailProvider(widget.wallpaperId));
                              });
                            }
                          },
                        ),
                      ],
                    ),
              body: Stack(
                children: [
                  // Full-screen image preview (Tap to toggle full clean mode)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isFullView = !_isFullView);
                      },
                      child: AppCachedImage(
                        imageUrl: imagePath,
                        fit: BoxFit.cover,
                        memCacheWidth: 1080,
                        memCacheHeight: 1920,
                      ),
                    ),
                  ),

                  // Scrollable Content Overlay with Glassmorphic Bottom Card
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: _isFullView,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: _isFullView ? 0.0 : 1.0,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // Top transparent spacer allowing 60% full wallpaper preview
                              SizedBox(height: MediaQuery.of(context).size.height * 0.58),

                              // Main Details & Reviews Container
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.screenPadding,
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bgPrimary.withValues(alpha: 0.95),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      blurRadius: 24,
                                      offset: const Offset(0, -6),
                                    )
                                  ],
                                ),
                                child: SafeArea(
                                  top: false,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(wallpaper.name, style: AppTypography.h2),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () {
                                          context.push(AppRoutes.creatorProfilePath(wallpaper.creatorId));
                                        },
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 11,
                                              backgroundColor: AppColors.bgElevated,
                                              backgroundImage: wallpaper.creatorAvatarUrl.isNotEmpty
                                                  ? NetworkImage(wallpaper.creatorAvatarUrl)
                                                  : null,
                                              child: wallpaper.creatorAvatarUrl.isEmpty
                                                  ? Text(
                                                      wallpaper.creatorName.isNotEmpty ? wallpaper.creatorName[0].toUpperCase() : 'C',
                                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'by ${wallpaper.creatorName}',
                                                style: AppTypography.creatorName.copyWith(
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: AppColors.accentCyan,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (wallpaper.isCreatorVerified) ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.verified_rounded, color: AppColors.accentCyan, size: 14),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _InfoChip(Icons.photo_size_select_actual_rounded, wallpaper.resolution),
                                          const SizedBox(width: 8),
                                          _InfoChip(Icons.aspect_ratio_rounded, '9:16'),
                                          const SizedBox(width: 8),
                                          _InfoChip(Icons.download_rounded, '${wallpaper.downloads}'),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              if (user != null) {
                                                _showRatingDialog(context, ref, wallpaper);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Please log in to rate wallpapers')),
                                                );
                                              }
                                            },
                                            child: _InfoChip(Icons.star_rounded, '${wallpaper.rating.toStringAsFixed(1)} (${wallpaper.ratingCount})'),
                                          ),
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
                                                    wallpaperId: widget.wallpaperId,
                                                    imageUrl: wallpaper.imageUrl,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          AnimatedDownloadButton(
                                            wallpaper: wallpaper,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 28),
                                      WallpaperReviewsSection(wallpaperId: widget.wallpaperId),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating Clean View Indicator Pill (Visible when in full clean mode)
                  if (_isFullView)
                    Positioned(
                      bottom: 36,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => setState(() => _isFullView = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.5), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  blurRadius: 20,
                                )
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.remove_red_eye_rounded, color: AppColors.accentCyan, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Clean View Mode — Tap to restore details',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AnimatedDownloadButton extends ConsumerStatefulWidget {
  final WallpaperModel wallpaper;
  const AnimatedDownloadButton({
    super.key,
    required this.wallpaper,
  });

  @override
  ConsumerState<AnimatedDownloadButton> createState() => _AnimatedDownloadButtonState();
}

class _AnimatedDownloadButtonState extends ConsumerState<AnimatedDownloadButton> with SingleTickerProviderStateMixin {
  int _downloadState = 0; // 0: Idle, 1: Loading, 2: Complete
  double _loadProgress = 0.0;
  final List<_Confetti> _confetti = [];
  bool _burstRunning = false;
  final RazorpayService _razorpayService = RazorpayService();

  @override
  void initState() {
    super.initState();
    _razorpayService.init(
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentError,
      onExternalWallet: _onExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    _startActualDownload();
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() {
      _downloadState = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: [${response.code}] ${response.message}')),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _triggerDownload() async {
    if (_downloadState != 0) return;

    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to download wallpapers')),
      );
      return;
    }

    if (widget.wallpaper.isPremium) {
      final isPro = user.subscription.isPro;
      final alreadyDownloaded = user.downloads.contains(widget.wallpaper.id);

      if (!isPro && !alreadyDownloaded) {
        setState(() {
          _downloadState = 1;
          _loadProgress = 0.0;
        });

        try {
          _razorpayService.openCheckout(
            amount: widget.wallpaper.price,
            name: 'WallVault Premium',
            description: 'Buy Wallpaper: ${widget.wallpaper.name}',
            email: user.email.isNotEmpty ? user.email : 'user@example.com',
            contact: user.phone.isNotEmpty ? user.phone : '9999999999',
          );
        } catch (e) {
          setState(() {
            _downloadState = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to initiate checkout: $e')),
          );
        }
        return;
      }
    }

    _startActualDownload();
  }

  void _startActualDownload() async {
    setState(() {
      _downloadState = 1;
      _loadProgress = 0.1;
    });

    try {
      // 1. Download image bytes
      final Uint8List imageBytes;
      if (widget.wallpaper.imageUrl.startsWith('assets/')) {
        final byteData = await rootBundle.load(widget.wallpaper.imageUrl);
        imageBytes = byteData.buffer.asUint8List();
      } else {
        final response = await Dio().get(
          widget.wallpaper.imageUrl,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (count, total) {
            if (total > 0 && mounted) {
              setState(() {
                _loadProgress = 0.1 + (count / total * 0.8);
              });
            }
          },
        );
        imageBytes = Uint8List.fromList(response.data);
      }

      // 2. Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: "WallVault_${widget.wallpaper.id}",
      );

      if (mounted && result['isSuccess'] == true) {
        setState(() => _loadProgress = 1.0);
        
        // 3. Increment downloads in DB
        await ref.read(wallpaperRepositoryProvider).incrementDownloads(widget.wallpaper.id);
        
        // Update user profile downloads list
        final user = ref.read(userProfileProvider).value;
        if (user != null) {
          final userRepo = ref.read(userRepositoryProvider);
          if (!user.downloads.contains(widget.wallpaper.id)) {
            final updatedDownloads = List<String>.from(user.downloads)..add(widget.wallpaper.id);
            await userRepo.updateUser(user.uid, {'downloads': updatedDownloads});
            ref.invalidate(userProfileProvider);
          }
        }

        ref.invalidate(wallpaperDetailProvider(widget.wallpaper.id));

        _onDownloadComplete();
      } else {
        throw Exception("Failed to save image");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadState = 0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download wallpaper')),
        );
      }
    }
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

void _showRatingDialog(BuildContext context, WidgetRef ref, dynamic wallpaper) {
  int selectedRating = 5;
  final ratingLabels = ['Poor', 'Fair', 'Good Wallpaper', 'Great Art!', 'Masterpiece ⭐'];

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: AppColors.bgElevated),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text('Rate This Wallpaper', style: AppTypography.h3),
                  const SizedBox(height: 4),
                  Text(
                    'Your feedback helps creators grow!',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Stars Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      final isSelected = starNum <= selectedRating;
                      return IconButton(
                        iconSize: 36,
                        icon: AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                            color: isSelected ? AppColors.accentGold : AppColors.textMuted,
                          ),
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = starNum;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating Feedback Label
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      ratingLabels[selectedRating - 1],
                      key: ValueKey(selectedRating),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGold.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          label: 'Submit Rating',
                          height: 44,
                          gradient: AppColors.gradientHero,
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final repo = ref.read(wallpaperRepositoryProvider);
                            final currentTotal = wallpaper.rating * wallpaper.ratingCount;
                            final newCount = wallpaper.ratingCount + 1;
                            final newRating = (currentTotal + selectedRating) / newCount;
                            
                            await repo.updateRating(wallpaper.id, newRating, newCount);
                            ref.invalidate(wallpaperDetailProvider(wallpaper.id));
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Rated ${wallpaper.name} $selectedRating ⭐!'),
                                  backgroundColor: AppColors.accentSuccess,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class WallpaperReviewsSection extends ConsumerStatefulWidget {
  final String wallpaperId;
  const WallpaperReviewsSection({super.key, required this.wallpaperId});

  @override
  ConsumerState<WallpaperReviewsSection> createState() => _WallpaperReviewsSectionState();
}

class _WallpaperReviewsSectionState extends ConsumerState<WallpaperReviewsSection> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  int _selectedRating = 5;
  String? _replyingToId;
  bool _isSubmitting = false;
  bool _isExpanded = true;

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _submitReview({String? parentId}) async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to post a review')),
      );
      return;
    }

    final text = (parentId != null ? _replyController.text : _commentController.text).trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final reviewRepo = ref.read(reviewRepositoryProvider);
      final newReview = ReviewModel(
        id: '',
        wallpaperId: widget.wallpaperId,
        userId: user.uid,
        userName: user.displayName.isNotEmpty ? user.displayName : 'Anonymous User',
        userAvatar: user.avatarUrl,
        rating: parentId != null ? 0.0 : _selectedRating.toDouble(),
        comment: text,
        parentId: parentId,
        createdAt: DateTime.now(),
      );

      await reviewRepo.addReview(newReview);

      if (parentId != null) {
        _replyController.clear();
        _replyingToId = null;
      } else {
        _commentController.clear();
        _selectedRating = 5;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(parentId != null ? 'Reply posted!' : 'Review posted successfully!'),
            backgroundColor: AppColors.accentSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post review: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(wallpaperReviewsStreamProvider(widget.wallpaperId));
    final user = ref.watch(userProfileProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.rate_review_rounded, color: AppColors.accentPurple, size: 20),
                  const SizedBox(width: 8),
                  Text('Reviews & Comments', style: AppTypography.h3),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Text(
                      _isExpanded ? 'Collapse' : 'Expand',
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_isExpanded) ...[

        // Review Input Form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rate this wallpaper:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRating = starIndex),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Icon(
                        starIndex <= _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: starIndex <= _selectedRating ? AppColors.accentGold : Colors.white24,
                        size: 26,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: user != null ? 'Share your thoughts or appreciation...' : 'Log in to leave a review...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.bgElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GradientButton(
                  label: _isSubmitting ? 'Posting...' : 'Post Review',
                  height: 38,
                  width: 130,
                  onPressed: _isSubmitting ? () {} : () => _submitReview(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Real-time Reviews List & Nested Replies
        reviewsAsync.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: AppColors.accentPurple))),
          error: (e, s) => Text('Error loading reviews: $e', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          data: (allReviews) {
            final topLevel = allReviews.where((r) => r.parentId == null).toList();

            if (topLevel.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text('No reviews yet. Be the first to rate & comment!', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topLevel.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = topLevel[index];
                final replies = allReviews.where((r) => r.parentId == review.id).toList();

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.bgElevated,
                            backgroundImage: review.userAvatar.isNotEmpty ? NetworkImage(review.userAvatar) : null,
                            child: review.userAvatar.isEmpty
                                ? Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(review.userName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    if (review.rating > 0) ...[
                                      Text('${review.rating.toInt()} ⭐ ', style: const TextStyle(fontSize: 10, color: AppColors.accentGold)),
                                      const Text('• ', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    ],
                                    Text(_timeAgo(review.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _replyingToId = _replyingToId == review.id ? null : review.id;
                              });
                            },
                            icon: const Icon(Icons.reply_rounded, size: 14, color: AppColors.accentCyan),
                            label: const Text('Reply', style: TextStyle(fontSize: 11, color: AppColors.accentCyan)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(review.comment, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),

                      // Nested Replies Section
                      if (replies.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: replies.map((reply) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.bgElevated.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: AppColors.bgCard,
                                          backgroundImage: reply.userAvatar.isNotEmpty ? NetworkImage(reply.userAvatar) : null,
                                          child: reply.userAvatar.isEmpty
                                              ? Text(reply.userName.isNotEmpty ? reply.userName[0].toUpperCase() : 'U',
                                                  style: const TextStyle(fontSize: 9, color: Colors.white))
                                              : null,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(reply.userName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Text(_timeAgo(reply.createdAt), style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(reply.comment, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      // Reply Input Form
                      if (_replyingToId == review.id) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _replyController,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  decoration: InputDecoration(
                                    hintText: 'Write a reply to ${review.userName}...',
                                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                    filled: true,
                                    fillColor: AppColors.bgElevated,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send_rounded, color: AppColors.accentPurple, size: 20),
                                onPressed: () => _submitReview(parentId: review.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

