WALLVAULT — AntiGravity IDE Prompts (Part 2: Prompts 21-40)
CRED-Inspired Dark Theme Wallpaper App with Creator Economy
📋 HOW TO USE THESE PROMPTS
Complete Prompts 1-20 first before starting these
Copy one prompt at a time into AntiGravity IDE
Run and test before moving to next
Reference previous prompts for consistency
PHASE 2 CONTINUED: MOBILE UI SCREENS (Prompts 21-25)
Prompt 21: Settings Screen (S25)
plain
Create SettingsScreen in lib/screens/settings/:

1. Deep black background
2. Top: back arrow + "Settings" heading

3. Grouped sections with headers:

   "Account" section:
   - Edit Profile (person icon, arrow)
   - Change Password (lock icon, arrow)
   - Delete Account (trash icon, red text)
     - Confirmation modal required

   "Preferences" section:
   - Notifications (bell icon, toggle switch)
     - Toggle: elastic snap animation
     - On: purple, Off: gray

   - Dark Mode (moon icon, toggle)
     - Animated sun/moon morph on toggle
     - Currently forced ON (app is dark-only)

   - Language (globe icon, "English", arrow)
     - Opens language selector bottom sheet

   - Download Quality (image icon, "4K", arrow)
     - Options: HD, 2K, 4K, 8K

   - Auto-Download on WiFi Only (wifi icon, toggle)

   "Support" section:
   - Help Center (question icon, arrow)
   - Contact Us (message icon, arrow)
   - Report a Bug (bug icon, arrow)
   - Terms of Service (document icon, arrow)
   - Privacy Policy (shield icon, arrow)

   "About" section:
   - App Version (info icon, "v1.0.0")
   - Rate App (star icon, arrow)
   - Share App (share icon, arrow)

4. Danger zone:
   - "Log Out" button: full width, red background, 16px radius
   - "Delete Account" button: red outline
   - Both require confirmation modal

5. Toggle animation:
   - Track: rounded pill, gray → purple
   - Thumb: circle, slides with spring
   - Haptic: light tap on toggle
Prompt 22: Creator Enrollment Step 1 (S14)
plain
Create CreatorEnrollmentScreen (Step 1) in lib/screens/creator/enroll/:

1. Deep black background
2. Top: "Become a Creator" heading, 28px, bold
3. Step indicator: "Step 1/4" with progress bar (25% purple fill)
   - Animated fill on enter

4. Section: "Basic Info"

5. Form fields:
   - Display Name:
     - Placeholder: "Your creator name"
     - Validation: min 3 chars, max 30
     - Dark card surface, purple focus glow

   - Bio:
     - Placeholder: "Tell us about yourself and your art..."
     - Multiline, max 200 chars
     - Character counter below
     - Same styling

6. Profile Photo upload:
   - Large tap area: 120px circular
   - Initial: camera icon + "Tap to upload"
   - After upload: preview with edit overlay
   - Border: 3px purple dashed (empty) / solid (uploaded)
   - Tap: open image picker
   - Upload progress: circular ring

7. "Next" button:
   - Purple gradient
   - Disabled until name entered
   - Navigates to Step 2

8. Validation:
   - Name required: shake + red border
   - Photo optional but recommended
Prompt 23: Creator Enrollment Step 2 (S15)
plain
Create CreatorEnrollmentScreen (Step 2):

1. Step indicator: "Step 2/4" (50% fill)
2. Heading: "Upload Portfolio"
3. Subtext: "Upload 3 sample wallpapers to showcase your style"

4. Three upload slots in a row:
   - Each: 100x140px, 16px radius
   - Empty state: dashed border, "+" icon, "Add"
   - Uploaded: thumbnail preview, "X" remove button top-right
   - Remove: spin animation on tap

5. Upload constraints:
   - Min resolution: 1080p
   - Max size: 20MB
   - Formats: JPG, PNG, WEBP
   - Validation: show error if below 1080p

