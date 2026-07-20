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
Object.defineProperty(exports, "__esModule", { value: true });
exports.processPayout = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
/// S41 — Process RazorpayX creator UPI payouts.
exports.processPayout = functions.https.onCall(async (data, context) => {
    // Ensure requested by admin
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
    }
    const adminUser = await admin.firestore().collection('users').doc(context.auth.uid).get();
    if (adminUser.data()?.role !== 'admin') {
        throw new functions.https.HttpsError('permission-denied', 'Only admin users can trigger payouts.');
    }
    const { payoutId } = data;
    const db = admin.firestore();
    const payoutRef = db.collection('payouts').doc(payoutId);
    const payoutDoc = await payoutRef.get();
    if (!payoutDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Payout request not found.');
    }
    const payoutData = payoutDoc.data();
    if (payoutData?.status !== 'pending') {
        throw new functions.https.HttpsError('failed-precondition', 'Payout request is not pending.');
    }
    try {
        // Transition status to processing
        await payoutRef.update({
            status: 'processing',
            processedBy: context.auth.uid,
        });
        // TODO: Perform RazorpayX API request
        // const response = await fetch('https://api.razorpay.com/v1/payouts', { ... });
        // Mock successful payout processing
        await payoutRef.update({
            status: 'completed',
            processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Deduct from creator available balance
        const creatorRef = db.collection('creators').doc(payoutData.creatorId);
        await db.runTransaction(async (transaction) => {
            const creatorDoc = await transaction.get(creatorRef);
            if (!creatorDoc.exists)
                return;
            const currentBalance = creatorDoc.data()?.availableBalance || 0;
            transaction.update(creatorRef, {
                availableBalance: currentBalance - payoutData.amount,
            });
        });
        return { success: true };
    }
    catch (error) {
        await payoutRef.update({
            status: 'failed',
            failureReason: error.message || 'RazorpayX payout failed.',
        });
        throw new functions.https.HttpsError('internal', error.message || 'Payout processing failed.');
    }
});
//# sourceMappingURL=payouts.js.map