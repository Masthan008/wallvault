import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/router/routes.dart';

/// S07 — OTP verification screen with 48x48px boxes, active cyan borders, and interactive resend countdown.
class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() => _resendCountdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verify when all filled
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp(otp);
    }
  }

  void _verifyOtp(String otp) {
    // Navigate on successful login
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Verify Your Number', style: AppTypography.h1)
                  .animate()
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to ${widget.phone.isNotEmpty ? widget.phone : '+91 98765 43210'}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 48),
              
              // OTP boxes row (6 inputs, 48x48px size)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                      onChanged: (v) => _onChanged(index, v),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.bgCard,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.accentCyan, width: 2), // Active cyan border
                        ),
                      ),
                    ),
                  )
                      .animate(delay: (100 * index).ms)
                      .fadeIn()
                      .scale(begin: const Offset(0.8, 0.8), curve: Curves.bounceOut);
                }),
              ),
              const SizedBox(height: 32),
              
              // Verify Button
              GradientButton(
                label: 'Verify',
                onPressed: () {
                  final otp = _controllers.map((c) => c.text).join();
                  if (otp.length == 6) _verifyOtp(otp);
                },
              ).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 24),
              
              // Countdown & Resend link
              Center(
                child: _resendCountdown > 0
                    ? Text(
                        'Didn\'t receive? Resend (${_resendCountdown}s)',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      )
                    : TextButton(
                        onPressed: _startCountdown,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: AppColors.accentCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
