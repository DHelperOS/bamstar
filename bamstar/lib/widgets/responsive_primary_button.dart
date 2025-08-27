import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive_utils.dart';

class ResponsivePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const ResponsivePrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final minHeight = isMobile ? 56.0 : 60.0;
    final horizontalPadding = isMobile ? 16.0 : 20.0;
    final borderRadius = isMobile ? 28.0 : 30.0; // Stadium shape
    
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 16 : 18,
            horizontal: horizontalPadding,
          ),
          minimumSize: Size.fromHeight(minHeight),
          elevation: ResponsiveUtils.isDesktop(context) ? 2 : 0,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        onPressed: isLoading ? null : onPressed,
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    }

    final List<Widget> children = [];
    
    if (leadingIcon != null) {
      children.addAll([
        leadingIcon!,
        const SizedBox(width: 8),
      ]);
    }
    
    children.add(
      Text(
        text,
        style: ResponsiveUtils.getResponsiveTextStyle(
          context,
          AppTextStyles.buttonText(context).copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          tabletScale: 1.05,
          desktopScale: 1.1,
        ),
      ),
    );
    
    if (trailingIcon != null) {
      children.addAll([
        const SizedBox(width: 8),
        trailingIcon!,
      ]);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}