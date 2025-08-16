// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// 중앙화된 앱 테마와 텍스트 테마 제공
class AppTheme {
  // Font
  static const String fontFamily = 'Pretendard';

  // Light colors
  static const Color lightBackgroundColor = Color(0xFFF6F6FA);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  // Primary palette based on #B28BFF (soft lavender)
  static const Color lightPrimaryColor = Color(0xFFB28BFF); // base lavender
  // Slightly deeper / saturated variant for emphasis (buttons, chips)
  static const Color lightPrimaryVariantColor = Color(0xFF8F6BFF);
  static const Color lightTextColorPrimary = Color(0xFF2D3057);
  static const Color lightTextColorSecondary = Color(0xFF9B9CB5);

  // Dark colors
  static const Color darkBackgroundColor = Color(0xFF1C1B29);
  static const Color darkSurfaceColor = Color(0xFF2A2A3D);
  // Dark theme uses a slightly deeper primary to keep contrast
  static const Color darkPrimaryColor = Color(0xFF8F6BFF);
  static const Color darkPrimaryVariantColor = Color(0xFFB28BFF);
  static const Color darkTextColorPrimary = Color(0xFFE0E0E0);
  static const Color darkTextColorSecondary = Color(0xFF9B9CB5);

  // Light ColorScheme
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: lightPrimaryColor,
    // White text/icons on primary for better contrast on filled buttons
    onPrimary: Colors.white,
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
    onPrimary: Colors.white,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
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
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: lightPrimaryColor.withAlpha(31)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: lightPrimaryColor.withAlpha(31)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: lightPrimaryColor),
      ),
    ),
    // App-specific extra tokens (gradients, glow colors, alternate accents)
    extensions: <ThemeExtension<dynamic>>[
      const AppExtras(
        focusColor: AppTheme.lightPrimaryVariantColor,
        gradientStart: Color(0xFFF6F7FB),
        gradientEnd: AppTheme.lightPrimaryColor,
        glowColor: Color(0x33B28BFF),
        cherryPink: Color(0xFFFFB7C9),
      ),
    ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
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
    textTheme: _buildTextTheme(Brightness.dark),
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
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: darkPrimaryColor.withAlpha(31)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: darkPrimaryColor.withAlpha(31)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: darkPrimaryColor),
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      const AppExtras(
        focusColor: AppTheme.darkPrimaryColor,
        gradientStart: Color(0xFF15131A),
        gradientEnd: AppTheme.darkPrimaryColor,
        glowColor: Color(0x553F2BFF),
        cherryPink: Color(0xFFFFB7C9),
      ),
    ],
  );

  // Centralized text theme builder so font family and overrides live in one place
  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
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

// AppExtras: small ThemeExtension for auxiliary tokens (gradients, glow, accents)
@immutable
class AppExtras extends ThemeExtension<AppExtras> {
  final Color focusColor;
  final Color gradientStart;
  final Color gradientEnd;
  final Color glowColor;
  final Color cherryPink;

  const AppExtras({
    required this.focusColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.glowColor,
    required this.cherryPink,
  });

  @override
  AppExtras copyWith({
    Color? focusColor,
    Color? gradientStart,
    Color? gradientEnd,
    Color? glowColor,
    Color? cherryPink,
  }) {
    return AppExtras(
      focusColor: focusColor ?? this.focusColor,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      glowColor: glowColor ?? this.glowColor,
      cherryPink: cherryPink ?? this.cherryPink,
    );
  }

  @override
  AppExtras lerp(ThemeExtension<AppExtras>? other, double t) {
    if (other is! AppExtras) return this;
    return AppExtras(
      focusColor: Color.lerp(focusColor, other.focusColor, t) ?? focusColor,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t) ?? gradientStart,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t) ?? gradientEnd,
      glowColor: Color.lerp(glowColor, other.glowColor, t) ?? glowColor,
      cherryPink: Color.lerp(cherryPink, other.cherryPink, t) ?? cherryPink,
    );
  }

  // helper to read easily from BuildContext
  static AppExtras? of(BuildContext context) => Theme.of(context).extension<AppExtras>();
}
