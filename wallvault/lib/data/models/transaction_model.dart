import 'package:cloud_firestore/cloud_firestore.dart';

/// Transaction model — maps to `transactions/{transactionId}`.
class TransactionModel {
  final String id;
  final String userId;
  final String type; // purchase | subscription | tip | payout
  final double amount;
  final String currency;
  final String status; // pending | completed | failed | refunded
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String wallpaperId;
  final String creatorId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'INR',
    this.status = 'pending',
    this.razorpayOrderId = '',
    this.razorpayPaymentId = '',
    this.wallpaperId = '',
    this.creatorId = '',
    this.metadata = const {},
    required this.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'INR',
      status: data['status'] ?? 'pending',
      razorpayOrderId: data['razorpayOrderId'] ?? '',
      razorpayPaymentId: data['razorpayPaymentId'] ?? '',
      wallpaperId: data['wallpaperId'] ?? '',
      creatorId: data['creatorId'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'type': type,
        'amount': amount,
        'currency': currency,
        'status': status,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'wallpaperId': wallpaperId,
        'creatorId': creatorId,
        'metadata': metadata,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Payout model — maps to `payouts/{payoutId}`.
class PayoutModel {
  final String id;
  final String creatorId;
  final double amount;
  final String method; // upi | razorpay
  final String upiId;
  final String razorpayPayoutId;
  final String status; // pending | processing | completed | failed
  final String processedBy;
  final DateTime? processedAt;
  final String failureReason;
  final DateTime createdAt;

  const PayoutModel({
    required this.id,
    required this.creatorId,
    required this.amount,
    this.method = 'upi',
    this.upiId = '',
    this.razorpayPayoutId = '',
    this.status = 'pending',
    this.processedBy = '',
    this.processedAt,
    this.failureReason = '',
    required this.createdAt,
  });

  factory PayoutModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PayoutModel(
      id: doc.id,
      creatorId: data['creatorId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      method: data['method'] ?? 'upi',
      upiId: data['upiId'] ?? '',
      razorpayPayoutId: data['razorpayPayoutId'] ?? '',
      status: data['status'] ?? 'pending',
      processedBy: data['processedBy'] ?? '',
      processedAt: (data['processedAt'] as Timestamp?)?.toDate(),
      failureReason: data['failureReason'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'creatorId': creatorId,
        'amount': amount,
        'method': method,
        'upiId': upiId,
        'razorpayPayoutId': razorpayPayoutId,
        'status': status,
        'processedBy': processedBy,
        'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
        'failureReason': failureReason,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Notification model — maps to `notifications/{notificationId}`.
class NotificationModel {
  final String id;
  final String userId;
  final String type; // sale | payout | approval | tip | system
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body = '',
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      type: d['type'] ?? 'system',
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      data: Map<String, dynamic>.from(d['data'] ?? {}),
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
        'data': data,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Report model — maps to `reports/{reportId}`.
class ReportModel {
  final String id;
  final String reporterId;
  final String wallpaperId;
  final String reason; // inappropriate | copyright | quality | other
  final String description;
  final String status; // pending | reviewed | resolved
  final String reviewedBy;
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.wallpaperId,
    required this.reason,
    this.description = '',
    this.status = 'pending',
    this.reviewedBy = '',
    required this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reporterId: d['reporterId'] ?? '',
      wallpaperId: d['wallpaperId'] ?? '',
      reason: d['reason'] ?? 'other',
      description: d['description'] ?? '',
      status: d['status'] ?? 'pending',
      reviewedBy: d['reviewedBy'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'reporterId': reporterId,
        'wallpaperId': wallpaperId,
        'reason': reason,
        'description': description,
        'status': status,
        'reviewedBy': reviewedBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
