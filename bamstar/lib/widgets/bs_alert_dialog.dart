import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import '../theme/typography.dart';
import '../theme/app_text_styles.dart';

/// Material 3 공통 얼럿 다이얼로그
/// - header(제목), body(본문)
/// - 1버튼 또는 2버튼 구성 지원
/// - 재사용을 위해 showBsAlert() 헬퍼 제공
class BsAlertDialog extends StatelessWidget {
  final String header;
  final String body;
  final String primaryText;
  final VoidCallback? onPrimary;
  final String? secondaryText;
  final VoidCallback? onSecondary;
  final IconData? icon;

  const BsAlertDialog({
    super.key,
    required this.header,
    required this.body,
    required this.primaryText,
    this.onPrimary,
    this.secondaryText,
    this.onSecondary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: cs.surface,
      surfaceTintColor: cs.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: cs.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              header,
              style: AppTextStyles.dialogTitle(context),
            ),
          ),
        ],
      ),
      content: Text(
        body,
        style: AppTextStyles.dialogContent(context),
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (secondaryText != null)
              TextButton(
                onPressed:
                    onSecondary ?? () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  backgroundColor: cs.onSurface.withValues(alpha: 0.06),
                  foregroundColor: cs.onSurfaceVariant,
                  minimumSize: const Size(64, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: const StadiumBorder(),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  secondaryText!,
                  style: AppTextStyles.secondaryText(context),
                ),
              ),
            const SizedBox(width: 12),
            SizedBox(
              height: 40,
              child: FilledButton(
                onPressed: onPrimary ?? () => Navigator.of(context).pop(true),
                child: Text(primaryText),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<T?> showBsAlert<T>(
  BuildContext context, {
  required String header,
  required String body,
  required String primaryText,
  VoidCallback? onPrimary,
  String? secondaryText,
  VoidCallback? onSecondary,
  IconData? icon,
  bool barrierDismissible = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => BsAlertDialog(
      header: header,
      body: body,
      primaryText: primaryText,
      onPrimary: onPrimary,
      secondaryText: secondaryText,
      onSecondary: onSecondary,
      icon: icon ?? SolarIconsOutline.checkCircle,
    ),
  );
}
