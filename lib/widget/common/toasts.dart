import 'dart:async';
import 'package:nextpay/export.dart';

enum ToastType { success, error, info, warning }

class AppToast {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;
  static const Duration _toastDuration = Duration(seconds: 3);
  static const double _borderRadius = 8.0;
  static const double _fontSize = 14.0;
  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  static void show(
    String message,
    BuildContext context, {
    ToastType type = ToastType.info,
    Duration duration = _toastDuration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _remove();

    final colors = _getToastColors(type, context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 32,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) => Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            ),
            child: Container(
              padding: _padding,
              decoration: BoxDecoration(
                color: colors['background'],
                borderRadius: BorderRadius.circular(_borderRadius),
                border: Border.all(
                  color: colors['border']!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colors['icon']!.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForType(type),
                        color: colors['icon'],
                        size: 12,
                      ),
                    ),
                  ),
                  const Gap(12),
                  // Message
                  Expanded(
                    child: MyText(
                      text: message,
                      color: colors['text'],
                      size: _fontSize,
                      weight: FontWeight.w500,
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Action Button (optional)
                  if (actionLabel != null && onAction != null) ...[
                    const Gap(12),
                    GestureDetector(
                      onTap: () {
                        onAction();
                        _remove();
                      },
                      child: MyText(
                        text: actionLabel,
                        color: colors['icon'],
                        size: 12,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                  // Close Button
                  const Gap(8),
                  GestureDetector(
                    onTap: _remove,
                    child: Icon(
                      Icons.close,
                      color: colors['text']!.withOpacity(0.6),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _timer = Timer(duration, _remove);
  }

  static Map<String, Color> _getToastColors(ToastType type, BuildContext context) {
    switch (type) {
      case ToastType.success:
        return {
          'background': context.isDarkMode 
              ? context.surface.withOpacity(0.9)
              : context.success.withOpacity(0.1),
          'border': context.isDarkMode 
              ? context.success.withOpacity(0.3)
              : context.success.withOpacity(0.2),
          'text': context.success,
          'icon': context.success,
        };
      case ToastType.error:
        return {
          'background': context.isDarkMode 
              ? context.surface.withOpacity(0.9)
              : context.error.withOpacity(0.1),
          'border': context.isDarkMode 
              ? context.error.withOpacity(0.3)
              : context.error.withOpacity(0.2),
          'text': context.error,
          'icon': context.error,
        };
      case ToastType.warning:
        return {
          'background': context.isDarkMode 
              ? context.surface.withOpacity(0.9)
              : context.warning.withOpacity(0.1),
          'border': context.isDarkMode 
              ? context.warning.withOpacity(0.3)
              : context.warning.withOpacity(0.2),
          'text': context.warning,
          'icon': context.warning,
        };
      case ToastType.info:
      default:
        return {
          'background': context.isDarkMode 
              ? context.surface.withOpacity(0.9)
              : context.info.withOpacity(0.1),
          'border': context.isDarkMode 
              ? context.info.withOpacity(0.3)
              : context.info.withOpacity(0.2),
          'text': context.info,
          'icon': context.info,
        };
    }
  }

  static IconData _getIconForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber;
      case ToastType.info:
      default:
        return Icons.info_outline;
    }
  }

  static void _remove() {
    _timer?.cancel();
    _overlayEntry?.remove();
    _timer = null;
    _overlayEntry = null;
  }

  // Convenience methods
  static void success(String message, BuildContext context, {Duration? duration}) {
    show(message, context, type: ToastType.success, duration: duration ?? _toastDuration);
  }

  static void error(String message, BuildContext context, {Duration? duration}) {
    show(message, context, type: ToastType.error, duration: duration ?? _toastDuration);
  }

  static void warning(String message, BuildContext context, {Duration? duration}) {
    show(message, context, type: ToastType.warning, duration: duration ?? _toastDuration);
  }

  static void info(String message, BuildContext context, {Duration? duration}) {
    show(message, context, type: ToastType.info, duration: duration ?? _toastDuration);
  }
}

// Usage Examples:
/*
// Basic toast
AppToast.show('Payment successful!', context, type: ToastType.success);

// Success shortcut
AppToast.success('Account created!', context);

// Error with custom duration
AppToast.error('Something went wrong', context, duration: Duration(seconds: 4));

// Toast with action button
AppToast.show(
  'File downloaded',
  context,
  type: ToastType.info,
  actionLabel: 'Open',
  onAction: () {
    // Handle action
  },
);

// Warning
AppToast.warning('Low balance', context);
*/