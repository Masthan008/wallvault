import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/// S41 — Process RazorpayX creator UPI payouts.
export const processPayout = functions.https.onCall(async (data, context) => {
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
      if (!creatorDoc.exists) return;
      const currentBalance = creatorDoc.data()?.availableBalance || 0;
      transaction.update(creatorRef, {
        availableBalance: currentBalance - payoutData.amount,
      });
    });

    return { success: true };
  } catch (error: any) {
    await payoutRef.update({
      status: 'failed',
      failureReason: error.message || 'RazorpayX payout failed.',
    });
    throw new functions.https.HttpsError('internal', error.message || 'Payout processing failed.');
  }
});