6. Progress indicator:
   - Each slot shows upload progress ring
   - All 3 required to proceed

7. "Next" button:
   - Disabled until 3 uploads complete
   - Navigates to Step 3

8. Back button: goes to Step 1, preserves data
Prompt 24: Creator Enrollment Step 3 (S16)
plain
Create CreatorEnrollmentScreen (Step 3):

1. Step indicator: "Step 3/4" (75% fill)
2. Heading: "Payout Setup"
3. Subtext: "How you'll receive your earnings"

4. Two option cards:

   Option 1 - UPI (selected by default):
   - Card with radio button
   - Selected: purple border glow
   - Input field: "UPI ID" (e.g., abc@upi)
   - Validation: regex for UPI format
   - Verified badge appears on valid UPI

   Option 2 - Razorpay Connect:
   - Card with radio button
   - "Link Account" button
   - Opens Razorpay Connect onboarding
   - Shows connected status after link

5. Info text:
   - "Minimum payout: ₹500" in gray
   - "You'll receive 70% of each sale" in gray

6. "Next" button:
   - Disabled until valid payout method
   - Navigates to Step 4

7. Security note:
   - "Your payout information is encrypted and secure"
   - Lock icon, 12px, gray
Prompt 25: Creator Enrollment Step 4 (S17)
plain
Create CreatorEnrollmentScreen (Step 4):

1. Step indicator: "Step 4/4" (100% fill, animated)
2. Heading: "Review & Submit"

3. Summary card:
   - Background: dark elevated
   - Border radius: 20px
   - Content:
     - Display Name: [value]
     - Bio: [preview, truncated]
     - Portfolio: 3 thumbnail images
     - Payout Method: [UPI ID / Razorpay]

4. Terms checkbox:
   - "I agree to the Creator Terms and Conditions"
   - Link: "Read Terms" in cyan
   - Required to submit

5. "Submit Application" button:
   - Purple gradient with rocket icon (🚀)
   - Full width, 56px height
   - On tap:
     - Button shrinks
     - Rocket launch animation (translateY: 0 → -100, rotate: 0 → 15deg)
     - Particle trail behind rocket
     - Success: "Application Submitted!" text

6. After submit:
   - "Pending Approval" status page
   - "We'll review your application within 24-48 hours"
   - "Go to Home" button
   - Email confirmation sent

7. Back navigation disabled after submit
Prompt 26: Creator Dashboard (S18)
plain
Create CreatorDashboardScreen in lib/screens/creator/dashboard/:

1. Deep black background
2. Header:
   - Creator avatar (60px) with verified badge
   - "@creative_alex", 18px, bold, white
   - Level badge: "Level 3: Bloom ⭐" in gold pill

3. Earnings card:
   - Background: dark elevated, 20px radius
   - "Total Earnings" label, 14px, gray
   - "₹12,450" large number, 36px, bold, white
   - Animated counter: counts up from 0 on enter
   - "↑ 23% this month" in green, 14px
   - Duration: 1.5s, ease-out

4. Earnings chart:
   - Line chart, 7 days
   - Gradient fill: purple to transparent
   - Interactive: tap point shows value tooltip
   - Animated draw-on-enter: stroke draws left to right
   - Duration: 1s

5. Top Wallpapers list:
   - Heading: "Top Wallpapers", 18px, bold
   - Ranked 1-3:
     - Rank number: 20px, bold, gray
     - Thumbnail: 60x80px, 12px radius
     - Name: 16px, white
     - Download bar: animated fill
       - Background: dark
       - Fill: purple gradient
       - Width proportional to downloads
       - Animates from 0 to value on enter
     - Download count: 14px, gray

   - "Trending" badge: fire icon + "Trending" text, red pill

