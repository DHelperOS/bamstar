// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:bamstar/theme/typography.dart';
import 'app_color_scheme.dart';

// 중앙화된 앱 테마와 텍스트 테마 제공
class AppTheme {
  // Font
  static const String fontFamily = 'Pretendard';

  // Public ThemeData instances using new color system
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: AppColorScheme.light,
    // Use new color scheme for background colors
    canvasColor: AppColorScheme.light.surface,
    scaffoldBackgroundColor: AppColorScheme.light.background,
    cardColor: AppColorScheme.light.surface,
    textTheme: _buildAppTextTheme(AppColorScheme.light),
    cardTheme: CardThemeData(
      color: AppColorScheme.light.surface,
      elevation: 0, // remove elevation to prevent M3 surfaceTint blending
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorScheme.light.surface,
      foregroundColor: AppColorScheme.light.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0, // prevent M3 scroll-under tint overlay
      surfaceTintColor: Colors.transparent, // remove primary tint blending
      shadowColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColorScheme.light.primary,
      foregroundColor: AppColorScheme.light.onPrimary,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorScheme.light.surface,
      selectedItemColor: AppColorScheme.light.primary,
      unselectedItemColor: AppColorScheme.light.onSurfaceVariant,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorScheme.light.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColorScheme.light.surface,
      disabledColor: AppColorScheme.light.surfaceContainerHighest,
      selectedColor: AppColorScheme.light.primaryContainer,
      secondarySelectedColor: AppColorScheme.light.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelStyle: TextStyle(color: AppColorScheme.light.onSurface),
      secondaryLabelStyle: TextStyle(color: AppColorScheme.light.onSurface),
      brightness: Brightness.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorScheme.light.primary,
        foregroundColor: AppColorScheme.light.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorScheme.light.primary,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorScheme.light.primary,
        side: BorderSide(color: AppColorScheme.light.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.transparent, width: 0),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: AppColorScheme.light.primary,
      unselectedLabelColor: AppColorScheme.light.onSurfaceVariant,
      labelStyle: _buildAppTextTheme(AppColorScheme.light).bodyMedium,
      unselectedLabelStyle: _buildAppTextTheme(AppColorScheme.light).bodyMedium,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: AppColorScheme.dark,
    scaffoldBackgroundColor: AppColorScheme.dark.background,
    cardColor: AppColorScheme.dark.surface,
    textTheme: _buildAppTextTheme(AppColorScheme.dark),
    cardTheme: CardThemeData(
      color: AppColorScheme.dark.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorScheme.dark.surface,
      foregroundColor: AppColorScheme.dark.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColorScheme.dark.primary,
      foregroundColor: AppColorScheme.dark.onPrimary,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorScheme.dark.surface,
      selectedItemColor: AppColorScheme.dark.primary,
      unselectedItemColor: AppColorScheme.dark.onSurfaceVariant,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorScheme.dark.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColorScheme.dark.surface,
      disabledColor: AppColorScheme.dark.surfaceContainerHighest,
      selectedColor: AppColorScheme.dark.primaryContainer,
      secondarySelectedColor: AppColorScheme.dark.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelStyle: TextStyle(color: AppColorScheme.dark.onSurface),
      secondaryLabelStyle: TextStyle(color: AppColorScheme.dark.onSurface),
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorScheme.dark.primary,
        foregroundColor: AppColorScheme.dark.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorScheme.dark.primary,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorScheme.dark.primary,
        side: BorderSide(color: AppColorScheme.dark.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.transparent, width: 0),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: AppColorScheme.dark.primary,
      unselectedLabelColor: AppColorScheme.dark.onSurfaceVariant,
      labelStyle: _buildAppTextTheme(AppColorScheme.dark).bodyMedium,
      unselectedLabelStyle: _buildAppTextTheme(AppColorScheme.dark).bodyMedium,
    ),
  );

  /// High contrast theme for accessibility
  static ThemeData get lightHighContrast => lightTheme.copyWith(
    colorScheme: AppColorScheme.highContrast(Brightness.light),
  );

  static ThemeData get darkHighContrast => darkTheme.copyWith(
    colorScheme: AppColorScheme.highContrast(Brightness.dark),
  );

  // Centralized text theme builder using new typography system
  static TextTheme _buildAppTextTheme(ColorScheme cs) {
    // Map new typography system to Material text theme slots
    return TextTheme(
      // Display styles (largest text)
      displayLarge: AppTypography.displayLarge(cs, fontFamily: fontFamily),
      displayMedium: AppTypography.displayMedium(cs, fontFamily: fontFamily),
      displaySmall: AppTypography.displaySmall(cs, fontFamily: fontFamily),
      
      // Headline styles (section headings)
      headlineLarge: AppTypography.headlineLarge(cs, fontFamily: fontFamily),
      headlineMedium: AppTypography.headlineMedium(cs, fontFamily: fontFamily),
      headlineSmall: AppTypography.headlineSmall(cs, fontFamily: fontFamily),
      
      // Title styles (component titles)
      titleLarge: AppTypography.titleLarge(cs, fontFamily: fontFamily),
      titleMedium: AppTypography.titleMedium(cs, fontFamily: fontFamily),
      titleSmall: AppTypography.titleSmall(cs, fontFamily: fontFamily),
      
      // Body styles (main content)
      bodyLarge: AppTypography.bodyLarge(cs, fontFamily: fontFamily),
      bodyMedium: AppTypography.bodyMedium(cs, fontFamily: fontFamily),
      bodySmall: AppTypography.bodySmall(cs, fontFamily: fontFamily),
      
      // Label styles (buttons, form labels)
      labelLarge: AppTypography.labelLarge(cs, fontFamily: fontFamily),
      labelMedium: AppTypography.labelMedium(cs, fontFamily: fontFamily),
      labelSmall: AppTypography.labelSmall(cs, fontFamily: fontFamily),
    );
  }
}