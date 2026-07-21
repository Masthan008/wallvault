import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallpaper_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class WallpaperRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WallpaperRepository() {
    seedWallpapersIfEmpty();
  }

  /// 3 Onboarding wallpapers fallback
  List<WallpaperModel> getPrebuiltList() {
    final now = DateTime.now();
    return [
      WallpaperModel(
        id: 'prebuilt_03',
        name: 'Fiery Warrior Spirit',
        description: 'Mighty warrior with colossal fiery spirit unleashing power in battle.',
        creatorId: 'creator_matrix',
        creatorName: 'Matrix',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'matrix'],
        imageUrl: 'assets/images/prebuilt_03.png',
        thumbnailUrl: 'assets/images/prebuilt_03.png',
        resolution: '4K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 1255,
        likes: 505,
        rating: 4.8,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_34',
        name: 'Cyber Skyline Neon',
        description: 'Panoramic view from skyscraper rooftop overlooking glowing metropolis.',
        creatorId: 'creator_satoshi',
        creatorName: 'Satoshi',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'satoshi'],
        imageUrl: 'assets/images/prebuilt_34.png',
        thumbnailUrl: 'assets/images/prebuilt_34.png',
        resolution: '4K UHD',
        isPremium: true,
        price: 2,
        status: 'approved',
        downloads: 3890,
        likes: 1420,
        rating: 4.9,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_20',
        name: 'Interstellar Drift',
        description: 'Astronaut tethered in open space above magnificent planetary ring system.',
        creatorId: 'creator_luna',
        creatorName: 'Luna',
        category: 'space',
        tags: ['space', 'wallpaper', 'hd', '4k', 'luna'],
        imageUrl: 'assets/images/prebuilt_20.png',
        thumbnailUrl: 'assets/images/prebuilt_20.png',
        resolution: '4K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 2040,
        likes: 860,
        rating: 4.8,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> seedWallpapersIfEmpty() async {
    try {
      final snapshot = await _firestore.collection('wallpapers').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final prebuilt = getPrebuiltList();
        for (final item in prebuilt) {
          await _firestore.collection('wallpapers').doc(item.id).set(item.toFirestore(), SetOptions(merge: true));
        }
      }
    } catch (e) {
      // Fail silently if offline
    }
  }

  Future<List<WallpaperModel>> getTrendingWallpapers({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('wallpapers')
          .where('status', isEqualTo: 'approved')
          .orderBy('downloads', descending: true)
          .limit(limit)
          .get();

      final docs = snapshot.docs.map((doc) => WallpaperModel.fromFirestore(doc)).toList();
      if (docs.isEmpty) {
        return getPrebuiltList();
      }
      return docs;
    } catch (e) {
      return getPrebuiltList();
    }
  }

  /// Real query filtering against Firestore collection
  Future<List<WallpaperModel>> getWallpapers({String? category, String? query, int limit = 50}) async {
    try {
      Query firestoreQuery = _firestore.collection('wallpapers').where('status', isEqualTo: 'approved');

      if (category != null && category.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category.toLowerCase());
      }

      final snapshot = await firestoreQuery.limit(limit).get();
      var list = snapshot.docs.map((doc) => WallpaperModel.fromFirestore(doc)).toList();

      if (list.isEmpty) {
        list = getPrebuiltList();
        if (category != null && category.isNotEmpty) {
          list = list.where((w) => w.category.toLowerCase() == category.toLowerCase()).toList();
        }
      }

      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        list = list.where((w) => w.name.toLowerCase().contains(q) || w.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }

      list.sort((a, b) => b.downloads.compareTo(a.downloads));
      return list;
    } catch (e) {
      var list = getPrebuiltList();
      if (category != null && category.isNotEmpty) {
        list = list.where((w) => w.category.toLowerCase() == category.toLowerCase()).toList();
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        list = list.where((w) => w.name.toLowerCase().contains(q) || w.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }
      list.sort((a, b) => b.downloads.compareTo(a.downloads));
      return list;
    }
  }

  Future<WallpaperModel?> getWallpaperById(String id) async {
    try {
      final doc = await _firestore.collection('wallpapers').doc(id).get();
      if (doc.exists) {
        return WallpaperModel.fromFirestore(doc);
      }
      final prebuilt = getPrebuiltList();
      return prebuilt.firstWhere((w) => w.id == id, orElse: () => prebuilt.first);
    } catch (e) {
      final prebuilt = getPrebuiltList();
      return prebuilt.firstWhere((w) => w.id == id, orElse: () => prebuilt.first);
    }
  }

  Future<void> createWallpaper(WallpaperModel wallpaper) async {
    await _firestore.collection('wallpapers').doc(wallpaper.id).set(wallpaper.toFirestore());
  }

  Future<void> incrementDownloads(String id) async {
    try {
      await _firestore.collection('wallpapers').doc(id).update({
        'downloads': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  Future<void> incrementLikes(String id) async {
    try {
      await _firestore.collection('wallpapers').doc(id).update({
        'likes': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  Future<void> decrementLikes(String id) async {
    try {
      await _firestore.collection('wallpapers').doc(id).update({
        'likes': FieldValue.increment(-1),
      });
    } catch (_) {}
  }

  Future<void> updateRating(String id, double newRating, int newRatingCount) async {
    try {
      await _firestore.collection('wallpapers').doc(id).update({
        'rating': newRating,
        'ratingCount': newRatingCount,
      });
    } catch (_) {}
  }
}
