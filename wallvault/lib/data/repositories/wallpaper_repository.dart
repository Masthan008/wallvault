import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallpaper_model.dart';

class WallpaperRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WallpaperRepository() {
    seedWallpapersIfEmpty();
  }

  /// Automatically seeds Firestore with the 6 prebuilt wallpapers if collection is empty.
  Future<void> seedWallpapersIfEmpty() async {
    try {
      final snapshot = await _firestore.collection('wallpapers').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final now = DateTime.now();
        final prebuilt = [
          WallpaperModel(
            id: 'japan_sunset_street',
            name: 'Japan Sunset Street',
            description: 'A beautiful Japanese street scenery with cherry blossoms, traditional lanterns, and Mt. Fuji under a warm sunset.',
            creatorId: 'creator_satoshi',
            creatorName: 'Satoshi',
            category: 'nature',
            tags: ['nature', 'japan', 'sunset', 'street', 'cherry blossoms'],
            imageUrl: 'assets/images/japan_sunset_street.png',
            thumbnailUrl: 'assets/images/japan_sunset_street.png',
            resolution: '4K',
            isPremium: false,
            price: 0,
            status: 'approved',
            downloads: 1200,
            likes: 450,
            rating: 4.9,
            createdAt: now,
            updatedAt: now,
          ),
          WallpaperModel(
            id: 'uchiha_madara_shadow',
            name: 'Uchiha Madara Shadow',
            description: 'Legendary anime character in dynamic stance with glowing red Sharingan eyes and dark background aura.',
            creatorId: 'creator_otakuart',
            creatorName: 'OtakuArt',
            category: 'anime',
            tags: ['anime', 'madara', 'sharingan', 'uchiha', 'dark'],
            imageUrl: 'assets/images/uchiha_madara_shadow.png',
            thumbnailUrl: 'assets/images/uchiha_madara_shadow.png',
            resolution: '4K',
            isPremium: true,
            price: 49,
            status: 'approved',
            downloads: 850,
            likes: 380,
            rating: 4.8,
            createdAt: now,
            updatedAt: now,
          ),
          WallpaperModel(
            id: 'neon_cyber_temple',
            name: 'Neon Cyber Temple',
            description: 'A detailed cyber temple with glowing neon holograms and sakura blossoms under tech sky.',
            creatorId: 'creator_matrix',
            creatorName: 'Matrix',
            category: 'abstract',
            tags: ['abstract', 'neon', 'cyberpunk', 'cyber', 'temple'],
            imageUrl: 'assets/images/neon_cyber_temple.png',
            thumbnailUrl: 'assets/images/neon_cyber_temple.png',
            resolution: '4K',
            isPremium: true,
            price: 49,
            status: 'approved',
            downloads: 1600,
            likes: 720,
            rating: 4.7,
            createdAt: now,
            updatedAt: now,
          ),
          WallpaperModel(
            id: 'cosmic_nebula_ocean',
            name: 'Cosmic Nebula Ocean',
            description: 'Vibrant nebula clouds casting bright colors over the reflective space ocean ripples.',
            creatorId: 'creator_luna',
            creatorName: 'Luna',
            category: 'space',
            tags: ['space', 'nebula', 'cosmic', 'ocean', 'stars'],
            imageUrl: 'assets/images/cosmic_nebula_ocean.png',
            thumbnailUrl: 'assets/images/cosmic_nebula_ocean.png',
            resolution: '4K',
            isPremium: false,
            price: 0,
            status: 'approved',
            downloads: 2300,
            likes: 980,
            rating: 4.9,
            createdAt: now,
            updatedAt: now,
          ),
          WallpaperModel(
            id: 'cyberpunk_car_drift',
            name: 'Cyberpunk Car Drift',
            description: 'Neon glowing sportscar drifting on the wet asphalt streets of a futuristic tech city.',
            creatorId: 'creator_speedy',
            creatorName: 'Speedy',
            category: 'cars',
            tags: ['cars', 'drift', 'cyberpunk', 'sportscar', 'neon'],
            imageUrl: 'assets/images/cyberpunk_car_drift.png',
            thumbnailUrl: 'assets/images/cyberpunk_car_drift.png',
            resolution: '4K',
            isPremium: true,
            price: 49,
            status: 'approved',
            downloads: 940,
            likes: 410,
            rating: 4.6,
            createdAt: now,
            updatedAt: now,
          ),
          WallpaperModel(
            id: 'minimalist_mountain_lake',
            name: 'Minimalist Mountain Lake',
            description: 'Calm flat vector minimalist art showing peaceful mountains and moon under star sky.',
            creatorId: 'creator_zen',
            creatorName: 'ZenDesign',
            category: 'nature',
            tags: ['nature', 'minimalist', 'mountains', 'lake', 'vector'],
            imageUrl: 'assets/images/minimalist_mountain_lake.png',
            thumbnailUrl: 'assets/images/minimalist_mountain_lake.png',
            resolution: '4K',
            isPremium: false,
            price: 0,
            status: 'approved',
            downloads: 1400,
            likes: 610,
            rating: 4.8,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        for (final item in prebuilt) {
          await createWallpaper(item);
        }
      }
    } catch (e) {
      // Fail silently if Firestore is not initialized or offline
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

      return snapshot.docs.map((doc) => WallpaperModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Real query filtering against Firestore collection
  Future<List<WallpaperModel>> getWallpapers({String? category, String? query, int limit = 20}) async {
    try {
      Query firestoreQuery = _firestore.collection('wallpapers').where('status', isEqualTo: 'approved');

      if (category != null && category.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category.toLowerCase());
      }

      final snapshot = await firestoreQuery.limit(limit).get();
      var list = snapshot.docs.map((doc) => WallpaperModel.fromFirestore(doc)).toList();

      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        list = list.where((w) => w.name.toLowerCase().contains(q) || w.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }

      list.sort((a, b) => b.downloads.compareTo(a.downloads));
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<WallpaperModel?> getWallpaperById(String id) async {
    try {
      final doc = await _firestore.collection('wallpapers').doc(id).get();
      if (!doc.exists) return null;
      return WallpaperModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
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
