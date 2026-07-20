import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/creator_model.dart';

class CreatorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CreatorModel?> getCreatorById(String id) async {
    final doc = await _firestore.collection('creators').doc(id).get();
    if (!doc.exists) return null;
    return CreatorModel.fromFirestore(doc);
  }

  Future<void> registerCreator(CreatorModel creator) async {
    await _firestore.collection('creators').doc(creator.id).set(creator.toFirestore());
  }

  Future<void> updatePayoutMethod(String creatorId, PayoutMethod method) async {
    await _firestore.collection('creators').doc(creatorId).update({
      'payoutMethod': method.toMap(),
    });
  }
}
