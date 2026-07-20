import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Razorpay from 'razorpay';

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID || 'mock_key_id',
  key_secret: process.env.RAZORPAY_KEY_SECRET || 'mock_key_secret',
});

/// S39 — Create order in Razorpay.
export const createOrder = functions.https.onCall(async (data, context) => {
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
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', error.message || 'Razorpay order creation failed.');
  }
});

/// S40 — Verify Razorpay payment signature.
export const verifyPayment = functions.https.onCall(async (data, context) => {
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
