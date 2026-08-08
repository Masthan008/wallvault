import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_animations.dart';
import '../../theme/app_colors.dart';

/// Toast variants mirror the palette (success/error/warning/info).
enum ToastType { success, error, warning, info }

IconData _iconFor(ToastType type) {
  switch (type) {
    case ToastType.success:
      return Icons.check_circle_rounded;
    case ToastType.error:
      return Icons.error_rounded;
    case ToastType.warning:
      return Icons.warning_amber_rounded;
    case ToastType.info:
      return Icons.info_rounded;
  }
}

Color _colorFor(ToastType type) {
  switch (type) {
    case ToastType.success:
      return AppColors.accentSuccess;
    case ToastType.error:
      return AppColors.accentError;
    case ToastType.warning:
      return AppColors.accentWarning;
    case ToastType.info:
      return AppColors.accentCyan;
  }
}

/// Animated floating toast replacement for bare `SnackBar`s.
void showAppToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.info,
  Duration duration = const Duration(milliseconds: 2400),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _AppToastOverlay(
      message: message,
      type: type,
      duration: duration,
      onDismissed: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _AppToastOverlay extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _AppToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppAnimations.fast,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _hide);
  }

  void _hide() {
    if (!mounted) return;
    _controller.reverse().whenComplete(() {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    final accent = _colorFor(widget.type);

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottom,
      child: IgnorePointer(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: _controller, curve: AppAnimations.easeOutExpo),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller,
              curve: AppAnimations.easeOutExpo,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xF2141420),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(_iconFor(widget.type), color: accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}