import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/router/routes.dart';
import '../../../providers/auth_provider.dart';

/// S25 — Premium Liquid Glass Settings Screen
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
        backgroundColor: const Color(0xFA0D0D14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Text('Edit Display Name', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Display Name',
            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accentPurple, width: 1.5),
            ),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await ref.read(userRepositoryProvider).updateUser(user.uid, {'displayName': newName});
                ref.invalidate(userProfileProvider);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        backgroundColor: const Color(0xFA0D0D14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Text('Change Password', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New Password',
            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accentPurple, width: 1.5),
            ),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
              }
            },
            child: const Text('Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFA0D0D14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentError.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.accentError, size: 36),
            ),
            const SizedBox(height: 16),
            Text('Delete Account Permanently', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              'This action is irreversible. All your downloads, saved wallpapers, and profile data will be purged.',
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

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFA0D0D14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Text('Help Center FAQs', style: AppTypography.h3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFAQItem('How do I set a wallpaper?', 'Tap any wallpaper, press "Apply Wallpaper", and select Home Screen, Lock Screen, or Both.'),
              _buildFAQItem('How do bulk downloads work?', 'Wallpapers save directly to your phone gallery with 4K UHD resolution preserved.'),
              _buildFAQItem('How do creators earn money?', 'Creators get a 70% revenue share on all premium wallpaper purchases, withdrawable to UPI/Bank.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.accentPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          const SizedBox(height: 4),
          Text(a, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }

  void _showContactUs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFA0D0D14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Text('Contact Support', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Have questions or custom creator inquiries? Contact us at:', style: AppTypography.bodySmall),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.email_rounded, color: AppColors.accentPurple, size: 20),
                  SizedBox(width: 10),
                  Text('support@wallvault.com', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('Average response time: < 2 hours', style: AppTypography.caption),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss', style: TextStyle(color: AppColors.accentPurple)),
          ),
        ],
      ),
    );
  }

  void _showReportBug() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFA0D0D14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Text('Report an Issue', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Describe what went wrong and we will resolve it immediately:', style: AppTypography.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe issue here...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.04),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.accentPurple),
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final bugDesc = controller.text.trim();
              if (bugDesc.isEmpty) return;
              final user = ref.read(userProfileProvider).value;
              try {
                await FirebaseFirestore.instance.collection('reports').add({
                  'userId': user?.uid,
                  'description': bugDesc,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bug report submitted. Thank you!'), backgroundColor: AppColors.accentSuccess),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRateApp() {
    int selectedStars = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFA0D0D14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: Center(child: Text('Rate WallVault', style: AppTypography.h3)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your feedback helps us create better wallpapers!', style: AppTypography.bodySmall),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(
                      starIndex <= selectedStars ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.accentGold,
                      size: 34,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        selectedStars = starIndex;
                      });
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not Now', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for rating!'), backgroundColor: AppColors.accentSuccess),
                );
              },
              child: const Text('Submit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share('Check out WallVault for 4K UHD liquid glass wallpapers & digital art! Download now: https://wallvault.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text('Settings & Preferences', style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 12),
        children: [
          // Header Hero Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentPurple.withValues(alpha: 0.18),
                  AppColors.accentCyan.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('App Configuration', style: AppTypography.h4),
                      const SizedBox(height: 2),
                      Text('Manage security, storage, and notifications', style: AppTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Section
          _buildSectionHeader('Account & Security', Icons.shield_rounded),
          _buildGlassCard([
            _buildSettingTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Display Name',
              subtitle: 'Update your public creator profile name',
              onTap: _showEditProfileDialog,
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.lock_outline_rounded,
              title: 'Change Password',
              subtitle: 'Update your login password',
              onTap: _showChangePasswordDialog,
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete Account',
              subtitle: 'Permanently remove account & data',
              color: AppColors.accentError,
              onTap: _showDeleteAccountConfirmation,
            ),
          ]),
          const SizedBox(height: 20),

          // Preferences Section
          _buildSectionHeader('App Preferences', Icons.tune_rounded),
          _buildGlassCard([
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              subtitle: 'Alerts for new wallpaper drops & rewards',
              value: _pushNotifications,
              onChanged: _setPushNotifications,
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.wifi_rounded,
              title: 'Download on WiFi Only',
              subtitle: 'Conserve mobile cellular data',
              value: _wifiOnly,
              onChanged: _setWifiOnly,
            ),
          ]),
          const SizedBox(height: 20),

          // Support Section
          _buildSectionHeader('Support & Legal', Icons.help_outline_rounded),
          _buildGlassCard([
            _buildSettingTile(
              icon: Icons.quiz_outlined,
              title: 'Help Center FAQs',
              subtitle: 'Common questions & download guides',
              onTap: _showHelpCenter,
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.headset_mic_outlined,
              title: 'Contact Support',
              subtitle: 'Direct email support team',
              onTap: _showContactUs,
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.bug_report_outlined,
              title: 'Report a Bug',
              subtitle: 'Feedback & feature requests',
              onTap: _showReportBug,
            ),
          ]),
          const SizedBox(height: 20),

          // About Section
          _buildSectionHeader('About WallVault', Icons.info_outline_rounded),
          _buildGlassCard([
            _buildSettingTile(
              icon: Icons.star_outline_rounded,
              title: 'Rate App',
              subtitle: 'Support WallVault on App Store / Play Store',
              onTap: _showRateApp,
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.share_outlined,
              title: 'Share App',
              subtitle: 'Invite friends & creators',
              onTap: _shareApp,
            ),
            _buildDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('App Version', style: AppTypography.bodyMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Text('v1.0.0 (Build 1)', style: TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.accentPurple),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xEB0D0D14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.04),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.accentPurple.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color == AppColors.accentError
                      ? AppColors.accentError.withValues(alpha: 0.12)
                      : AppColors.accentPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color == AppColors.accentError ? AppColors.accentError : AppColors.accentPurple,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.accentPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.accentPurple,
            activeTrackColor: AppColors.accentPurple.withValues(alpha: 0.4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
