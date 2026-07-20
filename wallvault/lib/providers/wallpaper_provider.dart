import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/wallpaper_repository.dart';
import '../data/models/wallpaper_model.dart';

final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  return WallpaperRepository();
});

final trendingWallpapersProvider = FutureProvider<List<WallpaperModel>>((ref) async {
  return ref.watch(wallpaperRepositoryProvider).getTrendingWallpapers();
});
