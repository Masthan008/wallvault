WALLVAULT — AntiGravity IDE Prompts (Part 1: Prompts 1-20)
CRED-Inspired Dark Theme Wallpaper App with Creator Economy
📋 HOW TO USE THESE PROMPTS
Copy one prompt at a time into AntiGravity IDE
Run and test before moving to next
Reference previous prompts for consistency
Use Google Stitch for visual design reference
PHASE 1: PROJECT FOUNDATION (Prompts 1-5)
Prompt 1: Project Scaffold & Dependencies
plain
Create a new Flutter project called "wallvault" with the following setup:

1. Add these dependencies to pubspec.yaml:
   - firebase_core, firebase_auth, cloud_firestore, firebase_storage, 
     firebase_messaging, firebase_analytics, firebase_crashlytics
   - flutter_riverpod (state management)
   - go_router (navigation)
   - http, dio (API calls)
   - image_picker, cached_network_image (image handling)
   - flutter_staggered_grid_view (masonry layout)
   - lottie (animations)
   - shimmer (loading skeletons)
   - fluttertoast (notifications)
   - razorpay_flutter (payments)
   - cloudinary_public (image uploads)
   - shared_preferences (local storage)
   - connectivity_plus (network status)
   - flutter_screenutil (responsive design)

2. Create folder structure:
   lib/
   ├── main.dart
   ├── app.dart
   ├── config/
   │   ├── theme.dart
   │   ├── constants.dart
   │   └── routes.dart
   ├── models/
   ├── providers/
   ├── services/
   ├── screens/
   ├── widgets/
   └── utils/

3. Initialize Firebase in main.dart
4. Setup dark theme with CRED-inspired color palette:
   - Background: #0A0A0F
   - Card Surface: #1A1A24
   - Accent Purple: #B829DD
   - Accent Cyan: #00D4FF
   - Gold: #FFD700
   - Text Primary: #FFFFFF
   - Text Secondary: #8B8B9E

5. Setup GoRouter with route guards for auth
Prompt 2: Design System & Theme Configuration
plain
Create a complete design system for WallVault in lib/config/theme.dart:

1. AppTheme class with:
   - DarkThemeData with custom color scheme
   - TextTheme with Inter font (headings bold, body regular)
   - ElevatedButtonTheme with purple gradient, 16px radius, 56px height
   - InputDecorationTheme with dark card surface, purple focus border
   - CardTheme with 20px radius, dark surface, subtle shadow
   - BottomSheetTheme with 24px top radius
   - AppBarTheme with transparent background, white icons

2. Animation constants:
   - Spring curve: cubic-bezier(0.34, 1.56, 0.64, 1)
   - Smooth curve: cubic-bezier(0.4, 0, 0.2, 1)
   - Durations: micro 150ms, fast 250ms, medium 400ms, slow 700ms

3. Spacing constants:
   - Screen padding: 16px
   - Card padding: 16px
   - Grid gap: 12px
   - Section spacing: 24px

4. Component styles:
   - WallpaperCard: 20px radius, aspect ratio 9:16
   - ActionButton: gradient background, shadow, press scale 0.95
   - FAB: 64px circular, purple gradient, floating animation
   - InputField: 12px radius, dark fill, purple border on focus

5. Export as singleton AppTheme.instance
Prompt 3: Firebase Configuration & Services
plain
Create Firebase service configurations in lib/services/:

1. firebase_service.dart:
   - Initialize Firebase app
   - Configure Firebase Auth (Phone, Google, Apple)
   - Setup Firestore instance
   - Configure Firebase Storage
   - Setup Firebase Messaging for push notifications
   - Configure Firebase Analytics
   - Handle Firebase errors gracefully

2. auth_service.dart:
   - PhoneAuth: sendOTP(phone), verifyOTP(otp, verificationId)
   - GoogleAuth: signInWithGoogle()
   - AppleAuth: signInWithApple()
   - AuthState: Stream<User?> authStateChanges
   - Logout: signOut()
   - Get current user: getCurrentUser()

