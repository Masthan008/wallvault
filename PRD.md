# WALLVAULT — Product Requirements Document (PRD)
## CRED-Inspired Dark Theme Wallpaper App with Creator Economy

**Version:** 1.0  
**Date:** 2026-07-20  
**Status:** Draft  
**Author:** Product Team  
**Tech Stack:** Firebase + Cloudinary + Razorpay + AntiGravity IDE (Vibe Coding)

---

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Objectives & Success Metrics](#3-objectives--success-metrics)
4. [Target Audience & Personas](#4-target-audience--personas)
5. [Competitive Analysis](#5-competitive-analysis)
6. [Product Scope](#6-product-scope)
7. [User Stories & Acceptance Criteria](#7-user-stories--acceptance-criteria)
8. [Feature Specifications](#8-feature-specifications)
9. [UI/UX Design System](#9-uiux-design-system)
10. [Screen Inventory](#10-screen-inventory)
11. [Technical Architecture](#11-technical-architecture)
12. [Database Schema](#12-database-schema)
13. [API Specifications](#13-api-specifications)
14. [Payment & Payout Flow](#14-payment--payout-flow)
15. [Security & Compliance](#15-security--compliance)
16. [Non-Functional Requirements](#16-non-functional-requirements)
17. [Analytics & Metrics](#17-analytics--metrics)
18. [Launch Plan](#18-launch-plan)
19. [AntiGravity IDE Prompt Strategy](#19-antigravity-ide-prompt-strategy)
20. [Appendix](#20-appendix)

---

## 1. Executive Summary
WallVault is a premium wallpaper marketplace that combines a curated discovery experience with a creator economy. Inspired by CRED's dark, motion-heavy, premium UI, WallVault allows users to discover, download, and apply stunning wallpapers while supporting independent creators through direct purchases and tips.

### Key Differentiators:
* CRED-inspired dark premium UI with micro-interactions and 3D effects
* Creator marketplace where users can upload, price, and sell wallpapers
* 70/20/10 revenue split favoring creators
* Gamified creator levels and user streaks
* Cross-platform: Android, iOS, Web (Creator Portal + Admin Dashboard)

---

## 2. Problem Statement
### User Problems:
* **Discovery Fatigue:** Existing wallpaper apps overwhelm users with low-quality, repetitive content.
* **No Creator Support:** Users want to support artists but lack direct channels.
* **Generic Experience:** Most apps feel utilitarian, not premium or delightful.
* **Limited Monetization for Creators:** Artists struggle to monetize digital wallpaper art.

### Business Problem:
* Wallpaper apps have high churn because they lack engagement mechanics.
* No existing platform successfully combines premium UX with creator marketplace.
* Subscription fatigue exists (e.g., MKBHD's Panels at $12/month failed due to pricing backlash).

### Solution:
WallVault solves this by creating a premium discovery + creator marketplace hybrid with gamification, fair revenue sharing, and a CRED-inspired experience that makes every interaction feel rewarding.

---

## 3. Objectives & Success Metrics
### Business Objectives
| Objective | Target | Timeline |
| :--- | :--- | :--- |
| Acquire 10,000 MAU | 10,000 monthly active users | Month 6 |
| Onboard 500 Creators | 500 verified creators | Month 6 |
| Achieve 5% Paid Conversion | 5% of users subscribe or buy | Month 6 |
| Process ₹5L Creator Payouts | ₹5,00,000 paid to creators | Month 6 |
| Maintain <3% Churn | Monthly churn under 3% | Ongoing |

### Success Metrics (KPIs)
| Metric | Definition | Target |
| :--- | :--- | :--- |
| DAU/MAU Ratio | Daily active / Monthly active | >20% |
| Avg Session Duration | Time spent per session | >4 minutes |
| Wallpaper Download Rate | Downloads / Views | >15% |
| Creator Retention | Creators active after 30 days | >60% |
| NPS Score | Net Promoter Score | >50 |
| App Store Rating | Average rating | >4.5 |

---

## 4. Target Audience & Personas
### Persona 1: "The Aesthetic Seeker" — Rahul, 24
* **Demographics:** College student/young professional, Android user.
* **Behaviors:** Changes wallpaper weekly, follows design trends, shares aesthetics on social media.
* **Pain Points:** Can't find unique wallpapers, tired of same stock images.
* **Goals:** Discover fresh, high-quality wallpapers that match their vibe.
* **Revenue Potential:** Free user → Pro subscriber after streak rewards.

### Persona 2: "The Creator" — Priya, 28
* **Demographics:** Freelance digital artist, uses Procreate/Photoshop.
* **Behaviors:** Creates 5-10 wallpapers/month, wants passive income.
* **Pain Points:** No platform to sell wallpapers, unfair revenue splits elsewhere.
* **Goals:** Build following, earn from digital art, get featured.
* **Revenue Potential:** Sells wallpapers at ₹29-99, earns 70% per sale.

### Persona 3: "The Premium User" — Arjun, 32
* **Demographics:** Tech professional, iOS user, values quality over price.
* **Behaviors:** Pays for premium apps, curates home screen setups.
* **Pain Points:** Ads ruin experience, low-res downloads, no exclusive content.
* **Goals:** Ad-free, high-res, exclusive wallpapers with seamless apply.
* **Revenue Potential:** Annual Pro subscriber (₹299/year).

### Persona 4: "The Admin" — Team WallVault
* **Demographics:** Internal operations team.
* **Behaviors:** Reviews content, processes payouts, monitors platform health.
* **Pain Points:** Manual processes, lack of visibility into creator performance.
* **Goals:** Efficient moderation, automated payouts, data-driven decisions.

---

## 5. Competitive Analysis
| Competitor | Strengths | Weaknesses | Our Advantage |
| :--- | :--- | :--- | :--- |
| **One4Wall** | Free 4K library, ad-light | No creator economy, no premium feel | Creator marketplace + CRED UI |
| **Walli** | Artist marketplace | Diluted with AI content, dated UI | Curated quality + premium UX |
| **Backdrops** | Freemium, AMOLED filter | Limited monetization for creators | Better revenue split + gamification |
| **Zedge** | Massive library | Cluttered UI, ad-heavy | Premium dark theme, clean UX |
| **Panels (MKBHD)**| High-quality | $12/month — pricing backlash | Fair pricing ₹49-299 |

---

## 6. Product Scope
### IN SCOPE (MVP)
* User authentication (Phone OTP, Google, Apple)
* Wallpaper browsing (categories, trending, search)
* Wallpaper download and apply (Home/Lock/Both)
* Creator enrollment and upload system
* Paid wallpaper marketplace (user sets price)
* Subscription tiers (Free, Pro Monthly, Pro Yearly)
* Creator dashboard with earnings analytics
* Admin dashboard for moderation and payouts
* Razorpay integration (payments + payouts)
* Cloudinary image management
* Firebase backend (Auth, Firestore, Functions)

### OUT OF SCOPE (Post-MVP)
* AI wallpaper generation
* Live wallpapers (platform restrictions)
* Social feed / following system
* In-app messaging between users and creators
* Multi-language support (Hindi, Tamil, etc.)
* Widget integration
* AR wallpaper preview

---

## 7. User Stories & Acceptance Criteria

### EPIC 1: User Authentication & Onboarding
#### US-1.1: User Registration
As a new user, I want to sign up with my phone number so that I can start using WallVault.
* **Acceptance Criteria:**
  - [ ] User can enter phone number (validated for Indian format +91)
  - [ ] OTP is sent within 30 seconds
  - [ ] 6-digit OTP auto-focuses between boxes
  - [ ] On success, user is taken to onboarding
  - [ ] Failed OTP shows error with retry option (30s cooldown)

#### US-1.2: Social Login
As a user, I want to sign up with Google/Apple so that I can skip phone verification.
* **Acceptance Criteria:**
  - [ ] Google Sign-In button triggers native OAuth flow
  - [ ] Apple Sign-In available on iOS
  - [ ] Account linking works for existing phone users
  - [ ] Profile auto-populates name and email

#### US-1.3: Onboarding Flow
As a new user, I want to see the app's value proposition so that I understand what WallVault offers.
* **Acceptance Criteria:**
  - [ ] 3-slide onboarding with parallax wallpapers
  - [ ] Slide 1: "Discover Stunning Walls" with tilt-to-parallax
  - [ ] Slide 2: "Support Creators" with coin rain animation
  - [ ] Slide 3: "Go Premium" with lock unlock animation
  - [ ] Skip button available on all slides
  - [ ] "Get Started" CTA on final slide navigates to Home

---

### EPIC 2: Wallpaper Discovery & Download
#### US-2.1: Browse Home Feed
As a user, I want to see personalized wallpaper recommendations so that I discover new content.
* **Acceptance Criteria:**
  - [ ] Home shows "For You", "Trending", "Categories", "Creators" tabs
  - [ ] Featured carousel auto-scrolls every 5s
  - [ ] 2-column masonry grid with lazy loading
  - [ ] Cards show: preview, name, creator, price, download count
  - [ ] Pull-to-refresh with elastic animation
  - [ ] Infinite scroll with shimmer skeleton

#### US-2.2: Wallpaper Detail View
As a user, I want to see wallpaper details before downloading so that I know what I'm getting.
* **Acceptance Criteria:**
  - [ ] Full-bleed image with pinch-to-zoom
  - [ ] Draggable info sheet with name, creator, tags, resolution
  - [ ] Price displayed (gold for paid, green for free)
  - [ ] Related wallpapers section
  - [ ] Share button generates preview card
  - [ ] Favorite button with heart burst animation

#### US-2.3: Download & Apply Wallpaper
As a user, I want to download and apply wallpapers so that I can use them immediately.
* **Acceptance Criteria:**
  - [ ] Download button morphs: text → circle → progress → checkmark → confetti
  - [ ] Progress shown with circular ring animation
  - [ ] Success triggers haptic feedback (medium tap)
  - [ ] Apply modal shows Home/Lock/Both previews
  - [ ] One-tap apply to system
  - [ ] Downloaded wallpapers available offline

#### US-2.4: Search & Filter
As a user, I want to search for specific wallpapers so that I find what I'm looking for.
* **Acceptance Criteria:**
  - [ ] Search bar with glowing purple border on focus
  - [ ] Trending searches as pill tags
  - [ ] Recent search history with clear option
  - [ ] Category grid (Nature, Abstract, Cars, Anime, Space, Dark)
  - [ ] Results show in grid with filter chips
  - [ ] Empty state with illustration when no results

---

### EPIC 3: Creator Economy
#### US-3.1: Creator Enrollment
As an aspiring creator, I want to apply to become a creator so that I can sell my wallpapers.
* **Acceptance Criteria:**
  - [ ] 4-step wizard: Basic Info → Portfolio → Payout Setup → Review
  - [ ] Step 1: Display name, bio, profile photo upload
  - [ ] Step 2: Upload 3 sample wallpapers (min 1080p)
  - [ ] Step 3: UPI ID or Razorpay Connect setup
  - [ ] Step 4: Review all details, agree to terms, submit
  - [ ] Admin receives notification for approval
  - [ ] User sees "Pending Approval" status

#### US-3.2: Upload Wallpaper
As a creator, I want to upload wallpapers with details so that users can discover and buy them.
* **Acceptance Criteria:**
  - [ ] 3-step upload: Select → Details → Pricing
  - [ ] Step 1: Image picker/drag-drop, auto-crop to 9:16
  - [ ] Step 2: Name, category, tags (auto-suggest), description
  - [ ] Step 3: Free/Paid toggle, price input (₹), earnings preview
  - [ ] Earnings breakdown: 70% creator, 20% platform, 10% community
  - [ ] Submit triggers admin review queue
  - [ ] Success shows rocket launch animation

#### US-3.3: Creator Dashboard
As a creator, I want to see my performance so that I track my earnings and growth.
* **Acceptance Criteria:**
  - [ ] Total earnings card with animated counter
  - [ ] Monthly earnings line chart (7-day view)
  - [ ] Top wallpapers list with download bars
  - [ ] Payout status: available balance + request button
  - [ ] Creator level badge with XP progress bar
  - [ ] Quick links: Upload New, View Analytics, Request Payout

#### US-3.4: Request Payout
As a creator, I want to withdraw my earnings so that I receive my money.
* **Acceptance Criteria:**
  - [ ] Shows available balance (min ₹500 to withdraw)
  - [ ] Amount input with max button
  - [ ] Payout method displayed (UPI/Razorpay)
  - [ ] Request triggers admin notification
  - [ ] Status updates: Pending → Processing → Completed
  - [ ] Payout history table with transaction IDs

---

### EPIC 4: Payments & Subscriptions
#### US-4.1: Buy Paid Wallpaper
As a user, I want to purchase wallpapers so that I support creators and get exclusive content.
* **Acceptance Criteria:**
  - [ ] Tap "Buy" opens Razorpay checkout
  - [ ] Supports UPI, Card, Wallet, Netbanking
  - [ ] Payment success triggers confetti + haptic
  - [ ] Wallpaper unlocks with cinematic reveal animation
  - [ ] Creator receives notification of sale
  - [ ] Transaction logged in user history

#### US-4.2: Subscribe to Pro
As a user, I want to subscribe to Pro so that I get unlimited downloads and exclusive content.
* **Acceptance Criteria:**
  - [ ] Three plans: Monthly ₹49, Yearly ₹299 (Save 49%), Lifetime ₹999
  - [ ] Feature checklist for each plan
  - [ ] Razorpay subscription checkout
  - [ ] Success shows golden unlock animation
  - [ ] Pro badge appears on profile
  - [ ] Subscription management in profile

#### US-4.3: Tip Creator
As a user, I want to tip creators so that I show appreciation for free wallpapers.
* **Acceptance Criteria:**
  - [ ] Tip button on wallpaper detail and creator profile
  - [ ] Preset amounts: ₹10, ₹29, ₹49, Custom
  - [ ] Razorpay checkout for tip
  - [ ] Creator receives tip notification
  - [ ] Tip count shown on creator profile

---

### EPIC 5: Admin Operations
#### US-5.1: Review Creator Applications
As an admin, I want to approve or reject creators so that I maintain quality.
* **Acceptance Criteria:**
  - [ ] Pending creators list with portfolio preview
  - [ ] Approve/Reject buttons with optional notes
  - [ ] Approved creators get verified badge
  - [ ] Rejected creators get reason + reapply option
  - [ ] Email notification sent to creator

#### US-5.2: Moderate Wallpapers
As an admin, I want to review uploaded wallpapers so that I ensure quality and compliance.
* **Acceptance Criteria:**
  - [ ] Pending wallpapers grid with preview
  - [ ] Bulk approve/reject/delete actions
  - [ ] Detail modal with metadata and preview
  - [ ] Flagged content queue (AI + user reports)
  - [ ] Auto-approve for verified creators (Level 3+)

#### US-5.3: Process Payouts
As an admin, I want to process creator payouts so that creators receive earnings.
* **Acceptance Criteria:**
  - [ ] Pending payouts table: creator, amount, method, date
  - [ ] Individual "Process" button per payout
  - [ ] Bulk "Process All" button
  - [ ] RazorpayX API integration for UPI transfers
  - [ ] Transaction ID logged on success
  - [ ] Creator and admin both notified

#### US-5.4: View Analytics
As an admin, I want to see platform analytics so that I make data-driven decisions.
* **Acceptance Criteria:**
  - [ ] KPI cards: Users, Wallpapers, Subscriptions, Revenue
  - [ ] Revenue breakdown by source (subscriptions, sales, tips)
  - [ ] User growth chart
  - [ ] Top creators and wallpapers tables
  - [ ] Export reports to CSV

---

## 8. Feature Specifications
### 8.1 Wallpaper Discovery Engine
* **Algorithm:** Hybrid (Editorial + Personalized + Trending)
  - **For You:** 40% editorial curated + 40% collaborative filtering + 20% new uploads
  - **Trending:** Download velocity (downloads/time) in last 24h
  - **Categories:** Manual tagging + AI auto-tagging (post-MVP)
  - **Creators:** Followed creators first, then trending creators

### 8.2 Creator Verification Levels
| Level | Name | Requirements | Benefits |
| :--- | :--- | :--- | :--- |
| 1 | 🌱 Seedling | Sign up | 10 uploads/day |
| 2 | 🌿 Sprout | 10 uploads, 100 downloads | 25 uploads/day |
| 3 | 🌸 Bloom | 50 uploads, 1K downloads | Verified badge, 50/day, auto-approve |
| 4 | ⭐ Star | 200 uploads, 10K downloads | Featured placement, 100/day |
| 5 | 👑 Legend | 500 uploads, 50K downloads | Custom profile, unlimited, early access |

### 8.3 Gamification System
#### User Side:
* **Download Streak:** Daily downloads earn streak points, milestones at 7/30/100 days
* **Collection Badges:** Complete category sets ("Nature Explorer", "Abstract Master")
* **Social Sharing:** Share to unlock exclusive wallpapers
* **Referral:** Invite friend → both get 7-day Pro trial

#### Creator Side:
* **XP System:** Uploads (+10 XP), Downloads (+1 XP), Sales (+50 XP), Tips (+20 XP)
* **Leaderboard:** Weekly top creators with podium animation
* **Achievements:** "First Download", "100 Downloads", "First Sale", "Trending Creator"

### 8.4 Revenue Model
| Revenue Stream | Split | Processing |
| :--- | :--- | :--- |
| **Wallpaper Sales** | 70% Creator / 20% Platform / 10% Community Pool | Razorpay checkout |
| **Tips** | 80% Creator / 20% Platform | Razorpay checkout |
| **Pro Subscriptions** | Platform revenue | Razorpay subscriptions |
| **Community Pool** | Monthly contests, featured rewards | Internal |

---

## 9. UI/UX Design System

### 9.1 Color Palette
```css
/* Backgrounds */
--bg-primary: #0A0A0F;      /* Deep Black */
--bg-secondary: #12121A;    /* Dark Navy */
--bg-card: #1A1A24;         /* Elevated Dark */
--bg-elevated: #22222E;     /* Higher Elevation */

/* Accents */
--accent-purple: #B829DD;   /* Neon Purple */
--accent-cyan: #00D4FF;     /* Electric Cyan */
--accent-gold: #FFD700;     /* Premium Gold */
--accent-success: #00E676;  /* Success Green */
--accent-error: #FF1744;    /* Error Red */
--accent-warning: #FF9100;  /* Warning Orange */

/* Text */
--text-primary: #FFFFFF;
--text-secondary: #8B8B9E;
--text-muted: #5A5A6E;

/* Gradients */
--gradient-hero: linear-gradient(135deg, #B829DD 0%, #00D4FF 100%);
--gradient-premium: linear-gradient(180deg, #1A1A24 0%, #0A0A0F 100%);
--gradient-gold: linear-gradient(135deg, #FFD700 0%, #FF9100 100%);
```

### 9.2 Typography
* **Font Family:** Inter (Android), SF Pro Display (iOS), Inter (Web)
* **Headings:** Bold, tight letter-spacing (-0.5px to -0.2px)
* **Body:** Regular, line-height 1.4-1.5
* **Scale:** 32px (H1) → 24px (H2) → 20px (H3) → 16px (H4) → 14px (Body) → 12px (Caption)

### 9.3 Spacing & Shape
* **Border Radius:** Cards 20px, Buttons 16px, Inputs 12px, Avatars 50%
* **Padding:** Screen 16px, Cards 16px, Buttons 16px horizontal / 14px vertical
* **Shadows:** Cards `0 8px 32px rgba(0,0,0,0.4)`, Buttons `0 4px 20px rgba(184,41,221,0.3)`

### 9.4 Animation Tokens
```css
/* Easing */
--ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
--ease-smooth: cubic-bezier(0.4, 0, 0.2, 1);
--ease-dramatic: cubic-bezier(0.87, 0, 0.13, 1);
--ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);

/* Durations */
--duration-micro: 150ms;
--duration-fast: 250ms;
--duration-medium: 400ms;
--duration-slow: 700ms;
--duration-epic: 1200ms;
```

### 9.5 Component Library
*(See Design System Document for full component specs)*

---

## 10. Screen Inventory
### 10.1 Mobile App Screens (28)

#### Authentication (7)
| ID | Screen | Description |
| :--- | :--- | :--- |
| S01 | Splash | Animated logo draw + particle burst |
| S02 | Onboarding 1 | Discover walls, parallax cards |
| S03 | Onboarding 2 | Support creators, coin rain |
| S04 | Onboarding 3 | Go Premium, lock unlock |
| S05 | Login | Phone + Password + Social |
| S06 | Sign Up | 4-step registration form |
| S07 | OTP Verification | 6-digit code input |

#### User Core (9)
| ID | Screen | Description |
| :--- | :--- | :--- |
| S08 | Home | Masonry grid, tabs, featured carousel |
| S09 | Wallpaper Detail | Full-bleed, draggable info sheet |
| S10 | Apply Modal | Home/Lock/Both preview |
| S11 | Search | Tags, recent, categories |
| S12 | Profile | Stats, subscription, settings |
| S13 | My Downloads | Offline grid, multi-select |
| S23 | Subscription | Plan cards, feature checklist |
| S24 | Notifications | List with swipe dismiss |
| S25 | Settings | Grouped toggles and options |

#### Creator Mobile (9)
| ID | Screen | Description |
| :--- | :--- | :--- |
| S14 | Enrollment Step 1 | Basic info + photo upload |
| S15 | Enrollment Step 2 | Portfolio (3 samples) |
| S16 | Enrollment Step 3 | Payout setup (UPI/Razorpay) |
| S17 | Enrollment Step 4 | Review + submit |
| S18 | Creator Dashboard | Earnings, chart, top wallpapers |
| S19 | Upload Step 1 | Drag-drop + crop guides |
| S20 | Upload Step 2 | Category, tags, description |
| S21 | Upload Step 3 | Pricing toggle + earnings calc |
| S22 | Payout Request | Balance, amount, request |

#### Shared States (3)
| ID | Screen | Description |
| :--- | :--- | :--- |
| S36 | Loading/Skeleton | Shimmer, pulsing dots |
| S37 | Empty States | Illustration + CTA |
| S38 | Error States | Alert + retry + support |

### 10.2 Web Screens (10)

#### Creator Web Portal (4)
| ID | Screen | Description |
| :--- | :--- | :--- |
| S26 | Dashboard | KPI cards, earnings chart, uploads |
| S27 | Upload Interface | Drag-drop, crop, pricing calc |
| S28 | Analytics | Charts, heatmap, performance table |
| S29 | Payout Management | Balance, history, export |

#### Admin Web Dashboard (6)
| ID | Screen | Description |
| :--- | :--- | :--- |
| S30 | Overview | 6 KPIs, revenue chart, alerts |
| S31 | Wallpaper Management| Grid, filters, bulk actions |
| S32 | Creator Management | Pending list, table, levels |
| S33 | Payout Management | Pending table, process, history |
| S34 | User Management | Search, table, sidebar, ban |
| S35 | Payment Analytics | Revenue breakdown, disputes |

**TOTAL SCREENS: 38**

---

## 11. Technical Architecture
### 11.1 System Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                           │
├──────────────────┬──────────────────┬───────────────────────┤
│   Android App    │    iOS App       │ Web (Next.js / React) │
│    (Flutter)     │    (Flutter)     │    Creator + Admin    │
└────────┬─────────┴────────┬─────────┴───────────┬───────────┘
         │                  │                     │
         └──────────────────┼─────────────────────┘
                            │ HTTPS/REST + WebSocket
┌───────────────────────────▼───────────────────────────────┐
│                    FIREBASE BACKEND                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Auth      │  │  Firestore  │  │  Cloud Functions    │ │
│  │  (Phone,    │  │  (Users,    │  │  (Business Logic, │ │
│  │   Google,   │  │   Walls,    │  │   Webhooks,        │ │
│  │   Apple)    │  │   Creators, │  │   Notifications)    │ │
│  │             │  │   Payments) │  │                     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   FCM       │  │  Analytics   │  │  Cloud Storage      │ │
│  │  (Push      │  │  (Events,   │  │  (Temp uploads)     │ │
│  │   Notifs)   │  │   Crashlytics│  │                     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└───────────────────────────┬─────────────────────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         │                  │                  │
┌────────▼────────┐  ┌───────▼───────┐  ┌───────▼────────┐
│   CLOUDINARY    │  │   RAZORPAY    │  │   RAZORPAYX    │
│  (Image Storage │  │  (Payments:   │  │  (Payouts:     │
│   + CDN +       │  │   Checkout,    │  │   Creator      │
│   Transform)    │  │   Subscriptions│  │   Transfers)   │
└─────────────────┘  └───────────────┘  └────────────────┘
```

### 11.2 Tech Stack
| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Mobile** | Flutter | Cross-platform iOS + Android |
| **Web** | Next.js 14 + Tailwind CSS | Creator Portal + Admin Dashboard |
| **State** | Riverpod (Mobile) / Zustand (Web) | App state management |
| **Backend** | Firebase | Auth, Database, Functions, Storage |
| **Images** | Cloudinary | Upload, transform, CDN delivery |
| **Payments** | Razorpay | In-app purchases, subscriptions |
| **Payouts** | RazorpayX | Creator UPI transfers |
| **Search** | Algolia / Firestore | Wallpaper search |
| **Analytics** | Firebase Analytics | User behavior tracking |
| **Crash** | Firebase Crashlytics | Error monitoring |

---

## 12. Database Schema
### 12.1 Firestore Collections

```javascript
// users/{userId}
{
  uid: string,
  phone: string,
  email: string,
  displayName: string,
  avatarUrl: string,
  isCreator: boolean,
  creatorStatus: "pending" | "approved" | "rejected",
  subscription: {
    plan: "free" | "monthly" | "yearly" | "lifetime",
    startDate: timestamp,
    endDate: timestamp,
    autoRenew: boolean
  },
  streak: {
    current: number,
    longest: number,
    lastDownloadDate: timestamp
  },
  xp: number,
  level: number,
  badges: ["streak_7", "collector_100", ...],
  favorites: [wallpaperId],
  downloads: [wallpaperId],
  following: [creatorId],
  createdAt: timestamp,
  updatedAt: timestamp
}

// creators/{creatorId}
{
  userId: string,
  displayName: string,
  bio: string,
  avatarUrl: string,
  portfolioUrls: [string],
  payoutMethod: {
    type: "upi" | "razorpay",
    upiId: string,
    razorpayAccountId: string
  },
  level: number,
  xp: number,
  totalEarnings: number,
  availableBalance: number,
  totalDownloads: number,
  totalSales: number,
  status: "pending" | "approved" | "suspended",
  verifiedAt: timestamp,
  createdAt: timestamp
}

// wallpapers/{wallpaperId}
{
  name: string,
  description: string,
  creatorId: string,
  creatorName: string,
  category: "nature" | "abstract" | "cars" | "anime" | "space" | "dark" | ...,
  tags: [string],
  imageUrl: string,           // Cloudinary URL
  thumbnailUrl: string,       // Cloudinary transformed
  resolution: "1080p" | "2K" | "4K" | "8K",
  aspectRatio: "9:16" | "16:9" | "1:1",
  isPremium: boolean,
  price: number,              // INR, 0 for free
  currency: "INR",
  status: "pending" | "approved" | "rejected" | "flagged",
  downloads: number,
  views: number,
  likes: number,
  rating: number,
  ratingCount: number,
  isOledOptimized: boolean,
  isLive: boolean,
  createdAt: timestamp,
  updatedAt: timestamp,
  featuredUntil: timestamp    // null if not featured
}

// transactions/{transactionId}
{
  userId: string,
  type: "purchase" | "subscription" | "tip" | "payout",
  amount: number,
  currency: "INR",
  status: "pending" | "completed" | "failed" | "refunded",
  razorpayOrderId: string,
  razorpayPaymentId: string,
  wallpaperId: string,        // for purchases
  creatorId: string,          // for tips/payouts
  metadata: {},
  createdAt: timestamp
}

// payouts/{payoutId}
{
  creatorId: string,
  amount: number,
  method: "upi" | "razorpay",
  upiId: string,
  razorpayPayoutId: string,
  status: "pending" | "processing" | "completed" | "failed",
  processedBy: string,        // admin userId
  processedAt: timestamp,
  failureReason: string,
  createdAt: timestamp
}

// notifications/{notificationId}
{
  userId: string,
  type: "sale" | "payout" | "approval" | "tip" | "system",
  title: string,
  body: string,
  data: {},
  isRead: boolean,
  createdAt: timestamp
}

// reports/{reportId}
{
  reporterId: string,
  wallpaperId: string,
  reason: "inappropriate" | "copyright" | "quality" | "other",
  description: string,
  status: "pending" | "reviewed" | "resolved",
  reviewedBy: string,
  createdAt: timestamp
}
```

### 12.2 Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Wallpapers: public read, creator write
    match /wallpapers/{wallpaperId} {
      allow read: if true;
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isCreator == true;
      allow update, delete: if request.auth != null && 
        resource.data.creatorId == request.auth.uid;
    }

    // Creators: public read, self write
    match /creators/{creatorId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == creatorId;
    }

    // Transactions: self read only
    match /transactions/{transactionId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }

    // Admin-only collections
    match /payouts/{payoutId} {
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }
  }
}
```

---

## 13. API Specifications
### 13.1 Razorpay Integration
#### Payment Flow
```
1. Client calls Firebase Cloud Function: createOrder
   Input: { amount, currency, receipt }
   Output: { orderId, amount, currency }

2. Client opens Razorpay Checkout with orderId
   User completes payment
   Razorpay returns: { razorpay_payment_id, razorpay_order_id, razorpay_signature }

3. Client calls Firebase Cloud Function: verifyPayment
   Input: { orderId, paymentId, signature }
   Output: { success: true, transactionId }

4. Cloud Function updates Firestore:
   - Create transaction document
   - Update user subscriptions (if subscription)
   - Update creator earnings (if wallpaper purchase)
   - Send FCM notification
```

#### Payout Flow (RazorpayX)
```
1. Admin clicks "Process Payout" in dashboard
2. Cloud Function calls RazorpayX API:
   POST /v1/payouts
   {
     account_number: "<razorpay_account>",
     fund_account_id: "<creator_fund_account>",
     amount: 245000,  // paise
     currency: "INR",
     mode: "UPI",
     purpose: "payout",
     queue_if_low_balance: true
   }

3. RazorpayX processes transfer
4. Webhook updates payout status in Firestore
5. Creator receives notification
```

### 13.2 Cloudinary Integration
```
Upload Flow:
1. Client uploads image to Cloudinary (signed upload)
2. Cloudinary returns: { public_id, url, secure_url }
3. Client stores public_id in Firestore
4. On fetch, request transformed versions:
   - Thumbnail: w_400,h_600,c_fill,q_auto
   - Preview: w_800,h_1200,c_fill,q_auto
   - Full: w_1920,h_2880,c_fill,q_auto
   - Download: original quality
```

### 13.3 Firebase Cloud Functions
| Function | Trigger | Purpose |
| :--- | :--- | :--- |
| `createOrder` | HTTPS Callable | Create Razorpay order |
| `verifyPayment` | HTTPS Callable | Verify payment signature |
| `processPayout` | HTTPS Callable | Process creator payout |
| `onWallpaperCreated` | Firestore onCreate | Auto-moderation, notify admin |
| `onTransactionComplete` | Firestore onCreate | Update creator balance, send notification |
| `onPayoutStatusUpdate` | Firestore onUpdate | Notify creator, log transaction |
| `sendPushNotification` | HTTPS Callable | Send FCM notification |
| `generateThumbnail` | Storage onFinalize | Auto-generate wallpaper thumbnails |
| `cleanupExpiredSubscriptions` | Scheduled (daily) | Check and expire subscriptions |

---

## 14. Payment & Payout Flow

### 14.1 User Purchase Flow
```
User taps "Buy" (₹49)
    ↓
Client calls createOrder Cloud Function
    ↓
Cloud Function creates Razorpay order
    ↓
Client opens Razorpay Checkout modal
    ↓
User completes payment (UPI/Card/Wallet)
    ↓
Razorpay returns payment signature
    ↓
Client calls verifyPayment Cloud Function
    ↓
Cloud Function verifies signature with Razorpay
    ↓
On success:
  - Create transaction document
  - Mark wallpaper as purchased for user
  - Add ₹34.30 to creator balance (70%)
  - Add ₹9.80 to platform revenue (20%)
  - Add ₹4.90 to community pool (10%)
  - Send FCM to creator: "You made a sale!"
  - Unlock wallpaper with cinematic animation
```

### 14.2 Subscription Flow
```
User selects Pro Yearly (₹299)
    ↓
Client creates Razorpay subscription
    ↓
User completes first payment
    ↓
Webhook confirms subscription active
    ↓
Cloud Function:
  - Update user.subscription.plan = "yearly"
  - Set endDate = today + 365 days
  - Add Pro badge to profile
  - Send welcome notification
    ↓
Recurring billing handled by Razorpay
    ↓
Webhook on renewal updates endDate
```

### 14.3 Creator Payout Flow
```
Creator requests payout (₹2,450)
    ↓
Check: availableBalance >= 500? Yes
    ↓
Create payout document (status: pending)
    ↓
Admin receives notification
    ↓
Admin reviews in dashboard
    ↓
Admin clicks "Process"
    ↓
Cloud Function calls RazorpayX API
    ↓
RazorpayX initiates UPI transfer
    ↓
Webhook confirms transfer
    ↓
Cloud Function:
  - Update payout status: completed
  - Deduct from creator.availableBalance
  - Create transaction record
  - Send notification to creator
```

---

## 15. Security & Compliance
* **Data Security:** Firebase Auth (Phone OTP, Google OAuth, Apple Sign-In), Firestore Rules (role-based access control), API Keys in Firebase environment config, Razorpay keys in Cloud Functions only, signed uploads to Cloudinary, TLS 1.3 encryption.
* **Compliance:** GDPR data portability & deletion, PCI-DSS compliance via Razorpay checkout, UPI payouts comply with NPCI regulations, content moderation queue, age gate (13+ for creators).
* **Fraud Prevention:** Rate limiting (100 API calls/minute), CAPTCHA, transaction anomaly flagging, creator profile verification before payout, ₹500 minimum payout threshold.

---

## 16. Non-Functional Requirements
### 16.1 Performance
| Metric | Target |
| :--- | :--- |
| App Launch Time | <2 seconds |
| Screen Load Time | <500ms |
| API Response Time | <200ms (p95) |
| Image Load Time | <1s for thumbnail, <3s for full |
| Search Response | <300ms |
| Payment Processing | <5s end-to-end |

### 16.2 Scalability & Reliability
* Support 100,000 MAU in Year 1.
* Handle 10,000 concurrent downloads.
* Uptime SLA: 99.9%.
* Offline mode: Cached wallpapers viewable without internet.
* Battery and data optimization via WebP formats, image caching, and lazy loading.

---

## 17. Analytics & Metrics
### 17.1 Event Tracking
| Event | Properties | Trigger |
| :--- | :--- | :--- |
| `app_open` | source | Every app launch |
| `wallpaper_view` | wallpaperId, source | Card tap |
| `wallpaper_download` | wallpaperId, price, creatorId | Download complete |
| `wallpaper_apply` | wallpaperId, target (home/lock/both) | Apply success |
| `wallpaper_share` | wallpaperId, platform | Share action |
| `creator_enroll_start` | step | Enrollment step 1 |
| `creator_enroll_complete` | method | Enrollment submit |
| `creator_upload` | wallpaperId, price | Upload publish |
| `purchase_initiated` | product, amount | Buy tap |
| `purchase_completed` | product, amount, method | Payment success |
| `subscription_started` | plan, amount | Subscription active |
| `payout_requested` | amount | Payout request |
| `payout_processed` | amount, method | Payout complete |

---

## 18. Launch Plan
* **Phase 1: MVP (Month 1-2)**
  - [ ] Core auth (Phone OTP + Google)
  - [ ] Home feed with curated wallpapers
  - [ ] Download and apply
  - [ ] Basic creator upload (free only)
  - [ ] Razorpay integration
  - [ ] Admin dashboard (basic)
* **Phase 2: Marketplace (Month 3-4)**
  - [ ] Paid wallpapers
  - [ ] Creator enrollment flow
  - [ ] Creator dashboard
  - [ ] Payout system
  - [ ] Subscription tiers
  - [ ] Tip feature
* **Phase 3: Growth (Month 5-6)**
  - [ ] Gamification (streaks, badges)
  - [ ] Referral program
  - [ ] Social sharing rewards
  - [ ] Advanced analytics
  - [ ] Push notifications
  - [ ] Seasonal collections
* **Phase 4: Scale (Month 7-12)**
  - [ ] AI-powered recommendations
  - [ ] Live wallpapers (if feasible)
  - [ ] International expansion
  - [ ] API for third-party integrations
  - [ ] White-label creator storefronts

---

## 19. AntiGravity IDE Prompt Strategy
### Category A: Project Setup (5 prompts)
1. **Project Scaffold:** Create a Flutter project called "wallvault" with Firebase integration. Setup Firebase Auth, Firestore, Cloud Storage, and Cloud Messaging. Configure Cloudinary for image uploads. Setup Razorpay for payments. Use Riverpod for state management. Dark theme with CRED-inspired design system.
2. **Navigation Structure:** Create bottom navigation with 5 tabs: Home, Search, Upload (FAB), Creator Dashboard, Profile. Setup GoRouter with deep linking. Include route guards for auth and creator status.
3. **Theme & Design System:** Create a complete theme configuration with: Color scheme (deep black backgrounds, neon purple #B829DD, electric cyan #00D4FF, gold #FFD700), typography (Inter font, heading scale), component styles (cards 20px radius, buttons 16px radius), animation constants (spring physics, durations), dark mode only.
4. **Firebase Configuration:** Setup Firebase services: Auth (Phone OTP, Google Sign-In, Apple Sign-In), Firestore (Collections for users, wallpapers, creators, transactions, payouts, notifications), Cloud Functions (createOrder, verifyPayment, processPayout, onWallpaperCreated, onTransactionComplete), Storage (Temporary upload bucket), FCM (Push notification service).
5. **API Service Layer:** Create service classes: AuthService, WallpaperService, CreatorService, PaymentService, AdminService, CloudinaryService.

### Category B: UI Screens (38 prompts)
Prompts for each of the 38 screens detailing layout description, animation requirements, state management, navigation actions in CRED-inspired dark premium theme.

### Category C: Business Logic (10 prompts)
Core business logic, state management, downloads, payments, payouts, gamification, and analytics.

### Category D: Web Portals (10 prompts)
Creator Web Portal and Admin Web Dashboard views, dashboards, payout management, and moderation UI.

### Category E: Backend Functions (8 prompts)
Cloud Functions (Auth, Payments, Payouts, Notifications, Image processing, Webhooks, and security rules).

---

## 20. Appendix
### 20.1 Glossary
| Term | Definition |
| :--- | :--- |
| **Vibe Coding** | AI-assisted development where natural language prompts generate code. |
| **CRED UI** | Premium dark interface with micro-interactions and gamification. |
| **RazorpayX** | Razorpay's payout solution for transferring money to vendors/creators. |
| **Cloudinary** | Cloud-based image management service with CDN. |
| **Firestore** | NoSQL document database by Firebase. |
| **FCM** | Firebase Cloud Messaging for push notifications. |
| **UPI** | Unified Payments Interface (India's instant payment system). |

### 20.2 Revision History
| Version | Date | Changes | Author |
| :--- | :--- | :--- | :--- |
| 1.0 | 2026-07-20 | Initial PRD | Product Team |

### 20.3 References
* CRED App Design Language
* Razorpay Integration Documentation
* Firebase Best Practices
* Cloudinary Image API
* WCAG 2.1 Accessibility Guidelines

---
**END OF DOCUMENT**  
*This PRD serves as the single source of truth for WallVault development.*
