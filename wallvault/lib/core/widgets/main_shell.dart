import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_bar/nav_bar.dart';

import '../theme/app_colors.dart';
import '../router/routes.dart';

/// Next-Gen Futuristic Liquid Navigation Bar powered by `nav_bar` engine
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.search)) return 1;
    if (location.startsWith(AppRoutes.saved)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(AppRoutes.home);
      case 1: context.go(AppRoutes.search);
      case 2: context.go(AppRoutes.saved);
      case 3: context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: child,
      bottomNavigationBar: RepaintBoundary(
        child: FuturisticNavBar(
          selectedIndex: currentIndex,
          onItemSelected: (index) => _onTap(context, index),
          style: NavBarStyle.liquid,
          showLiquid: true,
          showGlow: true,
          glowStrength: 1.5,
          iconAnimationType: IconAnimationType.magnetic,
          theme: FuturisticTheme(
            name: 'WallVaultPurple',
            accentColor: const Color(0xFFC77DFF),
            baseColor: const Color(0xFF140C24),
            backgroundColor: const Color(0xFF0A0A0F),
            glowGradient: const LinearGradient(
              colors: [Color(0xFF9D4EDD), Color(0xFFC77DFF)],
            ),
            particleColor: const Color(0xFFE0Aaff),
          ),
          items: [
            NavBarItem(icon: Icons.home_rounded, label: 'HOME'),
            NavBarItem(icon: Icons.search_rounded, label: 'SEARCH'),
            NavBarItem(icon: Icons.bookmark_rounded, label: 'SAVED'),
            NavBarItem(icon: Icons.person_rounded, label: 'PROFILE'),
          ],
        ),
      ),
    );
  }
}
