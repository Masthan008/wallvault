# WallVault Mobile — Advanced UI/UX Redesign Plan

> Target: the Flutter app in `wallvault/` (mobile app for creators + end users).
> Goal: a full motion-first redesign — animations, effects, transitions, and micro-interactions —
> matching the quality bar set by the web console redesign, on top of the existing CRED-inspired
> dark theme and Riverpod/go_router architecture.

---

## 1. Current State (Analysis Summary)

### 1.1 What already exists
- **Theme layer is solid**: `app_colors.dart`, `app_animations.dart`, `app_spacing.dart`, `app_typography.dart`,
  `app_theme.dart` — dark-only, `Inter`, purple/cyan/gold accents, Material 3.
- **Good animation DNA in a few screens**: splash (stroke-drawn logo, particle burst), onboarding
  (3D perspective phone cards, coin rain, confetti, Lottie), login/signup (flutter_animate stagger + 3D tilt).
- **Packages already present**: `flutter_animate`, `lottie`, `shimmer`, `flutter_staggered_grid_view`,
  `nav_bar` (liquid nav), `google_fonts`, `cached_network_image`, `go_router`.

### 1.2 Core problems to fix
| Area | Problem |
|---|---|
| **Dead/orphaned widgets** | `WallpaperCard`, `WallpaperGridShimmer`, `ListItemShimmer`, `EmptyScreen`, `ErrorScreen`, `LoadingScreen`, `AnimatedCounter` are all **defined but barely/never used**. Home/Search/Saved each re-implement cards inline. |
| **Route transitions** | go_router uses default transitions everywhere; shell tabs use `NoTransitionPage` (hard cut). |
| **Feed grids** | No entrance/stagger, no Hero to detail, loading = bare spinner (no skeleton). |
| **Detail screen** | No parallax, no pinch-zoom, no shared-element, hand-rolled confetti `doWhile` loop, abrupt full-view toggle. |
| **Auth drift** | OTP is the plainest screen (no glass/Lottie/glow) and breaks the visual language; `_SocialButton` copy-pasted with zero press animation; splash uses hard `Future.delayed` + no transition. |
| **Creator hub is mock** | analytics = emoji placeholders (no charts); payout CTA is an empty `// TODO`; dashboard/payout hardcoded; success states are `SnackBar` only. |
| **Profile/settings** | Static headers, dead "Favorites List" tile, no level-progress bar, raw `SnackBar` everywhere, list items never animate. |
| **Shared screens dead code** | `EmptyScreen`/`ErrorScreen`/`LoadingScreen` unused; every screen inlines plain `Text`/`CircularProgressIndicator`. |
| **No toast system** | All feedback is `ScaffoldMessenger.showSnackBar`. |

### 1.3 Inventories
- **20 total screens**: 5 auth (splash 388, onboarding 1104, login 400, signup 413, otp 209),
  5 discovery (home 470, detail 1221, search 276, saved 142, apply wall sheet 466),
  6 creator (enroll 454, upload 425, analytics 98, payout 119, profile 312, dashboard 202),
  4 profile (profile 340, downloads 102, notifications 89, settings 792) + subscription (290).
- **3 shared screens** (empty 66, error 63, loading 32) — unused infrastructure.
- **New dependency**: `fl_chart` (charts, add to pubspec) is the only required new package;
  everything else (aurora, toasts, confetti, tilts) is built with what exists.
- **Lottie assets**: `sparkle_stars.json`, `golden_coins.json`, `premium_crown.json`.

### 1.4 How state feeds the animation layer
- Riverpod 3 (classic `Provider`/`FutureProvider`/`StreamProvider`, no `AsyncNotifier`).
- `wallpaperProvider` yields full lists (atomic) → perfect for staggered entrances on data arrival.
- `notificationsProvider` is a live `StreamProvider` → detect insertions via `ref.listen` and animate.
- No pagination exists anywhere (all feeds load whole lists).
- Screens wrap verticals and horizontal lazy lists; grid + detail images serve from a nullable `imageUrl`.

---

## 2. Shared Motion Language (rules for every screen)

