import 'package:flutter/material.dart';
import 'typography.dart';

/// Pre-defined text styles for common use cases
/// Combines typography with semantic colors for easy usage
class AppTextStyles {
  const AppTextStyles._();

  // ===== HEADING STYLES WITH SEMANTIC COLORS =====
  
  static TextStyle pageTitle(BuildContext context) =>
      context.headlineLarge;

  static TextStyle sectionTitle(BuildContext context) =>
      context.headlineSmall;

  static TextStyle cardTitle(BuildContext context) =>
      context.titleLarge;

  static TextStyle listTitle(BuildContext context) =>
      context.titleMedium;

  static TextStyle subtitle(BuildContext context) =>
      context.titleSmall;

  // ===== BODY TEXT STYLES =====
  
  static TextStyle primaryText(BuildContext context) =>
      context.bodyLarge;

  static TextStyle secondaryText(BuildContext context) =>
      context.bodyMediumSecondaryText;

  static TextStyle captionText(BuildContext context) =>
      context.bodySmall;

  static TextStyle disabledText(BuildContext context) =>
      context.bodyLargeDisabled;

  // ===== BUTTON AND LABEL STYLES =====
  
  static TextStyle buttonText(BuildContext context) =>
      context.labelLarge;

  static TextStyle chipLabel(BuildContext context) =>
      context.labelMedium;

  static TextStyle formLabel(BuildContext context) =>
      context.labelLarge;

  static TextStyle helperText(BuildContext context) =>
      context.bodySmallSecondaryText;

  static TextStyle errorText(BuildContext context) =>
      context.bodyMediumError;

  // ===== SEMANTIC COLOR VARIANTS =====

  // Primary branded content
  static TextStyle primaryBrand(BuildContext context) =>
      context.bodyLargePrimary;

  static TextStyle secondaryBrand(BuildContext context) =>
      context.bodyLargeSecondary;

  // Status colors with fallback colors
  static TextStyle successText(BuildContext context) =>
      context.bodyLarge.copyWith(
        color: const Color(0xFF22C55E), // Green
      );

  static TextStyle warningText(BuildContext context) =>
      context.bodyLarge.copyWith(
        color: const Color(0xFFFFAB00), // Amber
      );

  static TextStyle infoText(BuildContext context) =>
      context.bodyLarge.copyWith(
        color: const Color(0xFF00B8D9), // Cyan
      );

  static TextStyle errorTextSemantic(BuildContext context) =>
      context.bodyLargeError;

  // ===== SPECIALIZED USE CASES =====

  // Navigation and menu items
  static TextStyle navigationLabel(BuildContext context) =>
      context.labelLarge;

  static TextStyle navigationTitle(BuildContext context) =>
      context.titleMedium;

  // Tab labels
  static TextStyle tabLabel(BuildContext context) =>
      context.labelLarge;

  // Dialog text
  static TextStyle dialogTitle(BuildContext context) =>
      context.headlineSmall;

  static TextStyle dialogContent(BuildContext context) =>
      context.bodyLarge;

  static TextStyle dialogAction(BuildContext context) =>
      context.labelLarge.copyWith(
        color: Theme.of(context).colorScheme.primary,
      );

  // App bar titles
  static TextStyle appBarTitle(BuildContext context) =>
      context.titleLarge;

  // List items
  static TextStyle listItemTitle(BuildContext context) =>
      context.bodyLarge;

  static TextStyle listItemSubtitle(BuildContext context) =>
      context.bodyMediumSecondaryText;

  static TextStyle listItemCaption(BuildContext context) =>
      context.bodySmallSecondaryText;

  // Form fields
  static TextStyle inputText(BuildContext context) =>
      context.bodyLarge;

  static TextStyle inputLabel(BuildContext context) =>
      context.bodyMediumSecondaryText;

  static TextStyle inputError(BuildContext context) =>
      context.bodySmallSecondaryText.copyWith(
        color: Theme.of(context).colorScheme.error,
      );

  static TextStyle inputHelper(BuildContext context) =>
      context.bodySmallSecondaryText;

  // ===== LEGACY MAPPING (for migration) =====
  
  @Deprecated('Use pageTitle instead')
  static TextStyle h1(BuildContext context) => pageTitle(context);
  
  @Deprecated('Use sectionTitle instead')
  static TextStyle h2(BuildContext context) => sectionTitle(context);
  
  @Deprecated('Use cardTitle instead')
  static TextStyle h3(BuildContext context) => cardTitle(context);
  
  @Deprecated('Use listTitle instead')
  static TextStyle h4(BuildContext context) => listTitle(context);
  
  @Deprecated('Use subtitle instead')
  static TextStyle h5(BuildContext context) => subtitle(context);
  
  @Deprecated('Use captionText instead')
  static TextStyle h6(BuildContext context) => captionText(context);
  
  @Deprecated('Use primaryText instead')
  static TextStyle body1(BuildContext context) => primaryText(context);
  
  @Deprecated('Use secondaryText instead')
  static TextStyle body2(BuildContext context) => secondaryText(context);
  
  @Deprecated('Use captionText instead')
  static TextStyle caption(BuildContext context) => captionText(context);
  
  @Deprecated('Use buttonText instead')
  static TextStyle button(BuildContext context) => buttonText(context);
  
  @Deprecated('Use captionText instead')
  static TextStyle overline(BuildContext context) => captionText(context);
}

/// Utility class for text style modifications
class AppTextStyleUtils {
  const AppTextStyleUtils._();

  /// Apply semantic color to any text style
  static TextStyle withSemanticColor(
    TextStyle baseStyle, 
    BuildContext context, 
    String semantic,
  ) {
    return AppTypography.withSemanticColor(
      baseStyle, 
      Theme.of(context).colorScheme, 
      semantic,
    );
  }

  /// Create bold variant of text style
  static TextStyle bold(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w700);

  /// Create semibold variant of text style
  static TextStyle semiBold(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w600);

  /// Create medium variant of text style
  static TextStyle medium(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w500);

  /// Create italic variant of text style
  static TextStyle italic(TextStyle style) =>
      style.copyWith(fontStyle: FontStyle.italic);

  /// Create underlined text style
  static TextStyle underlined(TextStyle style) =>
      style.copyWith(decoration: TextDecoration.underline);

  /// Create struck through text style
  static TextStyle strikeThrough(TextStyle style) =>
      style.copyWith(decoration: TextDecoration.lineThrough);

  /// Adjust font size by scale factor
  static TextStyle scaled(TextStyle style, double scale) =>
      style.copyWith(fontSize: (style.fontSize ?? 14) * scale);

  /// Create text style with specific color
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  /// Create text style with opacity
  static TextStyle withOpacity(TextStyle style, double opacity) =>
      style.copyWith(color: style.color?.withValues(alpha: opacity));
}