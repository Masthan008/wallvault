import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';
import '../../../providers/wallpaper_provider.dart';

/// S13 — Downloads screen with download history grid.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadedWallpapersProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('My Downloads')),
      body: downloadsAsync.when(
        data: (wallpapers) {
          if (wallpapers.isEmpty) {
            return const Center(
              child: Text(
                'No downloads yet.',
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
              return GestureDetector(
                onTap: () => context.push(AppRoutes.wallpaperDetailPath(item.id)),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    image: DecorationImage(
                      image: item.imageUrl.startsWith('assets/')
                          ? AssetImage(item.imageUrl) as ImageProvider
                          : NetworkImage(item.imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, Colors.black87],
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Text(
                          item.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentPurple),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading downloads: $err',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
