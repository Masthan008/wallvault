/// Named route constants for all WallVault screens.
class AppRoutes {
  AppRoutes._();

  // ── Auth ─────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';

  // ── Main Tabs ────────────────────────────────────────────
  static const String home = '/home';
  static const String search = '/search';
  static const String saved = '/saved';
  static const String profile = '/profile';

  // ── Wallpaper ────────────────────────────────────────────
  static const String wallpaperDetail = '/wallpaper/:id';
  static const String wallpaperApply = '/wallpaper/:id/apply';
  static const String categoryDetail = '/category/:slug';

  // ── Creator ──────────────────────────────────────────────
  static const String creatorEnroll = '/creator/enroll';
  static const String creatorUpload = '/creator/upload';
  static const String creatorAnalytics = '/creator/analytics';
  static const String creatorPayout = '/creator/payout';
  static const String creatorProfile = '/creator/:id';

  // ── Profile & Settings ───────────────────────────────────
  static const String downloads = '/profile/downloads';
  static const String subscription = '/subscription';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String editProfile = '/profile/edit';

  // ── Helpers ──────────────────────────────────────────────
  static String wallpaperDetailPath(String id) => '/wallpaper/$id';
  static String wallpaperApplyPath(String id) => '/wallpaper/$id/apply';
  static String categoryDetailPath(String slug) => '/category/$slug';
  static String creatorProfilePath(String id) => '/creator/$id';
}
