import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';

final userProfileProvider = Provider<UserModel?>((ref) {
  // Mock logged in user profile initially.
  return UserModel(
    uid: 'placeholder_uid',
    phone: '+91 98765 43210',
    email: 'user@example.com',
    displayName: 'User Name',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
});
