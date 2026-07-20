"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyPayment = exports.createOrder = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const razorpay_1 = __importDefault(require("razorpay"));
const razorpay = new razorpay_1.default({
    key_id: process.env.RAZORPAY_KEY_ID || 'mock_key_id',
    key_secret: process.env.RAZORPAY_KEY_SECRET || 'mock_key_secret',
});
/// S39 — Create order in Razorpay.
exports.createOrder = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
    }
    const { amount, currency = 'INR', wallpaperId, type } = data;
    try {
        const options = {
            amount: amount * 100, // Amount in paise
            currency,
            receipt: `receipt_${Date.now()}`,
            notes: {
                userId: context.auth.uid,
                wallpaperId: wallpaperId || '',
                type: type, // purchase | subscription | tip
            },
        };
        const order = await razorpay.orders.create(options);
        // Save transaction request in database
        await admin.firestore().collection('transactions').doc(order.id).set({
            userId: context.auth.uid,
            type,
            amount,
            currency,
            status: 'pending',
            razorpayOrderId: order.id,
            wallpaperId: wallpaperId || '',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { orderId: order.id, amount: order.amount };
    }
    catch (error) {
        throw new functions.https.HttpsError('internal', error.message || 'Razorpay order creation failed.');
    }
});
/// S40 — Verify Razorpay payment signature.
exports.verifyPayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
    }
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature } = data;
    const crypto = require('crypto');
    const hmac = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET || 'mock_key_secret');
    hmac.update(razorpayOrderId + '|' + razorpayPaymentId);
    const generatedSignature = hmac.digest('hex');
    if (generatedSignature !== razorpaySignature) {
        throw new functions.https.HttpsError('invalid-argument', 'Payment signature verification failed.');
    }
    // Update transaction status to completed
    const db = admin.firestore();
    const txRef = db.collection('transactions').doc(razorpayOrderId);
    const txDoc = await txRef.get();
    if (!txDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Transaction record not found.');
    }
    await txRef.update({
        status: 'completed',
        razorpayPaymentId,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true };
});
//# sourceMappingURL=payments.js.map