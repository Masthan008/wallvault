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
exports.cleanupSubscriptions = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
/// S44 — Daily subscription cleanup scheduler.
exports.cleanupSubscriptions = functions.pubsub
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
//# sourceMappingURL=scheduled.js.map