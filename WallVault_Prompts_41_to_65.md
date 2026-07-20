WALLVAULT — AntiGravity IDE Prompts (Part 3: Prompts 41-65)
CRED-Inspired Dark Theme Wallpaper App with Creator Economy
📋 HOW TO USE THESE PROMPTS
Complete Prompts 1-40 first before starting these
Copy one prompt at a time into AntiGravity IDE
Run and test before moving to next
Reference previous prompts for consistency
PHASE 3 CONTINUED: WEB PORTALS (Prompts 41-43)
Prompt 41: Admin Payout Management (S33)
plain
Create Admin Payout Management Page in Next.js:

1. Layout: sidebar + main content

2. Pending Payouts table (primary):
   - Heading: "Pending Payouts" with count badge
   - Columns: Creator (avatar + name), Amount, Method, Requested Date, Actions
   - Action: "Process" button (gold gradient) per row
   - "Process All" button top-right (for bulk)
   - Sortable by amount/date
   - Row hover highlight
   - Pagination: 10 per page

3. Payout History table (below):
   - Heading: "Payout History"
   - Columns: Date, Creator, Amount, Method, Status, Transaction ID
   - Status badges:
     - Completed: green checkmark + green left border
     - Failed: red X + failure reason tooltip
     - Processing: orange spinner
   - Filter by status, date range
   - Search by creator name

4. Summary cards (top):
   - "Total Processed: ₹45K"
   - "Pending: ₹12K"
   - "Failed: ₹0"
   - "This Month: ₹18K"

5. Export functionality:
   - "Export CSV" button
   - Includes all payout data
   - Date range selector for export

6. Process payout flow:
   - Click "Process" → confirmation modal
   - "Are you sure you want to process ₹X to [Creator]?"
   - "Process" / "Cancel"
   - Loading state while API call
   - Success: green toast, status updates
   - Failure: red toast with error
Prompt 42: Admin User Management (S34)
plain
Create Admin User Management Page in Next.js:

1. Layout: sidebar + main content

2. Top controls:
   - Heading: "Users"
   - Search bar: search by name, email, phone
   - Filters: Status (All/Active/Suspended), Subscription (All/Free/Pro), Date Joined
   - "Export CSV" button

3. Users table:
   - Columns: Avatar, Name, Email, Phone, Joined Date, Downloads, Subscription, Status, Actions
   - Subscription badge:
     - Free: gray pill
     - Pro Monthly: purple pill
     - Pro Yearly: gold pill
     - Lifetime: gold crown icon
   - Status: Active (green dot), Suspended (red dot), Banned (gray)
   - Actions: View, Edit, Suspend, Ban
   - Sortable columns
   - Pagination: 20 per page

4. User detail sidebar (right):
   - Triggered by "View" action
   - Width: 400px, slides in from right
   - Content:
     - Profile: avatar, name, email, phone, joined date
     - Stats: downloads, favorites, following, uploads
     - Activity log: recent actions with timestamps
     - Subscription details: plan, start date, end date
     - Payment history: list of transactions
     - Danger zone: Suspend, Ban buttons

5. Ban/Suspend flow:
   - Confirmation modal
   - Reason textarea (required)
   - Duration selector (temporary/permanent)
   - "Confirm" / "Cancel"
   - Email notification sent to user

6. Responsive:
   - Mobile: cards instead of table
   - Detail becomes full-screen modal
Prompt 43: Admin Payment Analytics (S35)
plain
Create Admin Payment Analytics Page in Next.js:

1. Layout: sidebar + main content

2. Date range picker:
   - Top right
   - Presets: Today, Yesterday, Last 7 Days, Last 30 Days, This Month, Custom
   - Dark themed calendar

3. Revenue cards (top row):
   - "Total Revenue" ₹89K
   - "Subscription Revenue" ₹45K
   - "Wallpaper Sales" ₹32K
   - "Tips" ₹12K
   - Each with % change indicator
   - Animated counters on enter

4. Charts:

   Revenue Breakdown (stacked area chart):
   - Layers: Subscriptions (purple), Sales (cyan), Tips (gold)
   - Time series: daily
   - Interactive legend (toggle layers)
   - Tooltip on hover

   Revenue vs Payouts (dual axis chart):
   - Left axis: Revenue (purple bars)
   - Right axis: Payouts (gold line)
   - Monthly view

   Top Selling Wallpapers (horizontal bar chart):
   - Wallpaper names on Y-axis
   - Revenue on X-axis
   - Top 10

   Revenue by Category (donut chart):
   - Categories: Nature, Abstract, Cars, etc.
   - Neon colors
   - Percentage labels

5. Refund/Disputes section:
   - Alert banner if pending disputes
   - Table: Date, User, Amount, Reason, Status
   - Actions: Approve Refund, Reject, View Details

