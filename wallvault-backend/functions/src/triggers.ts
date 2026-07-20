import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/// S42 — Auto-moderation trigger.
export const onWallpaperCreated = functions.firestore
  .document('wallpapers/{wallpaperId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    if (!data) return;

    const db = admin.firestore();
    const wallpaperId = context.params.wallpaperId;

    // Check basic filters e.g. title lengths or tag checks
    const hasFlag = data.name.toLowerCase().includes('inappropriate') || data.description.toLowerCase().includes('inappropriate');

    if (hasFlag) {
      await db.collection('wallpapers').doc(wallpaperId).update({
        status: 'rejected',
      });
    } else {
      // Auto-approve by default in MVP staging, otherwise 'pending'
      await db.collection('wallpapers').doc(wallpaperId).update({
        status: 'approved',
      });
    }
  });

/// S43 — Update creator balances on purchase transaction completion.
export const onTransactionComplete = functions.firestore
  .document('transactions/{transactionId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const prevData = change.before.data();

    // Check if status transitioned to completed
    if (newData.status === 'completed' && prevData.status !== 'completed') {
      const db = admin.firestore();

      if (newData.type === 'purchase' && newData.wallpaperId) {
        const wpDoc = await db.collection('wallpapers').doc(newData.wallpaperId).get();
        if (wpDoc.exists) {
          const creatorId = wpDoc.data()?.creatorId;
          if (creatorId) {
            const creatorRef = db.collection('creators').doc(creatorId);

            // Give creator 80% split per PRD pricing models
            const creatorEarnings = newData.amount * 0.8;

            await db.runTransaction(async (transaction) => {
              const creatorDoc = await transaction.get(creatorRef);
              if (creatorDoc.exists) {
                const totalEarnings = creatorDoc.data()?.totalEarnings || 0;
                const availableBalance = creatorDoc.data()?.availableBalance || 0;
                const totalSales = creatorDoc.data()?.totalSales || 0;

                transaction.update(creatorRef, {
                  totalEarnings: totalEarnings + creatorEarnings,
                  availableBalance: availableBalance + creatorEarnings,
                  totalSales: totalSales + 1,
                });
              }
            });

            // Create notification for creator S25
            await db.collection('notifications').add({
              userId: wpDoc.data()?.creatorUserId || creatorId,
              type: 'sale',
              title: 'Wallpaper Sold!',
              body: `Your wallpaper "${wpDoc.data()?.name}" was purchased. You earned ₹${creatorEarnings.toFixed(2)}.`,
              isRead: false,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
        }
      }
    }
  });
