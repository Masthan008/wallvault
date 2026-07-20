import 'package:cloud_firestore/cloud_firestore.dart';

/// User model — maps to `users/{userId}` Firestore collection.
class UserModel {
  final String uid;
  final String phone;
  final String email;
  final String displayName;
  final String avatarUrl;
  final bool isCreator;
  final String creatorStatus; // pending | approved | rejected
  final SubscriptionInfo subscription;
  final StreakInfo streak;
  final int xp;
  final int level;
  final List<String> badges;
  final List<String> favorites;
  final List<String> downloads;
  final List<String> following;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    this.phone = '',
    this.email = '',
    this.displayName = '',
    this.avatarUrl = '',
    this.isCreator = false,
    this.creatorStatus = 'pending',
    this.subscription = const SubscriptionInfo(),
    this.streak = const StreakInfo(),
    this.xp = 0,
    this.level = 1,
    this.badges = const [],
    this.favorites = const [],
    this.downloads = const [],
    this.following = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      isCreator: data['isCreator'] ?? false,
      creatorStatus: data['creatorStatus'] ?? 'pending',
      subscription: SubscriptionInfo.fromMap(data['subscription'] ?? {}),
      streak: StreakInfo.fromMap(data['streak'] ?? {}),
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      badges: List<String>.from(data['badges'] ?? []),
      favorites: List<String>.from(data['favorites'] ?? []),
      downloads: List<String>.from(data['downloads'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phone': phone,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isCreator': isCreator,
      'creatorStatus': creatorStatus,
      'subscription': subscription.toMap(),
      'streak': streak.toMap(),
      'xp': xp,
      'level': level,
      'badges': badges,
      'favorites': favorites,
      'downloads': downloads,
      'following': following,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? phone,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isCreator,
    String? creatorStatus,
    SubscriptionInfo? subscription,
    StreakInfo? streak,
    int? xp,
    int? level,
    List<String>? badges,
    List<String>? favorites,
    List<String>? downloads,
    List<String>? following,
  }) {
    return UserModel(
      uid: uid,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isCreator: isCreator ?? this.isCreator,
      creatorStatus: creatorStatus ?? this.creatorStatus,
      subscription: subscription ?? this.subscription,
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      favorites: favorites ?? this.favorites,
      downloads: downloads ?? this.downloads,
      following: following ?? this.following,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class SubscriptionInfo {
  final String plan; // free | monthly | yearly | lifetime
  final DateTime? startDate;
  final DateTime? endDate;
  final bool autoRenew;

  const SubscriptionInfo({
    this.plan = 'free',
    this.startDate,
    this.endDate,
    this.autoRenew = false,
  });

  bool get isPro => plan != 'free';

  factory SubscriptionInfo.fromMap(Map<String, dynamic> map) {
    return SubscriptionInfo(
      plan: map['plan'] ?? 'free',
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      autoRenew: map['autoRenew'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan': plan,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'autoRenew': autoRenew,
    };
  }
}

class StreakInfo {
  final int current;
  final int longest;
  final DateTime? lastDownloadDate;

  const StreakInfo({
    this.current = 0,
    this.longest = 0,
    this.lastDownloadDate,
  });

  factory StreakInfo.fromMap(Map<String, dynamic> map) {
    return StreakInfo(
      current: map['current'] ?? 0,
      longest: map['longest'] ?? 0,
      lastDownloadDate: (map['lastDownloadDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'current': current,
      'longest': longest,
      'lastDownloadDate': lastDownloadDate != null
          ? Timestamp.fromDate(lastDownloadDate!)
          : null,
    };
  }
}
