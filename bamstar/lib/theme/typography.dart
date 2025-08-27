import 'package:flutter/material.dart';

/// Global typography tokens for consistent text styles across the app.
///
/// Mapping (Pretendard):
/// - h1 (화면 타이틀): 24, w700
/// - h2 (섹션 제목):   20, w600
/// - h3 (문단 제목):   18, w600
/// - body (본문):      16, w400
/// - lead (부연):      14, w400
/// - button (버튼):    16, w600
/// - caption (캡션):   12, w400
/// - emphasis (강조):  body.bold
class AppTypography {
  const AppTypography._();

  // Font family constant
  static const String fontFamily = 'Pretendard';

  // ===== DISPLAY STYLES (가장 큰 텍스트) =====
  static TextStyle displayLarge(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 57,        // 3.5625rem (Material 3)
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,        // 64/57
    color: color ?? cs.onSurface,
  );

  static TextStyle displayMedium(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 45,        // 2.8125rem
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.16,        // 52/45
    color: color ?? cs.onSurface,
  );

  static TextStyle displaySmall(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 36,        // 2.25rem
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.22,        // 44/36
    color: color ?? cs.onSurface,
  );

  // ===== HEADLINE STYLES (주요 헤딩) =====
  static TextStyle headlineLarge(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 24,        // 1.5rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.33,        // 32/24
    color: color ?? cs.onSurface,
  );

  static TextStyle headlineMedium(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 22,        // 1.375rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.27,        // 28/22
    color: color ?? cs.onSurface,
  );

  static TextStyle headlineSmall(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 20,        // 1.25rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.40,        // 28/20
    color: color ?? cs.onSurface,
  );

  // ===== TITLE STYLES (섹션 제목) =====
  static TextStyle titleLarge(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 22,        // 1.375rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.27,        // 28/22
    color: color ?? cs.onSurface,
  );

  static TextStyle titleMedium(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 16,        // 1rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,        // 24/16
    color: color ?? cs.onSurface,
  );

  static TextStyle titleSmall(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 14,        // 0.875rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,        // 20/14
    color: color ?? cs.onSurface,
  );

  // ===== BODY STYLES (본문 텍스트) =====
  static TextStyle bodyLarge(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 16,        // 1rem
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.50,        // 24/16
    color: color ?? cs.onSurface,
  );

  static TextStyle bodyMedium(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 14,        // 0.875rem
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,        // 20/14
    color: color ?? cs.onSurface,
  );

  static TextStyle bodySmall(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 12,        // 0.75rem
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,        // 16/12
    color: color ?? cs.onSurface,
  );

  // ===== LABEL STYLES (레이블, 버튼 등) =====
  static TextStyle labelLarge(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 14,        // 0.875rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,        // 20/14
    color: color ?? cs.onSurface,
  );

  static TextStyle labelMedium(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 12,        // 0.75rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,        // 16/12
    color: color ?? cs.onSurface,
  );

  static TextStyle labelSmall(ColorScheme cs, {String? fontFamily, Color? color}) => TextStyle(
    fontFamily: fontFamily ?? AppTypography.fontFamily,
    fontSize: 11,        // 0.6875rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,        // 16/11
    color: color ?? cs.onSurface,
  );

  // ===== LEGACY COMPATIBILITY (기존 코드 호환성) =====
  @Deprecated('Use headlineSmall instead')
  static TextStyle h1(ColorScheme cs, {String? fontFamily}) => headlineSmall(cs, fontFamily: fontFamily);
  
  @Deprecated('Use titleLarge instead')
  static TextStyle h2(ColorScheme cs, {String? fontFamily}) => titleLarge(cs, fontFamily: fontFamily);
  
  @Deprecated('Use titleMedium instead')
  static TextStyle h3(ColorScheme cs, {String? fontFamily}) => titleMedium(cs, fontFamily: fontFamily);
  
  @Deprecated('Use titleSmall instead')
  static TextStyle h4(ColorScheme cs, {String? fontFamily}) => titleSmall(cs, fontFamily: fontFamily);
  
  @Deprecated('Use bodyLarge instead')
  static TextStyle body(ColorScheme cs, {String? fontFamily}) => bodyLarge(cs, fontFamily: fontFamily);
  