3. firestore_service.dart:
   - Generic CRUD: getDocument, setDocument, updateDocument, deleteDocument
   - Query helpers: where, orderBy, limit, pagination
   - Batch operations
   - Transaction support
   - Real-time listeners

4. storage_service.dart:
   - Upload image to Firebase Storage
   - Get download URL
   - Delete file
   - Upload progress tracking

5. fcm_service.dart:
   - Request notification permissions
   - Get FCM token
   - Handle foreground messages
   - Handle background messages
   - Handle notification taps
   - Subscribe/unsubscribe topics

6. Export all services through a service locator (GetIt or Provider)
Prompt 4: State Management & Providers
plain
Create Riverpod providers in lib/providers/:

1. auth_provider.dart:
   - StateNotifier for AuthState (initial, loading, authenticated, error)
   - loginWithPhone, verifyOTP, loginWithGoogle, loginWithApple, logout
   - Expose currentUser, isAuthenticated, isCreator

2. wallpaper_provider.dart:
   - StateNotifier for WallpaperState (loading, loaded, error)
   - fetchWallpapers(category, limit, lastDoc)
   - searchWallpapers(query)
   - fetchTrending()
   - fetchFeatured()
   - downloadWallpaper(wallpaperId)
   - toggleFavorite(wallpaperId)

3. creator_provider.dart:
   - StateNotifier for CreatorState
   - enrollCreator(data)
   - uploadWallpaper(data)
   - fetchCreatorDashboard()
   - requestPayout(amount)
   - fetchPayoutHistory()

4. payment_provider.dart:
   - StateNotifier for PaymentState
   - createOrder(amount, description)
   - verifyPayment(orderId, paymentId, signature)
   - subscribeToPlan(plan)
   - tipCreator(creatorId, amount)

5. user_provider.dart:
   - StateNotifier for UserState
   - fetchUserProfile()
   - updateProfile(data)
   - fetchDownloads()
   - fetchFavorites()
   - updateSettings(settings)

6. admin_provider.dart (web only):
   - StateNotifier for AdminState
   - fetchPendingWallpapers()
   - approveWallpaper(id)
   - rejectWallpaper(id, reason)
   - fetchPendingCreators()
   - processPayout(payoutId)
   - fetchAnalytics()

7. Create provider overrides for testing
Prompt 5: Navigation & Routing
plain
Create navigation system in lib/config/routes.dart:

1. Define all routes using GoRouter:
   - /splash → SplashScreen
   - /onboarding → OnboardingScreen
   - /login → LoginScreen
   - /signup → SignUpScreen
   - /otp → OTPVerificationScreen
   - /home → HomeScreen (bottom nav root)
   - /wallpaper/:id → WallpaperDetailScreen
   - /search → SearchScreen
   - /profile → ProfileScreen
   - /downloads → MyDownloadsScreen
   - /settings → SettingsScreen
   - /notifications → NotificationsScreen
   - /subscription → SubscriptionScreen
   - /creator/enroll → CreatorEnrollmentScreen
   - /creator/dashboard → CreatorDashboardScreen
   - /creator/upload → CreatorUploadScreen
   - /creator/payout → CreatorPayoutScreen
   - /admin/dashboard → AdminDashboardScreen (web)
   - /admin/wallpapers → AdminWallpapersScreen (web)
   - /admin/creators → AdminCreatorsScreen (web)
   - /admin/payouts → AdminPayoutsScreen (web)
   - /admin/users → AdminUsersScreen (web)
   - /admin/analytics → AdminAnalyticsScreen (web)

2. Route guards:
   - AuthGuard: redirect to /login if not authenticated
   - CreatorGuard: redirect to /creator/enroll if not creator
   - AdminGuard: redirect to /home if not admin
   - OnboardingGuard: show onboarding for first-time users

3. Deep linking configuration:
   - wallvault://wallpaper/:id
   - wallvault://creator/:id
   - Handle from push notifications

4. Bottom navigation configuration:
   - Home (icon: home)
   - Search (icon: search)
   - Upload FAB (icon: add, center, elevated)
   - Creator (icon: palette)
   - Profile (icon: person)

