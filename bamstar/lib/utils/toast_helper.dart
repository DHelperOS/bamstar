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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _showToast(
      context: context,
      message: message,
      title: title ?? '알림',
      backgroundColor: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE3F2FD),
      borderColor: const Color(0xFF2196F3),
      iconColor: const Color(0xFF2196F3),
      titleColor: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1976D2),
      messageColor: isDark ? const Color(0xFFBBDEFB) : const Color(0xFF1565C0),
      icon: Icons.info_rounded,
    );
  }

  /// Show success toast (green theme)
  static void success(BuildContext context, String message, {String? title}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _showToast(
      context: context,
      message: message,
      title: title ?? '완료',
      backgroundColor: isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E8),
      borderColor: const Color(0xFF4CAF50),
      iconColor: const Color(0xFF4CAF50),
      titleColor: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32),
      messageColor: isDark ? const Color(0xFFC8E6C9) : const Color(0xFF388E3C),
      icon: Icons.check_circle_rounded,
    );
  }

  /// Show warning toast (orange theme)
  static void warning(BuildContext context, String message, {String? title}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _showToast(
      context: context,
      message: message,
      title: title ?? '주의',
      backgroundColor: isDark ? const Color(0xFF5D4037) : const Color(0xFFFFF8E1),
      borderColor: const Color(0xFFFF9800),
      iconColor: const Color(0xFFFF9800),
      titleColor: isDark ? const Color(0xFFFFCC02) : const Color(0xFFF57C00),
      messageColor: isDark ? const Color(0xFFFDD835) : const Color(0xFFEF6C00),
      icon: Icons.warning_rounded,
    );
  }

  /// Show error toast (red theme)
  static void error(BuildContext context, String message, {String? title}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _showToast(
      context: context,
      message: message,
      title: title ?? '오류',
      backgroundColor: isDark ? const Color(0xFF5D1A1A) : const Color(0xFFFFEBEE),
      borderColor: const Color(0xFFF44336),
      iconColor: const Color(0xFFF44336),
      titleColor: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
      messageColor: isDark ? const Color(0xFFFFAB91) : const Color(0xFFD32F2F),
      icon: Icons.error_rounded,
    );
  }

  /// Internal method to show customized delightful toast
  static void _showToast({
    required BuildContext context,
    required String message,
    required String title,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required Color titleColor,
    required Color messageColor,
    required IconData icon,
  }) {
    final titleStyle = AppTextStyles.formLabel(context).copyWith(
      color: titleColor,
      fontWeight: FontWeight.w700,
      fontSize: 14,
      letterSpacing: -0.2,
    );
    final messageStyle = AppTextStyles.primaryText(context).copyWith(
      color: messageColor,
      fontSize: 13,
      height: 1.3,
    );
    final shadowColor = Theme.of(context).colorScheme.shadow;

    DelightToastBar(
      autoDismiss: true,
      animationDuration: const Duration(milliseconds: 350),
      snackbarDuration: const Duration(seconds: 4),
      builder: (ctx) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                backgroundColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
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
                        style: titleStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: messageStyle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).show(context);
  }
}
