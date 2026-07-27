import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String wallpaperId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String? parentId; // null if top-level review, parent reviewId if reply
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.wallpaperId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    this.parentId,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel(
      id: doc.id,
      wallpaperId: data['wallpaperId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      userAvatar: data['userAvatar'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      comment: data['comment'] as String? ?? '',
      parentId: data['parentId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'wallpaperId': wallpaperId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'parentId': parentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
