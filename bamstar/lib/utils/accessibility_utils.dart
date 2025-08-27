import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for enhanced user experience
class AccessibilityUtils {
  /// Minimum touch target size for accessibility (44x44 logical pixels)
  static const double minTouchTargetSize = 44.0;
  
  /// Recommended touch target size for better UX (48x48 logical pixels)  
  static const double recommendedTouchTargetSize = 48.0;
  
  /// Minimum contrast ratio for normal text (WCAG AA)
  static const double minContrastRatio = 4.5;
  
  /// Minimum contrast ratio for large text (WCAG AA)
  static const double minLargeTextContrastRatio = 3.0;

  /// Wrap a widget to ensure minimum touch target size
  static Widget ensureTouchTarget({
    required Widget child,
    double minSize = recommendedTouchTargetSize,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }

  /// Add semantic label to a widget for screen readers
  static Widget addSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isTextField = false,
    bool isEnabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      textField: isTextField,
      enabled: isEnabled,
      child: child,
    );
  }

  /// Create accessible focus decoration for custom widgets
  static BoxDecoration getFocusDecoration(
    BuildContext context, {
    bool hasFocus = false,
    Color? focusColor,
    double borderWidth = 2.0,
  }) {
    if (!hasFocus) return const BoxDecoration();
    
    final color = focusColor ?? Theme.of(context).colorScheme.primary;
    
    return BoxDecoration(
      border: Border.all(
        color: color,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }

  /// Provide haptic feedback for user interactions
  static void provideFeedback({
    HapticFeedbackType type = HapticFeedbackType.selectionClick,
  }) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Check if device has accessibility features enabled
  static bool hasAccessibilityFeatures(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation || 
           mediaQuery.boldText ||
           mediaQuery.highContrast ||
           mediaQuery.textScaler.scale(14) > 14;
  }

  /// Get accessible text scale factor
  static double getAccessibleTextScale(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Create accessible button with proper semantics and touch targets
  static Widget createAccessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    required String semanticLabel,
    String? semanticHint,
    double minTouchTarget = recommendedTouchTargetSize,
  }) {
    return ensureTouchTarget(
      minSize: minTouchTarget,
      child: addSemantics(
        label: semanticLabel,
        hint: semanticHint,
        isButton: true,
        child: child,
      ),
    );
  }

  /// Create accessible text field with proper semantics
  static Widget createAccessibleTextField({
    required Widget child,
    required String label,
    String? hint,
    String? errorText,
    bool isRequired = false,
  }) {
    String fullLabel = label;
    if (isRequired) {
      fullLabel += ', 필수 입력';
    }
    if (errorText != null) {
      fullLabel += ', 오류: $errorText';
    }

    return addSemantics(
      label: fullLabel,
      hint: hint,
      isTextField: true,
      child: child,
    );
  }

  /// Get high contrast colors if accessibility requires it
  static ColorScheme getAccessibleColors(
    BuildContext context,
    ColorScheme originalColors,
  ) {
    final mediaQuery = MediaQuery.of(context);
    
    if (mediaQuery.highContrast) {
      // Return high contrast color scheme
      return ColorScheme.fromSeed(
        seedColor: originalColors.primary,
        brightness: originalColors.brightness,
        contrastLevel: 1.0, // Maximum contrast
      );
    }
    
    return originalColors;
  }

  /// Announce message to screen readers
  static void announceToScreenReader(
    BuildContext context,
    String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
}

/// Haptic feedback types for different interactions
enum HapticFeedbackType {
  lightImpact,
  mediumImpact, 
  heavyImpact,
  selectionClick,
}

/// Screen reader announcement assertiveness levels
enum Assertiveness {
  polite,
  assertive,
}