import 'package:cloud_firestore/cloud_firestore.dart';

/// Wallpaper model — maps to `wallpapers/{wallpaperId}` Firestore collection.
class WallpaperModel {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String creatorName;
  final String creatorAvatarUrl;
  final bool isCreatorVerified;
  final String category;
  final List<String> tags;
  final String imageUrl;
  final String thumbnailUrl;
  final String resolution;
  final String aspectRatio;
  final bool isPremium;
  final double price;
  final String currency;
  final String status; // pending | approved | rejected | flagged
  final int downloads;
  final int views;
  final int likes;
  final double rating;
  final int ratingCount;
  final bool isOledOptimized;
  final bool isLive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? featuredUntil;

  const WallpaperModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.creatorId,
    this.creatorName = '',
    this.creatorAvatarUrl = '',
    this.isCreatorVerified = false,
    this.category = 'abstract',
    this.tags = const [],
    this.imageUrl = '',
    this.thumbnailUrl = '',
    this.resolution = '1080p',
    this.aspectRatio = '9:16',
    this.isPremium = false,
    this.price = 0,
    this.currency = 'INR',
    this.status = 'pending',
    this.downloads = 0,
    this.views = 0,
    this.likes = 0,
    this.rating = 0,
    this.ratingCount = 0,
    this.isOledOptimized = false,
    this.isLive = false,
    required this.createdAt,
    required this.updatedAt,
    this.featuredUntil,
  });

  bool get isFree => price == 0;
  bool get isFeatured =>
      featuredUntil != null && featuredUntil!.isAfter(DateTime.now());

  /// Cloudinary-transformed thumbnail URL (400x600).
  String get thumbnailTransformed {
    if (imageUrl.contains('cloudinary.com')) {
      return imageUrl.replaceFirst('/upload/', '/upload/w_400,h_600,c_fill,q_auto/');
    }
    return thumbnailUrl.isNotEmpty ? thumbnailUrl : imageUrl;
  }

  /// Cloudinary-transformed preview URL (800x1200).
  String get previewTransformed {
    if (imageUrl.contains('cloudinary.com')) {
      return imageUrl.replaceFirst('/upload/', '/upload/w_800,h_1200,c_fill,q_auto/');
    }
    return imageUrl;
  }

  factory WallpaperModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WallpaperModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorAvatarUrl: data['creatorAvatarUrl'] ?? '',
      isCreatorVerified: data['isCreatorVerified'] ?? false,
      category: data['category'] ?? 'abstract',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      resolution: data['resolution'] ?? '1080p',
      aspectRatio: data['aspectRatio'] ?? '9:16',
      isPremium: data['isPremium'] ?? false,
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'INR',
      status: data['status'] ?? 'pending',
      downloads: data['downloads'] ?? 0,
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      isOledOptimized: data['isOledOptimized'] ?? false,
      isLive: data['isLive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      featuredUntil: (data['featuredUntil'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorAvatarUrl': creatorAvatarUrl,
      'isCreatorVerified': isCreatorVerified,
      'category': category,
      'tags': tags,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'resolution': resolution,
      'aspectRatio': aspectRatio,
      'isPremium': isPremium,
      'price': price,
      'currency': currency,
      'status': status,
      'downloads': downloads,
      'views': views,
      'likes': likes,
      'rating': rating,
      'ratingCount': ratingCount,
      'isOledOptimized': isOledOptimized,
      'isLive': isLive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'featuredUntil': featuredUntil != null ? Timestamp.fromDate(featuredUntil!) : null,
    };
  }

  WallpaperModel copyWith({
    String? name,
    String? description,
    String? creatorId,
    String? creatorName,
    String? creatorAvatarUrl,
    bool? isCreatorVerified,
    String? category,
    List<String>? tags,
    String? imageUrl,
    String? thumbnailUrl,
    String? resolution,
    String? aspectRatio,
    bool? isPremium,
    double? price,
    String? currency,
    String? status,
    int? downloads,
    int? views,
    int? likes,
    double? rating,
    int? ratingCount,
    bool? isOledOptimized,
    bool? isLive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? featuredUntil,
  }) {
    return WallpaperModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
      isCreatorVerified: isCreatorVerified ?? this.isCreatorVerified,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      resolution: resolution ?? this.resolution,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isPremium: isPremium ?? this.isPremium,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      downloads: downloads ?? this.downloads,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isOledOptimized: isOledOptimized ?? this.isOledOptimized,
      isLive: isLive ?? this.isLive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      featuredUntil: featuredUntil ?? this.featuredUntil,
    );
  }
}

