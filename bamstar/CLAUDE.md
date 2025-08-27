# BamStar Flutter Development Guidelines

## 🎨 MANDATORY Theme & Typography System Usage

> **CRITICAL**: ALL Flutter code MUST use our centralized theme and typography system. Zero exceptions.

### **🚫 NEVER USE:**
- `Color(0x...)` - Hardcoded hex colors
- `Colors.*` - Direct Flutter color constants  
- `TextStyle(fontSize: ..., fontWeight: ...)` - Hardcoded text styles
- Direct theme access for text: `Theme.of(context).textTheme.*`

### **✅ ALWAYS USE:**

#### **Colors**
```dart
// Background Colors
Theme.of(context).colorScheme.surface
Theme.of(context).colorScheme.background

// Text Colors  
Theme.of(context).colorScheme.onSurface
Theme.of(context).colorScheme.onSurfaceVariant

// UI Element Colors
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.secondary
Theme.of(context).colorScheme.error
Theme.of(context).colorScheme.outline
Theme.of(context).colorScheme.shadow
```

#### **Typography**
```dart
// Semantic Text Styles (MANDATORY)
AppTextStyles.pageTitle(context)      // Page headers
AppTextStyles.sectionTitle(context)   // Section headings
AppTextStyles.cardTitle(context)      // Card titles
AppTextStyles.primaryText(context)    // Main body text
AppTextStyles.secondaryText(context)  // Secondary text
AppTextStyles.captionText(context)    // Small text
AppTextStyles.buttonText(context)     // Button labels
AppTextStyles.chipLabel(context)      // Chip labels
AppTextStyles.formLabel(context)      // Form labels
AppTextStyles.errorText(context)      // Error messages
AppTextStyles.dialogTitle(context)    // Dialog titles
```

---

## 🤖 AI Code Generation Rules

### **Pre-Generation Checks**
Before generating ANY Flutter code, verify:

1. ✅ **Color Check**: No `Color(0x...)` or `Colors.*` usage
2. ✅ **Typography Check**: No hardcoded `TextStyle(...)` 
3. ✅ **Theme Check**: Uses `colorScheme.*` for colors
4. ✅ **Semantic Check**: Uses `AppTextStyles.*` for text

### **Automatic Rejections**
AI MUST reject any code containing:
- `Color(0xFFFFFFFF)` → Use `colorScheme.surface`
- `Colors.white` → Use `colorScheme.surface`  
- `Colors.black` → Use `colorScheme.onSurface`
- `TextStyle(fontSize: 14)` → Use `AppTextStyles.primaryText(context)`

---

## 📂 Project Structure Context

### **Theme Files (Reference Only)**
- `lib/theme/app_theme.dart` - Central theme configuration
- `lib/theme/app_color_scheme.dart` - Color system
- `lib/theme/app_text_styles.dart` - Typography system
- `lib/theme/typography.dart` - Base typography definitions

### **Import Requirements**
Always include these imports when using theme system:
```dart
import '../theme/app_text_styles.dart'; // For typography
// ColorScheme accessed via Theme.of(context).colorScheme
```

---

## 🎯 Common UI Patterns

### **Container Styling**
```dart
// ✅ Correct
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Theme.of(context).colorScheme.outline,
    ),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

### **Text Widget Styling**
```dart
// ✅ Correct
Text(
  'Card Title',
  style: AppTextStyles.cardTitle(context),
)

Text(
  'Body content here',  
  style: AppTextStyles.primaryText(context),
)

Text(
  'Supporting info',
  style: AppTextStyles.secondaryText(context),
)
```

### **Button Styling**
```dart
// ✅ Correct
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
  ),
  child: Text(
    'Button Text',
    style: AppTextStyles.buttonText(context),
  ),
)
```

---

## 🔍 Code Review Standards

Every Flutter code change MUST pass this checklist:

- [ ] ❌ Zero hardcoded colors (`Color(0x...)`, `Colors.*`)
- [ ] ❌ Zero hardcoded text styles (`TextStyle(...)`) 
- [ ] ✅ All colors use `Theme.of(context).colorScheme.*`
- [ ] ✅ All text uses `AppTextStyles.*`
- [ ] ✅ Semantic meaning matches usage
- [ ] ✅ Supports light/dark theme switching
- [ ] ✅ Maintains accessibility standards

**⚠️ Any code failing these checks will be automatically rejected.**

---

## 📚 Quick Reference

| Need | Use |
|------|-----|
| White background | `colorScheme.surface` |
| Black text | `colorScheme.onSurface` |
| Gray text | `colorScheme.onSurfaceVariant` |
| Red error | `colorScheme.error` |
| Primary action | `colorScheme.primary` |
| Border | `colorScheme.outline` |
| Page title | `AppTextStyles.pageTitle(context)` |
| Body text | `AppTextStyles.primaryText(context)` |
| Small text | `AppTextStyles.captionText(context)` |
| Button text | `AppTextStyles.buttonText(context)` |

---

**🎯 Remember: Consistency is key to maintainable, accessible, and professional Flutter applications.**