6. Export Reports:
   - "Export Revenue Report" button
   - CSV/PDF options
   - Date range applied
PHASE 4: BUSINESS LOGIC (Prompts 44-53)
Prompt 44: Authentication Flow
plain
Implement complete authentication flow in lib/providers/auth_provider.dart:

1. AuthState enum: initial, loading, authenticated, unauthenticated, error

2. Phone Authentication:
   - sendOTP(phoneNumber):
     - Validate Indian phone format (+91)
     - Call Firebase Auth verifyPhoneNumber
     - Return verificationId
     - Handle errors: invalid format, too many requests

   - verifyOTP(otp, verificationId):
     - Create PhoneAuthCredential
     - Sign in with credential
     - Create user document in Firestore if new
     - Update lastLoginAt
     - Navigate based on onboarding status

3. Google Sign-In:
   - Trigger Google OAuth
   - Get GoogleAuthCredential
   - Sign in with credential
   - Create/update user document
   - Handle account linking if phone exists

4. Apple Sign-In:
   - Trigger Apple OAuth (iOS only)
   - Get AppleAuthCredential
   - Handle name/email (first-time only)
   - Sign in with credential

5. Auth State Management:
   - StreamSubscription on authStateChanges
   - Auto-login on app launch
   - Token refresh handling
   - Logout: clear state, navigate to login

6. Error Handling:
   - Network error: retry button
   - Invalid OTP: shake animation + error message
   - Account disabled: show support contact
   - Rate limiting: countdown timer

7. Security:
   - Store auth tokens securely (Flutter Secure Storage)
   - Biometric prompt option
   - Session timeout after 30 days inactivity
Prompt 45: Wallpaper Discovery Engine
plain
Implement wallpaper discovery algorithm in lib/services/wallpaper_service.dart:

1. Fetch Methods:
   - getForYou(userId, limit, lastDoc):
     - 40% editorial curated (featured flag)
     - 40% collaborative filtering (based on downloads/likes)
     - 20% new uploads (last 7 days)
     - Exclude already downloaded
     - Shuffle results

   - getTrending(limit, lastDoc):
     - Download velocity: downloads / hours since upload
     - Weighted by recency (last 24h = 3x, 7d = 2x, 30d = 1x)
     - Minimum 10 downloads to qualify

   - getByCategory(category, limit, lastDoc):
     - Filter by category field
     - Sort by downloads desc
     - Pagination with Firestore cursor

   - searchWallpapers(query, filters):
     - Full-text search on name, tags, description
     - Use Algolia or Firestore array-contains
     - Filter by price (free/paid), resolution, category
     - Sort by relevance score

2. Caching:
   - Cache home feed for 5 minutes
   - Cache search results for 2 minutes
   - Image thumbnails cached via CachedNetworkImage
   - Offline support: store last viewed in SQLite

3. Personalization:
   - Track user interactions (views, downloads, likes)
   - Store preference vector in user document
   - Recommend similar wallpapers based on tags
   - "Because you liked X" section

4. Real-time Updates:
   - Listen to featured wallpapers collection
   - Update trending every hour via Cloud Function
   - New upload notifications for followers
Prompt 46: Download & Apply Logic
plain
Implement download and apply functionality in lib/services/download_service.dart:

1. Download Flow:
   - checkPermission():
     - Android: storage permission (Android 13+ granular)
     - iOS: photo library permission

   - downloadWallpaper(wallpaperId):
     - Check if already downloaded (local DB)
     - If paid: verify purchase (check transactions)
     - Get download URL from Cloudinary (full resolution)
     - Show progress notification
     - Download to app cache
     - Save to device gallery (optional setting)
     - Mark as downloaded in Firestore
     - Update download count (Cloud Function)
     - Show success notification with confetti
     - Haptic: medium tap

2. Apply Flow:
   - previewWallpaper(wallpaperId, target):
     - Show preview overlay on Home/Lock/Both
     - Render wallpaper behind simulated UI

   - applyWallpaper(wallpaperId, target):
     - Use platform channel to set wallpaper
     - Android: WallpaperManager API
     - iOS: UIApplication.shared.open (limited, show guide)
     - Show "Applied successfully" toast
     - Update apply count analytics
     - Haptic: medium tap

3. Offline Support:
   - Store downloaded wallpapers in app documents
   - Show offline indicator in My Downloads
   - Allow apply without internet
   - Sync pending actions when online

4. Batch Operations:
   - Multi-select in My Downloads
   - Delete selected (with confirmation)
   - Share selected (zip file)
Prompt 47: Creator Upload Pipeline
plain
Implement creator upload pipeline in lib/services/creator_service.dart:

