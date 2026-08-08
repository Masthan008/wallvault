import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/effects/aurora_background.dart';
import '../../../core/widgets/effects/entrance.dart';
import '../../../core/widgets/effects/glow_button.dart';

/// OTP verification screen with custom pill inputs, auto-focus/advance,
/// error shake, resend countdown and auto-submit.
class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;

  const OtpScreen({super.key, this.phone = '', this.verificationId = ''});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  static const int _length = 6;
  static const int _resendSeconds = 30;

  late final List<TextEditingController> _controllers =
      List.generate(_length, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes =
      List.generate(_length, (_) => FocusNode());

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: AppAnimations.medium,
  )..addListener(() => setState(() {}));

  Timer? _resendTimer;
  int _secondsLeft = _resendSeconds;
  bool _submitting = false;
  bool _error = false;

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _shake.dispose();
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  Future<void> _verify() async {
    if (_code.length != _length || _submitting) return;
    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();

    // placeholder wire — swap with auth controller once wired
    await Future.delayed(AppAnimations.medium);

    if (!mounted) return;
    setState(() => _submitting = false);
    context.go(AppRoutes.home);
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    setState(() {
      _secondsLeft = _resendSeconds;
      _error = false;
    });
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _startCountdown();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: AuroraBackground(
        intensity: 0.6,
        child: SafeArea(
          child: SizedBox.expand(
            child: Stack(
              children: [
                Positioned(
                  left: AppSpacing.screenPadding,
                  top: AppSpacing.screenPadding,
                  child: Entrance.fadeIn(
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        onTap: () => context.pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.bgElevated.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x1FFFFFFF)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24)
                        .copyWith(bottom: 40),
                    physics: const BouncingScrollPhysics(),
                    child: Entrance.fadeUp(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _OtpCard(
                          phone: widget.phone,
                          secondsLeft: _secondsLeft,
                          submitting: _submitting,
                          error: _error,
                          shakeOffset: _shake.value * 10,
                          controllers: _controllers,
                          focusNodes: _focusNodes,
                          onChanged: _onChanged,
                          onResend: _resend,
                          onVerify: _verify,
                        ),
                      ),
                      delayMs: 120,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onChanged(int index, String value) {
    _error = false;
    if (value.length > 1) {
      final code = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _length && i < code.length; i++) {
        _controllers[i].text = code[i];
      }
      final last = (code.length > _length ? _length : code.length) - 1;
      if (last >= 0) _focusNodes[last].requestFocus();
      if (code.length >= _length) _verify();
      return;
    }
    if (value.isNotEmpty) {
      if (index < _length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verify();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }
}

/// Glass card containing the OTP inputs.
class _OtpCard extends StatelessWidget {
  final String phone;
  final int secondsLeft;
  final bool submitting;
  final bool error;
  final double shakeOffset;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final VoidCallback onResend;
  final VoidCallback onVerify;

  const _OtpCard({
    required this.phone,
    required this.secondsLeft,
    required this.submitting,
    required this.error,
    required this.shakeOffset,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onResend,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding + 8),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: const Color(0x1FFFFFFF)),
        boxShadow: AppColors.buttonShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientPremium,
            ),
            child: const Icon(Icons.sms_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),
          Text(
            'Verify OTP',
            style: AppTypography.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit code sent to',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            phone.isEmpty ? 'your phone' : '+91 $phone',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: Listenable.merge([
              ...controllers,
              ...focusNodes,
            ]),
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < controllers.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      _OtpBox(
                        controller: controllers[i],
                        focusNode: focusNodes[i],
                        onChanged: (v) => onChanged(i, v),
                        hasValue: controllers[i].text.isNotEmpty,
                        isFocused: focusNodes[i].hasFocus,
                        isError: error,
                        enabled: !submitting,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                secondsLeft > 0
                    ? 'Resend code in ${secondsLeft}s'
                    : 'Didn\'t get a code?',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              if (secondsLeft == 0) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onResend,
                  child: Text(
                    ' Resend',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          GlowButton(
            onPressed: submitting ? null : onVerify,
            label: submitting ? 'Verifying…' : 'Verify Code',
            height: AppSpacing.buttonHeight,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

/// Single pill-shaped OTP input.
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool hasValue;
  final bool isFocused;
  final bool isError;
  final bool enabled;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.hasValue,
    required this.isFocused,
    required this.isError,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isError
        ? AppColors.accentError
        : isFocused
            ? AppColors.accentCyan
            : hasValue
                ? AppColors.accentPurple.withValues(alpha: 0.45)
                : const Color(0x22FFFFFF);

    return AnimatedContainer(
      duration: AppAnimations.fast,
      curve: AppAnimations.easeOutExpo,
      width: AppSpacing.otpBoxSize,
      height: AppSpacing.otpBoxSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall * 2),
        color: AppColors.bgCard.withValues(alpha: isFocused ? 0.9 : 0.7),
        border: Border.all(
          color: borderColor,
          width: isFocused ? 2 : 1.4,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.28),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          enabled: !enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}