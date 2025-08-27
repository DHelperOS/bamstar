import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
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
    _showToast(
      context: context,
      message: message,
      title: title ?? '알림',
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      iconColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.onPrimaryContainer,
      icon: Icons.info_rounded,
    );
  }

  /// Show success toast (green theme)
  static void success(BuildContext context, String message, {String? title}) {
    _showToast(
      context: context,
      message: message,
      title: title ?? '완료',
      backgroundColor: const Color(0xFFE8F5E8),
      iconColor: const Color(0xFF4CAF50),
      textColor: const Color(0xFF2E7D32),
      icon: Icons.check_circle_rounded,
    );
  }

  /// Show warning toast (orange theme)
  static void warning(BuildContext context, String message, {String? title}) {
    _showToast(
      context: context,
      message: message,
      title: title ?? '주의',
      backgroundColor: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFFF9800),
      textColor: const Color(0xFFE65100),
      icon: Icons.warning_rounded,
    );
  }

  /// Show error toast (red theme)
  static void error(BuildContext context, String message, {String? title}) {
    _showToast(
      context: context,
      message: message,
      title: title ?? '오류',
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      iconColor: Theme.of(context).colorScheme.error,
      textColor: Theme.of(context).colorScheme.onErrorContainer,
      icon: Icons.error_rounded,
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
    DelightToastBar(
      autoDismiss: true,
      animationDuration: const Duration(milliseconds: 300),
      snackbarDuration: const Duration(seconds: 4),
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.formLabel(context).copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: AppTextStyles.primaryText(context).copyWith(
                        color: textColor,
                      ),
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