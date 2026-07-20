import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/payment_repository.dart';
import '../data/models/transaction_model.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository();
});

final userTransactionsProvider = FutureProvider.family<List<TransactionModel>, String>((ref, userId) async {
  return ref.watch(paymentRepositoryProvider).getUserTransactions(userId);
});
