WALLVAULT - CRED-INSPIRED WALLPAPER APP
Complete UI/UX + Feature Architecture Document
🎨 DESIGN SYSTEM OVERVIEW
Color Palette (Dark-First)
plain
Background Primary:   #0A0A0F  (Deep Black)
Background Secondary: #12121A  (Dark Navy)
Card Surface:         #1A1A24  (Elevated Dark)
Accent Purple:        #B829DD  (Neon Purple)
Accent Cyan:          #00D4FF  (Electric Cyan)
Premium Gold:         #FFD700  (Gold)
Success Green:        #00E676
Error Red:            #FF1744
Text Primary:         #FFFFFF
Text Secondary:       #8B8B9E
Text Muted:           #5A5A6E
Typography
Font: Inter / SF Pro Display
Headings: Bold, tight letter-spacing (-0.5px)
Body: Regular, comfortable line-height (1.5)
Special: Price tags in gold, creator names in cyan
📱 MOBILE APP SCREENS (Android + iOS)
1. SPLASH SCREEN
plain
┌─────────────────────────────┐
│                             │
│      [Animated Logo]        │
│         (Neon W)            │
│                             │
│   "Your Walls, Your Story"  │
│      (Typing effect)        │
│                             │
│    [Particle burst]         │
└─────────────────────────────┘
Duration: 2.5s → Auto-navigate to Onboarding/Home
2. ONBOARDING FLOW
plain
┌─────────────────────────────┐
│  [Parallax Wallpaper BG]    │
│                             │
│    "Discover Stunning       │
│        Walls"               │
│                             │
│  [3D floating wallpapers] │
│                             │
│    [Swipe indicator]  →   │
└─────────────────────────────┘

Slides:
1. Discover → Tilt phone to parallax wallpapers
2. Support Creators → Coin rain animation
3. Go Premium → Lock unlocks with golden key
3. HOME SCREEN
plain
┌─────────────────────────────┐
│  👋 Good Morning, Alex      │
│  🔥 7-day streak!          │
│  [Search]        [Profile]  │
├─────────────────────────────┤
│  [For You] [Trending] [Cat] │
│  ════════                    │
│  [Featured Carousel]        │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │     │ │     │ │     │   │
│  │ PRE │ │ NEW │ │ HOT │   │
│  └─────┘ └─────┘ └─────┘   │
├─────────────────────────────┤
│  [Wallpaper Grid - 2 col]   │
│  ┌────┐ ┌────┐             │
│  │    │ │    │             │
│  │Name│ │Name│             │
│  │👤✓ │ │👤  │             │
│  │💰29│ │FREE│             │
│  └────┘ └────┘             │
│  ┌────┐ ┌────┐             │
│  │    │ │    │             │
│  └────┘ └────┘             │
│                             │
│        [+] FAB              │
└─────────────────────────────┘
4. WALLPAPER DETAIL SCREEN
plain
┌─────────────────────────────┐
│  [←]    [♡]    [⋯]        │
│                             │
│  [Full-bleed Wallpaper]     │
│  [Pinch to zoom]            │
│                             │
│  ═══════════════════════    │
│  ┌─────────────────────┐   │
│  │ Neon Sunset         │   │
│  │ by @creative_alex ✓│   │
│  │ ⭐ 4.9  📥 12.5K    │   │
│  │                     │   │
│  │ Tags: #nature #neon │   │
│  │ Res: 4K (3840x2160)│   │
│  │                     │   │
│  │ [💰 ₹49]            │   │
│  │                     │   │
│  │ [📥 Download]       │   │
│  │ [🎨 Apply]          │   │
│  │ [🔗 Share]  [💸 Tip]  │   │
│  └─────────────────────┘   │
│  [Drag up for more info]   │
└─────────────────────────────┘
5. APPLY WALLPAPER MODAL
plain
┌─────────────────────────────┐
│  Preview & Apply            │
│  ┌─────────┐ ┌─────────┐   │
│  │  HOME   │ │  LOCK   │   │
│  │ [Icons] │ │ [Clock] │   │
│  │         │ │         │   │
│  └─────────┘ └─────────┘   │
│                             │
│  [Apply to Home]            │
│  [Apply to Lock]            │
│  [Apply to Both]            │
│  [Cancel]                   │
└─────────────────────────────┘
6. LOGIN / SIGNUP
plain
┌─────────────────────────────┐
│  [Animated BG Wallpaper]    │
│                             │
│      [App Logo]             │
│                             │
│  ┌─────────────────────┐   │
│  │ 📱 Phone Number     │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 🔒 Password         │   │
│  └─────────────────────┘   │
│                             │
│  [    Continue    ]         │
│                             │
│  ──── or continue with ─── │
│  [G] [🍎]                   │
│                             │
│  New here? Sign Up →        │
└─────────────────────────────┘
7. CREATOR ENROLLMENT
plain
┌─────────────────────────────┐
│  Become a Creator           │
│                             │
│  Step 1/4                   │
│  [━━━━○○○] Progress         │
│                             │
│  Basic Info                 │
│  ┌─────────────────────┐   │
│  │ Display Name        │   │
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ Bio                 │   │
│  └─────────────────────┘   │
│                             │
│  [Upload Profile Photo]     │
│                             │
│  [    Next    ]             │
└─────────────────────────────┘

