# BamStar Typography System Guide

Complete typography system implementation for the BamStar Flutter app with Material 3 compliance and mobile optimization.

## 🎨 System Overview

### Architecture Components

1. **AppTypography** (`typography.dart`)
   - Material 3 compliant typography scale
   - Mobile-optimized font sizes and line heights
   - Semantic color integration
   - Legacy compatibility layer

2. **AppTypographyX Extension** (`typography.dart`)
   - Context-based easy access: `context.headlineLarge`
   - Semantic color variants: `context.bodyLargePrimary`
   - Theme-aware text colors
   - Legacy compatibility getters

3. **AppTextStyles** (`app_text_styles.dart`)
   - Pre-defined styles for common use cases
   - Semantic naming: `AppTextStyles.pageTitle(context)`
   - Status-specific variants: `errorText`, `successText`
   - Specialized contexts: `dialogTitle`, `navigationLabel`

4. **AppTextStyleUtils** (`app_text_styles.dart`)
   - Utility functions for style modifications
   - Bold, italic, underlined variants
   - Color and opacity adjustments
   - Scale factor applications

## 📐 Typography Scale (Material 3 Compliant)

### Display Styles (Largest Text)
- **Display Large**: 57px, Regular (3.5625rem) - Hero sections
- **Display Medium**: 45px, Regular (2.8125rem) - Feature highlights  
- **Display Small**: 36px, Regular (2.25rem) - Large announcements

### Headline Styles (Section Headings)
- **Headline Large**: 32px, SemiBold (2rem) - Page titles
- **Headline Medium**: 28px, SemiBold (1.75rem) - Section titles
- **Headline Small**: 24px, SemiBold (1.5rem) - Card titles

### Title Styles (Component Titles)
- **Title Large**: 22px, SemiBold (1.375rem) - List headers
- **Title Medium**: 16px, SemiBold (1rem) - Widget titles
- **Title Small**: 14px, SemiBold (0.875rem) - Small headers

### Body Styles (Content Text)
- **Body Large**: 16px, Regular (1rem) - Primary content
- **Body Medium**: 14px, Regular (0.875rem) - Secondary content
- **Body Small**: 12px, Regular (0.75rem) - Captions, metadata

### Label Styles (UI Elements)
- **Label Large**: 14px, SemiBold (0.875rem) - Buttons, form labels
- **Label Medium**: 12px, SemiBold (0.75rem) - Chips, small buttons
- **Label Small**: 11px, SemiBold (0.6875rem) - Tiny labels

## 🌈 Color System Integration

### Text Hierarchy Colors
```dart
// Primary text (highest emphasis)
AppTypography.textPrimary(colorScheme)           // onSurface

// Secondary text (medium emphasis)  
AppTypography.textSecondary(colorScheme)         // onSurfaceVariant

// Disabled text (lowest emphasis)
AppTypography.textDisabled(colorScheme)          // onSurface with 38% opacity
```

### Semantic Colors
```dart
// Brand colors
context.bodyLargePrimary     // Primary brand color
context.bodyLargeSecondary   // Secondary brand color

// Status colors (via extension)
AppTextStyles.successText(context)    // Success green
AppTextStyles.warningText(context)    // Warning orange  
AppTextStyles.infoText(context)       // Info blue
AppTextStyles.errorText(context)      // Error red
```

### Theme-Aware Colors
All text styles automatically adapt to light/dark themes through ColorScheme integration.

## 🚀 Usage Examples

### Basic Typography
```dart
import 'package:bamstar/theme/typography.dart';
import 'package:bamstar/theme/app_text_styles.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page title
        Text('Welcome', style: AppTextStyles.pageTitle(context)),
        
        // Section heading  
        Text('Latest Updates', style: context.headlineMedium),
        
        // Primary content
        Text('Content text here', style: context.bodyLarge),
        
        // Secondary info
        Text('Supporting details', style: context.bodyMediumSecondaryText),
        
        // Button text
        ElevatedButton(
          child: Text('Action', style: AppTextStyles.buttonText(context)),
          onPressed: () {},
        ),
      ],
    );
  }
}
```

### Semantic Color Variants
```dart
// Status messages
Text('Success!', style: AppTextStyles.successText(context))
Text('Warning notice', style: AppTextStyles.warningText(context))
Text('Error occurred', style: AppTextStyles.errorText(context))
Text('Information', style: AppTextStyles.infoText(context))

// Brand colors
Text('Brand title', style: context.titleLargePrimary)
Text('Featured content', style: context.bodyLargeSecondary)

// Disabled state
Text('Unavailable', style: context.bodyLargeDisabled)
```

### Style Modifications
```dart
import 'package:bamstar/theme/app_text_styles.dart';

// Make text bold
final boldStyle = AppTextStyleUtils.bold(context.bodyLarge);

// Add semantic color
final primaryStyle = AppTextStyleUtils.withSemanticColor(
  context.bodyLarge, 
  context, 
  'primary'
);

// Scale font size
final largerStyle = AppTextStyleUtils.scaled(context.bodyMedium, 1.2);

// Custom color
final customStyle = AppTextStyleUtils.withColor(
  context.bodyLarge, 
  Colors.purple
);
```

