import 'package:flutter/material.dart';

/// Centralized color palette based on provided design system
/// All colors are defined here to ensure consistency across the app
class AppColorPalette {
  // Private constructor to prevent instantiation
  AppColorPalette._();

  // ===== PRIMARY COLORS =====
  static const Color primaryLighter = Color(0xFFEBD6FD); // #EBD6FD
  static const Color primaryLight = Color(0xFFB985F4);    // #B985F4
  static const Color primaryMain = Color(0xFF7635DC);     // #7635DC
  static const Color primaryDark = Color(0xFF431A9E);     // #431A9E
  static const Color primaryDarker = Color(0xFF200A69);   // #200A69

  // ===== SECONDARY COLORS =====
  static const Color secondaryLighter = Color(0xFFEFD6FF); // #EFD6FF
  static const Color secondaryLight = Color(0xFFC684FF);    // #C684FF
  static const Color secondaryMain = Color(0xFF8E33FF);     // #8E33FF
  static const Color secondaryDark = Color(0xFF5119B7);     // #5119B7
  static const Color secondaryDarker = Color(0xFF27097A);   // #27097A

  // ===== INFO COLORS =====
  static const Color infoLighter = Color(0xFFCAFDF5); // #CAFDF5
  static const Color infoLight = Color(0xFF61F3F3);   // #61F3F3
  static const Color infoMain = Color(0xFF00B8D9);    // #00B8D9
  static const Color infoDark = Color(0xFF006C9C);    // #006C9C
  static const Color infoDarker = Color(0xFF003768);  // #003768

  // ===== SUCCESS COLORS =====
  static const Color successLighter = Color(0xFFD3FCD2); // #D3FCD2
  static const Color successLight = Color(0xFF77ED8B);   // #77ED8B
  static const Color successMain = Color(0xFF22C55E);    // #22C55E
  static const Color successDark = Color(0xFF118D57);    // #118D57
  static const Color successDarker = Color(0xFF065E49);  // #065E49

  // ===== WARNING COLORS =====
  static const Color warningLighter = Color(0xFFFFF5CC); // #FFF5CC
  static const Color warningLight = Color(0xFFFFD666);   // #FFD666
  static const Color warningMain = Color(0xFFFFAB00);    // #FFAB00
  static const Color warningDark = Color(0xFFB76E00);    // #B76E00
  static const Color warningDarker = Color(0xFF7A4100);  // #7A4100

  // ===== ERROR COLORS =====
  static const Color errorLighter = Color(0xFFFFE9D5); // #FFE9D5
  static const Color errorLight = Color(0xFFFFAC82);   // #FFAC82
  static const Color errorMain = Color(0xFFFF5630);    // #FF5630
  static const Color errorDark = Color(0xFFB71D18);    // #B71D18
  static const Color errorDarker = Color(0xFF7A0916);  // #7A0916

  // ===== GREY COLORS =====
  static const Color grey50 = Color(0xFFFCFDFD);   // #FCFDFD
  static const Color grey100 = Color(0xFFF9FAFB);  // #F9FAFB
  static const Color grey200 = Color(0xFFF4F6F8);  // #F4F6F8
  static const Color grey300 = Color(0xFFDFE3E8);  // #DFE3E8
  static const Color grey400 = Color(0xFFC4CDD5);  // #C4CDD5
  static const Color grey500 = Color(0xFF919EAB);  // #919EAB
  static const Color grey600 = Color(0xFF637381);  // #637381
  static const Color grey700 = Color(0xFF454F5B);  // #454F5B
  static const Color grey800 = Color(0xFF1C252E);  // #1C252E
  static const Color grey900 = Color(0xFF141A21);  // #141A21

  // ===== SURFACE COLORS FOR LIGHT/DARK THEMES =====
  // Light theme surfaces
  static const Color lightBackground = grey50;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = grey100;

  // Dark theme surfaces
  static const Color darkBackground = grey900;
  static const Color darkSurface = grey800;
  static const Color darkSurfaceVariant = grey700;

  // ===== TEXT COLORS =====
  // Light theme text
  static const Color lightTextPrimary = grey800;
  static const Color lightTextSecondary = grey600;
  static const Color lightTextTertiary = grey500;

  // Dark theme text
  static const Color darkTextPrimary = grey100;
  static const Color darkTextSecondary = grey300;
  static const Color darkTextTertiary = grey400;
}

/// Helper class for accessing color variations
class AppColorVariants {
  final Color lighter;
  final Color light;
  final Color main;
  final Color dark;
  final Color darker;

  const AppColorVariants({
    required this.lighter,
    required this.light,
    required this.main,
    required this.dark,
    required this.darker,
  });

  static const AppColorVariants primary = AppColorVariants(
    lighter: AppColorPalette.primaryLighter,
    light: AppColorPalette.primaryLight,
    main: AppColorPalette.primaryMain,
    dark: AppColorPalette.primaryDark,
    darker: AppColorPalette.primaryDarker,
  );

  static const AppColorVariants secondary = AppColorVariants(
    lighter: AppColorPalette.secondaryLighter,
    light: AppColorPalette.secondaryLight,
    main: AppColorPalette.secondaryMain,
    dark: AppColorPalette.secondaryDark,
    darker: AppColorPalette.secondaryDarker,
  );

  static const AppColorVariants info = AppColorVariants(
    lighter: AppColorPalette.infoLighter,
    light: AppColorPalette.infoLight,
    main: AppColorPalette.infoMain,
    dark: AppColorPalette.infoDark,
    darker: AppColorPalette.infoDarker,
  );

  static const AppColorVariants success = AppColorVariants(
    lighter: AppColorPalette.successLighter,
    light: AppColorPalette.successLight,
    main: AppColorPalette.successMain,
    dark: AppColorPalette.successDark,
    darker: AppColorPalette.successDarker,
  );

  static const AppColorVariants warning = AppColorVariants(
    lighter: AppColorPalette.warningLighter,
    light: AppColorPalette.warningLight,
    main: AppColorPalette.warningMain,
    dark: AppColorPalette.warningDark,
    darker: AppColorPalette.warningDarker,
  );

  static const AppColorVariants error = AppColorVariants(
    lighter: AppColorPalette.errorLighter,
    light: AppColorPalette.errorLight,
    main: AppColorPalette.errorMain,
    dark: AppColorPalette.errorDark,
    darker: AppColorPalette.errorDarker,
  );
}