Steps:
1. Basic Info (Name, Bio, Avatar)
2. Portfolio (Upload 3 sample wallpapers)
3. Payout Setup (UPI ID / Razorpay Connect)
4. Terms & Submit (Review + Agreement)
8. CREATOR UPLOAD FLOW
plain
┌─────────────────────────────┐
│  Upload Wallpaper           │
│  [━━━━○○] Step 2/3          │
│                             │
│  [Drag or Tap to Upload]    │
│  ┌─────────────────────┐   │
│  │                     │   │
│  │   [Preview with     │   │
│  │    crop guides]     │   │
│  │                     │   │
│  └─────────────────────┘   │
│                             │
│  Wallpaper Name             │
│  ┌─────────────────────┐   │
│  │ Neon Sunset         │   │
│  └─────────────────────┘   │
│                             │
│  Category: [Dropdown ▼]     │
│  Tags: #nature #neon [+]    │
│                             │
│  [    Next    ]             │
└─────────────────────────────┘

Step 3 - Pricing:
┌─────────────────────────────┐
│  Set Pricing                │
│                             │
│  [●] Free                   │
│  [○] Paid                   │
│                             │
│  If Paid:                   │
│  ┌─────────────────────┐   │
│  │ ₹ 49                │   │
│  └─────────────────────┘   │
│                             │
│  Your Earnings: ₹34 (70%)   │
│  Platform Fee: ₹10 (20%)    │
│  Community: ₹5 (10%)        │
│                             │
│  Payout Method:             │
│  ┌─────────────────────┐   │
│  │ UPI: abc@upi        │   │
│  └─────────────────────┘   │
│                             │
│  [    Publish    ]          │
└─────────────────────────────┘
9. CREATOR DASHBOARD
plain
┌─────────────────────────────┐
│  Creator Dashboard          │
│  [👤 @creative_alex ✓]      │
│  Level 3: Bloom ⭐          │
│                             │
│  ┌─────────────────────┐   │
│  │ 💰 Total Earnings   │   │
│  │    ₹12,450          │   │
│  │    ↑ 23% this month │   │
│  └─────────────────────┘   │
│                             │
│  [Earnings Chart]           │
│  ┌─────────────────────┐   │
│  │    ╱╲    ╱╲        │   │
│  │   ╱  ╲  ╱  ╲       │   │
│  │  ╱    ╲╱    ╲      │   │
│  │ ╱            ╲     │   │
│  └─────────────────────┘   │
│                             │
│  Top Wallpapers:            │
│  1. Neon Sunset    📥 5.2K │
│  2. Ocean Dreams   📥 3.1K │
│  3. Cyber City     📥 2.8K │
│                             │
│  Payout Status:             │
│  [₹2,450] [Request Payout]  │
│                             │
│  [My Uploads] [Analytics]   │
│  [Settings]  [Help]         │
└─────────────────────────────┘
10. PROFILE SCREEN
plain
┌─────────────────────────────┐
│  [Settings ⚙️]              │
│                             │
│      [Avatar]               │
│     @alex_wallz             │
│    Member since 2024        │
│                             │
│  ┌────┐ ┌────┐ ┌────┐     │
│  │ 247│ │ 89 │ │ 12 │     │
│  │Dwn │ │Fav │ │Foll│     │
│  └────┘ └────┘ └────┘     │
│                             │
│  ──── Subscription ────    │
│  [PRO] Active until Dec 2026│
│  [Manage Subscription]      │
│                             │
│  My Downloads               │
│  My Favorites               │
│  My Uploads (Creator)       │
│  ─────────────────────      │
│  Notifications              │
│  Dark Mode [●]              │
│  Language                   │
│  Help & Support             │
│  Log Out                    │
└─────────────────────────────┘
🌐 CREATOR WEB PORTAL (creators.wallvault.app)
Dashboard Layout
plain
┌─────────────────────────────────────────────────────────────┐
│  [≡]  WallVault Creator Hub              [🔔] [👤 Alex ▼]   │
├──────────┬──────────────────────────────────────────────────┤
│          │                                                  │
│  Dashboard│  💰 Earnings Overview          📊 Performance   │
│  ─────────│  ┌────────────────────────┐  ┌────────────────┐  │
│  Upload   │  │  Total: ₹12,450      │  │  Views: 45.2K  │  │
│  My Walls │  │  This Month: ₹3,200  │  │  Downloads: 8K │  │
│  Analytics│  │  Pending: ₹2,450     │  │  Likes: 12.5K  │  │
│  Payouts  │  └────────────────────────┘  └────────────────┘  │
│  Settings │                                                  │
│  Help     │  [Revenue Chart - Interactive]                   │
│           │                                                  │
│  ─────────│  Recent Uploads:                                 │
│  [Upgrade]│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                   │
│  to PRO   │  │    │ │    │ │    │ │    │                   │
│           │  │W1  │ │W2  │ │W3  │ │W4  │                   │
│           │  └────┘ └────┘ └────┘ └────┘                   │
│           │                                                  │
│           │  Quick Actions:                                  │
│           │  [+ Upload New] [📊 View Analytics] [💸 Payout]   │
│           │                                                  │
└──────────┴──────────────────────────────────────────────────┘
Upload Interface (Web)
plain
┌─────────────────────────────────────────────────────────────┐
│  Upload New Wallpaper                                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │     [Drag & Drop or Click to Upload]                │   │
│  │                                                     │   │
│  │     Supports: JPG, PNG, WEBP (Max 20MB)            │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Wallpaper Details:                                         │
│  Name: [_________________________]                          │
│  Category: [Select ▼]  Tags: [tag1] [tag2] [+]            │
│  Description: [_________________________]                   │
│                                                             │
│  Pricing:                                                   │
│  (•) Free    ( ) Paid ₹ [_____]                           │
│                                                             │
│  Your earnings: ₹___ (70%)                                │
│                                                             │
│  [   Preview   ]  [   Publish   ]                           │
└─────────────────────────────────────────────────────────────┘
🖥️ ADMIN WEB DASHBOARD (admin.wallvault.app)
Overview Dashboard
plain
┌─────────────────────────────────────────────────────────────────────────────┐
│  WallVault Admin                                    [🔍] [🔔5] [👤 Admin ▼] │
├──────────────┬────────────────────────────────────────────────────────────────┤
│              │                                                                │
│  Dashboard   │  📊 Overview                                    [Today ▼]    │
│  Wallpapers  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐      │
│  Creators    │  │ Users  │ │ Walls  │ │ Subs   │ │ Revenue│ │Pending │      │
│  Users       │  │ 45.2K  │ │ 12.8K  │ │ 3.2K   │ │ ₹89K   │ │  23    │      │
│  Payments    │  │ ↑12%   │ │ ↑8%    │ │ ↑15%   │ │ ↑22%   │ │ ⚠️     │      │
│  Payouts     │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘      │
│  Reports     │                                                                │
│  Settings    │  [Revenue Chart]          [User Growth Chart]                │
│              │                                                                │
│  ─────────── │  ⚠️ Action Required:                                         │
│  System      │  ┌─────────────────────────────────────────────────────────┐  │
│  Status: 🟢  │  │ 23 wallpapers pending approval  [Review Now →]         │  │
│              │  │ 5 creators pending verification  [Review Now →]        │  │
│              │  │ 8 payout requests pending        [Process Now →]       │  │
│              │  └─────────────────────────────────────────────────────────┘  │
│              │                                                                │
└──────────────┴────────────────────────────────────────────────────────────────┘
Wallpaper Management
plain
┌─────────────────────────────────────────────────────────────────────────────┐
│  Wallpapers                                      [Filter ▼] [Search ______] │
│                                                                             │
│  [All] [Pending] [Approved] [Rejected] [Flagged]                              │
│                                                                             │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                  │
│  │    │ │    │ │    │ │    │ │    │ │    │ │    │ │    │                  │
│  │ ⏳ │ │ ✓  │ │ ✓  │ │ ✗  │ │ ⚠️ │ │ ✓  │ │ ⏳ │ │ ✓  │                  │
│  │Pend│ │App │ │App │ │Rej │ │Flag│ │App │ │Pend│ │App │                  │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘ └────┘ └────┘                  │
│                                                                             │
│  Selected: 3  [Approve] [Reject] [Delete]                                   │
│                                                                             │
│  Detail View (on click):                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  [Large Preview]        │ Name: Neon Sunset                        │   │
│  │                         │ Creator: @creative_alex ✓               │   │
│  │                         │ Uploaded: 2 hours ago                    │   │
│  │                         │ Resolution: 4K                           │   │
│  │                         │ Price: ₹49                               │   │
│  │                         │ Status: Pending                          │   │
│  │                         │                                          │   │
│  │                         │ [✓ Approve] [✗ Reject] [📝 Notes]       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
Creator Management
plain
┌─────────────────────────────────────────────────────────────────────────────┐
│  Creators                                                                     │
│                                                                             │
│  Pending Approvals (5):                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ [👤] John Doe          │ 3 uploads │ UPI: john@upi │ [✓] [✗] [👁]   │   │
│  │ [👤] Sarah Smith       │ 5 uploads │ Razorpay: ✓   │ [✓] [✗] [👁]   │   │
│  │ [👤] Mike Johnson      │ 2 uploads │ UPI: mike@upi │ [✓] [✗] [👁]   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  All Creators:                                                              │
│  [Search] [Filter by Level] [Filter by Status]                              │
│                                                                             │
│  ┌────────┬─────────────┬────────┬──────────┬─────────┬──────────┐         │
│  │ Name   │ Level       │ Uploads│ Earnings │ Payouts │ Status   │         │
│  ├────────┼─────────────┼────────┼──────────┼─────────┼──────────┤         │
│  │ Alex   │ ⭐ Star     │ 245    │ ₹45K     │ ₹32K    │ Active   │         │
│  │ John   │ 🌱 Seedling │ 12     │ ₹1.2K    │ ₹800    │ Active   │         │
│  │ Sarah  │ 🌸 Bloom    │ 89     │ ₹23K     │ ₹18K    │ Active   │         │
│  └────────┴─────────────┴────────┴──────────┴─────────┴──────────┘         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
Payout Management
plain
┌─────────────────────────────────────────────────────────────────────────────┐
│  Payouts                                                                      │
│                                                                             │
│  Pending Payouts (8):                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Creator        │ Amount  │ Method    │ Requested    │ Action         │   │
│  ├────────────────┼─────────┼───────────┼──────────────┼────────────────┤   │
│  │ @creative_alex │ ₹2,450  │ UPI       │ 2 hours ago  │ [Process]      │   │
│  │ @sarah_art     │ ₹1,800  │ Razorpay  │ 5 hours ago  │ [Process]      │   │
│  │ @mike_pixels   │ ₹950    │ UPI       │ 1 day ago    │ [Process]      │   │
│  └────────────────┴─────────┴───────────┴──────────────┴────────────────┘   │
│                                                                             │
│  [💰 Process All]  [📥 Export CSV]                                          │
│                                                                             │
│  Payout History:                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Date       │ Creator        │ Amount  │ Method    │ Status    │ TXN   │   │
│  ├────────────┼────────────────┼─────────┼───────────┼───────────┼───────┤   │
│  │ 2026-07-19 │ @alex_wallz    │ ₹3,200  │ UPI       │ ✅ Success│ U123  │   │
│  │ 2026-07-18 │ @sarah_art     │ ₹1,500  │ Razorpay  │ ✅ Success│ R456  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
🎬 ANIMATION SPECIFICATIONS
CRED-Inspired Effects
Table
Effect	Implementation	Duration	Easing
Card 3D Tilt	transform: rotateX/Y based on touch position	Real-time	Linear
Neon Glow Pulse	box-shadow animation with purple/cyan	2s loop	ease-in-out
Download Morph	Button → Circle → Progress Ring → Checkmark → Confetti	2.5s total	Spring
Page Transition	Shared element: image scales from grid to fullscreen	500ms	Spring
Scroll Reveal	opacity: 0→1, translateY: 30→0 with stagger	400ms	Smooth
Pull Refresh	Elastic stretch with logo rotation	Variable	Spring
Tab Indicator	Liquid morph between tabs	350ms	Smooth
Premium Unlock	Curtain split + golden particles + scale	1.2s	Dramatic
Creator Badge Pop	Scale bounce 0→1.2→1 with sparkle orbit	600ms	Bounce
Coin Tip	Coin drops with rotation, stack bounces	800ms	Bounce
Notification Toast	Slide from top + border glow pulse	400ms	Smooth
XP Bar Fill	Width animation with particle trail	1s	Smooth
Streak Flame	Flame flicker animation on counter	Continuous	ease-in-out
Haptic Patterns
Light Tap: Button press, toggle
Medium Tap: Download complete, success action
Heavy Tap: Premium unlock, major achievement
Error Pattern: Two quick medium taps
Success Pattern: Light → Medium → Heavy triple
💰 PAYMENT & PAYOUT FLOW
User Purchase Flow
plain
User taps "Buy" on paid wallpaper
    ↓
