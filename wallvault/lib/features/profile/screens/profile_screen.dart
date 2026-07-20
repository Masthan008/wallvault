import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';

/// S12 — Profile screen with user info, stats, and menu items.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Avatar + Name
              CircleAvatar(
                radius: AppSpacing.avatarLarge / 2,
                backgroundColor: AppColors.bgCard,
                child: const Icon(Icons.person_rounded,
                    size: 40, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Text('User Name', style: AppTypography.h2),
              const SizedBox(height: 4),
              Text('+91 98765 43210',
                  style: AppTypography.caption),
              const SizedBox(height: 20),
              // Streak + XP bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Row(
                  children: [
                    _MiniStat(icon: '🔥', label: 'Streak', value: '7'),
                    _MiniStat(icon: '⭐', label: 'XP', value: '1,250'),
                    _MiniStat(icon: '🏅', label: 'Level', value: '3'),
                    _MiniStat(icon: '📥', label: 'Downloads', value: '42'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Menu items
              _MenuItem(
                icon: Icons.download_rounded,
                label: 'My Downloads',
                onTap: () => context.push(AppRoutes.downloads),
              ),
              _MenuItem(
                icon: Icons.favorite_rounded,
                label: 'Favorites',
                color: AppColors.accentError,
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.workspace_premium_rounded,
                label: 'Subscription',
                color: AppColors.accentGold,
                onTap: () => context.push(AppRoutes.subscription),
              ),
              _MenuItem(
                icon: Icons.palette_rounded,
                label: 'Become a Creator',
                color: AppColors.accentCyan,
                onTap: () => context.push(AppRoutes.creatorEnroll),
              ),
              _MenuItem(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                onTap: () => context.push(AppRoutes.notifications),
              ),
              _MenuItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                onTap: () => context.push(AppRoutes.settings),
              ),
              _MenuItem(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                color: AppColors.accentError,
                onTap: () {
                  // TODO: Sign out
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.h4),
          Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.color = AppColors.accentPurple,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: AppTypography.bodyMedium),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textMuted, size: 20),
        onTap: onTap,
      ),
    );
  }
}
