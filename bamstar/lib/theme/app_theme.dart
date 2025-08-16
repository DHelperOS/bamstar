// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// 중앙화된 앱 테마와 텍스트 테마 제공
class AppTheme {
  // Font
  static const String fontFamily = 'Pretendard';

  // Light colors
  static const Color lightBackgroundColor = Color(0xFFF6F6FA);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightPrimaryColor = Color(0xFFC4A8FF);
  static const Color lightPrimaryVariantColor = Color(0xFF9479EA);
  static const Color lightTextColorPrimary = Color(0xFF2D3057);
  static const Color lightTextColorSecondary = Color(0xFF9B9CB5);

  // Dark colors
  static const Color darkBackgroundColor = Color(0xFF1C1B29);
  static const Color darkSurfaceColor = Color(0xFF2A2A3D);
  static const Color darkPrimaryColor = Color(0xFFA77DFF);
  static const Color darkPrimaryVariantColor = Color(0xFFC4A8FF);
  static const Color darkTextColorPrimary = Color(0xFFE0E0E0);
  static const Color darkTextColorSecondary = Color(0xFF9B9CB5);

  // Light ColorScheme
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
  primary: lightPrimaryColor,
  onPrimary: lightBackgroundColor,
    secondary: lightPrimaryVariantColor,
    onSecondary: lightTextColorPrimary,
  error: Colors.red.shade700,
  onError: Colors.white,
  surface: lightSurfaceColor,
  onSurface: lightTextColorPrimary,
  );

  // Dark ColorScheme
  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
  primary: darkPrimaryColor,
  onPrimary: lightBackgroundColor,
    secondary: darkPrimaryVariantColor,
    onSecondary: darkTextColorPrimary,
  error: Colors.red.shade400,
  onError: Colors.black,
  surface: darkSurfaceColor,
  onSurface: darkTextColorPrimary,
  );

  // Public ThemeData instances
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: lightBackgroundColor,
        cardColor: lightColorScheme.surface,
        cardTheme: const CardThemeData(
          color: lightSurfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBackgroundColor,
          foregroundColor: lightTextColorPrimary,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
        ),
        textTheme: _buildTextTheme(Brightness.light),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: lightSurfaceColor,
          selectedItemColor: lightPrimaryVariantColor,
          unselectedItemColor: lightTextColorSecondary,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: lightSurfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: lightSurfaceColor,
          disabledColor: lightSurfaceColor,
          selectedColor: lightPrimaryVariantColor.withAlpha(51),
          secondarySelectedColor: lightPrimaryColor.withAlpha(51),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          labelStyle: const TextStyle(color: lightTextColorPrimary),
          secondaryLabelStyle: const TextStyle(color: lightTextColorPrimary),
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightPrimaryVariantColor,
            foregroundColor: lightTextColorPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: lightPrimaryColor,
            side: BorderSide(color: lightPrimaryColor.withAlpha(31)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: darkBackgroundColor,
        cardColor: darkColorScheme.surface,
        cardTheme: const CardThemeData(
          color: darkSurfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackgroundColor,
          foregroundColor: darkTextColorPrimary,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary,
        ),
        textTheme: _buildTextTheme(Brightness.dark),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: darkSurfaceColor,
          selectedItemColor: darkPrimaryVariantColor,
          unselectedItemColor: darkTextColorSecondary,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: darkSurfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: darkSurfaceColor,
          disabledColor: darkSurfaceColor,
          selectedColor: darkPrimaryVariantColor.withAlpha(51),
          secondarySelectedColor: darkPrimaryColor.withAlpha(51),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          labelStyle: const TextStyle(color: darkTextColorPrimary),
          secondaryLabelStyle: const TextStyle(color: darkTextColorPrimary),
          brightness: Brightness.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPrimaryVariantColor,
            foregroundColor: darkTextColorPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: darkPrimaryColor,
            side: BorderSide(color: darkPrimaryColor.withAlpha(31)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  // Centralized text theme builder so font family and overrides live in one place
  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.light ? ThemeData.light().textTheme : ThemeData.dark().textTheme;
    return base.copyWith(
      bodySmall: base.bodySmall?.copyWith(fontFamily: fontFamily),
      bodyMedium: base.bodyMedium?.copyWith(fontFamily: fontFamily),
      bodyLarge: base.bodyLarge?.copyWith(fontFamily: fontFamily),
      headlineSmall: base.headlineSmall?.copyWith(fontFamily: fontFamily),
      headlineMedium: base.headlineMedium?.copyWith(fontFamily: fontFamily),
      headlineLarge: base.headlineLarge?.copyWith(fontFamily: fontFamily),
      titleMedium: base.titleMedium?.copyWith(fontFamily: fontFamily),
    );
  }
}
