import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/wallpaper_repository.dart';
import '../data/models/wallpaper_model.dart';
import 'auth_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  return WallpaperRepository();
});

final categoriesStreamProvider = StreamProvider<List<String>>((ref) {
  final defaultCategories = [
    'All',
    'Anime',
    'Abstract',
    'Nature',
    'Space',
    'Cars',
    'Cyberpunk',
    '3D',
    'Dark',
    'Minimalist'
  ];

  return FirebaseFirestore.instance.collection('categories').snapshots().map((snapshot) {
    final fetched = <String>[];
    for (final doc in snapshot.docs) {
      final name = doc.data()['name'] as String?;
      if (name != null && name.trim().isNotEmpty) {
        fetched.add(name.trim());
      }
    }
    final combined = <String>{...defaultCategories, ...fetched};
    return combined.toList();
  }).handleError((_) => defaultCategories);
});

final trendingWallpapersProvider = FutureProvider<List<WallpaperModel>>((ref) async {
  return ref.watch(wallpaperRepositoryProvider).getTrendingWallpapers();
});

final searchWallpapersProvider = FutureProvider.family<List<WallpaperModel>, String>((ref, query) async {
  return ref.watch(wallpaperRepositoryProvider).getWallpapers(query: query);
});

final categoryWallpapersProvider = FutureProvider.family<List<WallpaperModel>, String>((ref, category) async {
  return ref.watch(wallpaperRepositoryProvider).getWallpapers(category: category);
});

final wallpaperDetailProvider = FutureProvider.family<WallpaperModel?, String>((ref, id) async {
  return ref.watch(wallpaperRepositoryProvider).getWallpaperById(id);
});

final downloadedWallpapersProvider = FutureProvider<List<WallpaperModel>>((ref) async {
  final user = ref.watch(userProfileProvider).asData?.value;
  if (user == null || user.downloads.isEmpty) return [];

  final repo = ref.watch(wallpaperRepositoryProvider);
  final futures = user.downloads.map((id) => repo.getWallpaperById(id));
  final results = await Future.wait(futures);
  return results.whereType<WallpaperModel>().toList();
});

final savedWallpapersProvider = FutureProvider<List<WallpaperModel>>((ref) async {
  final user = ref.watch(userProfileProvider).asData?.value;
  if (user == null || user.favorites.isEmpty) return [];

  final repo = ref.watch(wallpaperRepositoryProvider);
  final futures = user.favorites.map((id) => repo.getWallpaperById(id));
  final results = await Future.wait(futures);
  return results.whereType<WallpaperModel>().toList();
});

