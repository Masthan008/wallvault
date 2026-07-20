import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class UserRepository {
  FirebaseFirestore? _firestore;
  bool _isFirebaseInitialized = false;
  final Map<String, UserModel> _mockDb = {};

  UserRepository() {
    try {
      Firebase.app();
      _firestore = FirebaseFirestore.instance;
      _isFirebaseInitialized = true;
    } catch (e) {
      debugPrint("UserRepository: Firebase not initialized, running in Mock Mode.");
      _isFirebaseInitialized = false;
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    if (!_isFirebaseInitialized) {
      return _mockDb[uid] ?? UserModel(
        uid: uid,
        phone: '1234567890',
        email: 'mock_user@wallvault.com',
        displayName: 'Mock User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    try {
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  Future<void> createUser(UserModel user) async {
    if (!_isFirebaseInitialized) {
      _mockDb[user.uid] = user;
      return;
    }
    await _firestore!.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    if (!_isFirebaseInitialized) {
      final existing = _mockDb[uid];
      if (existing != null) {
        _mockDb[uid] = existing.copyWith(
          phone: updates['phone'] as String?,
          email: updates['email'] as String?,
          displayName: updates['displayName'] as String?,
          isCreator: updates['isCreator'] as bool?,
          creatorStatus: updates['creatorStatus'] as String?,
        );
      }
      return;
    }

    await _firestore!.collection('users').doc(uid).update({
      ...updates,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