  @Deprecated('Use bodyMedium instead')
  static TextStyle lead(ColorScheme cs, {String? fontFamily}) => bodyMedium(cs, fontFamily: fontFamily);
  
  @Deprecated('Use labelLarge instead')
  static TextStyle button(ColorScheme cs, {String? fontFamily}) => labelLarge(cs, fontFamily: fontFamily);
  
  @Deprecated('Use bodySmall instead')
  static TextStyle caption(ColorScheme cs, {String? fontFamily}) => bodySmall(cs, fontFamily: fontFamily);
  
  @Deprecated('Use bodyLarge with bold weight instead')
  static TextStyle emphasis(ColorScheme cs, {String? fontFamily}) =>
      bodyLarge(cs, fontFamily: fontFamily).copyWith(fontWeight: FontWeight.w700);

  // ===== SEMANTIC COLOR VARIANTS =====

  // Text Primary (기본 텍스트)
  static Color textPrimary(ColorScheme cs) => cs.onSurface;
  
  // Text Secondary (보조 텍스트)
  static Color textSecondary(ColorScheme cs) => cs.onSurfaceVariant;
  
  // Text Disabled (비활성화 텍스트)
  static Color textDisabled(ColorScheme cs) => cs.onSurface.withValues(alpha: 0.38);

  // Primary Color Text
  static Color textOnPrimary(ColorScheme cs) => cs.onPrimary;
  
  // Secondary Color Text
  static Color textOnSecondary(ColorScheme cs) => cs.onSecondary;

  // ===== HELPER METHODS =====
  
  /// Get text color based on semantic meaning
  static Color getSemanticTextColor(ColorScheme cs, String semantic) {
    // Using extension colors from AppColorSchemeExtension
    switch (semantic.toLowerCase()) {
      case 'primary':
        return cs.primary;
      case 'secondary':
        return cs.secondary;
      case 'info':
        // Will use extension when available
        return const Color(0xFF00B8D9);
      case 'success':
        return const Color(0xFF22C55E);
      case 'warning':
        return const Color(0xFFFFAB00);
      case 'error':
        return cs.error;
      case 'disabled':
        return textDisabled(cs);
      default:
        return textPrimary(cs);
    }
  }

  /// Create text style with semantic color
  static TextStyle withSemanticColor(TextStyle baseStyle, ColorScheme cs, String semantic) {
    return baseStyle.copyWith(color: getSemanticTextColor(cs, semantic));
  }
}

extension AppTypographyX on BuildContext {
  String get _appFontFamily =>
      Theme.of(this).textTheme.bodyMedium?.fontFamily ?? AppTypography.fontFamily;