1. Upload Flow:
   - validateImage(file):
     - Check format: JPG, PNG, WEBP
     - Check size: max 20MB
     - Check resolution: min 1080p (1920x1080)
     - Check aspect ratio: 9:16, 16:9, or 1:1
     - Return validation errors if any

   - uploadToCloudinary(file):
     - Get signed upload URL from Cloud Function
     - Upload with progress tracking
     - Return: public_id, url, secure_url
     - Handle upload errors (retry 3x)

   - createWallpaperDocument(data):
     - Create wallpaper document in Firestore
     - Status: "pending"
     - Set createdAt, updatedAt
     - Add to creator's uploads array
     - Trigger admin notification (Cloud Function)

2. Pricing Logic:
   - calculateEarnings(price):
     - Creator: price * 0.70
     - Platform: price * 0.20
     - Community: price * 0.10
     - Return breakdown object

   - validatePrice(price):
     - Min: ₹10, Max: ₹999
     - Must be integer
     - Return error if invalid

3. Auto-Moderation:
   - Check image hash against known inappropriate content
   - Flag if resolution doesn't match claimed
   - AI content detection (post-MVP)
   - Auto-approve for Level 3+ creators

4. Status Tracking:
   - Listen to wallpaper document changes
   - Show pending/approved/rejected status
   - Push notification on status change
   - Update creator dashboard in real-time
Prompt 48: Payment Processing
plain
Implement payment processing in lib/services/payment_service.dart:

1. Razorpay Integration:
   - initializeRazorpay():
     - Set key ID (test/live based on build)
     - Configure theme: dark, color: #B829DD
     - Set business name: "WallVault"

   - createOrder(amount, description, userId):
     - Call Cloud Function: createRazorpayOrder
     - Return: orderId, amount, currency

   - openCheckout(options):
     - Set orderId, amount, description
     - Prefill: user email, phone, name
     - Theme: dark mode
     - Show Razorpay checkout modal

   - handlePaymentSuccess(response):
     - Get: razorpay_payment_id, razorpay_order_id, razorpay_signature
     - Call Cloud Function: verifyPayment
     - On success: create transaction, update user
     - On failure: show error, allow retry

   - handlePaymentError(response):
     - Log error details
     - Show user-friendly error message
     - Offer retry or alternative method

2. Subscription Management:
   - subscribeToPlan(plan):
     - Create Razorpay subscription
     - Plans: monthly_49, yearly_299, lifetime_999
     - Handle first payment
     - Update user.subscription on webhook

   - cancelSubscription():
     - Call Razorpay API to cancel
     - Update user document
     - Show confirmation

   - restorePurchases():
     - Query Razorpay for active subscriptions
     - Sync with local state
     - Handle edge cases

3. Wallet / Balance:
   - For creator earnings
   - Track available balance
   - Update on each sale
   - Payout reduces balance

4. Security:
   - Never store API keys in client
   - All sensitive operations via Cloud Functions
   - Webhook signature verification
   - Idempotency keys for all transactions
Prompt 49: Payout Management
plain
Implement payout management in lib/services/payout_service.dart:

1. Creator Side:
   - getAvailableBalance(creatorId):
     - Sum of completed sales (70%)
     - Subtract processed payouts
     - Subtract pending payouts
     - Return available amount

   - requestPayout(amount, method):
     - Validate: amount >= ₹500
     - Validate: amount <= available balance
     - Validate: payout method exists
     - Create payout document: status "pending"
     - Deduct from available balance (hold)
     - Notify admin (FCM + email)
     - Return payoutId

   - getPayoutHistory(creatorId):
     - Query payouts collection
     - Sort by createdAt desc
     - Return paginated list

2. Admin Side:
   - getPendingPayouts():
     - Query payouts where status == "pending"
     - Sort by createdAt asc (oldest first)
     - Return list with creator details

   - processPayout(payoutId):
     - Get payout document
     - Get creator payout method
     - Call RazorpayX API:
       - Create fund account if not exists
       - Create payout (UPI or Razorpay account)
       - Amount in paise
       - Purpose: "payout"
     - Update payout: status "processing", razorpayPayoutId
     - Wait for webhook

   - handlePayoutWebhook(event):
     - On processed: update status "completed", add transactionId
     - On failed: update status "failed", add failureReason
     - Release hold on failure
     - Notify creator (FCM + email)
     - Log for admin review

3. RazorpayX Integration:
   - Create contact for new creator
   - Create fund account (UPI ID)
   - Validate UPI ID before payout
   - Handle NPCI errors gracefully
   - Retry failed payouts (max 3x)

4. Reporting:
   - Monthly payout report for creators
   - Tax document generation (TDS if applicable)
   - Export for accounting
Prompt 50: Notification System
plain
Implement notification system in lib/services/notification_service.dart:

1. Push Notifications (FCM):
   - initializeFCM():
     - Request permission (iOS)
     - Get FCM token
     - Store token in user document
     - Handle token refresh

   - foregroundMessageHandler(message):
     - Show local notification
     - Custom styling: purple accent
     - Tap: navigate to relevant screen

   - backgroundMessageHandler(message):
     - Store in local notification list
     - Update badge count

   - onNotificationTap(message):
     - Parse data payload
     - Navigate: wallpaper detail, creator dashboard, payout status

2. In-App Notifications:
   - getNotifications(userId):
     - Query notifications collection
     - Sort by createdAt desc
     - Mark as read on view
     - Return paginated list

   - markAsRead(notificationId):
     - Update isRead: true
     - Decrement unread count

   - markAllAsRead(userId):
     - Batch update all unread notifications

3. Notification Types:
   - Sale: "You made a sale! [Wallpaper] purchased for ₹X"
   - Payout: "Payout of ₹X processed successfully"
   - Approval: "Your creator application was approved!"
   - Tip: "@user tipped you ₹X for [Wallpaper]"
   - Follow: "@user started following you"
   - System: "New feature: Dark mode is here!"
   - Streak: "🔥 7-day streak! Keep it up!"

4. Notification Builder (Cloud Function):
   - createNotification(userId, type, title, body, data):
     - Create document in notifications collection
     - Send FCM if user has token
     - Increment unread count
     - Email fallback for important notifications

5. Settings:
   - Allow user to toggle notification types
   - Quiet hours (10 PM - 8 AM)
   - Email preferences
Prompt 51: Gamification Engine
plain
Implement gamification in lib/services/gamification_service.dart:

1. User Gamification:
   - trackDownloadStreak(userId):
     - Check last download date
     - If consecutive day: increment streak
     - If missed: reset to 1
     - If streak milestone (7, 30, 100): award badge
     - Update streak in user document

   - awardBadge(userId, badgeId):
     - Check if already has badge
     - Add to badges array
     - Show badge unlock animation
     - Send notification
     - Award XP bonus

   - checkCollectionCompletion(userId, category):
     - Count unique downloads in category
     - If threshold met (e.g., 10 nature wallpapers):
     - Award "[Category] Explorer" badge

   - calculateUserLevel(xp):
     - Level formula: floor(sqrt(xp / 100))
     - Max level: 50
     - Return level + progress to next

2. Creator Gamification:
   - calculateCreatorLevel(creatorId):
     - XP sources:
       - Upload: +10 XP
       - Download: +1 XP per download
       - Sale: +50 XP
       - Tip: +20 XP
       - Featured: +100 XP
     - Level thresholds:
       - 1: 0 XP (Seedling)
       - 2: 100 XP (Sprout)
       - 3: 500 XP (Bloom)
       - 4: 2000 XP (Star)
       - 5: 10000 XP (Legend)

   - updateLeaderboard():
     - Weekly cron job (Cloud Function)
     - Rank creators by downloads + earnings
     - Top 10 get "Trending Creator" badge
     - Update leaderboard document

3. Rewards:
   - Streak rewards:
     - 7 days: 50 XP + "Week Warrior" badge
     - 30 days: 200 XP + "Month Master" badge
     - 100 days: 1000 XP + "Centurion" badge + 7-day Pro trial

   - Referral rewards:
     - Referrer: 7-day Pro trial
     - Referee: 7-day Pro trial
     - Track referral code usage

4. Animations:
   - Badge unlock: scale bounce + sparkle
   - Level up: XP bar fill + particle trail
   - Streak milestone: fire burst animation
Prompt 52: Search & Filtering
plain
Implement search in lib/services/search_service.dart:

1. Search Implementation:
   - searchWallpapers(query, filters, sort, pagination):
     - Sanitize query (remove special chars)
     - Case-insensitive search
     - Fields: name, description, tags, creatorName

     - Filters:
       - Price: free / paid / range
       - Category: multi-select
       - Resolution: 1080p / 2K / 4K / 8K
       - Aspect Ratio: 9:16 / 16:9 / 1:1
       - Date: today / week / month / all
       - Creator: verified only / all

     - Sort options:
       - Relevance (default)
       - Most Downloaded
       - Newest First
       - Price: Low to High
       - Price: High to Low
       - Top Rated

   - getSearchSuggestions(query):
     - Return matching tags, creators, popular searches
     - Max 8 suggestions
     - Cache for 1 hour

2. Algolia Integration (optional, post-MVP):
   - Index wallpapers on upload
   - Faceted search
   - Typo tolerance
   - Synonyms support

3. Firestore Search (MVP):
   - array-contains for tags
   - range queries for price
   - orderBy + startAfter for pagination
   - Composite indexes for complex queries

4. Search Analytics:
   - Track search queries
   - Track zero-result searches
   - Track filter usage
   - Improve suggestions based on data
Prompt 53: Analytics Tracking
plain
Implement analytics in lib/services/analytics_service.dart:

