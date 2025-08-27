import 'package:flutter/material.dart';
import 'app_color_palette.dart';

/// Factory class for creating Material 3 compatible ColorSchemes
/// using our custom color palette
class AppColorScheme {
  // Private constructor to prevent instantiation
  AppColorScheme._();

  /// Light theme ColorScheme based on Material 3 specification
  static final ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    // Primary colors
    primary: AppColorPalette.primaryMain,
    onPrimary: Colors.white,
    primaryContainer: AppColorPalette.primaryLight,
    onPrimaryContainer: AppColorPalette.primaryDarker,
    
    // Secondary colors
    secondary: AppColorPalette.secondaryMain,
    onSecondary: Colors.white,
    secondaryContainer: AppColorPalette.secondaryLight,
    onSecondaryContainer: AppColorPalette.secondaryDarker,
    
    // Tertiary colors (using info colors)
    tertiary: AppColorPalette.infoMain,
    onTertiary: Colors.white,
    tertiaryContainer: AppColorPalette.infoLight,
    onTertiaryContainer: AppColorPalette.infoDarker,
    
    // Error colors
    error: AppColorPalette.errorMain,
    onError: Colors.white,
    errorContainer: AppColorPalette.errorLight,
    onErrorContainer: AppColorPalette.errorDarker,
    
    // Surface colors
    surface: AppColorPalette.lightSurface,
    onSurface: AppColorPalette.lightTextPrimary,
    surfaceContainerHighest: AppColorPalette.lightSurfaceVariant,
    onSurfaceVariant: AppColorPalette.lightTextSecondary,
    
    // Background (deprecated but still used in some widgets)
    // background: AppColorPalette.lightBackground,
    // onBackground: AppColorPalette.lightTextPrimary,
    
    // Outline colors
    outline: AppColorPalette.grey400,
    outlineVariant: AppColorPalette.grey300,
    
    // Shadow and scrim
    shadow: AppColorPalette.grey900.withValues(alpha: 0.1),
    scrim: AppColorPalette.grey900.withValues(alpha: 0.5),
    
    // Inverse colors for contrast
    inverseSurface: AppColorPalette.grey800,
    onInverseSurface: AppColorPalette.grey100,
    inversePrimary: AppColorPalette.primaryLight,
    
    // Surface tint (Material 3)
    surfaceTint: AppColorPalette.primaryMain,
  );

  /// Dark theme ColorScheme based on Material 3 specification
  static final ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    // Primary colors
    primary: AppColorPalette.primaryLight, // Lighter primary for dark theme
    onPrimary: AppColorPalette.primaryDarker,
    primaryContainer: AppColorPalette.primaryDark,
    onPrimaryContainer: AppColorPalette.primaryLighter,
    
    // Secondary colors
    secondary: AppColorPalette.secondaryLight, // Lighter secondary for dark theme
    onSecondary: AppColorPalette.secondaryDarker,
    secondaryContainer: AppColorPalette.secondaryDark,
    onSecondaryContainer: AppColorPalette.secondaryLighter,
    
    // Tertiary colors (using info colors)
    tertiary: AppColorPalette.infoLight,
    onTertiary: AppColorPalette.infoDarker,
    tertiaryContainer: AppColorPalette.infoDark,
    onTertiaryContainer: AppColorPalette.infoLighter,
    
    // Error colors
    error: AppColorPalette.errorLight, // Lighter error for dark theme
    onError: AppColorPalette.errorDarker,
    errorContainer: AppColorPalette.errorDark,
    onErrorContainer: AppColorPalette.errorLighter,
    
    // Surface colors
    surface: AppColorPalette.darkSurface,
    onSurface: AppColorPalette.darkTextPrimary,
    surfaceContainerHighest: AppColorPalette.darkSurfaceVariant,
    onSurfaceVariant: AppColorPalette.darkTextSecondary,
    
    // Background (deprecated but still used in some widgets)
    // background: AppColorPalette.darkBackground,
    // onBackground: AppColorPalette.darkTextPrimary,
    
    // Outline colors
    outline: AppColorPalette.grey500,
    outlineVariant: AppColorPalette.grey600,
    
    // Shadow and scrim
    shadow: AppColorPalette.grey900.withValues(alpha: 0.3),
    scrim: AppColorPalette.grey900.withValues(alpha: 0.7),
    
    // Inverse colors for contrast
    inverseSurface: AppColorPalette.grey200,
    onInverseSurface: AppColorPalette.grey800,
    inversePrimary: AppColorPalette.primaryMain,
    
    // Surface tint (Material 3)
    surfaceTint: AppColorPalette.primaryLight,
  );

  /// Creates a custom ColorScheme with harmonized colors
  /// Useful for dynamic theming or user customization
  static ColorScheme harmonized({
    required Brightness brightness,
    required Color primaryColor,
  }) {
    final baseScheme = brightness == Brightness.light ? light : dark;
    
    // Create harmonized version using Flutter's harmonization
    return baseScheme.copyWith(
      primary: primaryColor,
      // Add other harmonization logic here if needed
    );
  }

  /// Creates a high contrast version of the color scheme
  /// Useful for accessibility
  static ColorScheme highContrast(Brightness brightness) {
    if (brightness == Brightness.light) {
      return light.copyWith(
        primary: AppColorPalette.primaryDarker,
        secondary: AppColorPalette.secondaryDarker,
        outline: AppColorPalette.grey800,
        onSurface: AppColorPalette.grey900,
      );
    } else {
      return dark.copyWith(
        primary: AppColorPalette.primaryLighter,
        secondary: AppColorPalette.secondaryLighter,
        outline: AppColorPalette.grey200,
        onSurface: AppColorPalette.grey50,
      );
    }
  }
}