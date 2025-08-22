// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:bamstar/theme/typography.dart';

// 중앙화된 앱 테마와 텍스트 테마 제공
class AppTheme {
  // Font
  static const String fontFamily = 'Pretendard';

  // Light colors
  // Use pure white for light mode backgrounds to ensure consistent white background
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
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
    // Ensure a consistent background color across scrollable surfaces
    background: lightBackgroundColor,
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
  // CanvasColor affects many Material widgets (e.g., Drawer, Material)
  canvasColor: lightBackgroundColor,
  scaffoldBackgroundColor: lightBackgroundColor,
  // Note: avoid using surfaceTintColor directly to maintain SDK compatibility;
  // scaffoldBackgroundColor and canvasColor above enforce white background.
    cardColor: lightColorScheme.surface,
    textTheme: _buildAppTextTheme(lightColorScheme),
    cardTheme: const CardThemeData(
      color: lightSurfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      // Force AppBar background to pure white in light mode
      backgroundColor: Colors.white,
      foregroundColor: lightTextColorPrimary,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
    ),
    // Buttons & others will inherit from textTheme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightSurfaceColor,
      selectedItemColor: lightPrimaryVariantColor,
      unselectedItemColor: lightTextColorSecondary,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: lightSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
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
        // 모든 ElevatedButton의 텍스트/아이콘 색상을 흰색으로 일관되게 유지
        foregroundColor: Colors.white,
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
    // TabBar: remove default underline indicator and ensure selected label
    // color matches the app primary color.
    tabBarTheme: TabBarThemeData(
      // Explicitly hide the underline indicator by using a transparent
      // UnderlineTabIndicator which is stable across SDK versions.
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.transparent, width: 0),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      // Use the ColorScheme primary so selected tabs reflect the theme color
      labelColor: lightColorScheme.primary,
      unselectedLabelColor: lightTextColorSecondary,
      labelStyle: _buildAppTextTheme(lightColorScheme).bodyMedium,
      unselectedLabelStyle: _buildAppTextTheme(lightColorScheme).bodyMedium,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkColorScheme.surface,
    textTheme: _buildAppTextTheme(darkColorScheme),
    cardTheme: const CardThemeData(
      color: darkSurfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
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
    // Buttons & others will inherit from textTheme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: darkPrimaryVariantColor,
      unselectedItemColor: darkTextColorSecondary,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: darkSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
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
        // 다크 테마에서도 버튼 텍스트/아이콘은 흰색으로 고정
        foregroundColor: Colors.white,
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
    tabBarTheme: TabBarThemeData(
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.transparent, width: 0),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: darkColorScheme.primary,
      unselectedLabelColor: darkTextColorSecondary,
      labelStyle: _buildAppTextTheme(darkColorScheme).bodyMedium,
      unselectedLabelStyle: _buildAppTextTheme(darkColorScheme).bodyMedium,
    ),
  );

  // Centralized text theme builder so font family and overrides live in one place
  static TextTheme _buildAppTextTheme(ColorScheme cs) {
    // Map custom tokens to Material text slots for broad widget compatibility
    return TextTheme(
      displaySmall: AppTypography.h1(cs, fontFamily: fontFamily), // rarely used
      headlineLarge: AppTypography.h1(cs, fontFamily: fontFamily),
      headlineMedium: AppTypography.h2(cs, fontFamily: fontFamily),
      headlineSmall: AppTypography.h3(cs, fontFamily: fontFamily),
      titleLarge: AppTypography.h2(cs, fontFamily: fontFamily),
      titleMedium: AppTypography.h3(cs, fontFamily: fontFamily),
      titleSmall: AppTypography.lead(cs, fontFamily: fontFamily),
      bodyLarge: AppTypography.body(cs, fontFamily: fontFamily),
      bodyMedium: AppTypography.lead(cs, fontFamily: fontFamily),
      bodySmall: AppTypography.caption(cs, fontFamily: fontFamily),
      labelLarge: AppTypography.button(cs, fontFamily: fontFamily),
      labelMedium: AppTypography.caption(cs, fontFamily: fontFamily),
      labelSmall: AppTypography.caption(cs, fontFamily: fontFamily),
    );
  }
}
