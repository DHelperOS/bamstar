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

  // Slots as TextStyle factories using a ColorScheme for color
  static TextStyle h1(ColorScheme cs, {String? fontFamily}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: cs.onSurface,
  );

  static TextStyle h2(ColorScheme cs, {String? fontFamily}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: cs.onSurface,
  );

  static TextStyle h3(ColorScheme cs, {String? fontFamily}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: cs.onSurface,
  );

  static TextStyle body(ColorScheme cs, {String? fontFamily}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: cs.onSurface,
  );

  static TextStyle lead(ColorScheme cs, {String? fontFamily}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: cs.onSurfaceVariant,
  );

  static TextStyle button(ColorScheme cs, {String? fontFamily}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: cs.onPrimary,
  );

  static TextStyle caption(ColorScheme cs, {String? fontFamily}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: cs.onSurfaceVariant,
  );

  static TextStyle emphasis(ColorScheme cs, {String? fontFamily}) =>
      body(cs, fontFamily: fontFamily).copyWith(fontWeight: FontWeight.w700);
}

extension AppTypographyX on BuildContext {
  String get _appFontFamily =>
      Theme.of(this).textTheme.bodyMedium?.fontFamily ?? 'Pretendard';
  TextStyle get h1 =>
      AppTypography.h1(Theme.of(this).colorScheme, fontFamily: _appFontFamily);
  TextStyle get h2 =>
      AppTypography.h2(Theme.of(this).colorScheme, fontFamily: _appFontFamily);
  TextStyle get h3 =>
      AppTypography.h3(Theme.of(this).colorScheme, fontFamily: _appFontFamily);
  TextStyle get bodyText => AppTypography.body(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
  TextStyle get lead => AppTypography.lead(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
  TextStyle get buttonText => AppTypography.button(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
  TextStyle get caption => AppTypography.caption(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
  TextStyle get emphasis => AppTypography.emphasis(
    Theme.of(this).colorScheme,
    fontFamily: _appFontFamily,
  );
}