6. Payout Status card:
   - "Available for Payout" label
   - "₹2,450" in gold, 28px, bold
   - "Request Payout" button:
     - Gold gradient, 16px radius
     - Disabled if < ₹500
     - Idle: subtle pulse glow

7. Quick actions row:
   - "+ Upload New" (purple, camera icon)
   - "📊 View Analytics" (cyan, chart icon)
   - "💸 Payout History" (gold, wallet icon)

8. Bottom: XP progress bar
   - "450 / 1000 XP to Level 4"
   - Bar: purple fill, animated on enter
   - Particle trail effect on progress
Prompt 27: Creator Upload Step 1 (S19)
plain
Create CreatorUploadScreen (Step 1) in lib/screens/creator/upload/:

1. Deep black background
2. Top: "Upload Wallpaper" + "Step 1/3" progress (33%)

3. Large upload zone:
   - Dashed border: 2px purple, animated dash offset
   - Center: upload icon (cloud with arrow), 48px
   - Text: "Tap to select or drag wallpaper here"
   - Subtext: "Supports: JPG, PNG, WEBP (Max 20MB)"
   - Tap: open image picker
   - Drag-over: border solid, background purple tint

4. After selection:
   - Preview area: 9:16 aspect ratio
   - Crop guide overlay: grid lines (rule of thirds)
   - "Change" button below preview
   - Resolution badge: "4K detected" in green

5. Wallpaper Name input:
   - Placeholder: "Give your wallpaper a name"
   - Below preview
   - Validation: required

6. "Next" button:
   - Disabled until image selected and named
   - Navigates to Step 2

7. Image validation:
   - Min resolution check
   - Format check
   - Size check
   - Error: red toast with specific message
Prompt 28: Creator Upload Step 2 (S20)
plain
Create CreatorUploadScreen (Step 2):

1. Step indicator: "Step 2/3" (66%)
2. Thumbnail preview at top (small, 80px width)

3. Form fields:
   - Category dropdown:
     - Label: "Category"
     - Options: Nature, Abstract, Cars, Anime, Space, Dark, Minimal, City, Animals, Other
     - Dark card surface, 12px radius
     - Dropdown animation: slide down with stagger

   - Tags input:
     - Label: "Tags"
     - Placeholder: "Add tags (e.g., nature, sunset)"
     - Auto-suggest dropdown as user types
     - Selected tags: pill badges with X remove
     - Max 5 tags
     - Tag pop-in animation

   - Description:
     - Label: "Description"
     - Placeholder: "Describe your wallpaper..."
     - Multiline, max 200 chars
     - Character counter

4. "Next" button:
   - Category required
   - Navigates to Step 3

5. Back button: preserves data
Prompt 29: Creator Upload Step 3 - Pricing (S21)
plain
Create CreatorUploadScreen (Step 3):

1. Step indicator: "Step 3/3" (100%)
2. Heading: "Set Pricing"

3. Pricing toggle:
   - Two cards side by side:

     "Free" option:
     - Radio button
     - "Free" label, 18px
     - "Share your art with everyone" subtext
     - Selected: green border glow

     "Paid" option:
     - Radio button
     - "Paid" label, 18px
     - "Earn from your creations" subtext
     - Selected: gold border glow

   - Toggle animation: morphs card shape, border color transitions

4. When "Paid" selected:
   - Price input field:
     - ₹ prefix in gold
     - Placeholder: "Enter amount"
     - Number keyboard
     - Min: ₹10, Max: ₹999
     - Animated number counter as user types

   - Earnings preview card:
     - Background: dark elevated
     - "Your Earnings: ₹34" in green (70%)
     - "Platform Fee: ₹10" in gray (20%)
     - "Community Pool: ₹5" in cyan (10%)
     - Updates live as price changes
     - Number animation: counts up/down

5. Payout method display:
   - "Payout to: abc@upi" 
   - Verified checkmark
   - "Edit" link in cyan

