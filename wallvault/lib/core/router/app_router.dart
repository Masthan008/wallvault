import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/wallpaper_detail_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/saved/screens/saved_screen.dart';
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
import '../../providers/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return null;

      final isLoggedIn = authState.asData?.value != null;
      final currentPath = state.matchedLocation;

      final isAuthRoute = currentPath == AppRoutes.splash ||
          currentPath == AppRoutes.onboarding ||
          currentPath == AppRoutes.login ||
          currentPath == AppRoutes.signup ||
          currentPath.startsWith(AppRoutes.otp);

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isAuthRoute && currentPath != AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
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
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return OtpScreen(
              phone: extra['phone'] as String? ?? '',
              verificationId: extra['verificationId'] as String? ?? '',
            );
          }
          final phone = extra as String? ?? '';
          return OtpScreen(phone: phone, verificationId: '');
        },
      ),

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
            path: AppRoutes.saved,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SavedScreen(),
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

      GoRoute(
        path: AppRoutes.wallpaperDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WallpaperDetailScreen(wallpaperId: id);
        },
      ),

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
});
