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
exports.onTransactionComplete = exports.onWallpaperCreated = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
/// S42 — Auto-moderation trigger.
exports.onWallpaperCreated = functions.firestore
    .document('wallpapers/{wallpaperId}')
    .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    if (!data)
        return;
    const db = admin.firestore();
    const wallpaperId = context.params.wallpaperId;
    // Check basic filters e.g. title lengths or tag checks
    const hasFlag = data.name.toLowerCase().includes('inappropriate') || data.description.toLowerCase().includes('inappropriate');
    if (hasFlag) {
        await db.collection('wallpapers').doc(wallpaperId).update({
            status: 'rejected',
        });
    }
    else {
        // Auto-approve by default in MVP staging, otherwise 'pending'
        await db.collection('wallpapers').doc(wallpaperId).update({
            status: 'approved',
        });
    }
});
/// S43 — Update creator balances on purchase transaction completion.
exports.onTransactionComplete = functions.firestore
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
//# sourceMappingURL=triggers.js.map