import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final authUser = ref.watch(authStateProvider).asData?.value;
  if (authUser == null) return null;

  final userRepo = ref.watch(userRepositoryProvider);
  final user = await userRepo.getUserById(authUser.uid);

  if (user != null) return user;

  // First sign-in: create user document from Firebase Auth user
  final now = DateTime.now();
  final newUser = UserModel(
    uid: authUser.uid,
    phone: authUser.phoneNumber ?? '',
    email: authUser.email ?? '',
    displayName: authUser.displayName ?? '',
    avatarUrl: authUser.photoURL ?? '',
    createdAt: now,
    updatedAt: now,
  );
  
  try {
    await userRepo.createUser(newUser);
  } catch (e) {
    debugPrint('Failed to save user to Firestore (permissions or network error): $e');
    // We still return the local user object so the app functions instead of crashing.
  }
  
  return newUser;
});
