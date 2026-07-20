import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? phoneNumber;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #uid) return uid;
    if (invocation.memberName == #email) return email;
    if (invocation.memberName == #displayName) return displayName;
    if (invocation.memberName == #phoneNumber) return phoneNumber;
    return null;
  }
}

class MockUserCredential implements UserCredential {
  @override
  final User? user;

  MockUserCredential({this.user});

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #user) return user;
    return null;
  }
}

class AuthRepository {
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  bool _isFirebaseInitialized = false;

  final StreamController<User?> _mockStreamController = StreamController<User?>.broadcast();
  User? _mockCurrentUser;

  AuthRepository() {
    try {
      Firebase.app();
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
      _isFirebaseInitialized = true;
    } catch (e) {
      debugPrint("AuthRepository: Firebase is uninitialized/missing config, running in Mock Mode.");
      _isFirebaseInitialized = false;
      _mockCurrentUser = null;
      _mockStreamController.add(null);
    }
  }

  Stream<User?> get authStateChanges {
    if (_isFirebaseInitialized) {
      return _auth!.authStateChanges();
    } else {
      return _mockStreamController.stream;
    }
  }

  User? get currentUser {
    if (_isFirebaseInitialized) {
      return _auth!.currentUser;
    } else {
      return _mockCurrentUser;
    }
  }

  // ── Phone Auth ──

  Future<void> signInWithPhone(
    String phoneNumber,
    void Function(PhoneAuthCredential) verificationCompleted,
    void Function(FirebaseAuthException) verificationFailed,
    void Function(String, int?) codeSent,
    void Function(String) codeAutoRetrievalTimeout,
  ) async {
    if (!_isFirebaseInitialized) {
      // Simulate verification code sent instantly in mock mode
      Future.delayed(const Duration(milliseconds: 600), () {
        codeSent("mock_verification_id", 0);
      });
      return;
    }
    await _auth!.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    if (!_isFirebaseInitialized) {
      _mockCurrentUser = MockUser(
        uid: "mock_uid_${DateTime.now().millisecondsSinceEpoch}",
        email: "mock_user@wallvault.com",
        displayName: "Mock User",
        phoneNumber: "1234567890",
      );
      _mockStreamController.add(_mockCurrentUser);
      return MockUserCredential(user: _mockCurrentUser);
    }
    return await _auth!.signInWithCredential(credential);
  }

  // ── Email/Password Auth ──

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!_isFirebaseInitialized) {
      _mockCurrentUser = MockUser(
        uid: "mock_uid_${email.hashCode}",
        email: email,
        displayName: email.split('@')[0],
      );
      _mockStreamController.add(_mockCurrentUser);
      return MockUserCredential(user: _mockCurrentUser);
    }
    return await _auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!_isFirebaseInitialized) {
      _mockCurrentUser = MockUser(
        uid: "mock_uid_${email.hashCode}",
        email: email,
        displayName: email.split('@')[0],
      );
      _mockStreamController.add(_mockCurrentUser);
      return MockUserCredential(user: _mockCurrentUser);
    }
    return await _auth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ── Google Sign-In ──

  Future<UserCredential> signInWithGoogle() async {
    if (!_isFirebaseInitialized) {
      _mockCurrentUser = MockUser(
        uid: "mock_google_uid_${DateTime.now().millisecondsSinceEpoch}",
        email: "google_user@gmail.com",
        displayName: "Google User",
      );
      _mockStreamController.add(_mockCurrentUser);
      return MockUserCredential(user: _mockCurrentUser);
    }
    final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'CANCELED',
        message: 'Google sign-in was canceled.',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth!.signInWithCredential(credential);
  }

  // ── Apple Sign-In ──

  Future<UserCredential> signInWithApple() async {
    if (!_isFirebaseInitialized) {
      _mockCurrentUser = MockUser(
        uid: "mock_apple_uid_${DateTime.now().millisecondsSinceEpoch}",
        email: "apple_user@icloud.com",
        displayName: "Apple User",
      );
      _mockStreamController.add(_mockCurrentUser);
      return MockUserCredential(user: _mockCurrentUser);
    }
    final rawNonce = _generateNonce();
    final nonce = sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    return await _auth!.signInWithCredential(credential);
  }

  String _generateNonce() {
    final random = _generateRandomString();
    return base64Url.encode(utf8.encode(random));
  }

  String _generateRandomString() {
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer(now);
    for (int i = 0; i < 16; i++) {
      buffer.write(chars[now.codeUnitAt(i % now.length) % chars.length]);
    }
    return buffer.toString();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ── Sign Out ──

  Future<void> signOut() async {
    if (_isFirebaseInitialized) {
      await _googleSignIn?.signOut();
      await _auth?.signOut();
    } else {
      _mockCurrentUser = null;
      _mockStreamController.add(null);
    }
  }
}

