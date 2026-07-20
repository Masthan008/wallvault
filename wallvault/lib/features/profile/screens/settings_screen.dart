import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';

/// S25 — Settings screen with profile options, support details, and logout confirmations.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _wifiOnly = false;

  void _showDeleteAccountConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.accentError, size: 48),
            const SizedBox(height: 16),
            Text('Are you absolutely sure?', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              'This action is permanent and will delete all your downloaded wallpapers, transactions, and profile data.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Delete Account Forever',
              gradient: const LinearGradient(
                colors: [AppColors.accentError, Colors.redAccent],
              ),
              onPressed: () {
                Navigator.pop(context);
                // TODO: Perform account deletion
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log Out', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text('Are you sure you want to log out of your account?', style: AppTypography.bodySmall),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Log Out',
              gradient: const LinearGradient(
                colors: [AppColors.accentError, Colors.redAccent],
              ),
              onPressed: () {
                Navigator.pop(context);
                // TODO: Perform logout
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Account Section
          _buildHeader('Account'),
          _buildItem(Icons.person_outline_rounded, 'Edit Profile'),
          _buildItem(Icons.lock_outline_rounded, 'Change Password'),
          _buildItem(
            Icons.delete_outline_rounded,
            'Delete Account',
            color: AppColors.accentError,
            onTap: _showDeleteAccountConfirmation,
          ),
          const SizedBox(height: 24),

          // Preferences Section
          _buildHeader('Preferences'),
          SwitchListTile(
            title: Row(
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.accentPurple),
                const SizedBox(width: 16),
                Text('Push Notifications', style: AppTypography.bodyMedium),
              ],
            ),
            value: _pushNotifications,
            activeColor: AppColors.accentPurple,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          SwitchListTile(
            title: Row(
              children: [
                const Icon(Icons.wifi_rounded, color: AppColors.accentPurple),
                const SizedBox(width: 16),
                Text('Auto-Download on WiFi Only', style: AppTypography.bodyMedium),
              ],
            ),
            value: _wifiOnly,
            activeColor: AppColors.accentPurple,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _wifiOnly = val),
          ),
          const SizedBox(height: 24),

          // Support Section
          _buildHeader('Support'),
          _buildItem(Icons.help_outline_rounded, 'Help Center'),
          _buildItem(Icons.chat_bubble_outline_rounded, 'Contact Us'),
          _buildItem(Icons.bug_report_outlined, 'Report a Bug'),
          _buildItem(Icons.description_outlined, 'Terms of Service'),
          _buildItem(Icons.shield_outlined, 'Privacy Policy'),
          const SizedBox(height: 24),

          // About Section
          _buildHeader('About'),
          _buildItem(Icons.star_outline_rounded, 'Rate App'),
          _buildItem(Icons.share_outlined, 'Share App'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
            title: Text('Version', style: AppTypography.bodyMedium),
            trailing: Text('1.0.0 (1)', style: AppTypography.bodySmall),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 32),

          // Log Out Button
          GradientButton(
            label: 'Log Out',
            gradient: const LinearGradient(
              colors: [AppColors.accentError, Colors.redAccent],
            ),
            onPressed: _showLogoutConfirmation,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.caption.copyWith(
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
          color: AppColors.accentPurple,
        ),
      ),
    );
  }

  Widget _buildItem(
    IconData icon,
    String label, {
    Color color = AppColors.textPrimary,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: onTap == null ? AppColors.textMuted : AppColors.accentPurple),
      title: Text(label, style: AppTypography.bodyMedium.copyWith(color: color)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      contentPadding: EdgeInsets.zero,
      onTap: onTap ?? () {},
    );
  }
}
