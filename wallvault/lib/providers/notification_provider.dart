import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/notification_model.dart';
import 'auth_provider.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final authUser = ref.watch(authStateProvider).asData?.value;
  if (authUser == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: authUser.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList());
});