Razorpay Checkout opens (UPI/Card/Wallet)
    ↓
Payment Success → Haptic heavy tap + confetti
    ↓
Wallpaper unlocks with cinematic reveal
    ↓
Creator gets notified (push + email)
    ↓
Amount held in escrow (platform wallet)
Creator Payout Flow
plain
Creator requests payout (min ₹500)
    ↓
Admin receives notification
    ↓
Admin reviews in Payouts panel
    ↓
Admin clicks "Process" → RazorpayX Payout API
    ↓
UPI/Razorpay transfer initiated
    ↓
Creator receives money + notification
    ↓
Transaction logged in admin + creator history
Revenue Split
plain
Wallpaper Price: ₹100
├── Creator: ₹70 (70%)
├── Platform: ₹20 (20%)
└── Community Pool: ₹10 (10%) → Monthly contests, featured rewards
🎮 GAMIFICATION SYSTEM
User Achievements
Table
Achievement	Condition	Reward
First Steps	First download	50 XP
Streak Starter	3-day download streak	100 XP + Badge
Streak Master	30-day streak	500 XP + "Dedicated" title
Collector	100 downloads	"Collector" badge
Social Butterfly	Share 10 wallpapers	Premium trial 3 days
Supporter	Tip 5 creators	"Patron" badge
Creator Levels
Table
Level	Name	Requirement	Benefits
1	🌱 Seedling	Sign up	Basic upload (10/day)
2	🌿 Sprout	10 uploads, 100 downloads	Upload limit 25/day
3	🌸 Bloom	50 uploads, 1K downloads	Verified badge, 50/day
4	⭐ Star	200 uploads, 10K downloads	Featured placement, 100/day
5	👑 Legend	500 uploads, 50K downloads	Custom profile, early access, unlimited
📋 FEATURE SUMMARY TABLE
Table
Feature	User App	Creator App	Creator Web	Admin Web
Browse Wallpapers	✅	✅	❌	❌
Download/Apply	✅	❌	❌	❌
Share	✅	❌	❌	❌
Login/Signup	✅	✅	✅	✅
Upload Wallpapers	❌	✅	✅	❌
Set Pricing	❌	✅	✅	❌
View Earnings	❌	✅	✅	❌
Request Payout	❌	✅	✅	❌
Creator Enrollment	❌	✅	✅	❌
Approve Creators	❌	❌	❌	✅
Manage Wallpapers	❌	❌	❌	✅
Process Payouts	❌	❌	❌	✅
View Analytics	❌	✅	✅	✅
User Management	❌	❌	❌	✅
Payment Reports	❌	❌	❌	✅
Content Moderation	❌	❌	❌	✅
🛠️ TECH STACK RECOMMENDATIONS
Mobile (Android + iOS)
Framework: Flutter (single codebase) OR React Native + Reanimated 3
State Management: Riverpod / Zustand
Animations: Lottie, Rive (for complex), Native animations
Image: Cached network image, progressive loading
Payments: Razorpay SDK
Web (Creator + Admin)
Framework: Next.js 14 + TypeScript
Styling: Tailwind CSS + Framer Motion
Charts: Recharts / Tremor
Tables: TanStack Table
Forms: React Hook Form + Zod
Payments: RazorpayX API for payouts
Backend
API: Node.js + Express / Fastify OR Firebase
Database: PostgreSQL (structured data) + Redis (caching)
Storage: AWS S3 / Cloudflare R2 (wallpaper images)
CDN: Cloudflare (global delivery)
Queue: BullMQ (payout processing, notifications)
Search: Algolia (wallpaper search)
Document Version: 1.0
Last Updated: 2026-07-20