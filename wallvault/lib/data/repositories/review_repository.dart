import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of real-time reviews for a specific wallpaper
  Stream<List<ReviewModel>> getWallpaperReviewsStream(String wallpaperId) {
    return _firestore
        .collection('reviews')
        .where('wallpaperId', isEqualTo: wallpaperId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
  }

  /// Add a new review or reply
  Future<void> addReview(ReviewModel review) async {
    final docRef = _firestore.collection('reviews').doc();
    final newReview = ReviewModel(
      id: docRef.id,
      wallpaperId: review.wallpaperId,
      userId: review.userId,
      userName: review.userName,
      userAvatar: review.userAvatar,
      rating: review.rating,
      comment: review.comment,
      parentId: review.parentId,
      createdAt: DateTime.now(),
    );

    await docRef.set(newReview.toFirestore());

    // Update wallpaper rating & ratingCount if top-level review with rating > 0
    if (review.parentId == null && review.rating > 0) {
      final wallpaperRef = _firestore.collection('wallpapers').doc(review.wallpaperId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(wallpaperRef);
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final currentRating = (data['rating'] as num?)?.toDouble() ?? 5.0;
          final currentCount = (data['ratingCount'] as num?)?.toInt() ?? 0;

          final newCount = currentCount + 1;
          final newRating = ((currentRating * currentCount) + review.rating) / newCount;

          transaction.update(wallpaperRef, {
            'rating': double.parse(newRating.toStringAsFixed(1)),
            'ratingCount': newCount,
          });
        }
      });
    }
  }

  /// Delete a review or reply
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }
}