6. "Publish" button:
   - Purple gradient with rocket icon
   - Full width, 56px height
   - On tap:
     - Rocket launch animation
     - "Publishing..." loading state
     - Success: confetti + "Published!" + navigate to dashboard

7. Terms note:
   - "By publishing, you agree to our Content Guidelines"
   - Link in cyan
Prompt 30: Creator Payout Request (S22)
plain
Create CreatorPayoutScreen in lib/screens/creator/payout/:

1. Deep black background
2. Top: back arrow + "Request Payout" heading

3. Balance card:
   - Background: dark elevated with gold tint (5%)
   - Border: 1px gold
   - Border radius: 20px
   - "Available Balance" label, 14px, gray
   - "₹2,450" in gold (#FFD700), 48px, bold
   - Animated counter on enter

4. Amount input:
   - Label: "Amount to Withdraw"
   - ₹ prefix in gold
   - Placeholder: "Enter amount"
   - Number keyboard
   - "Max" button: fills with full balance
   - Validation: min ₹500, max available balance
   - Error: "Minimum payout is ₹500" in red

5. Payout method card:
   - "Payout Method" label
   - UPI ID display: "abc@upi" with verified badge
   - "Razorpay Secure" text with lock icon
   - "Change" link in cyan

6. Info text:
   - "Payouts are processed within 24-48 hours"
   - "A ₹5 processing fee applies" in gray

7. "Request Payout" button:
   - Gold gradient, full width, 56px height
   - Idle: subtle pulse glow (box-shadow animation)
   - Disabled if amount < 500 or > balance
   - Press: scale 0.95, haptic medium
   - Loading: shimmer
   - Success: checkmark + "Request submitted!"

8. "Payout History" link:
   - Below button
   - Navigates to history screen
   - Arrow right icon

9. Empty/error states:
   - Balance < 500: "You need at least ₹500 to request a payout"
   - No payout method: "Add a payout method first"
Prompt 31: Loading / Skeleton States (S36)
plain
Create reusable skeleton widgets in lib/widgets/skeleton/:

1. Shimmer effect widget:
   - Animated gradient sweep
   - Colors: #1A1A24 → #2A2A3A → #1A1A24
   - Direction: left to right
   - Duration: 1.5s, infinite loop
   - Clip to child shape

2. Skeleton card:
   - Rounded rectangle: 20px radius
   - Aspect ratio: 9:16
   - Shimmer overlay
   - Used for wallpaper grid loading

3. Skeleton text:
   - Rounded rectangle lines
   - Heights: 24px (heading), 16px (body), 12px (caption)
   - Widths: 60%, 80%, 40% (randomized)
   - Shimmer overlay

4. Skeleton avatar:
   - Circular, 40-100px depending on context
   - Shimmer overlay

5. Skeleton list:
   - 5-10 items with stagger animation
   - Each item: avatar + 2-3 text lines
   - Stagger delay: 100ms

6. Usage contexts:
   - Home grid: 6 skeleton cards
   - Wallpaper detail: full image skeleton + text lines
   - Creator dashboard: stat cards + chart skeleton
   - List views: 8 skeleton list items

7. Transition to content:
   - Skeleton fades out (200ms)
   - Content fades in (300ms)
   - Cross-fade effect
Prompt 32: Empty States (S37)
plain
Create reusable empty state widget in lib/widgets/empty_state/:

1. Layout:
   - Centered vertically and horizontally
   - Padding: 32px

2. Illustration:
   - SVG line art icon
   - Color: purple (#B829DD) or gray (#5A5A6E)
   - Size: 120px
   - Examples:
     - Downloads: download icon
     - Favorites: heart icon
     - Search: search icon with magnifying glass
     - Notifications: bell icon
     - Uploads: cloud icon

   - Animation: SVG stroke draw-on-enter
   - Duration: 1s

3. Heading:
   - "No [content] yet"
   - Font: Inter, 20px, bold, white
   - Examples: "No downloads yet", "No favorites yet"

4. Subtext:
   - Helpful message in gray
   - Examples:
     - "Browse wallpapers to get started"
     - "Search for something amazing"
     - "Upload your first wallpaper"

5. CTA button (if applicable):
   - "Explore", "Search", "Upload" 
   - Purple gradient
   - Navigates to relevant screen

6. Variations:
   - No search results: search icon + "No results found" + "Try different keywords"
   - No internet: wifi-off icon + "No connection" + "Retry" button
   - Error state: alert icon + "Something went wrong" + "Retry" button
Prompt 33: Error States (S38)
plain
Create reusable error state widget in lib/widgets/error_state/:

1. Layout:
   - Centered, padding 32px
   - Can be full screen or inline (within list)

2. Alert icon:
   - Triangle with exclamation mark
   - Color: red (#FF1744)
   - Size: 64px
   - Animation: subtle pulse glow (red box-shadow)
   - Duration: 2s, infinite

3. Heading:
   - "Something went wrong"
   - Font: Inter, 20px, bold, white

4. Subtext:
   - Specific error message
   - Examples:
     - "Please check your internet connection"
     - "Failed to load wallpapers"
     - "Payment could not be processed"
   - Font: 14px, gray

5. Action buttons:
   - Primary: "Retry" 
     - Purple gradient, full width
     - On tap: reload data, show loading

   - Secondary: "Contact Support"
     - Transparent, cyan text
     - Opens support email/chat

6. Network error variation:
   - Icon: wifi-off, gray
   - Heading: "No internet connection"
   - Subtext: "Please check your network and try again"
   - "Retry" button

7. Payment error variation:
   - Icon: credit-card with X, red
   - Heading: "Payment failed"
   - Subtext: "Your payment could not be processed. Please try again."
   - "Retry Payment" button
   - "Use Different Method" link

8. Animation:
   - Shake on enter: translateX ±5px, 3 cycles
   - Duration: 400ms
   - Haptic: error pattern (two quick medium taps)
PHASE 3: WEB PORTALS (Prompts 34-40)
Prompt 34: Creator Web Dashboard (S26)
plain
Create Creator Web Dashboard in Next.js:

1. Layout:
   - Left sidebar: 240px width, collapsible to 80px
   - Top bar: 64px height, sticky
   - Main content: fluid width
   - Background: #0A0A0F

2. Sidebar navigation:
   - Items: Dashboard, Upload, My Wallpapers, Analytics, Payouts, Settings
   - Each: icon (24px) + label
   - Active: purple left border (3px), purple text, subtle background glow
   - Hover: background highlight
   - Collapse toggle at bottom
   - Animation: width transition 300ms smooth

3. Top bar:
   - Left: hamburger menu (mobile), page title
   - Center: search bar (collapsible)
   - Right: notification bell (badge with count), profile avatar dropdown

4. Dashboard content:

   KPI cards row (4 cards):
   - "Total Earnings" ₹12,450, green up arrow 23%
   - "Total Downloads" 45.2K
   - "Wallpapers" 89
   - "Avg Rating" 4.8
   - Each: dark card surface, 20px radius, icon top-right
   - Numbers: animated counter on enter

   Earnings chart:
   - Line chart, Recharts library
   - 30-day view
   - Purple gradient fill
   - Interactive tooltip on hover
   - Animated draw-on-enter

   Recent uploads grid:
   - 4 wallpaper thumbnails
   - 200px width, 16px radius
   - Status badge: approved/pending
   - Hover: scale 1.02, shadow increase

   Quick actions:
   - "+ Upload New" purple button
   - "View Analytics" cyan button
   - "Request Payout" gold button

5. Responsive:
   - Mobile: sidebar becomes bottom nav
   - Tablet: sidebar collapsible
   - Desktop: full sidebar
Prompt 35: Creator Web Upload Interface (S27)
plain
Create Creator Web Upload Interface in Next.js:

1. Layout: sidebar + main content (same as dashboard)

2. Main content:
   - Heading: "Upload New Wallpaper"

   Large drag-drop zone:
   - Full width, 300px height
   - Dashed border: 2px purple, animated
   - Center: cloud upload icon (48px) + "Drag & drop or click to upload"
   - Subtext: "Supports: JPG, PNG, WEBP (Max 20MB)"
   - Drag over: solid border, purple background tint
   - Drop: files bounce in animation

   Preview area:
   - Shows uploaded image
   - Crop tool overlay (9:16 guide)
   - "Change" button

   Form fields:
   - Wallpaper Name: input, dark surface
   - Category: dropdown, dark surface
   - Tags: input with auto-suggest, pill badges
   - Description: textarea, 200 char limit

   Pricing section:
   - Free / Paid toggle (radio cards)
   - Paid: price input with ₹ prefix
   - Live earnings calculator:
     "You earn: ₹X (70%)" — updates in real-time
     Number animation on change

   Buttons:
   - "Preview" outline button
   - "Publish" purple gradient button
   - Rocket launch animation on publish

3. Batch upload support:
   - Multiple files in drop zone
   - Individual progress bars
   - Queue system
Prompt 36: Creator Web Analytics (S28)
plain
Create Creator Web Analytics Page in Next.js:

1. Layout: sidebar + main content

2. Date range picker:
   - Top right
   - Options: Last 7 days, 30 days, 90 days, Custom
   - Dark themed calendar popup

3. Stat cards row:
   - Views, Downloads, Earnings, Conversion Rate
   - Same styling as dashboard KPIs

4. Charts (using Recharts):

   Downloads by Wallpaper (bar chart):
   - Vertical bars, purple gradient
   - Wallpaper names on X-axis
   - Download counts on Y-axis
   - Hover tooltip

   Downloads by Category (donut chart):
   - Neon colors per category
   - Center: total downloads
   - Legend below

   Earnings Trend (area chart):
   - Purple gradient fill
   - Daily data points
   - Interactive

5. Heatmap calendar:
   - 7x7 grid (weeks x days)
   - Color intensity: darker purple = more downloads
   - Hover: date + download count
   - Today highlighted

6. Top Performing Wallpapers table:
   - Columns: Rank, Wallpaper (thumbnail + name), Views, Downloads, Earnings, Trend sparkline
   - Sortable columns
   - Row hover highlight
   - Pagination

7. Export button:
   - "Export CSV" top-right
   - Downloads data for selected date range
Prompt 37: Creator Web Payout Management (S29)
plain
Create Creator Web Payout Page in Next.js:

1. Layout: sidebar + main content

2. Balance card:
   - Large: "₹2,450" in gold, 48px
   - "Available Balance" label
   - "Request Payout" gold gradient button
   - Disabled if < ₹500

3. Payout History table:
   - Columns: Date, Amount, Method, Status, Transaction ID
   - Status badges:
     - Completed: green checkmark
     - Pending: orange clock
     - Failed: red X
   - Sortable by date
   - Row hover highlight
   - Pagination: 10 per page

4. Empty state:
   - "No payouts yet"
   - Wallet icon illustration
   - "Request your first payout" CTA

5. Export:
   - "Export CSV" button
   - Includes all payout history

6. Responsive:
   - Mobile: cards instead of table
Prompt 38: Admin Web Dashboard Overview (S30)
plain
Create Admin Dashboard in Next.js:

1. Layout:
   - Left sidebar: 260px, dark surface
   - Top bar: 64px, sticky, blur background
   - Main: fluid, padding 24px

2. Sidebar items:
   - Dashboard, Wallpapers, Creators, Users, Payments, Payouts, Reports, Settings
   - Each: icon + label + badge (if pending items)
   - Active: purple left border, background glow

3. Top bar:
   - Search: global search across all data
   - Notifications: bell with red badge (count of pending items)
   - Profile: avatar dropdown with admin options

4. Dashboard content:

   KPI cards (2 rows x 3):
   - Total Users: 45.2K (↑12%)
   - Total Wallpapers: 12.8K (↑8%)
   - Active Subscriptions: 3.2K (↑15%)
   - Monthly Revenue: ₹89K (↑22%)
   - Pending Approvals: 23 (⚠️ alert pulse)
   - Payouts Due: 8 (⚠️ alert pulse)
   - Alert badges: orange pulse animation

   Revenue chart:
   - Area chart, 30 days
   - Gradient fill
   - Tooltip on hover

   User growth chart:
   - Line chart
   - New vs returning users

5. Action Required section:
   - Alert box with orange left border
   - "23 wallpapers pending approval [Review Now →]"
   - "5 creators pending verification [Review Now →]"
   - "8 payout requests pending [Process Now →]"
   - Each links to respective admin page

6. Real-time updates:
   - WebSocket or polling for live data
   - New notification badge updates
Prompt 39: Admin Wallpaper Management (S31)
plain
Create Admin Wallpaper Management Page in Next.js:

1. Layout: sidebar + main content

2. Top controls:
   - Heading: "Wallpapers"
   - Filter tabs: All, Pending, Approved, Rejected, Flagged
   - Each tab shows count badge
   - Search bar: search by name, creator, tag
   - View toggle: Grid / List

3. Grid view:
   - 6 thumbnails per row
   - Each: 200px width, 16px radius
   - Status badge top-right:
     - Pending: orange clock
     - Approved: green check
     - Rejected: red X
     - Flagged: red alert
   - Hover: scale 1.02, shadow increase
   - Checkbox for bulk select

4. List view:
   - Table: Thumbnail, Name, Creator, Date, Resolution, Price, Status, Actions
   - Sortable columns
   - Row hover highlight
   - Actions: View, Approve, Reject, Delete

5. Bulk actions bar:
   - Appears when items selected
   - "Approve", "Reject", "Delete" buttons
   - "X items selected" text

6. Detail modal:
   - Left: large preview (400px)
   - Right: metadata panel
     - Name, Creator, Upload Date, Resolution
     - Price, Category, Tags
     - Status dropdown
     - Admin notes textarea
     - Action buttons: Approve, Reject, Flag
   - Backdrop blur

7. Pagination:
   - 24 items per page
   - Page numbers + prev/next
Prompt 40: Admin Creator Management (S32)
plain
Create Admin Creator Management Page in Next.js:

1. Layout: sidebar + main content

2. Pending Approvals section (top):
   - Card list of pending creators
   - Each card:
     - Avatar (48px), Name, Email
     - "3 uploads" badge
     - Payout method: UPI/Razorpay
     - "View Portfolio" button
     - "Approve" (green) / "Reject" (red) buttons
   - Expandable: shows portfolio thumbnails

3. All Creators table:
   - Columns: Avatar, Name, Level, Uploads, Earnings, Payouts, Status, Actions
   - Level badges with emoji:
     - 🌱 Seedling, 🌿 Sprout, 🌸 Bloom, ⭐ Star, 👑 Legend
   - Status: Active (green dot), Suspended (red dot)
   - Actions: View, Edit, Suspend
   - Sortable columns
   - Search by name/email
   - Filter by level

4. Creator detail sidebar:
   - Slides in from right
   - Shows: profile, all uploads, earnings history, payout history
   - "Suspend" / "Reinstate" buttons
   - "Message" button

5. Responsive:
   - Mobile: cards instead of table
   - Detail becomes full-screen modal
✅ PROMPTS 21-40 COMPLETE
Previous: Prompts 1-20 (Foundation + Mobile UI)
Next: Request Prompts 41-65 (Business Logic + Backend + Integration)
Estimated time for Prompts 21-40: 7-10 days (with testing and iteration)