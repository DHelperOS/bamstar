import 'package:flutter/material.dart';

/// Design tokens for consistent spacing, sizing, and visual properties
/// across all screen sizes and components
class DesignTokens {
  // === SPACING SCALE ===
  static const double spacing2xs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;  
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacing2xl = 32.0;
  static const double spacing3xl = 48.0;
  static const double spacing4xl = 64.0;

  // === RESPONSIVE SPACING ===
  static EdgeInsets getCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return const EdgeInsets.all(spacing2xl); // 32px mobile
    } else if (width < 1024) {
      return const EdgeInsets.all(spacing3xl); // 48px tablet
    } else {
      return const EdgeInsets.all(spacing4xl); // 64px desktop
    }
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return const EdgeInsets.all(spacingLg); // 16px mobile
    } else if (width < 1024) {
      return const EdgeInsets.all(spacing2xl); // 32px tablet
    } else {
      return const EdgeInsets.all(spacing3xl); // 48px desktop
    }
  }

  static double getVerticalSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return spacingLg; // 16px mobile
    } else if (width < 1024) {
      return spacingXl; // 24px tablet
    } else {
      return spacing2xl; // 32px desktop
    }
  }

  // === BORDER RADIUS ===
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 9999.0;

  // === ELEVATION SHADOWS ===
  static List<BoxShadow> getShadow(String level) {
    switch (level) {
      case 'sm':
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
      case 'md':
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ];
      case 'lg':
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ];
      default:
        return [];
    }
  }

  // === ANIMATION DURATIONS ===
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // === CURVES ===
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;

  // === BUTTON DIMENSIONS ===
  static const double buttonHeightMobile = 56.0;
  static const double buttonHeightTablet = 60.0;
  static const double buttonHeightDesktop = 64.0;

  static double getButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return buttonHeightMobile;
    } else if (width < 1024) {
      return buttonHeightTablet;
    } else {
      return buttonHeightDesktop;
    }
  }

  // === INPUT FIELD DIMENSIONS ===
  static const double inputHeightMobile = 56.0;
  static const double inputHeightTablet = 60.0;
  static const double inputHeightDesktop = 64.0;

  static double getInputHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return inputHeightMobile;
    } else if (width < 1024) {
      return inputHeightTablet;
    } else {
      return inputHeightDesktop;
    }
  }

  // === LOGO SIZING ===
  static const double logoSizeMobile = 80.0;
  static const double logoSizeTablet = 100.0;
  static const double logoSizeDesktop = 120.0;

  static double getLogoSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return logoSizeMobile;
    } else if (width < 1024) {
      return logoSizeTablet;
    } else {
      return logoSizeDesktop;
    }
  }

  // === GLASSMORPHISM EFFECT ===
  static double getBlurRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return 20.0; // Mobile
    } else if (width < 1024) {
      return 24.0; // Tablet  
    } else {
      return 28.0; // Desktop
    }
  }

  static double getCardOpacity(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return 0.86; // Mobile
    } else if (width < 1024) {
      return 0.90; // Tablet
    } else {
      return 0.92; // Desktop
    }
  }

  // === CONTENT CONSTRAINTS ===
  static const double contentMaxWidthMobile = double.infinity;
  static const double contentMaxWidthTablet = 600.0;
  static const double contentMaxWidthDesktop = 800.0;
  static const double contentMaxWidthWide = 900.0;

  static double getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return contentMaxWidthMobile;
    } else if (width < 1024) {
      return contentMaxWidthTablet;
    } else if (width < 1440) {
      return contentMaxWidthDesktop;
    } else {
      return contentMaxWidthWide;
    }
  }

  // === Z-INDEX LAYERS ===
  static const int layerBase = 0;
  static const int layerCard = 1;
  static const int layerModal = 10;
  static const int layerOverlay = 50;
  static const int layerToast = 100;
}

/// Typography scale with responsive sizing
class ResponsiveTypography {
  static TextStyle getDisplayStyle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return const TextStyle(fontSize: 32, fontWeight: FontWeight.w900);
    } else if (width < 1024) {
      return const TextStyle(fontSize: 40, fontWeight: FontWeight.w900);
    } else {
      return const TextStyle(fontSize: 56, fontWeight: FontWeight.w900);
    }
  }

  static TextStyle getHeadlineStyle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return const TextStyle(fontSize: 24, fontWeight: FontWeight.w800);
    } else if (width < 1024) {
      return const TextStyle(fontSize: 28, fontWeight: FontWeight.w800);
    } else {
      return const TextStyle(fontSize: 32, fontWeight: FontWeight.w800);
    }
  }

  static TextStyle getTitleStyle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
    } else if (width < 1024) {
      return const TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
    } else {
      return const TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
    }
  }

  static TextStyle getBodyStyle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    } else if (width < 1024) {
      return const TextStyle(fontSize: 17, fontWeight: FontWeight.w400);
    } else {
      return const TextStyle(fontSize: 18, fontWeight: FontWeight.w400);
    }
  }

  static TextStyle getCaptionStyle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
    } else if (width < 1024) {
      return const TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
    } else {
      return const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    }
  }
}