1. Event Tracking:
   - logEvent(name, parameters):
     - Firebase Analytics logEvent
     - Custom events for business metrics
     - Batch events (send every 30s or 20 events)

   - Screen Tracking:
     - Auto-track screen views
     - Screen name, duration
     - Navigation path

2. Key Events:
   - User: app_open, login, signup, logout
   - Discovery: wallpaper_view, search, category_filter
   - Engagement: wallpaper_download, wallpaper_apply, wallpaper_share, wallpaper_like
   - Creator: creator_enroll_start, creator_enroll_complete, upload_start, upload_complete
   - Monetization: purchase_initiated, purchase_completed, subscription_started, tip_sent
   - Retention: session_start, session_end, streak_maintained

3. User Properties:
   - Set on login: user_id, subscription_tier, creator_level
   - Update on change
   - Use for cohort analysis

4. Dashboard Metrics:
   - DAU/MAU (daily cron)
   - Conversion funnel (view → download → purchase)
   - Churn rate (30-day rolling)
   - LTV calculation
   - Cohort retention curves

5. Privacy:
   - Respect user tracking preferences
   - Anonymize data where possible
   - GDPR compliance: data export, deletion
PHASE 5: BACKEND CLOUD FUNCTIONS (Prompts 54-65)
Prompt 54: Auth Cloud Functions
plain
Implement Firebase Cloud Functions for auth in functions/src/auth/:

1. onUserCreated (trigger: auth.user().onCreate):
   - Create user document in Firestore
   - Set default values: isCreator: false, subscription: free
   - Send welcome email
   - Initialize analytics user

2. onUserDeleted (trigger: auth.user().onDelete):
   - Anonymize user data (GDPR)
   - Delete or anonymize uploads
   - Cancel subscriptions
   - Log deletion for compliance

3. createCustomToken (HTTPS Callable):
   - Input: uid
   - Output: custom Firebase token
   - Use case: linking accounts

4. verifyIdToken (HTTPS Callable):
   - Input: idToken
   - Output: decoded token or error
   - Use case: custom verification flows

5. cleanupAnonymousUsers (scheduled: daily):
   - Delete anonymous users older than 30 days
   - Free up Firebase Auth quota
Prompt 55: Payment Cloud Functions
plain
Implement payment Cloud Functions in functions/src/payments/:

1. createRazorpayOrder (HTTPS Callable):
   - Input: { amount, currency, receipt, notes }
   - Validate: amount >= 100 (₹1 in paise)
   - Call Razorpay API: orders.create
   - Return: { orderId, amount, currency }
   - Log for audit

2. verifyRazorpayPayment (HTTPS Callable):
   - Input: { orderId, paymentId, signature }
   - Verify signature using HMAC SHA256
   - Secret from environment variable
   - Return: { success: true/false }
   - If success: trigger onPaymentSuccess

3. onPaymentSuccess (internal):
   - Create transaction document
   - Update user subscriptions (if subscription)
   - Update creator balance (if wallpaper purchase)
   - Send notifications
   - Update analytics

4. handleRazorpayWebhook (HTTPS onRequest):
   - Verify webhook signature
   - Handle events:
     - payment.captured: confirm transaction
     - payment.failed: mark failed, notify user
     - subscription.charged: extend subscription
     - subscription.cancelled: update user
   - Return 200 OK

5. createRazorpaySubscription (HTTPS Callable):
   - Input: { plan, userId }
   - Create subscription via Razorpay API
   - Return: { subscriptionId }

6. cancelRazorpaySubscription (HTTPS Callable):
   - Input: { subscriptionId }
   - Cancel via Razorpay API
   - Update user document
Prompt 56: Payout Cloud Functions
plain
Implement payout Cloud Functions in functions/src/payouts/:

1. requestPayout (HTTPS Callable):
   - Input: { creatorId, amount, method }
   - Validate: amount >= 50000 (₹500 in paise)
   - Validate: amount <= available balance
   - Create payout document: status "pending"
   - Hold balance (create hold record)
   - Notify admin
   - Return: { payoutId }

2. processPayout (HTTPS Callable - admin only):
   - Input: { payoutId }
   - Get payout document
   - Get creator payout method
   - Call RazorpayX:
     - Create contact (if new)
     - Create fund account (if new)
     - Create payout
   - Update payout: status "processing"
   - Return: { success, razorpayPayoutId }

3. handlePayoutWebhook (HTTPS onRequest):
   - Verify RazorpayX webhook signature
   - Handle events:
     - payout.processed: update completed
     - payout.failed: update failed, release hold
     - payout.reversed: update reversed
   - Notify creator
   - Update analytics

4. batchProcessPayouts (HTTPS Callable - admin only):
   - Input: { payoutIds }
   - Process each payout sequentially
   - Return: { processed: [], failed: [] }
   - Rate limit: max 10 per call

