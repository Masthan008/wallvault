import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/wallpaper_repository.dart';
import '../data/models/wallpaper_model.dart';

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