5. Transition animations:
   - Shared element for wallpaper detail
   - Slide from right for screens
   - Fade for modal bottomsheets
PHASE 2: MOBILE UI SCREENS (Prompts 6-20)
Prompt 6: Splash Screen (S01)
plain
Create SplashScreen in lib/screens/splash/:

1. Full-screen deep black background (#0A0A0F)
2. Centered animated logo:
   - Stylized "W" lettermark
   - SVG stroke animation: draws outline in neon purple (#B829DD)
   - Duration: 0.5s, easing: ease-in-out
   - After stroke completes, fill with purple-to-cyan gradient
   - Subtle pulse animation after fill (scale 1.0 → 1.05 → 1.0)

3. Below logo, tagline "Your Walls, Your Story":
   - Types in character by character
   - Cursor blink effect
   - Font: Inter, 16px, weight 400, color #8B8B9E
   - Duration: 0.8s after logo fill

4. At 1.8s, particle burst from logo:
   - 20 small circles in purple/cyan/gold
   - Explode outward and fade
   - Duration: 0.5s

5. At 2.5s, fade to next screen:
   - If first launch: navigate to /onboarding
   - If logged in: navigate to /home
   - If logged out: navigate to /login

6. Use AnimationController + TweenSequence
7. Add haptic feedback on logo pulse (light tap)
Prompt 7: Onboarding Slide 1 (S02)
plain
Create OnboardingScreen with PageView (3 slides) in lib/screens/onboarding/:

Slide 1 - "Discover Stunning Walls":
1. Full-screen deep black background
2. Background layer: 3 floating wallpaper cards in 3D perspective
   - Slightly tilted (rotateY: ±15deg)
   - Subtle floating animation (translateY: ±10px, 3s loop)
   - Blurred edges for depth
   - Images: nature, abstract, neon wallpapers

3. Foreground content:
   - Large heading: "Discover Stunning Walls"
     Font: Inter, 32px, weight 700, color white

   - Subtext: "Explore thousands of 4K wallpapers curated just for you"
     Font: Inter, 16px, weight 400, color #8B8B9E
     Max width: 280px, centered

   - Bottom hint: "Swipe to explore →"
     Font: Inter, 14px, weight 500, color #B829DD
     Pulsing arrow animation (translateX: 0 → 10px → 0, 1.5s loop)

4. Page indicator:
   - 3 dots at bottom
   - Active dot: 24px wide pill, purple gradient
   - Inactive dot: 8px circle, gray
   - Animated width transition

5. Parallax effect:
   - On swipe, background cards move at 0.5x speed
   - Text moves at 1.0x speed
   - Creates depth illusion

6. Skip button top-right:
   - "Skip" text, white, 14px
   - Navigates to /home
Prompt 8: Onboarding Slide 2 (S03)
plain
Onboarding Slide 2 - "Support Creators":

1. Deep black background
2. Background animation: golden coins raining from top
   - 15-20 coin icons falling at different speeds
   - Rotation while falling (0 → 360deg)
   - Fade out at bottom
   - Continuous loop

3. Center: 3 creator avatar circles popping in with stagger
   - Size: 80px diameter
   - Border: 3px solid purple
   - Stagger delay: 200ms between each
   - Pop animation: scale 0 → 1.2 → 1.0, spring curve
   - Avatars: diverse creator photos

4. Foreground text:
   - Heading: "Support Creators"
     Font: Inter, 32px, weight 700, white
   - Subtext: "Buy wallpapers directly from independent artists and tip your favorites"
     Font: Inter, 16px, weight 400, #8B8B9E

5. Bottom: "Next" button
   - Purple gradient (#B829DD → #00D4FF)
   - Rounded 16px, height 56px
   - Width: 200px
   - Text: "Next", white, 16px, weight 600
   - Press: scale 0.95, haptic light tap

6. Page indicator updates (second dot active)
Prompt 9: Onboarding Slide 3 (S04)
plain
Onboarding Slide 3 - "Go Premium":

1. Deep black background
2. Center animation: golden padlock
   - Initial state: locked, gold color (#FFD700)
   - Key icon appears, rotates 90deg
   - Lock opens with satisfying "click" visual (shake)
   - Duration: 0.8s

3. After unlock:
   - Confetti particles burst from lock center
   - 30 particles in gold, purple, cyan
   - Explode outward, rotate, fade
   - Duration: 0.6s

4. Foreground text:
   - Heading: "Go Premium"
     Font: Inter, 32px, weight 700, white
   - Subtext: "Unlock exclusive wallpapers, remove ads, and support the community"
     Font: Inter, 16px, weight 400, #8B8B9E

5. Bottom: "Get Started" button
   - Gold gradient (#FFD700 → #FF9100)
   - Rounded 16px, height 56px
   - Width: 250px
   - Text: "Get Started", black, 16px, weight 700
   - Press: scale 0.95, haptic medium tap
   - Navigates to /home

6. Page indicator: third dot active
Prompt 10: Login Screen (S05)
plain
Create LoginScreen in lib/screens/auth/:

1. Background: deep black (#0A0A0F) with subtle blurred wallpaper overlay (10% opacity)
2. Top: back arrow (if from onboarding) or close button
3. Center content:
   - App logo (stylized W, 80px, purple gradient)
   - "Welcome Back" heading, 28px, bold, white
   - "Sign in to continue" subtext, 14px, #8B8B9E

4. Form fields:
   - Phone Number input:
     - Prefix: "+91" in purple
     - Placeholder: "Phone Number"
     - Dark card surface (#1A1A24), 12px radius
     - Purple border glow on focus
     - Number keyboard
     - Validation: 10 digits

   - Password input:
     - Placeholder: "Password"
     - Same styling as phone
     - Obscure text toggle (eye icon)
     - Validation: min 6 characters

5. "Forgot Password?" link, cyan (#00D4FF), 14px

6. "Continue" button:
   - Purple gradient, 16px radius, 56px height
   - Full width (minus padding)
   - Text: "Continue", white, 16px, bold
   - Loading state: shimmer animation when processing
   - Success: morphs to checkmark with confetti
   - Disabled state: gray, 50% opacity

7. Divider: "or continue with"
   - Horizontal lines, gray
   - Text centered, 12px, #8B8B9E

8. Social login buttons:
   - Google: white button, Google icon, "Google" text
   - Apple: white button, Apple icon, "Apple" text
   - Both: 48px height, 12px radius, subtle border
   - Press: scale 0.95

9. Bottom: "New here? Sign Up" → navigates to /signup
   - "Sign Up" in cyan, underlined

10. Error handling:
    - Invalid phone: shake animation + red border
    - Wrong password: toast notification
    - Network error: retry button
Prompt 11: Sign Up Screen (S06)
plain
Create SignUpScreen in lib/screens/auth/:

1. Deep black background
2. Top: "Create Your Account" heading, 28px, bold, white
3. Step indicator: "Step 1/4" with progress bar (25% purple)

4. Form fields (all with dark card surface, purple glow on focus):
   - Full Name: text input, placeholder "Full Name"
   - Phone Number: +91 prefix, number keyboard
   - Email: email keyboard, validation
   - Password: obscure toggle, min 6 chars
   - Confirm Password: match validation

5. "Continue" button (same styling as login)
   - Validates all fields before enabling
   - Shows loading shimmer when processing

6. Bottom: "Already have an account? Login" → /login

7. Field animations:
   - On focus: label floats up, border glows purple
   - On error: red border, shake animation, error text below
   - On valid: green checkmark appears right

8. Password strength indicator:
   - Weak: red bar (1/4)
   - Medium: orange bar (2-3/4)
   - Strong: green bar (4/4)
   - Below password field
Prompt 12: OTP Verification Screen (S07)
plain
Create OTPVerificationScreen in lib/screens/auth/:

1. Deep black background
2. Top: "Verify Your Number" heading, 28px, bold, white
3. Subtext: "Enter the 6-digit code sent to +91 98765 43210"
   - Phone number in cyan (#00D4FF)
   - 14px, #8B8B9E

4. OTP input row:
   - 6 square boxes, 48x48px each
   - Spacing: 12px between boxes
   - Dark card surface (#1A1A24), 12px radius
   - Cyan border (#00D4FF) when active/focused
   - Gray border (#5A5A6E) when inactive
   - White text, 24px, bold, centered
   - Auto-focus: typing in one box moves to next
   - Backspace: moves to previous box
   - Paste: distributes across all 6 boxes

5. Number entry animation:
   - Each number bounces in: scale 0 → 1.2 → 1.0
   - Spring curve
   - Duration: 200ms

6. "Didn't receive? Resend (30s)"
   - Timer counts down from 30s
   - "Resend" disabled during countdown, gray
   - After countdown: cyan, tappable
   - Tap: resend OTP, reset timer

7. "Verify" button:
   - Purple gradient, full width
   - Disabled until 6 digits entered
   - Loading: circular progress
   - Success: checkmark + navigate to /home
   - Error: shake OTP boxes + red border + "Invalid OTP" text

8. Haptic feedback:
   - Each digit entry: light tap
   - Successful verification: success pattern (light-medium-heavy)
   - Error: error pattern (two quick medium taps)
Prompt 13: Home Screen (S08)
plain
Create HomeScreen in lib/screens/home/:

1. Scaffold with deep black background
2. Collapsible header:
   - Greeting: "Good Morning, Alex" (dynamic based on time)
     Font: Inter, 20px, weight 600, white
   - Streak counter: "🔥 7-day streak!" 
     Fire emoji with flickering animation
     Orange text (#FF9100), 14px, bold
   - Right: search icon (tappable → /search)
     Profile avatar (tappable → /profile)

3. Tab bar below header:
   - Tabs: "For You", "Trending", "Categories", "Creators"
   - Active tab: white text, purple underline
   - Inactive: gray text (#8B8B9E)
   - Liquid morph indicator: pill shape slides between tabs
   - Duration: 350ms, smooth curve
   - On scroll: header shrinks, tab bar pins to top

4. Featured section (horizontal carousel):
   - Height: 320px
   - Cards: 280px wide, 16px radius
   - Auto-scroll: every 5s with smooth transition
   - Snap to card center
   - 3D perspective: edge cards slightly rotated
   - Badge overlay: "PREMIUM" (gold), "NEW" (cyan), "HOT" (red)
   - Pagination dots below

5. Wallpaper grid (2-column masonry):
   - Gap: 12px
   - Padding: 16px horizontal
   - Cards:
     - Aspect ratio: 9:16 (portrait wallpapers)
     - Border radius: 20px
     - Shadow: 0 8px 32px rgba(0,0,0,0.4)
     - 3D tilt on touch: rotateX/Y ±5deg based on touch position
     - Neon glow follows finger on hover
     - Overlay at bottom: gradient from transparent to black

   - Card content overlay:
     - Wallpaper name: 14px, white, bold
     - Creator row: avatar (24px) + name (12px, cyan) + verified checkmark
     - Download count: 12px, gray, download icon
     - Price tag: "FREE" (green) or "₹49" (gold)

6. Scroll animations:
   - Cards fade in: opacity 0→1, translateY 30→0
   - Stagger: 50ms between cards
   - Trigger: IntersectionObserver at 10% visibility

7. Floating Action Button (FAB):
   - Position: bottom-right, 24px from edges
   - Size: 64px circular
   - Background: purple gradient
   - Icon: add (+), white, 24px
   - Shadow: 0 8px 24px rgba(184,41,221,0.3)
   - Idle animation: subtle float (translateY ±3px, 2s loop)
   - Press: scale 0.9, haptic medium tap
   - Navigates to /creator/upload

8. Bottom navigation bar:
   - Height: 64px
   - Background: dark card surface with blur
   - 5 items: Home, Search, Upload (FAB center), Creator, Profile
   - Active: purple icon + label
   - Inactive: gray icon only
   - Tap: icon scales 1.2 → 1.0 with spring
Prompt 14: Wallpaper Detail Screen (S09)
plain
Create WallpaperDetailScreen in lib/screens/wallpaper/:

1. Full-screen layout:
   - Top 70%: wallpaper image (full-bleed)
   - Bottom 30%: draggable info sheet

2. Wallpaper image:
   - Hero animation: shared element transition from grid
   - Pinch-to-zoom with elastic bounds
   - Double-tap to like: heart burst animation
   - Long-press to preview apply

3. Top overlay bar (transparent with blur):
   - Left: back arrow (←), white, 24px
   - Center: heart favorite button (♡ → ♥ with particle burst)
   - Right: more options (⋯), opens bottom sheet

4. Draggable info sheet:
   - Background: dark card surface (#1A1A24)
   - Top radius: 24px
   - Handle: pill shape (40x4px), gray, centered
   - Initial position: 30% visible
   - Drag up: expands to 70% visible
   - Drag down: dismisses to 30% or closes
   - Spring physics on release

5. Sheet content:
   - Wallpaper name: "Neon Sunset", 24px, bold, white
   - Creator row:
     - Avatar: 40px circular
     - Name: "@creative_alex", 16px, cyan (#00D4FF)
     - Verified badge: blue checkmark with golden ring
     - "Follow" button (if not following)

   - Stats row:
     - Star rating: 4.9, gold stars
     - Download count: "12.5K downloads", 14px, gray
     - Resolution badge: "4K (3840x2160)", 12px, purple pill

   - Tags: horizontal scroll
     - Pill badges: #nature, #neon, #abstract
     - Background: dark elevated, text: cyan
     - 12px font, 8px padding

   - Price: "₹49" in gold (#FFD700), 20px, bold
     - Or "FREE" in green (#00E676)

6. Action buttons row:
   - "Download" button:
     - Purple gradient, 16px radius, 56px height
     - Morphing animation:
       1. Tap: shrinks to 56px circle, shows progress ring
       2. 50%: ring fills with gradient
       3. 100%: checkmark draws with SVG stroke
       4. Complete: confetti particles burst from center
     - Haptic: medium tap on complete

   - "Apply" button:
     - Cyan outline, transparent fill
     - Text: "Apply", cyan
     - Opens apply modal

   - "Share" button:
     - Gray outline, share icon
     - Opens native share sheet with preview card

   - "Tip" button (for free wallpapers):
     - Gold coin icon
     - Opens tip amount selector

7. Related wallpapers section:
   - "More from @creative_alex" heading
   - Horizontal scroll: 3-4 thumbnails
   - "Similar Style" heading below
   - Another horizontal scroll

8. Premium unlock animation (for paid wallpapers):
   - Dark overlay splits from center like curtains
   - Golden light rays emanate from wallpaper
   - Wallpaper scales: 0.8 → 1.0 with spring
   - "Premium Unlocked" text types in with cursor
   - Confetti burst in gold
   - Duration: 1.2s
Prompt 15: Apply Wallpaper Modal (S10)
plain
Create ApplyWallpaperModal as bottom sheet:

1. Background: dark card surface (#1A1A24)
2. Top radius: 24px
3. Handle: pill shape, gray

4. Header: "Preview & Apply", 20px, bold, white

5. Preview section:
   - Two side-by-side cards:
     - Left: "Home Screen" label
       Simulated phone frame (160x280px)
       Wallpaper behind app icons grid
       Time widget at top

     - Right: "Lock Screen" label
       Simulated phone frame
       Wallpaper behind clock (large time)
       Notification previews below

   - Both frames: 12px radius, subtle border
   - Active frame: purple border glow

6. Action buttons (stacked, full width):
   - "Apply to Home Screen"
     - Purple gradient, 16px radius, 48px height
     - Press: scale 0.95, haptic medium

   - "Apply to Lock Screen"
     - Cyan gradient, same styling

   - "Apply to Both"
     - Gold gradient, same styling

   - "Cancel"
     - Transparent, gray text
     - Dismisses modal

7. Success feedback:
   - Checkmark overlay on applied frame
   - Brief toast: "Applied successfully!"
   - Auto-dismiss after 2s
Prompt 16: Search Screen (S11)
plain
Create SearchScreen in lib/screens/search/:

1. Deep black background
2. Top search bar:
   - Expanded state: full width, 56px height
   - Background: dark card surface
   - Border: purple glow when focused
   - Left: search icon (magnifying glass)
   - Placeholder: "Search wallpapers..."
   - Right: clear button (X) when text entered
   - Clear animation: X morphs from search icon with rotation

3. Below search bar:

   "Trending Searches" section:
   - Heading: "Trending", 18px, bold, white
   - Horizontal scroll of pill tags:
     - #nature, #neon, #minimal, #dark, #anime, #cars, #space
     - Background: dark elevated
     - Text: cyan, 14px
     - Tap: scale 1.1, search executes

   "Recent Searches" section:
   - Heading: "Recent", 18px, bold, white
   - List of recent search terms
   - Each row: search icon + term + X clear button
   - Swipe left: delete with red background
   - "Clear All" link at bottom

   "Popular Categories" section:
   - Heading: "Categories", 18px, bold, white
   - 2x3 grid of category cards:
     - Each: icon (48px) + label below
     - Background: dark card surface, 16px radius
     - Tap: scale 0.95, purple border glow
     - Categories: Nature, Abstract, Cars, Anime, Space, Dark

4. Search results state:
   - Replaces trending/recent/categories
   - Filter chips: "All", "Free", "Premium", "4K", "Trending"
   - 2-column masonry grid (same as home)
   - Empty state: "No results found" with illustration

5. Keyboard handling:
   - Search on submit (return key)
   - Dismiss keyboard on scroll
   - Auto-suggestions dropdown below search bar
Prompt 17: Profile Screen (S12)
plain
Create ProfileScreen in lib/screens/profile/:

1. Deep black background
2. Top right: settings gear icon (→ /settings)

3. Profile header:
   - Large circular avatar: 100px
   - 3D tilt on touch: rotateX/Y based on finger position
   - Border: 3px purple gradient
   - Online indicator: green dot, bottom-right

   - Username: "@alex_wallz", 20px, bold, white
   - Member since: "Member since 2024", 14px, gray

4. Stats row (3 columns):
   - "247" / "Downloads" — number animates count-up
   - "89" / "Favorites"
   - "12" / "Following"
   - Numbers: 24px, bold, white
   - Labels: 12px, gray
   - Dividers between columns

5. Subscription card:
   - Background: gold gradient (subtle, 10% opacity)
   - Border: 1px gold
   - "PRO" badge: gold pill
   - "Active until Dec 2026"
   - "Manage Subscription" button: gold outline
   - If free user: "Upgrade to PRO" CTA with gold gradient

6. Menu list (grouped sections):

   "My Content" section:
   - My Downloads (download icon, right arrow)
   - My Favorites (heart icon)
   - My Uploads (palette icon, "Creator" badge if applicable)

   "Preferences" section:
   - Notifications (bell icon, toggle switch)
   - Dark Mode (moon icon, toggle — animated sun/moon morph)
   - Language (globe icon, "English", right arrow)

   "Support" section:
   - Help Center (question icon)
   - Contact Us (message icon)
   - Terms of Service (document icon)

   "Account" section:
   - Log Out (red text, logout icon)
   - Delete Account (red text, danger style)

7. Menu item styling:
   - Icon: 24px, gray
   - Label: 16px, white
   - Right: arrow or toggle
   - Divider: 1px, dark elevated
   - Tap: background highlight, haptic light

8. Logout confirmation:
   - Bottom sheet: "Are you sure?"
   - "Log Out" button: red
   - "Cancel" button: gray
   - Shake animation on sheet enter
Prompt 18: My Downloads Screen (S13)
plain
Create MyDownloadsScreen in lib/screens/downloads/:

1. Deep black background
2. Top: back arrow + "My Downloads" heading

3. Grid view:
   - 2-column masonry (same as home)
   - Each card shows:
     - Wallpaper preview
     - Name overlay at bottom
     - Offline indicator: cloud with checkmark, green, top-right

4. Long-press to enter multi-select mode:
   - Haptic: heavy tap
   - Cards scale slightly (1.02)
   - Checkbox appears top-left of each card
   - Bottom action bar slides up:
     - "Delete" (red, trash icon)
     - "Share" (cyan, share icon)
     - "Apply" (purple, apply icon)
     - "Select All" text button

5. Empty state:
   - Download icon illustration (line art, purple)
   - "No downloads yet"
   - "Browse wallpapers to get started"
   - "Explore" button: purple gradient

6. Swipe actions:
   - Swipe right: "Apply" (purple background)
   - Swipe left: "Delete" (red background)
   - Elastic snap back
Prompt 19: Subscription Screen (S23)
plain
Create SubscriptionScreen in lib/screens/subscription/:

1. Deep black background
2. Top: "Go Premium" heading with crown icon (gold)

3. Hero animation:
   - Large golden padlock (120px)
   - Key turns, lock opens
   - Confetti burst
   - "Unlock the full experience" text

4. Plan cards (stacked vertically):

   Card 1 - Monthly:
   - "Monthly" label, 18px, white
   - "₹49/month", 32px, bold, white
   - Feature checklist:
     ✓ Unlimited downloads
     ✓ Ad-free experience
     ✓ 4K & 8K wallpapers
     ✗ Exclusive collections
   - Border: gray (unselected)

   Card 2 - Yearly (RECOMMENDED):
   - "Yearly" label + "RECOMMENDED" badge (purple pill)
   - "₹299/year", 32px, bold, white
   - "Save 49%" badge (green)
   - Feature checklist:
     ✓ Everything in Monthly
     ✓ Exclusive collections
     ✓ Early access to new wallpapers
   - Border: purple glow (selected by default)
   - Background: subtle purple tint

   Card 3 - Lifetime:
   - "Lifetime" label + "BEST VALUE" badge (gold pill)
   - "₹999 one-time", 32px, bold, gold
   - Feature checklist:
     ✓ Everything forever
     ✓ All future updates
     ✓ Priority support
   - Border: gold (optional select)

5. Selection animation:
   - Tap card: border glows, scales 1.02
   - Other cards: deselect, gray border
   - Smooth transition

6. "Subscribe Now" button:
   - Gold gradient (#FFD700 → #FF9100)
   - Full width, 56px height, 16px radius
   - Text: "Subscribe Now - ₹299/year", black, bold
   - Idle: subtle pulse glow
   - Press: scale 0.95
   - Opens Razorpay checkout

7. Bottom notes:
   - "Cancel anytime" in gray
   - "Restore Purchases" link in cyan
   - "Terms & Privacy" link

8. Success state:
   - Golden unlock animation
   - "Welcome to PRO!" heading
   - Confetti burst
   - Auto-navigate to /home after 3s
Prompt 20: Notifications Screen (S24)
plain
Create NotificationsScreen in lib/screens/notifications/:

1. Deep black background
2. Top: "Notifications" heading + "Mark all read" text button

3. Notification list:
   - Each item: card with 16px radius
   - Unread: purple left border (3px), subtle background glow
   - Read: no border, normal background

   - Content:
     - Icon left: 40px circular, colored background
       - Sale: green (₹)
       - Payout: gold (💰)
       - System: purple (ℹ️)
       - Tip: cyan (💸)

     - Title: 16px, bold, white
     - Body: 14px, gray
     - Timestamp: 12px, muted gray
     - Right: arrow or dismiss button

   - Swipe right: "Read" (purple background)
   - Swipe left: "Dismiss" (red background)

4. Empty state:
   - Bell icon illustration (line art)
   - "No notifications yet"
   - "We'll notify you about sales, payouts, and updates"

5. Notification types:
   - "You made a sale! Neon Sunset was purchased for ₹49"
   - "Payout processed: ₹2,450 sent to your UPI"
   - "Your creator application was approved!"
   - "New follower: @wallpaper_lover started following you"
   - "Weekly summary: 120 downloads, ₹340 earnings"
✅ PROMPTS 1-20 COMPLETE
Next: Request Prompts 21-40 (remaining mobile screens + web portals)
After that: Request Prompts 41-65 (business logic + backend + integration)
Estimated time for Prompts 1-20: 7-10 days (with testing and iteration)