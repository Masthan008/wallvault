import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/glow_input.dart';

/// S19-S21 — Creator upload screen (multi-step wizard).
class CreatorUploadScreen extends StatefulWidget {
  const CreatorUploadScreen({super.key});

  @override
  State<CreatorUploadScreen> createState() => _CreatorUploadScreenState();
}

class _CreatorUploadScreenState extends State<CreatorUploadScreen> {
  int _step = 0;
  final _pageController = PageController();

  // Step 1 states
  bool _hasImage = false;
  final _nameController = TextEditingController();

  // Step 2 states
  String _selectedCategory = 'Abstract';
  final List<String> _tags = [];
  final _tagInputController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 3 states
  bool _isPremium = false;
  final _priceController = TextEditingController(text: '49');
  bool _isPublishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _tagInputController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 2) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _publishWallpaper();
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

  void _publishWallpaper() async {
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallpaper published successfully!'),
          backgroundColor: AppColors.accentSuccess,
        ),
      );
    }
  }

  bool _isNextEnabled() {
    if (_step == 0) {
      return _hasImage && _nameController.text.isNotEmpty;
    }
    if (_step == 1) {
      return _selectedCategory.isNotEmpty && _descriptionController.text.isNotEmpty;
    }
    if (_step == 2) {
      if (_isPremium) {
        final price = double.tryParse(_priceController.text) ?? 0;
        return price >= 10 && price <= 999;
      }
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Upload Wallpaper'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _prevStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicators
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: List.generate(3, (i) => Expanded(
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
                  Text('Step ${_step + 1} of 3', style: AppTypography.caption),
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
                ],
              ),
            ),

            // Navigation Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  GradientButton(
                    label: _step == 2 ? 'Publish Wallpaper' : 'Continue',
                    onPressed: _isNextEnabled() ? _nextStep : null,
                    isLoading: _isPublishing,
                    icon: _step == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
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

  // Step 1: Select image and name
  Widget _buildStep1() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.screenPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _hasImage = !_hasImage),
          child: Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(
                color: _hasImage ? AppColors.accentPurple : AppColors.bgElevated,
                width: 2,
              ),
            ),
            child: !_hasImage
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_rounded, color: AppColors.accentPurple, size: 48),
                      SizedBox(height: 16),
                      Text('Tap to select wallpaper', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Supports: JPG, PNG, WEBP (Max 20MB)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard - 2),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=400',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        GlowInput(
          controller: _nameController,
          hintText: 'Wallpaper Name',
          prefixIcon: Icons.title_rounded,
          onChanged: (_) => setState(() {}),
        ),
      ],
    ),
  );

  // Step 2: Metadata tags & description
  Widget _buildStep2() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.screenPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTypography.h4),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bgElevated),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              dropdownColor: AppColors.bgCard,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: ['Nature', 'Abstract', 'Cars', 'Anime', 'Space', 'Dark', 'Minimal']
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Description', style: AppTypography.h4),
        const SizedBox(height: 8),
        GlowInput(
          controller: _descriptionController,
          hintText: 'Describe your wallpaper...',
          prefixIcon: Icons.description_rounded,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        Text('Tags', style: AppTypography.h4),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GlowInput(
                controller: _tagInputController,
                hintText: 'Add a tag...',
                prefixIcon: Icons.tag_rounded,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.accentPurple),
              onPressed: () {
                if (_tagInputController.text.isNotEmpty && _tags.length < 5) {
                  setState(() {
                    _tags.add(_tagInputController.text.trim());
                    _tagInputController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _tags.map((tag) => Chip(
            label: Text(tag, style: const TextStyle(fontSize: 12)),
            backgroundColor: AppColors.bgCard,
            onDeleted: () => setState(() => _tags.remove(tag)),
            deleteIconColor: AppColors.accentError,
          )).toList(),
        ),
      ],
    ),
  );

  // Step 3: Pricing
  Widget _buildStep3() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.screenPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set Pricing', style: AppTypography.h2),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isPremium = false),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: !_isPremium ? AppColors.accentSuccess : AppColors.bgElevated,
                      width: 2,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.money_off_rounded, color: AppColors.accentSuccess),
                      SizedBox(height: 8),
                      Text('Free', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isPremium = true),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isPremium ? AppColors.accentGold : AppColors.bgElevated,
                      width: 2,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: AppColors.accentGold),
                      SizedBox(height: 8),
                      Text('Premium', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_isPremium) ...[
          const SizedBox(height: 32),
          GlowInput(
            controller: _priceController,
            hintText: 'Price (INR)',
            prefixIcon: Icons.currency_rupee_rounded,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          _buildLiveEarningsSplit(),
        ],
      ],
    ),
  );

  Widget _buildLiveEarningsSplit() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final creatorShare = price * 0.8;
    final platformShare = price * 0.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgElevated),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Split Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Creator Share (80%)', style: TextStyle(fontSize: 13)),
              Text('₹${creatorShare.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentSuccess)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Platform Fee (20%)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('₹${platformShare.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
