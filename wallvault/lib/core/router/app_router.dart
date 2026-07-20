import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/wallpaper_detail_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/creator/screens/creator_dashboard_screen.dart';
import '../../features/creator/screens/creator_enroll_screen.dart';
import '../../features/creator/screens/creator_upload_screen.dart';
import '../../features/creator/screens/creator_analytics_screen.dart';
import '../../features/creator/screens/creator_payout_screen.dart';
import '../../features/creator/screens/creator_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/downloads_screen.dart';
import '../../features/profile/screens/subscription_screen.dart';
import '../../features/profile/screens/notifications_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../widgets/main_shell.dart';
import 'routes.dart';

/// WallVault GoRouter configuration with bottom navigation shell.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // ── Auth Flow (no bottom nav) ──────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phone: phone);
      },
    ),

    // ── Main App (with bottom nav) ─────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.search,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.creatorDashboard,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CreatorDashboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),

    // ── Detail Screens (pushed over bottom nav) ────────────
    GoRoute(
      path: AppRoutes.wallpaperDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return WallpaperDetailScreen(wallpaperId: id);
      },
    ),

    // ── Creator Screens ────────────────────────────────────
    GoRoute(
      path: AppRoutes.creatorEnroll,
      builder: (context, state) => const CreatorEnrollScreen(),
    ),
    GoRoute(
      path: AppRoutes.creatorUpload,
      builder: (context, state) => const CreatorUploadScreen(),
    ),
    GoRoute(
      path: AppRoutes.creatorAnalytics,
      builder: (context, state) => const CreatorAnalyticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.creatorPayout,
      builder: (context, state) => const CreatorPayoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.creatorProfile,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CreatorProfileScreen(creatorId: id);
      },
    ),

    // ── Profile Sub-screens ────────────────────────────────
    GoRoute(
      path: AppRoutes.downloads,
      builder: (context, state) => const DownloadsScreen(),
    ),
    GoRoute(
      path: AppRoutes.subscription,
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
