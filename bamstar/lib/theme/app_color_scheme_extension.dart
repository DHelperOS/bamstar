import 'package:flutter/material.dart';
import 'app_color_palette.dart';

/// Extension on ColorScheme to add semantic colors (info, success, warning, error)
/// with variations for comprehensive color system
extension AppColorSchemeExtension on ColorScheme {
  // ===== INFO COLORS =====
  Color get infoLighter => AppColorPalette.infoLighter;
  Color get infoLight => AppColorPalette.infoLight;
  Color get info => AppColorPalette.infoMain;
  Color get infoDark => AppColorPalette.infoDark;
  Color get infoDarker => AppColorPalette.infoDarker;

  // ===== SUCCESS COLORS =====
  Color get successLighter => AppColorPalette.successLighter;
  Color get successLight => AppColorPalette.successLight;
  Color get success => AppColorPalette.successMain;
  Color get successDark => AppColorPalette.successDark;
  Color get successDarker => AppColorPalette.successDarker;

  // ===== WARNING COLORS =====
  Color get warningLighter => AppColorPalette.warningLighter;
  Color get warningLight => AppColorPalette.warningLight;
  Color get warning => AppColorPalette.warningMain;
  Color get warningDark => AppColorPalette.warningDark;
  Color get warningDarker => AppColorPalette.warningDarker;

  // ===== EXTENDED ERROR COLORS =====
  Color get errorLighter => AppColorPalette.errorLighter;
  Color get errorLight => AppColorPalette.errorLight;
  // error already exists in ColorScheme, but we can add variants
  Color get errorDark => AppColorPalette.errorDark;
  Color get errorDarker => AppColorPalette.errorDarker;

  // ===== PRIMARY EXTENDED COLORS =====
  Color get primaryLighter => AppColorPalette.primaryLighter;
  Color get primaryLight => AppColorPalette.primaryLight;
  // primary already exists in ColorScheme
  Color get primaryDark => AppColorPalette.primaryDark;
  Color get primaryDarker => AppColorPalette.primaryDarker;

  // ===== SECONDARY EXTENDED COLORS =====
  Color get secondaryLighter => AppColorPalette.secondaryLighter;
  Color get secondaryLight => AppColorPalette.secondaryLight;
  // secondary already exists in ColorScheme
  Color get secondaryDark => AppColorPalette.secondaryDark;
  Color get secondaryDarker => AppColorPalette.secondaryDarker;

  // ===== GREY SCALE =====
  Color get grey50 => AppColorPalette.grey50;
  Color get grey100 => AppColorPalette.grey100;
  Color get grey200 => AppColorPalette.grey200;
  Color get grey300 => AppColorPalette.grey300;
  Color get grey400 => AppColorPalette.grey400;
  Color get grey500 => AppColorPalette.grey500;
  Color get grey600 => AppColorPalette.grey600;
  Color get grey700 => AppColorPalette.grey700;
  Color get grey800 => AppColorPalette.grey800;
  Color get grey900 => AppColorPalette.grey900;

  // ===== SEMANTIC TEXT COLORS =====
  Color get textPrimary => brightness == Brightness.light 
    ? AppColorPalette.lightTextPrimary 
    : AppColorPalette.darkTextPrimary;
    
  Color get textSecondary => brightness == Brightness.light 
    ? AppColorPalette.lightTextSecondary 
    : AppColorPalette.darkTextSecondary;
    
  Color get textTertiary => brightness == Brightness.light 
    ? AppColorPalette.lightTextTertiary 
    : AppColorPalette.darkTextTertiary;

  // ===== HELPER METHODS =====
  
  /// Get appropriate text color for given background color
  Color getOnColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColorPalette.grey800 : AppColorPalette.grey100;
  }

  /// Get color variations for semantic colors
  AppColorVariants getInfoVariants() => AppColorVariants.info;
  AppColorVariants getSuccessVariants() => AppColorVariants.success;
  AppColorVariants getWarningVariants() => AppColorVariants.warning;
  AppColorVariants getErrorVariants() => AppColorVariants.error;
  AppColorVariants getPrimaryVariants() => AppColorVariants.primary;
  AppColorVariants getSecondaryVariants() => AppColorVariants.secondary;
}