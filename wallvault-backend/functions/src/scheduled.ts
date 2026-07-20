import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/// S44 — Daily subscription cleanup scheduler.
export const cleanupSubscriptions = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    const expiredUsers = await db
      .collection('users')
      .where('subscription.endDate', '<', now)
      .where('subscription.plan', '!=', 'free')
      .get();

    const batch = db.batch();

    expiredUsers.docs.forEach((doc) => {
      const userData = doc.data();
      // If auto-renew is true, we don't downgrade, we process payment instead (handled by webhook).
      // If auto-renew is false, downgrade to free plan.
      if (!userData.subscription?.autoRenew) {
        batch.update(doc.ref, {
          'subscription.plan': 'free',
          'subscription.endDate': null,
          'subscription.startDate': null,
        });
      }
    });

    await batch.commit();
    console.log(`Cleaned up ${expiredUsers.size} expired subscriptions.`);
    return null;
  });
