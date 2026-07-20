import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/routes.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please sign in'));
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Hero(
                    tag: 'user-profile-avatar',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accentPurple,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: user.avatarUrl.isNotEmpty
                            ? NetworkImage(user.avatarUrl)
                            : null,
                        child: user.avatarUrl.isEmpty
                            ? Text(
                                (user.displayName.isNotEmpty
                                        ? user.displayName[0]
                                        : 'U')
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName.isNotEmpty ? user.displayName : 'User',
                    style: AppTypography.h2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone.isNotEmpty ? user.phone : user.email,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusCard),
                      border: Border.all(color: AppColors.bgElevated),
                    ),
                    child: Row(
                      children: [
                        _MiniStat(
                            icon: '🔥',
                            label: 'Streak',
                            targetValue: user.streak.current),
                        _MiniStat(
                            icon: '⭐',
                            label: 'XP',
                            targetValue: user.xp),
                        _MiniStat(
                            icon: '🏅',
                            label: 'Level',
                            targetValue: user.level),
                        _MiniStat(
                            icon: '📥',
                            label: 'Downloads',
                            targetValue: user.downloads.length),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  _MenuItem(
                    icon: Icons.download_rounded,
                    label: 'My Downloads',
                    onTap: () => context.push(AppRoutes.downloads),
                  ),
                  _MenuItem(
                    icon: Icons.favorite_rounded,
                    label: 'Favorites List',
                    color: AppColors.accentError,
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Subscription Plans',
                    color: AppColors.accentGold,
                    onTap: () => context.push(AppRoutes.subscription),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_rounded,
                    label: 'Notifications',
                    onTap: () => context.push(AppRoutes.notifications),
                  ),
                  _MenuItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings Configuration',
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    color: AppColors.accentError,
                    onTap: () =>
                        _showSignOutDialog(context, authRepo),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, dynamic authRepo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Text('Confirm Sign Out', style: AppTypography.h3),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to sign out of WallVault?',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.bgElevated),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentError,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        authRepo.signOut();
                      },
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatefulWidget {
  final String icon;
  final String label;
  final int targetValue;
  const _MiniStat(
      {required this.icon,
      required this.label,
      required this.targetValue});

  @override
  State<_MiniStat> createState() => _MiniStatState();
}

class _MiniStatState extends State<_MiniStat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = IntTween(begin: 0, end: widget.targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(widget.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                _animation.value >= 1000
                    ? '${(_animation.value / 1000).toStringAsFixed(1)}K'
                    : _animation.value.toString(),
                style:
                    AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
              );
            },
          ),
          Text(widget.label,
              style:
                  AppTypography.caption.copyWith(fontSize: 10)),
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
          width: 40,
          height: 40,
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