1. **Motion constants** — extend `AppAnimations` with Flutter equivalents of the web signature ease:
   `Easing.emphasizedDecelerate`-style cubic `(0.16, 1, 0.3, 1)` and `emphasizedAccelerate` `(0.3, 0, 1, 1)`;
   durations micro(150) / fast(250) / medium(400) / slow(700) / epic(1200).
2. **Entrance** — pages/views fade+slide up; **grid/lists stagger** by index (50–150ms); **numbers count up**;
   **loading = branded skeleton shimmer**, never bare spinners.
3. **Haptics** — `HapticFeedback.lightImpact()` on like/press/success; `selectionClick()` on toggles/filters.
4. **Toast system** — replace raw `ScaffoldMessenger.showSnackBar` with a single animated `AppToast`
   (slide+scale in, auto-dismiss, success/error/warning variants).
5. **Success moments** — celebratory `ConfettiBurst` (controller-driven) + Lottie on completion
   (payout, purchase, upload, publication, etc.).
6. **Shared notes**: one `ShimmerBox` skeleton style; glass panels via a single `GlassPanel`; hero
   transitions use matching `Hero` tags; `AnimatedSwitcher` for state swaps (loading↔data, category, tab).

---

## 3. Phased Execution Plan

### Phase 0 — Foundations (design-system + shared widget library)
**Goal:** one place for every new effect so screens only wire config, not animation code.

Files (new):
- `lib/core/theme/app_gradients.dart` — aurora mesh gradients, glass surface tokens, shimmer sweep,
  text-gradient shader recipes (top-level blue used by native).
- `lib/core/theme/app_animations.dart` — extend with the two eased curves + stagger/ease helpers.
- `lib/core/widgets/effects/` library:
  - `aurora_background.dart` — `AuroraBackground` (custom painter, 2–3 slowly drifting radial blobs,
    ambient pulse) mounted under auth + shell screens.
  - `motion_scaffold.dart` / `fade_page_transition.dart` — `FadeSlidePage` builder + `slideUp` helper.
  - `entrance.dart` — `Entrance` wrapper (`flutter_animate`-based) with `delay`/`direction`/`player`.
  - `stagger.dart` — `StaggerGrid`/`StaggerList` wrappers (indexed delays).
  - `glass_panel.dart` — reusable glass/container w/ border, blur, gradient hairline, glow.
  - `gradient_border.dart` — animated gradient border (conic sweep via `CustomPainter`).
  - `animated_text_gradient.dart` — `ShaderMask` hero title.
  - `holder_shimmer.dart` — raster-grid skeleton (`WallpaperGridSkeleton` refactor, wire-able).
  - `glow_button.dart` — upgrade `GradientButton`: add sheen sweep (position-driven gradient),
    ripple, glow pulse on press; keep existing API for back-compat.
  - `count_up.dart` — promote `AnimatedCounter` from `core/widgets/animated_counter.dart`.
  - `progress_bar.dart` — animated XP/level fill with goal chevron.
  - `app_toast.dart` — animated toast host + `showAppToast(ctx, ...)`.
  - `live_dot.dart` — pulsing online/status dot.
  - `confetti.dart` — controller-driven `ConfettiBurst` component.
  - `tilt_card.dart` — pointer-driven 3D tilt card (ported from web Magnetic/TiltCard).

**Check:** `flutter analyze` clean after phase.

---

### Phase 1 — Navigation, MainShell & route transitions
Tasks:
1. Add `transitionPages` — replace default go_router push on all non-shell routes with a shared
   `CustomTransitionPage` (fade + slight scale/slide, `AppAnimations.medium`, emphasized ease).
2. Wire `Hero` across grid → detail: `WallpaperCard` gains `heroTag` (imageUrl-bounded);
   `wallpaper_detail_screen` wraps image in same-tag `Hero`. Route-level Hero + transition = fluid.
3. MainShell: wrap `child` in `AnimatedSwitcher` keyed by route; tabs keep the liquid `nav_bar` but
   refine theme tokens to match `AppColors` (single source of brand color), add tab-progress
   cross-fade under each bar item.
4. Reuse `FadeSlidePage` for all shared screens (Empty/Error/Loading) so they animate too.

**Files:** `app_router.dart`, `main_shell.dart`, `routes.dart`, new `route_transitions.dart`.

