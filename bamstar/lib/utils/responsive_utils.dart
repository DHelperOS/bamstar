import 'package:flutter/material.dart';

/// Responsive utility class for adaptive layouts and sizing
class ResponsiveUtils {
  // Breakpoint constants
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double wideBreakpoint = 1440;
  
  // Screen type detection
  static bool isMobile(BuildContext context) => 
    MediaQuery.of(context).size.width < tabletBreakpoint;
  
  static bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= tabletBreakpoint && 
    MediaQuery.of(context).size.width < desktopBreakpoint;
  
  static bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= desktopBreakpoint;
    
  static bool isWideDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= wideBreakpoint;
  
  // Adaptive sizing utilities
  static double getCardMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return double.infinity; // Full width on mobile
    } else if (width < desktopBreakpoint) {
      return 600; // Medium width on tablet
    } else if (width < wideBreakpoint) {
      return 800; // Large width on desktop
    } else {
      return 900; // Extra large on wide screens
    }
  }
  
  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 32;
    } else {
      return 48;
    }
  }
  
  static double getVerticalSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 24;
    } else {
      return 32;
    }
  }
  
  static double getLogoSize(BuildContext context) {
    if (isMobile(context)) {
      return 80;
    } else if (isTablet(context)) {
      return 100;
    } else {
      return 120;
    }
  }
  
  // Typography scaling
  static TextStyle getResponsiveTextStyle(
    BuildContext context, 
    TextStyle baseStyle, {
    double? mobileScale,
    double? tabletScale, 
    double? desktopScale,
  }) {
    double scale = 1.0;
    
    if (isMobile(context) && mobileScale != null) {
      scale = mobileScale;
    } else if (isTablet(context) && tabletScale != null) {
      scale = tabletScale;
    } else if (isDesktop(context) && desktopScale != null) {
      scale = desktopScale;
    }
    
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * scale,
    );
  }
  
  // Safe area utilities
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }
}