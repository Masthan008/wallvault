import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';
import '../../../data/models/wallpaper_model.dart';
import '../../../data/models/user_model.dart';

final creatorPublicProfileProvider = FutureProvider.family<UserModel?, String>((ref, creatorId) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(creatorId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
  } catch (_) {}
  return null;
});

final creatorWallpapersProvider = FutureProvider.family<List<WallpaperModel>, String>((ref, creatorId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('wallpapers')
        .where('creatorId', isEqualTo: creatorId)
        .where('status', isEqualTo: 'approved')
        .get();

    return snapshot.docs.map((doc) => WallpaperModel.fromFirestore(doc)).toList();
  } catch (_) {
    return [];
  }
});

/// S08 Public Creator Profile Screen — Shows public metrics, wallpapers, downloads & category badges
class CreatorProfileScreen extends ConsumerWidget {
  final String creatorId;
  const CreatorProfileScreen({super.key, required this.creatorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorAsync = ref.watch(creatorPublicProfileProvider(creatorId));
    final wallpapersAsync = ref.watch(creatorWallpapersProvider(creatorId));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.bgSecondary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientHero),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: creatorAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: AppColors.accentPurple)),
              ),
              error: (e, s) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(child: Text('Error loading profile: $e', style: const TextStyle(color: Colors.white))),
              ),
              data: (creator) {
                return wallpapersAsync.when(
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator(color: AppColors.accentPurple)),
                  ),
                  error: (e, s) => Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(child: Text('Error loading wallpapers: $e', style: const TextStyle(color: Colors.white))),
                  ),
                  data: (wallpapers) {
                    final name = (creator?.displayName.isNotEmpty == true) ? creator!.displayName : 'Creator';
                    final avatar = creator?.avatarUrl ?? '';
                    final isVerified = creator?.isCreatorVerified ?? true;
                    final bio = (creator?.bio.isNotEmpty == true) ? creator!.bio : 'Digital creator showcasing high-definition wallpapers on WallVault.';

                    // Compute dynamic creator public statistics
                    final totalWalls = wallpapers.length;
                    final totalDownloads = wallpapers.fold<int>(0, (sum, w) => sum + w.downloads);
                    final categoriesSet = wallpapers.map((w) => w.category).where((c) => c.isNotEmpty).toSet().toList();

                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Public Creator Avatar
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: AppColors.bgPrimary,
                              child: CircleAvatar(
                                radius: 44,
                                backgroundColor: AppColors.bgCard,
                                backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                child: avatar.isEmpty
                                    ? Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'C',
                                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(name, style: AppTypography.h2),
                                    if (isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, color: AppColors.accentCyan, size: 20),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(bio, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                                const SizedBox(height: 20),

                                // Dynamic Creator Stats (Public Only)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgCard,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _StatColumn('$totalWalls', 'Wallpapers'),
                                      Container(height: 30, width: 1, color: Colors.white12),
                                      _StatColumn(_formatNumber(totalDownloads), 'Downloads'),
                                      Container(height: 30, width: 1, color: Colors.white12),
                                      _StatColumn('${categoriesSet.length}', 'Categories'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Category Badges created by this creator
                                if (categoriesSet.isNotEmpty) ...[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Active Categories', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 34,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: categoriesSet.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final cat = categoriesSet[index];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentPurple.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            cat.toUpperCase(),
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Wallpapers by $name', style: AppTypography.h3),
                                ),
                              ],
                            ),
                          ),

                          // Creator Wallpapers Grid
                          if (wallpapers.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No wallpapers uploaded yet.', style: TextStyle(color: AppColors.textMuted)),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.68,
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
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
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
                                          bottom: 12,
                                          left: 12,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.name, style: AppTypography.h4.copyWith(fontSize: 13)),
                                              Text('📥 ${item.downloads} downloads', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return '$num';
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.h3.copyWith(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