---

### Phase 2 — Auth flow redesign
- **splash**: replace hard timers with `AnimationController` statuses; add tap-to-skip; cross-fade
  exit into next route (not hard `context.go`); add one ambient `AuroraBackground`.
- **onboarding**: unify redundant custom particles behind Lottie/controllers (remove duplicated
  coin+confetti hand-rolled loops where Lottie already exists); add per-slide text entrance;
  make slides responsive (remove magic 340/450 coordinates); use shared `GradientButton` for CTA.
- **login / signup**: extract shared `_SocialButton` → `SocialButton` (press scale + ripple + loading);
  add inline field validation (no bare SnackBar), error shake on failed submit, password
  visibility toggle; give signup a brand mark (mirror login). Backdrop keeps tilted glass card.
- **otp**: bring into the brand language — glass card, `AuroraBackground`, auto-focus first box,
  error shake + haptic on wrong code, auto-submit on 6 digits, resend countdown with effort-cooldown.
- All auth pages use new page transitions + `AppToast` for errors.

**Screens:** splash, onboarding, login, signup, otp (+ new `widgets/social_button.dart`).
**Note:** `OtpScreen` exists in the router but nothing navigates to it (phone auth gap) — keep as-is,
only restyle; flag for product decision.

---

### Phase 3 — Home / Discovery (Feed → Detail)
1. **WallpaperCard becomes the single card** — home, search, saved all consume it (kill inline
   duplicates). Add `heroTag`, tap-feedback (scale 0.98 on press-down), like-heart pop (`AnimatedScale`).
2. **Feed entrance** — `StaggerGrid` on masonry; grid + featured rail fade/slide on category change
   via `AnimatedSwitcher` (keyed by category filter).
3. **Loading** — wire `WallpaperGridSkeleton` into all `AsyncValue.isLoading` branches.
4. **Category pills** — keep active-glide but run it through shared `GlowPill` (spans/selected-tracking);
   "See all" now navigates to `search` pre-filled.
5. **Featured rail** — subtle auto-scroll (slow `ScrollController` timer) + `TiltCard`.
6. **Detail screen**
   - Parallax full-bleed image translating/scale with `NotificationListener<ScrollNotification>`.
   - Pinch-zoom/double-tap via `InteractiveViewer` in full-view mode.
   - Cleaning full-view toggle: fade/slide the AppBar & clean pill via `AnimatedOpacity` + transition
     (no abrupt `setState` mutation).
   - Staggered entrance of bottom glass sheet content + reviews.
   - Replace confetti loop with `ConfettiBurst` (`Ticker`/controller).
   - Download button: determinate progress via controllers that are ACTUALLY wired
     (`SingleTickerProviderStateMixin` exists but controller is never created — fix that);
     success check burst + `AppToast`.
   - Reviews: `ref.listen(wallpaperReviewsStreamProvider)` → fade/scale new entries; heart pop on rate.
   - Loading/error states → shimmer + `ErrorScreen` with retry.
7. **Saved screen** — `AnimatedSwitcher`-style removal (shrink/fade item out), fabric entrance,
   `EmptyScreen` with CTA.

**Screens:** home, wallpaper_detail, apply_wallpaper_sheet, search, saved.

---

### Phase 4 — Creator Hub + Subscription
1. **analysis_metadata**:
   - Add `fl_chart`; build real charts: earnings area/bar (animated line-crawl), downloads-by-wallpaper
     horizontal bars, revenue split. Interactive time-range pills (7D/30D/90D/All) drive real queries.
   - Wrap stats in `StaggerGrid` + `count_up`; `AnimatedSwitcher` per range.
   - Wire to real providers (creator stats) — or, if data does not exist, scaffold the provider with
     clean empty/loading states (document assumption).
2. **creator dashboard**: animated XP progress bar (`progress_bar.dart`) + level-up `ConfettiBurst`;
   wire KPIs to real (or seeded) data; recent-uploads rows with thumbnails + entrance stagger;
   wire the analytics action.
3. **creator payout**: `count_up` balance, gold glass balance card, animated request flow
   (confirm dialog → success state + `ConfettiBurst`), history with status iconography
   (pending/processing/completed/rejected) + entrance.
