import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';
import '../../../providers/wallpaper_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/effects/app_toast.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/wallpaper_card.dart';

/// S26 — Saved/Favorites screen.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedWallpapersProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final user = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Saved Wallpapers'),
        automaticallyImplyLeading: false,
      ),
      body: savedAsync.when(
        data: (wallpapers) {
          if (wallpapers.isEmpty) {
            return const Center(
              child: Text(
                'No saved wallpapers yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.gridSpacing,
              crossAxisSpacing: AppSpacing.gridSpacing,
              childAspectRatio: 0.65,
            ),
            itemCount: wallpapers.length,
            itemBuilder: (context, index) {
              final item = wallpapers[index];
              return WallpaperCard(
                wallpaper: item,
                isLiked: true,
                entranceDelayMs: (index % 8) * 30,
                onLike: () async {
                  if (user != null) {
                    final updatedFavorites = List<String>.from(user.favorites)
                      ..remove(item.id);
                    await userRepo.updateUser(user.uid, {'favorites': updatedFavorites});
                    ref.invalidate(userProfileProvider);
                    ref.invalidate(savedWallpapersProvider);
                    if (!context.mounted) return;
                    showAppToast(context, 'Removed from Saved', type: ToastType.success);
                  }
                },
                onTap: () => context.push(AppRoutes.wallpaperDetailPath(item.id)),
              );
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: WallpaperGridShimmer(),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading saved wallpapers: $err',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
