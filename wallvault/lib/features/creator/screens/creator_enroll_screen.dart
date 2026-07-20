import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/glow_input.dart';

/// S14-S17 — Creator enrollment multi-step form.
class CreatorEnrollScreen extends StatefulWidget {
  const CreatorEnrollScreen({super.key});

  @override
  State<CreatorEnrollScreen> createState() => _CreatorEnrollScreenState();
}

class _CreatorEnrollScreenState extends State<CreatorEnrollScreen> {
  int _step = 0;
  final _pageController = PageController();

  // Step 1 values
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _hasAvatar = false;

  // Step 2 values
  final List<bool> _uploadedSlots = [false, false, false];

  // Step 3 values
  int _selectedPaymentMethod = 0; // 0: UPI, 1: Razorpay Connect
  final _upiController = TextEditingController();

  // Step 4 values
  bool _agreeTerms = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 3) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submitApplication();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  void _submitApplication() async {
    if (!_agreeTerms) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application Submitted successfully! We\'ll review it in 24-48 hours.'),
          backgroundColor: AppColors.accentSuccess,
        ),
      );
    }
  }

  bool _isNextEnabled() {
    if (_step == 0) {
      return _nameController.text.length >= 3 && _bioController.text.isNotEmpty;
    }
    if (_step == 1) {
      return _uploadedSlots.every((uploaded) => uploaded);
    }
    if (_step == 2) {
      if (_selectedPaymentMethod == 0) {
        return _upiController.text.contains('@');
      }
      return true; // Razorpay mock link
    }
    if (_step == 3) {
      return _agreeTerms && !_isSubmitting;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Become a Creator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _prevStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: List.generate(4, (i) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _step
                              ? AppColors.accentPurple
                              : AppColors.bgElevated,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 8),
                  Text('Step ${_step + 1} of 4',
                      style: AppTypography.caption),
                ],
              ),
            ),

            // Form Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),

            // Navigation Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  GradientButton(
                    label: _step == 3 ? 'Submit Application' : 'Continue',
                    onPressed: _isNextEnabled() ? _nextStep : null,
                    isLoading: _isSubmitting,
                    icon: _step == 3 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                  ),
                  if (_step > 0) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _prevStep,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Tell us about yourself
  Widget _buildStep1() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.screenPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basic Info', style: AppTypography.h2),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _hasAvatar = !_hasAvatar),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.bgCard,
              backgroundImage: _hasAvatar
                  ? const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200')
                  : null,
              child: !_hasAvatar
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: AppColors.textMuted, size: 28),
                        SizedBox(height: 4),
                        Text('Tap to upload', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 32),
        GlowInput(
          controller: _nameController,
          hintText: 'Display Name',
          prefixIcon: Icons.person_rounded,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        GlowInput(
          controller: _bioController,
          hintText: 'Bio (Tell us about your art style)',
          prefixIcon: Icons.edit_note_rounded,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
        ),
      ],
    ),
  );

  // Step 2: Portfolio Upload
  Widget _buildStep2() => Padding(
    padding: const EdgeInsets.all(AppSpacing.screenPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Portfolio', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text('Upload 3 sample wallpapers to showcase your style',
            style: AppTypography.bodySmall),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            final isUploaded = _uploadedSlots[index];
            return GestureDetector(
              onTap: () => setState(() => _uploadedSlots[index] = !_uploadedSlots[index]),
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(
                    color: isUploaded ? AppColors.accentPurple : AppColors.bgElevated,
                    width: isUploaded ? 2 : 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isUploaded)
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: AppColors.textMuted, size: 24),
                          SizedBox(height: 4),
                          Text('Add', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      )
                    else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCard - 1),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=150',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    ),
  );

  // Step 3: Payout Setup
  Widget _buildStep3() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.screenPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payout Setup', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text('How you\'ll receive your earnings', style: AppTypography.bodySmall),
        const SizedBox(height: 24),

        // UPI Option Card
        GestureDetector(
          onTap: () => setState(() => _selectedPaymentMethod = 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedPaymentMethod == 0 ? AppColors.accentPurple : AppColors.bgElevated,
                width: _selectedPaymentMethod == 0 ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Radio<int>(
                  value: 0,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                  activeColor: AppColors.accentPurple,
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UPI Payout', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Direct bank transfer via UPI', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Razorpay Connect Option Card
        GestureDetector(
          onTap: () => setState(() => _selectedPaymentMethod = 1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedPaymentMethod == 1 ? AppColors.accentPurple : AppColors.bgElevated,
                width: _selectedPaymentMethod == 1 ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Radio<int>(
                  value: 1,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                  activeColor: AppColors.accentPurple,
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Razorpay Connect', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Integrated merchants payouts ledger', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (_selectedPaymentMethod == 0)
          GlowInput(
            controller: _upiController,
            hintText: 'UPI ID (e.g. creator@upi)',
            prefixIcon: Icons.account_balance_wallet_rounded,
            onChanged: (_) => setState(() {}),
          ),
        const SizedBox(height: 16),
        Text('• Minimum payout threshold: ₹500', style: AppTypography.caption),
        Text('• You\'ll receive 80% split of each sale', style: AppTypography.caption),
      ],
    ),
  );

  // Step 4: Review & Submit
  Widget _buildStep4() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.screenPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Submit', style: AppTypography.h2),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.bgElevated),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${_nameController.text}', style: AppTypography.h4),
              const SizedBox(height: 4),
              Text('Bio: ${_bioController.text}', style: AppTypography.bodyMedium),
              const SizedBox(height: 12),
              Text(
                _selectedPaymentMethod == 0
                    ? 'Payout: UPI (${_upiController.text})'
                    : 'Payout: Razorpay Connect linked',
                style: AppTypography.bodySmall.copyWith(color: AppColors.accentCyan),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Checkbox(
              value: _agreeTerms,
              onChanged: (val) => setState(() => _agreeTerms = val!),
              activeColor: AppColors.accentPurple,
            ),
            Expanded(
              child: Text(
                'I agree to the Creator Terms and Conditions and Guidelines.',
                style: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