5. autoProcessPayouts (scheduled: weekly):
   - Find payouts pending > 48 hours
   - Auto-process for verified creators
   - Log all actions
   - Send summary to admin

6. calculateCreatorBalance (HTTPS Callable):
   - Input: { creatorId }
   - Calculate: total earnings - total payouts - pending payouts
   - Return: { availableBalance, totalEarnings, totalPayouts }
Prompt 57: Notification Cloud Functions
plain
Implement notification Cloud Functions in functions/src/notifications/:

1. sendPushNotification (HTTPS Callable):
   - Input: { userId, title, body, data }
   - Get FCM token from user document
   - Send via Firebase Admin FCM
   - Handle token errors (remove invalid tokens)
   - Log delivery status

2. onWallpaperPurchased (trigger: transactions onCreate):
   - If type == "purchase":
     - Notify creator: "You made a sale!"
     - Include wallpaper name, amount
   - If type == "tip":
     - Notify creator: "You received a tip!"
     - Include tipper name, amount

3. onPayoutStatusChanged (trigger: payouts onUpdate):
   - If status changed to "completed":
     - Notify creator: "Payout processed!"
     - Include amount, transaction ID
   - If status changed to "failed":
     - Notify creator: "Payout failed"
     - Include reason, retry option

4. onCreatorStatusChanged (trigger: creators onUpdate):
   - If status changed to "approved":
     - Notify user: "Your creator application was approved!"
   - If status changed to "suspended":
     - Notify user: "Your creator account was suspended"
     - Include reason, appeal option

5. sendBulkNotification (HTTPS Callable - admin only):
   - Input: { userIds, title, body, data }
   - Send to multiple users
   - Rate limit: 100 per call
   - Use FCM multicast

6. cleanupOldNotifications (scheduled: daily):
   - Delete notifications older than 90 days
   - Archive to BigQuery (optional)
Prompt 58: Image Processing Functions
plain
Implement image processing in functions/src/images/:

1. onWallpaperUploaded (trigger: storage.onFinalize):
   - Get uploaded image from Firebase Storage
   - Validate: format, size, resolution
   - Generate thumbnails via Cloudinary:
     - Thumbnail: 400x600, quality: auto
     - Preview: 800x1200, quality: auto
     - Full: 1920x2880, quality: auto
   - Store URLs in wallpaper document
   - Delete original from Firebase Storage
   - Log processing time

2. generateThumbnail (HTTPS Callable):
   - Input: { imageUrl, width, height }
   - Use Cloudinary transformation URL
   - Return: { thumbnailUrl }

3. validateImage (HTTPS Callable):
   - Input: { imageUrl }
   - Check resolution, format, size
   - Check for inappropriate content (AI vision API)
   - Return: { valid, errors, metadata }

4. optimizeImage (HTTPS Callable):
   - Input: { publicId }
   - Apply Cloudinary optimizations:
     - Auto format (f_auto)
     - Auto quality (q_auto)
     - Progressive JPEG
   - Return: { optimizedUrl }

5. cleanupUnusedImages (scheduled: weekly):
   - Find images not referenced in Firestore
   - Delete from Cloudinary
   - Log cleanup report
Prompt 59: Scheduled Functions
plain
Implement scheduled Cloud Functions in functions/src/scheduled/:

1. updateTrendingWallpapers (schedule: every 1 hour):
   - Calculate download velocity for last 24h
   - Update trending collection
   - Rank by velocity score
   - Keep top 100

2. cleanupExpiredSubscriptions (schedule: every day at midnight):
   - Find subscriptions with endDate < now
   - Update user.subscription.plan = "free"
   - Send expiry notification (3 days before, 1 day before, on day)
   - Log churn events

3. calculateCreatorLeaderboard (schedule: every Monday at midnight):
   - Rank creators by: downloads (40%) + earnings (40%) + new uploads (20%)
   - Update leaderboard document
   - Award "Trending Creator" badges to top 10
   - Send weekly summary to creators

4. processCommunityPool (schedule: every month):
   - Calculate 10% community pool total
   - Distribute to:
     - Monthly contest winners (50%)
     - Featured creator rewards (30%)
     - Platform improvements (20%)
   - Log distribution

5. sendStreakReminders (schedule: every day at 8 PM):
   - Find users with active streak (downloaded yesterday)
   - Not downloaded today
   - Send push: "Don't break your 🔥 streak! Download a wallpaper today"

6. generateWeeklyReport (schedule: every Monday):
   - Aggregate metrics: new users, downloads, revenue, payouts
   - Send email report to admin
   - Store in reports collection
Prompt 60: Webhook Handlers
plain
Implement webhook handlers in functions/src/webhooks/:

1. razorpayPaymentWebhook (HTTPS onRequest):
   - Path: /webhooks/razorpay/payment
   - Verify signature (Razorpay secret)
   - Handle events:
     - payment.captured: confirm, update transaction
     - payment.failed: mark failed, notify user
     - refund.processed: update transaction, notify user
   - Return 200 OK
   - Log all events

2. razorpaySubscriptionWebhook (HTTPS onRequest):
   - Path: /webhooks/razorpay/subscription
   - Verify signature
   - Handle events:
     - subscription.charged: extend endDate
     - subscription.cancelled: update plan to free
     - subscription.pending: notify user
   - Return 200 OK

3. razorpayXPayoutWebhook (HTTPS onRequest):
   - Path: /webhooks/razorpayx/payout
   - Verify signature
   - Handle events:
     - payout.processed: update payout, notify creator
     - payout.failed: update payout, release hold, notify creator
     - payout.reversed: update payout, notify creator
   - Return 200 OK

4. cloudinaryWebhook (HTTPS onRequest):
   - Path: /webhooks/cloudinary
   - Verify Cloudinary signature
   - Handle events:
     - upload: update wallpaper with URLs
     - delete: cleanup references
   - Return 200 OK

5. healthCheck (HTTPS onRequest):
   - Path: /health
   - Return: { status: "ok", timestamp, version }
   - Use for uptime monitoring
Prompt 61: Security Rules
plain
Implement Firestore Security Rules in firestore.rules:

1. Users Collection:
   match /users/{userId} {
     allow read: if request.auth != null && request.auth.uid == userId;
     allow write: if request.auth != null && request.auth.uid == userId;
     allow create: if request.auth != null && request.auth.uid == userId;
   }