  // ===== DISPLAY STYLES =====
  TextStyle get displayLarge => AppTypography.displayLarge(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get displayMedium => AppTypography.displayMedium(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get displaySmall => AppTypography.displaySmall(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  // ===== HEADLINE STYLES =====
  TextStyle get headlineLarge => AppTypography.headlineLarge(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get headlineMedium => AppTypography.headlineMedium(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get headlineSmall => AppTypography.headlineSmall(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  // ===== TITLE STYLES =====
  TextStyle get titleLarge => AppTypography.titleLarge(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get titleMedium => AppTypography.titleMedium(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get titleSmall => AppTypography.titleSmall(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  // ===== BODY STYLES =====
  TextStyle get bodyLarge => AppTypography.bodyLarge(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get bodyMedium => AppTypography.bodyMedium(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get bodySmall => AppTypography.bodySmall(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  // ===== LABEL STYLES =====
  TextStyle get labelLarge => AppTypography.labelLarge(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get labelMedium => AppTypography.labelMedium(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  TextStyle get labelSmall => AppTypography.labelSmall(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );

  // ===== SEMANTIC COLOR VARIANTS =====

  // Primary color text styles
  TextStyle get displayLargePrimary => displayLarge.copyWith(
    color: Theme.of(this).colorScheme.primary,
  );
  TextStyle get headlineLargePrimary => headlineLarge.copyWith(
    color: Theme.of(this).colorScheme.primary,
  );
  TextStyle get titleLargePrimary => titleLarge.copyWith(
    color: Theme.of(this).colorScheme.primary,
  );
  TextStyle get bodyLargePrimary => bodyLarge.copyWith(
    color: Theme.of(this).colorScheme.primary,
  );

  // Secondary color text styles
  TextStyle get displayLargeSecondary => displayLarge.copyWith(
    color: Theme.of(this).colorScheme.secondary,
  );
  TextStyle get headlineLargeSecondary => headlineLarge.copyWith(
    color: Theme.of(this).colorScheme.secondary,
  );
  TextStyle get titleLargeSecondary => titleLarge.copyWith(
    color: Theme.of(this).colorScheme.secondary,
  );
  TextStyle get bodyLargeSecondary => bodyLarge.copyWith(
    color: Theme.of(this).colorScheme.secondary,
  );

  // Text hierarchy colors
  TextStyle get bodyLargeSecondaryText => bodyLarge.copyWith(
    color: AppTypography.textSecondary(Theme.of(this).colorScheme),
  );
  TextStyle get bodyMediumSecondaryText => bodyMedium.copyWith(
    color: AppTypography.textSecondary(Theme.of(this).colorScheme),
  );
  TextStyle get bodySmallSecondaryText => bodySmall.copyWith(
    color: AppTypography.textSecondary(Theme.of(this).colorScheme),
  );

  // Disabled text styles
  TextStyle get bodyLargeDisabled => bodyLarge.copyWith(
    color: AppTypography.textDisabled(Theme.of(this).colorScheme),
  );
  TextStyle get bodyMediumDisabled => bodyMedium.copyWith(
    color: AppTypography.textDisabled(Theme.of(this).colorScheme),
  );
  TextStyle get labelLargeDisabled => labelLarge.copyWith(
    color: AppTypography.textDisabled(Theme.of(this).colorScheme),
  );

  // Error text styles
  TextStyle get bodyLargeError => bodyLarge.copyWith(
    color: Theme.of(this).colorScheme.error,
  );
  TextStyle get bodyMediumError => bodyMedium.copyWith(
    color: Theme.of(this).colorScheme.error,
  );
  TextStyle get labelLargeError => labelLarge.copyWith(
    color: Theme.of(this).colorScheme.error,
  );

  // ===== HELPER METHODS =====

  /// Get text style with semantic color
  TextStyle getSemanticStyle(String styleType, String semantic) {
    final ColorScheme cs = Theme.of(this).colorScheme;
    
    // Get base style
    TextStyle baseStyle;
    switch (styleType.toLowerCase()) {
      case 'display-large':
        baseStyle = displayLarge;
        break;
      case 'headline-large':
        baseStyle = headlineLarge;
        break;
      case 'title-large':
        baseStyle = titleLarge;
        break;
      case 'body-large':
        baseStyle = bodyLarge;
        break;
      case 'body-medium':
        baseStyle = bodyMedium;
        break;
      case 'label-large':
        baseStyle = labelLarge;
        break;
      default:
        baseStyle = bodyLarge;
    }
    
    return AppTypography.withSemanticColor(baseStyle, cs, semantic);
  }

  // ===== LEGACY COMPATIBILITY =====
  @Deprecated('Use headlineSmall instead')
  TextStyle get h1 => AppTypography.h1(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );
  
  @Deprecated('Use titleLarge instead')
  TextStyle get h2 => AppTypography.h2(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );
  
  @Deprecated('Use titleMedium instead')
  TextStyle get h3 => AppTypography.h3(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );
  
  @Deprecated('Use titleSmall instead')
  TextStyle get h4 => AppTypography.h4(
    Theme.of(this).colorScheme, 
    fontFamily: _appFontFamily,
  );
  
  @Deprecated('Use bodyLarge instead')
  TextStyle get bodyText => AppTypography.body(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
  
  @Deprecated('Use bodyMedium instead')
  TextStyle get lead => AppTypography.lead(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
  
  @Deprecated('Use labelLarge instead')
  TextStyle get buttonText => AppTypography.button(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
  
  @Deprecated('Use bodySmall instead')
  TextStyle get caption => AppTypography.caption(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
  
  @Deprecated('Use bodyLarge with bold weight instead')
  TextStyle get emphasis => AppTypography.emphasis(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
}
