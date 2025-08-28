import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';
import '../theme/app_text_styles.dart';

/// Global toast utility for consistent app-wide toast notifications
///
/// Usage:
/// - ToastHelper.info(context, '정보 메시지')
/// - ToastHelper.warning(context, '경고 메시지')
/// - ToastHelper.error(context, '에러 메시지')
/// - ToastHelper.success(context, '성공 메시지')
class ToastHelper {
  ToastHelper._();

  /// Show info toast (blue theme)
  static void info(BuildContext context, String message, {String? title}) {
    final colorScheme = Theme.of(context).colorScheme;
    _showToast(
      context: context,
      message: message,
      title: title ?? '알림',
      backgroundColor: colorScheme.surfaceContainer,
      iconColor: colorScheme.primary,
      textColor: colorScheme.onSurface,
      icon: Icons.info_outline_rounded,
    );
  }

  /// Show success toast (green theme)
  static void success(BuildContext context, String message, {String? title}) {
    final colorScheme = Theme.of(context).colorScheme;
    _showToast(
      context: context,
      message: message,
      title: title ?? '완료',
      backgroundColor: colorScheme.surfaceContainer,
      iconColor: const Color(0xFF4CAF50),
      textColor: colorScheme.onSurface,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Show warning toast (orange theme)
  static void warning(BuildContext context, String message, {String? title}) {
    final colorScheme = Theme.of(context).colorScheme;
    _showToast(
      context: context,
      message: message,
      title: title ?? '주의',
      backgroundColor: colorScheme.surfaceContainer,
      iconColor: const Color(0xFFFF9800),
      textColor: colorScheme.onSurface,
      icon: Icons.warning_amber_outlined,
    );
  }

  /// Show error toast (red theme)
  static void error(BuildContext context, String message, {String? title}) {
    final colorScheme = Theme.of(context).colorScheme;
    _showToast(
      context: context,
      message: message,
      title: title ?? '오류',
      backgroundColor: colorScheme.surfaceContainer,
      iconColor: colorScheme.error,
      textColor: colorScheme.onSurface,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Internal method to show customized delightful toast
  static void _showToast({
    required BuildContext context,
    required String message,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    required IconData icon,
  }) {
    // Capture theme-dependent values BEFORE the builder to avoid using a deactivated context.
    final titleStyle = AppTextStyles.captionText(context).copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
    );
    final messageStyle = AppTextStyles.captionText(context).copyWith(
      color: textColor,
    );

    DelightToastBar(
      autoDismiss: true,
      animationDuration: const Duration(milliseconds: 250),
      snackbarDuration: const Duration(seconds: 3),
      builder: (ctx) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titleStyle,
                    ),
                    Text(
                      message,
                      style: messageStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).show(context);
  }
}
