import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toFirestore());
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
  }
}
