import '../models/wallpaper_model.dart';
import '../repositories/wallpaper_repository.dart';

class WallpaperService {
  final WallpaperRepository _repository;
  WallpaperService(this._repository);

  /// S45 — Personalized Discovery algorithm:
  /// - 40% featured/editorial wallpapers
  /// - 40% collaborative download popularity
  /// - 20% recent uploads (last 7 days)
  Future<List<WallpaperModel>> getForYouFeed({int limit = 20}) async {
    try {
      final allWallpapers = await _repository.getTrendingWallpapers(limit: limit * 2);
      
      // Separate lists based on attributes
      final featured = allWallpapers.where((w) => w.isPremium).toList();
      final popular = allWallpapers.where((w) => w.downloads > 100).toList();
      final recent = allWallpapers.where((w) => w.createdAt.isAfter(
        DateTime.now().subtract(const Duration(days: 7))
      )).toList();

      final List<WallpaperModel> mixedFeed = [];
      
      // Mix them according to 40-40-20 ratio
      final featuredCount = (limit * 0.4).round();
      final popularCount = (limit * 0.4).round();
      final recentCount = limit - featuredCount - popularCount;

      mixedFeed.addAll(featured.take(featuredCount));
      mixedFeed.addAll(popular.take(popularCount));
      mixedFeed.addAll(recent.take(recentCount));

      // Fallback if mixes are empty
      if (mixedFeed.isEmpty) {
        mixedFeed.addAll(allWallpapers.take(limit));
      }

      mixedFeed.shuffle();
      return mixedFeed;
    } catch (e) {
      return [];
    }
  }

  /// S45 — Calculate download velocity: downloads divided by hours since upload
  List<WallpaperModel> sortByDownloadVelocity(List<WallpaperModel> wallpapers) {
    final now = DateTime.now();
    return List.from(wallpapers)..sort((a, b) {
      final hoursA = now.difference(a.createdAt).inHours.clamp(1, 999999);
      final hoursB = now.difference(b.createdAt).inHours.clamp(1, 999999);
      
      final velocityA = a.downloads / hoursA;
      final velocityB = b.downloads / hoursB;
      
      return velocityB.compareTo(velocityA);
    });
  }
}
