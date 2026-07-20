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
exports.cleanupSubscriptions = exports.onTransactionComplete = exports.onWallpaperCreated = exports.processPayout = exports.verifyPayment = exports.createOrder = void 0;
const admin = __importStar(require("firebase-admin"));
// Initialize the Firebase Admin SDK
admin.initializeApp();
// Export payments functions
var payments_1 = require("./payments");
Object.defineProperty(exports, "createOrder", { enumerable: true, get: function () { return payments_1.createOrder; } });
Object.defineProperty(exports, "verifyPayment", { enumerable: true, get: function () { return payments_1.verifyPayment; } });
// Export payouts functions
var payouts_1 = require("./payouts");
Object.defineProperty(exports, "processPayout", { enumerable: true, get: function () { return payouts_1.processPayout; } });
// Export triggers
var triggers_1 = require("./triggers");
Object.defineProperty(exports, "onWallpaperCreated", { enumerable: true, get: function () { return triggers_1.onWallpaperCreated; } });
Object.defineProperty(exports, "onTransactionComplete", { enumerable: true, get: function () { return triggers_1.onTransactionComplete; } });
// Export scheduled tasks
var scheduled_1 = require("./scheduled");
Object.defineProperty(exports, "cleanupSubscriptions", { enumerable: true, get: function () { return scheduled_1.cleanupSubscriptions; } });
//# sourceMappingURL=index.js.map