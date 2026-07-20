import * as admin from 'firebase-admin';

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Export payments functions
export { createOrder, verifyPayment } from './payments';

// Export payouts functions
export { processPayout } from './payouts';

// Export triggers
export { onWallpaperCreated, onTransactionComplete } from './triggers';

// Export scheduled tasks
export { cleanupSubscriptions } from './scheduled';
