# BamStar Theme System

Complete color system implementation for the BamStar Flutter app with Material 3 support and comprehensive semantic color palette.

## 🎨 Architecture Overview

### Core Components

1. **AppColorPalette** (`app_color_palette.dart`)
   - Base color definitions matching design system
   - All colors defined as static constants for performance
   - Includes variations: lighter, light, main, dark, darker
   - Grey scale from 50-900

2. **AppColorSchemeExtension** (`app_color_scheme_extension.dart`)
   - Extends Flutter's ColorScheme with semantic colors
   - Provides access to info, success, warning, error variations
   - Helper methods for dynamic color calculation
   - Theme-aware text color utilities

3. **AppColorScheme** (`app_color_scheme.dart`)
   - Material 3 compatible ColorScheme factory
   - Light and dark theme variants
   - High contrast accessibility options
   - Harmonization support for dynamic theming

4. **AppTheme** (`app_theme.dart`)
   - Updated to use centralized color system
   - Complete widget theme definitions
   - Typography integration maintained

## 🌈 Color Palette

### Primary Colors
- **Lighter**: #EBD6FD (235, 214, 253)
- **Light**: #B985F4 (185, 133, 244)
- **Main**: #7635DC (118, 53, 220)
- **Dark**: #431A9E (67, 26, 158)
- **Darker**: #200A69 (32, 10, 105)

### Secondary Colors
- **Lighter**: #EFD6FF (239, 214, 255)
- **Light**: #C684FF (198, 132, 255)
- **Main**: #8E33FF (142, 51, 255)
- **Dark**: #5119B7 (81, 25, 183)
- **Darker**: #27097A (39, 9, 122)

### Semantic Colors

**Info**: Cyan/Teal variations (#CAFDF5 to #003768)
**Success**: Green variations (#D3FCD2 to #065E49)
**Warning**: Orange variations (#FFF5CC to #7A4100)
**Error**: Red variations (#FFE9D5 to #7A0916)

### Grey Scale
From Grey 50 (#FCFDFD) to Grey 900 (#141A21)

## 🚀 Usage Examples

### Basic Theme Colors
```dart
// Primary colors
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.primaryContainer
Theme.of(context).colorScheme.onPrimary

// Surface colors
Theme.of(context).colorScheme.surface
Theme.of(context).colorScheme.background
Theme.of(context).colorScheme.onSurface
```

### Semantic Colors (via Extension)
```dart
// Import the extension
import 'package:bamstar/theme/app_color_scheme_extension.dart';

// Use semantic colors
Theme.of(context).colorScheme.success
Theme.of(context).colorScheme.warning
Theme.of(context).colorScheme.error
Theme.of(context).colorScheme.info

// Color variations
Theme.of(context).colorScheme.successLight
Theme.of(context).colorScheme.warningDark
Theme.of(context).colorScheme.errorLighter
```

### Grey Scale
```dart
Theme.of(context).colorScheme.grey100
Theme.of(context).colorScheme.grey500
Theme.of(context).colorScheme.grey900
```

### Helper Methods
```dart
// Get appropriate text color for background
final textColor = Theme.of(context).colorScheme.getOnColor(backgroundColor);

// Access color variations
final successVariants = Theme.of(context).colorScheme.getSuccessVariants();
```

## ✨ Key Features

- **Material 3 Compatible**: Full compliance with Material 3 color system
- **Dark/Light Theme Support**: Optimized colors for both themes
- **Accessibility**: High contrast variants and proper contrast ratios
- **Type Safety**: Centralized color definitions prevent typos
- **Performance**: Static color constants for optimal performance
- **Extensible**: Easy to add new semantic colors
- **Modern Syntax**: Uses `withValues(alpha: ...)` instead of deprecated APIs

## 🔄 Migration Completed

The following changes were made across the codebase:

### Replaced Patterns
- `Color(0x...)` → `Theme.of(context).colorScheme.*`
- `Colors.*` → Theme references
- `withAlpha()` → `withValues(alpha: ...)`
- `withOpacity()` → `withValues(alpha: ...)`

### Updated Files
- Core UI components (buttons, fields, toasts)
- Community features (posts, actions)
- Authentication screens
- Onboarding flows

## 🎯 Best Practices

1. **Always use theme colors**: Never hardcode colors in widgets
2. **Import extension**: Add `app_color_scheme_extension.dart` for semantic colors
3. **Consider theme context**: Colors adapt automatically to light/dark themes
4. **Use semantic colors**: Choose appropriate semantic colors (success, warning, etc.)
5. **Test both themes**: Verify appearance in light and dark modes
6. **Accessibility**: Use high contrast variants when needed

## 📦 Integration

Add to your widget:

```dart
import 'package:bamstar/theme/app_color_scheme_extension.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      color: colors.surface,
      child: Text(
        'Hello World',
        style: TextStyle(color: colors.onSurface),
      ),
    );
  }
}
```

## 🔧 Customization

To add new semantic colors:

1. Add colors to `AppColorPalette`
2. Add getters to `AppColorSchemeExtension`  
3. Update `AppColorScheme` if needed for Material 3 integration
4. Test with both light and dark themes

---

**Theme System Status**: ✅ Complete
**Material 3 Compatibility**: ✅ Verified
**Accessibility Support**: ✅ Implemented
**Dark Theme Support**: ✅ Optimized