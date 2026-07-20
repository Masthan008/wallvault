import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/wallpaper_repository.dart';
import '../data/models/wallpaper_model.dart';
import 'auth_provider.dart';

final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  return WallpaperRepository();
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

