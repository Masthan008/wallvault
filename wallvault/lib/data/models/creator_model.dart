import 'package:cloud_firestore/cloud_firestore.dart';

/// Creator model — maps to `creators/{creatorId}` Firestore collection.
class CreatorModel {
  final String id;
  final String userId;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final List<String> portfolioUrls;
  final PayoutMethod payoutMethod;
  final int level;
  final int xp;
  final double totalEarnings;
  final double availableBalance;
  final int totalDownloads;
  final int totalSales;
  final String status; // pending | approved | suspended
  final DateTime? verifiedAt;
  final DateTime createdAt;

  const CreatorModel({
    required this.id,
    required this.userId,
    this.displayName = '',
    this.bio = '',
    this.avatarUrl = '',
    this.portfolioUrls = const [],
    this.payoutMethod = const PayoutMethod(),
    this.level = 1,
    this.xp = 0,
    this.totalEarnings = 0,
    this.availableBalance = 0,
    this.totalDownloads = 0,
    this.totalSales = 0,
    this.status = 'pending',
    this.verifiedAt,
    required this.createdAt,
  });

  String get levelName {
    switch (level) {
      case 1: return '🌱 Seedling';
      case 2: return '🌿 Sprout';
      case 3: return '🌸 Bloom';
      case 4: return '⭐ Star';
      case 5: return '👑 Legend';
      default: return '🌱 Seedling';
    }
  }

  bool get isVerified => status == 'approved' && level >= 3;
  bool get canRequestPayout => availableBalance >= 500;

  factory CreatorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CreatorModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      portfolioUrls: List<String>.from(data['portfolioUrls'] ?? []),
      payoutMethod: PayoutMethod.fromMap(data['payoutMethod'] ?? {}),
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
      availableBalance: (data['availableBalance'] ?? 0).toDouble(),
      totalDownloads: data['totalDownloads'] ?? 0,
      totalSales: data['totalSales'] ?? 0,
      status: data['status'] ?? 'pending',
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'portfolioUrls': portfolioUrls,
      'payoutMethod': payoutMethod.toMap(),
      'level': level,
      'xp': xp,
      'totalEarnings': totalEarnings,
      'availableBalance': availableBalance,
      'totalDownloads': totalDownloads,
      'totalSales': totalSales,
      'status': status,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class PayoutMethod {
  final String type; // upi | razorpay
  final String upiId;
  final String razorpayAccountId;

  const PayoutMethod({
    this.type = 'upi',
    this.upiId = '',
    this.razorpayAccountId = '',
  });

  factory PayoutMethod.fromMap(Map<String, dynamic> map) {
    return PayoutMethod(
      type: map['type'] ?? 'upi',
      upiId: map['upiId'] ?? '',
      razorpayAccountId: map['razorpayAccountId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'upiId': upiId,
      'razorpayAccountId': razorpayAccountId,
    };
  }
}
