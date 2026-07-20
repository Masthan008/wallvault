import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallpaper_model.dart';

class WallpaperRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<WallpaperModel>> getTrendingWallpapers({int limit = 10}) async {
    final snapshot = await _firestore
        .collection('wallpapers')
        .where('status', isEqualTo: 'approved')
        .orderBy('downloads', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => WallpaperModel.fromFirestore(doc)).toList();
  }

  Future<WallpaperModel?> getWallpaperById(String id) async {
    final doc = await _firestore.collection('wallpapers').doc(id).get();
    if (!doc.exists) return null;
    return WallpaperModel.fromFirestore(doc);
  }

  Future<void> createWallpaper(WallpaperModel wallpaper) async {
    await _firestore.collection('wallpapers').doc(wallpaper.id).set(wallpaper.toFirestore());
  }

  Future<void> incrementDownloads(String id) async {
    await _firestore.collection('wallpapers').doc(id).update({
      'downloads': FieldValue.increment(1),
    });
  }
}
