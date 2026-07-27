import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/review_repository.dart';
import '../data/models/review_model.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

final wallpaperReviewsStreamProvider = StreamProvider.family<List<ReviewModel>, String>((ref, wallpaperId) {
  return ref.watch(reviewRepositoryProvider).getWallpaperReviewsStream(wallpaperId);
});
