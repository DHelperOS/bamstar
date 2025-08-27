import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';

/// Global navigator key used to obtain a BuildContext from non-widget code
/// (for example StateNotifiers) so we can show global toasts.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Show a simple DelightToastBar using the global navigator context.
void showGlobalToast({
  required String title,
  required String message,
  required Color backgroundColor,
  Widget? icon,
  Duration autoDismiss = const Duration(milliseconds: 3200),
}) {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;

  DelightToastBar(
    builder: (innerCtx) => Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(ctx).colorScheme.shadow.withValues(alpha: 0.26),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.24),
                  shape: BoxShape.circle,
                ),
                child: icon,
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    autoDismiss: true,
  ).show(ctx);
}