### Form and Input Styles
```dart
// Form labels
Text('Email Address', style: AppTextStyles.formLabel(context))

// Input text
TextField(
  style: AppTextStyles.inputText(context),
  decoration: InputDecoration(
    labelStyle: AppTextStyles.inputLabel(context),
    errorStyle: AppTextStyles.inputError(context),
    helperStyle: AppTextStyles.inputHelper(context),
  ),
)

// Helper text
Text('Enter valid email', style: AppTextStyles.helperText(context))

// Error text  
Text('Invalid input', style: AppTextStyles.errorText(context))
```

### Dialog and Navigation
```dart
// Dialog components
AlertDialog(
  title: Text('Confirm', style: AppTextStyles.dialogTitle(context)),
  content: Text('Are you sure?', style: AppTextStyles.dialogContent(context)),
  actions: [
    TextButton(
      child: Text('Cancel', style: AppTextStyles.dialogAction(context)),
      onPressed: () {},
    ),
  ],
)

// App bar
AppBar(
  title: Text('Page Title', style: AppTextStyles.appBarTitle(context)),
)

// Navigation
BottomNavigationBarItem(
  label: 'Home',  // Uses AppTextStyles.navigationLabel automatically
)

// Tab labels
Tab(
  child: Text('Tab 1', style: AppTextStyles.tabLabel(context)),
)
```

### List Items
```dart
ListTile(
  title: Text('Item title', style: AppTextStyles.listItemTitle(context)),
  subtitle: Text('Description', style: AppTextStyles.listItemSubtitle(context)),
  trailing: Text('Meta', style: AppTextStyles.listItemCaption(context)),
)
```

## 🔄 Migration Guide

### From Old System
```dart
// OLD - Hardcoded styles
Text('Title', style: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: Colors.black,
))

// NEW - Semantic styles
Text('Title', style: AppTextStyles.cardTitle(context))
// OR
Text('Title', style: context.titleLarge)
```

### Theme.of(context) Migration
```dart
// OLD
style: Theme.of(context).textTheme.bodyLarge

// NEW  
style: context.bodyLarge
// OR (more semantic)
style: AppTextStyles.primaryText(context)
```

### Legacy Compatibility
Deprecated methods are available during transition:
```dart
// Still works but deprecated
context.h1  // Use context.headlineSmall instead
context.h2  // Use context.titleLarge instead
context.bodyText  // Use context.bodyLarge instead
```

## 📱 Mobile Optimization Features

### Responsive Font Sizes
- Optimized for mobile screens (12px - 57px range)
- Proper line heights for readability (1.12 - 1.50)
- Appropriate letter spacing for Korean/English text

### Accessibility
- WCAG compliant contrast ratios
- Proper semantic hierarchy
- Support for system font scaling
- Dark theme optimization

### Performance
- Static TextStyle objects where possible  
- Efficient theme color resolution
- Minimal widget rebuilds

## 🛠️ Best Practices

### DO:
✅ Use semantic styles: `AppTextStyles.pageTitle(context)`  
✅ Use context extensions: `context.bodyLarge`  
✅ Apply semantic colors for status messages  
✅ Import required theme files  
✅ Test in both light and dark themes  

### DON'T:
❌ Hardcode font sizes or weights  
❌ Use direct color values for text  
❌ Mix different typography systems  
❌ Forget to import typography extensions  
❌ Skip testing theme switching  

### Performance Tips:
- Cache commonly used styles in build methods
- Use `const` constructors where possible
- Avoid creating new TextStyle objects unnecessarily

## 📊 Implementation Status

### ✅ Completed Files
- `onboarding_page.dart` - Complete semantic typography
- `login_page.dart` - AppTextStyles integration
- `post_card.dart` - Centralized typography system
- `auth_fields.dart` - Form text styles
- `social_auth_button.dart` - Button text styles
- Core typography system files

### 🔄 Migration Patterns Applied
- `TextStyle(fontSize: X, fontWeight: Y)` → `AppTextStyles.semanticName(context)`
- `Theme.of(context).textTheme.*` → `context.*` extensions
- Hardcoded colors → Semantic color variants

### 📈 Benefits Achieved
- **Consistency**: Unified typography across all components
- **Maintainability**: Central font management
- **Accessibility**: Better contrast and readability
- **Performance**: Optimized TextStyle objects
- **Theme Support**: Automatic light/dark adaptation
- **Mobile UX**: Optimized for mobile screens

---

**Typography System Status**: ✅ Implemented  
**Material 3 Compliance**: ✅ Certified  
**Mobile Optimization**: ✅ Optimized  
**Theme Integration**: ✅ Complete  
**Legacy Support**: ✅ Maintained