2. Wallpapers Collection:
   match /wallpapers/{wallpaperId} {
     allow read: if true;
     allow create: if request.auth != null && 
       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isCreator == true;
     allow update: if request.auth != null && 
       (resource.data.creatorId == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin");
     allow delete: if request.auth != null && 
       (resource.data.creatorId == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin");
   }

3. Creators Collection:
   match /creators/{creatorId} {
     allow read: if true;
     allow write: if request.auth != null && request.auth.uid == creatorId;
   }

4. Transactions Collection:
   match /transactions/{transactionId} {
     allow read: if request.auth != null && 
       (resource.data.userId == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin");
     allow write: if false; // Only Cloud Functions
   }

5. Payouts Collection:
   match /payouts/{payoutId} {
     allow read: if request.auth != null && 
       (resource.data.creatorId == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin");
     allow write: if false; // Only Cloud Functions
   }

6. Notifications Collection:
   match /notifications/{notificationId} {
     allow read: if request.auth != null && resource.data.userId == request.auth.uid;
     allow write: if false; // Only Cloud Functions
   }

7. Admin Collection:
   match /admin/{document=**} {
     allow read, write: if request.auth != null && 
       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
   }
Prompt 62: Firebase Storage Rules
plain
Implement Storage Security Rules in storage.rules:

1. User Uploads:
   match /users/{userId}/{allPaths=**} {
     allow read: if request.auth != null && request.auth.uid == userId;
     allow write: if request.auth != null && request.auth.uid == userId
       && request.resource.size < 20 * 1024 * 1024 // 20MB
       && request.resource.contentType.matches('image/.*');
   }

2. Temp Uploads (before Cloudinary processing):
   match /temp/{allPaths=**} {
     allow read: if request.auth != null;
     allow write: if request.auth != null
       && request.resource.size < 20 * 1024 * 1024
       && request.resource.contentType.matches('image/.*');
     allow delete: if request.auth != null;
   }

3. Admin Access:
   match /admin/{allPaths=**} {
     allow read, write: if request.auth != null && 
       firestore.get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
   }
Prompt 63: Firebase Configuration & Indexes
plain
Setup Firebase configuration in firebase.json and firestore.indexes.json:

1. Firebase.json:
   - Hosting: SPA rewrite rules
   - Functions: Node.js 18 runtime
   - Storage: default bucket rules
   - Emulators: all services for local dev

2. Firestore Indexes (firestore.indexes.json):
   - wallpapers: category ASC, downloads DESC
   - wallpapers: status ASC, createdAt DESC
   - wallpapers: creatorId ASC, createdAt DESC
   - wallpapers: tags ARRAY_CONTAINS, downloads DESC
   - transactions: userId ASC, createdAt DESC
   - transactions: creatorId ASC, createdAt DESC
   - payouts: creatorId ASC, createdAt DESC
   - payouts: status ASC, createdAt ASC
   - notifications: userId ASC, createdAt DESC
   - notifications: userId ASC, isRead ASC, createdAt DESC

3. Environment Variables (.env):
   - RAZORPAY_KEY_ID
   - RAZORPAY_KEY_SECRET
   - RAZORPAYX_KEY_ID
   - RAZORPAYX_KEY_SECRET
   - CLOUDINARY_CLOUD_NAME
   - CLOUDINARY_API_KEY
   - CLOUDINARY_API_SECRET
   - ALGOLIA_APP_ID (optional)
   - ALGOLIA_API_KEY (optional)

4. Firebase Emulators:
   - Auth emulator: 9099
   - Firestore emulator: 8080
   - Functions emulator: 5001
   - Storage emulator: 9199
   - Hosting emulator: 5000
PHASE 6: INTEGRATION & TESTING (Prompts 64-65)
Prompt 64: Integration Testing
plain
Create integration tests for WallVault:

1. Auth Flow Tests:
   - Sign up with phone → verify OTP → onboard → home
   - Login with Google → sync data → home
   - Logout → clear state → login screen
   - Token refresh → seamless re-auth

2. Wallpaper Flow Tests:
   - Browse home → tap wallpaper → detail → download → apply
   - Search → filter → download → add to favorites
   - Pull to refresh → new content loaded
   - Offline → cached wallpapers viewable

3. Creator Flow Tests:
   - Enroll as creator → upload 3 samples → set UPI → submit
   - Upload wallpaper → set price → publish → pending approval
   - Admin approves → wallpaper live → user purchases
   - Creator sees earnings → requests payout → admin processes

4. Payment Flow Tests:
   - Buy wallpaper → Razorpay checkout → success → unlock
   - Subscribe to Pro → recurring billing → access premium
   - Tip creator → small amount → instant success
   - Failed payment → error handling → retry

5. Admin Flow Tests:
   - Login as admin → view dashboard → process pending items
   - Review wallpaper → approve → creator notified
   - Process payout → RazorpayX → creator receives
   - Ban user → user suspended → can't login

6. Edge Cases:
   - Network failure during payment
   - App killed during upload
   - Invalid UPI ID for payout
   - Duplicate purchase attempt
   - Concurrent downloads
Prompt 65: Performance Optimization
plain
Optimize WallVault performance:

1. Image Optimization:
   - Use WebP format with JPEG fallback
   - Progressive JPEG loading
   - Blur hash placeholder while loading
   - Lazy loading for off-screen images
   - Preload next 3 images in carousel

2. Code Optimization:
   - Code splitting by route
   - Tree shaking unused dependencies
   - Minimize rebuilds with const constructors
   - Use isolates for heavy computations

3. Network Optimization:
   - HTTP/2 for API calls
   - Request batching where possible
   - Cache API responses (5 min for home, 1 min for trending)
   - Offline-first architecture

4. Animation Optimization:
   - Use hardware-accelerated properties only
   - Avoid layout thrashing
   - Use RepaintBoundary for complex widgets
   - Respect reduced-motion preferences

5. Startup Optimization:
   - Defer non-critical initialization
   - Splash screen while loading
   - Preload essential assets
   - Lazy load secondary features

6. Memory Management:
   - Image cache limit: 100MB
   - Dispose controllers on screen exit
   - Clear unused streams
   - Monitor memory leaks in dev mode
✅ ALL 65 PROMPTS COMPLETE
Part 1: Prompts 1-20 (Foundation + Mobile UI)
Part 2: Prompts 21-40 (Mobile UI continued + Web Portals)
Part 3: Prompts 41-65 (Web Portals + Business Logic + Backend + Testing)
Total Prompts: 65
Estimated Development Time: 18-25 days
📊 PROMPT SUMMARY TABLE
Table
Phase	Prompts	Description	Est. Days
Phase 1: Foundation	1-5	Project scaffold, theme, Firebase, state, navigation	1-2
Phase 2: Mobile UI	6-33	All 28 mobile screens + shared states	7-10
Phase 3: Web Portals	34-43	Creator web (4) + Admin web (6)	3-4
Phase 4: Business Logic	44-53	Auth, discovery, download, upload, payment, payout, notifications, gamification, search, analytics	4-5
Phase 5: Backend	54-63	Cloud Functions, webhooks, security rules, configuration	3-4
Phase 6: Integration	64-65	Testing, performance optimization	2-3
TOTAL	65	Complete WallVault	18-25
🚀 EXECUTION CHECKLIST
[ ] Download all 3 prompt files
[ ] Complete Prompts 1-5 (Foundation)
[ ] Complete Prompts 6-20 (Mobile UI Part 1)
[ ] Complete Prompts 21-33 (Mobile UI Part 2 + Shared States)
[ ] Complete Prompts 34-43 (Web Portals)
[ ] Complete Prompts 44-53 (Business Logic)
[ ] Complete Prompts 54-63 (Backend)
[ ] Complete Prompts 64-65 (Integration & Testing)
[ ] Deploy to app stores
[ ] Launch! 🚀