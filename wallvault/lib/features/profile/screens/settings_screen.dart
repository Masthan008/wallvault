import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/router/routes.dart';
import '../../../providers/auth_provider.dart';

/// S25 — Settings screen with profile options, support details, and logout confirmations.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _wifiOnly = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _wifiOnly = prefs.getBool('wifi_only') ?? false;
    });
  }

  Future<void> _setPushNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', val);
    setState(() {
      _pushNotifications = val;
    });
  }

  Future<void> _setWifiOnly(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wifi_only', val);
    setState(() {
      _wifiOnly = val;
    });
  }

  void _showEditProfileDialog() {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;
    final controller = TextEditingController(text: user.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Edit Profile', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.bgElevated)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accentPurple)),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await ref.read(userRepositoryProvider).updateUser(user.uid, {'displayName': newName});
                ref.invalidate(userProfileProvider);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: AppColors.accentPurple)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Change Password', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.bgElevated)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accentPurple)),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final newPass = controller.text.trim();
              if (newPass.length >= 6) {
                try {
                  await ref.read(authRepositoryProvider).currentUser?.updatePassword(newPass);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully.')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters.')),
                );
              }
            },
            child: const Text('Update', style: TextStyle(color: AppColors.accentPurple)),
          ),
        ],
      ),
    );
  }

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
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final authRepo = ref.read(authRepositoryProvider);
                  final user = authRepo.currentUser;
                  if (user != null) {
                    await user.delete();
                    await authRepo.signOut();
                    if (mounted) {
                      context.go(AppRoutes.login);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete account: $e')),
                    );
                  }
                }
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
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ref.read(authRepositoryProvider).signOut();
                  if (mounted) {
                    context.go(AppRoutes.login);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                }
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
          _buildItem(Icons.person_outline_rounded, 'Edit Profile', onTap: _showEditProfileDialog),
          _buildItem(Icons.lock_outline_rounded, 'Change Password', onTap: _showChangePasswordDialog),
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
            onChanged: _setPushNotifications,
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
            onChanged: _setWifiOnly,
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