4. **creator enroll / upload wizards**: 
   - Animated step progress (checkmarks + slide-fill); use `AnimatedSwitcher` for step transitions.
   - Real image picking + bytes + upload progress percent + cancel (they are currently mock
     toggles to Unsplash URLs).
   - Split calc → animated proportional bar (80/20) not text rows.
   - Success: toast + confetti + navigate.
5. **creator profile**: `count_up` stats, shimmer skeleton for both providers, pull-to-refresh,
   share button, follow placeholder, hero `stretch` effect on SliverAppBar.
6. **subscription**: plan selection state; animated price/re-sale label per plan; popular card
   breathing glow; success replaces `AlertDialog` with a celebration screen (Lottie crown +
   confetti + PRO badge); show current subscription + manage state; `AnimatedSwitcher` on PRO switch.

**Screens:** creator_analytics, creator_dashboard, creator_payout, creator_enroll, creator_upload,
  creator_profile, subscription.

---

### Phase 5 — Profile, Settings, Downloads, Notifications
1. **profile**: animated header (avatar + name + level intro), XP-to-next-level progress `bar`,
   avatar upload shimmer overlay, sign-out confirm with animated dialog; `StaggerReveal` menu list.
2. **settings**: `StaggerReveal` cards, glass cards with hairline gradient, animated toggles
   (OS switch already animate — add brand tint), toast feedback; fix Favorites dead-end tile →
   navigate to `saved`.
3. **downloads**: mason grid with `StaggerGrid`, image fade-in + skeleton, pull-to-refresh,
   `EmptyScreen` with CTA.
4. **notifications**: list item entrance from top on new stream emission; unread dot/glow;
   slide-in timestamp; `swipe-to-dismiss` working; unread count badge in header.
5. **Shared screens**: upgrade and USE `EmptyScreen`/`ErrorScreen`(retry)/`LoadingScreen`
   everywhere — delete all inline `Text('Error: ...')` / raw spinners.

**Screens:** profile, settings, downloads, notifications, empty, error, loading.

---

### Phase 6 — Global Smoothing & QA
- Sweep all `ScaffoldMessenger.showSnackBar` → `AppToast`.
- Confirm no `CircularProgressIndicator` used as a primary loader (skeletons + loading screens).
- Add haptic feedback on like, toggle, submit, purchase.
- Ensure all shared states (loading/empty/error) use shared widgets.
- Optionally add `AnimationController`-driven **pull-to-refresh** on every list.
- Run `flutter analyze` (0 issues), `flutter test`, manual device grid/Phone/Tablet smoke run.
- Update `README`/PRD references to match the new motion docs.

**Final gates:** build clean, analyze clean, no dead widgets remaining (grep for orphaned components).

---

## 4. New Packages
| Package | Why |
|---|---|
| `fl_chart` | analytics/revenue charts (only new dep). Add under `dependencies`. |

All other motion is built with `flutter_animate`, `lottie`, `CustomPainter`, `AnimationController`,
already in the project.

---

## 5. File Map (new/changed)
```
lib/core/theme/app_gradients.dart            (new)
lib/core/theme/app_animations.dart           (extend: easing system)
lib/core/widgets/effects/…                    (new shared effects library)
lib/core/widgets/glow_button.dart             (new — refactor GradientButton)
lib/core/widgets/social_button.dart           (new — replaces duplicated _SocialButton)
lib/core/widgets/wallpaper_card.dart          (rewire: Hero, press feedback, used everywhere)
lib/core/widgets/shimmer_loading.dart          (rewire — grids use skeletons)
lib/core/router/app_router.dart                (route transitions + Hero route)
lib/core/widgets/main_shell.dart               (AnimatedSwitcher tabs)
lib/features/auth/screens/*                    (redesign per Phase 2)
lib/features/home/screens/* + widgets/*        (redesign per Phase 3)
lib/features/creator/screens/*                 (redesign per Phase 4)
lib/features/profile/screens/* + shared/*      (redesign per Phase 5)
.github/. — native unchanged
```

## 6. Recommended Execution Order (after this plan is approved)
Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6, verifying with
`flutter analyze` between phases and hot-reloading each screen bundle.