# Theme & Typography System Audit and AI Guidelines

## 🔍 Current Usage Analysis

### ❌ Issues Found in community_home_page.dart and post_comment_page.dart

#### **Hardcoded Colors (High Priority Issues)**
1. **Background Colors**: `Color(0xFFFFFFFF)` instead of `Theme.of(context).colorScheme.surface`
2. **Text Colors**: `Color(0xFF1C252E)` instead of `Theme.of(context).colorScheme.onSurface`
3. **Border Colors**: `Color(0x0F919EAB)` instead of `Theme.of(context).colorScheme.outline`
4. **Surface Colors**: `Color(0x26919EAB)` instead of proper theme colors
5. **Shadow Colors**: `Color(0x08000000)` instead of `Theme.of(context).colorScheme.shadow`

#### **Direct Colors.* Usage**
- `Colors.white`, `Colors.black`, `Colors.red`, `Colors.grey` used extensively
- Should use theme-based colors: `colorScheme.surface`, `colorScheme.error`, etc.

#### **Hardcoded TextStyles**
- `TextStyle(fontSize: 12, fontWeight: FontWeight.w400)` 
- `TextStyle(color: Colors.white, fontSize: 14)`
- Should use `AppTextStyles.*` methods

#### **Mixed Approaches**
- Some places correctly use `AppTextStyles.primaryText(context)` 
- Others use `Theme.of(context).textTheme.bodyMedium`
- Inconsistent pattern creates maintenance issues

---

## ✅ Correct Theme & Typography System

### **Color System Hierarchy**
```dart
// ✅ ALWAYS USE - Primary Colors
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.onPrimary
Theme.of(context).colorScheme.secondary
Theme.of(context).colorScheme.onSecondary

// ✅ ALWAYS USE - Surface Colors  
Theme.of(context).colorScheme.surface
Theme.of(context).colorScheme.onSurface
Theme.of(context).colorScheme.surfaceContainerHighest
Theme.of(context).colorScheme.onSurfaceVariant

// ✅ ALWAYS USE - Status Colors
Theme.of(context).colorScheme.error
Theme.of(context).colorScheme.onError
Theme.of(context).colorScheme.outline
Theme.of(context).colorScheme.shadow
```

### **Typography System Hierarchy** 
```dart
// ✅ ALWAYS USE - Semantic Text Styles
AppTextStyles.pageTitle(context)         // Page headings
AppTextStyles.sectionTitle(context)      // Section headings  
AppTextStyles.cardTitle(context)         // Card titles
AppTextStyles.primaryText(context)       // Main body text
AppTextStyles.secondaryText(context)     // Secondary body text
AppTextStyles.captionText(context)       // Small descriptive text
AppTextStyles.buttonText(context)        // Button labels
AppTextStyles.chipLabel(context)         // Chip labels
AppTextStyles.dialogTitle(context)       // Dialog titles
AppTextStyles.errorText(context)         // Error messages
```

---

## 🤖 MANDATORY AI GUIDELINES

### **RULE 1: Zero Hardcoded Colors**
```dart
// ❌ NEVER DO THIS
Container(color: Color(0xFFFFFFFF))
Container(color: Colors.white)
Text('Hello', style: TextStyle(color: Color(0xFF000000)))

// ✅ ALWAYS DO THIS
Container(color: Theme.of(context).colorScheme.surface)
Text('Hello', style: AppTextStyles.primaryText(context))
```

### **RULE 2: Zero Hardcoded TextStyles** 
```dart
// ❌ NEVER DO THIS
Text('Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
Text('Body', style: TextStyle(color: Colors.black, fontSize: 14))

// ✅ ALWAYS DO THIS  
Text('Title', style: AppTextStyles.cardTitle(context))
Text('Body', style: AppTextStyles.primaryText(context))
```

### **RULE 3: Semantic Color Mapping**
| UI Element | Correct Theme Color |
|------------|-------------------|
| Page Background | `colorScheme.surface` |
| Card Background | `colorScheme.surface` |
| Primary Text | `colorScheme.onSurface` |
| Secondary Text | `colorScheme.onSurfaceVariant` |
| Borders | `colorScheme.outline` |
| Subtle Borders | `colorScheme.outlineVariant` |
| Error Elements | `colorScheme.error` |
| Primary Actions | `colorScheme.primary` |
| Shadows | `colorScheme.shadow` |

### **RULE 4: Semantic Typography Mapping**
| UI Element | Correct AppTextStyles |
|------------|---------------------|
| Page Headers | `AppTextStyles.pageTitle(context)` |
| Section Headers | `AppTextStyles.sectionTitle(context)` |
| Card Titles | `AppTextStyles.cardTitle(context)` |
| Main Body Text | `AppTextStyles.primaryText(context)` |
| Secondary Text | `AppTextStyles.secondaryText(context)` |
| Small Text/Captions | `AppTextStyles.captionText(context)` |
| Button Labels | `AppTextStyles.buttonText(context)` |
| Form Labels | `AppTextStyles.formLabel(context)` |
| Error Messages | `AppTextStyles.errorText(context)` |
| Dialog Titles | `AppTextStyles.dialogTitle(context)` |

---

## 🚨 AI ENFORCEMENT RULES

### **Before ANY Code Generation:**
1. ✅ **Check**: Does this use hardcoded `Color(0x...)` or `Colors.*`? → REJECT
2. ✅ **Check**: Does this use hardcoded `TextStyle(fontSize:...)`? → REJECT  
3. ✅ **Check**: Does this use `Theme.of(context).colorScheme.*`? → APPROVE
4. ✅ **Check**: Does this use `AppTextStyles.*`? → APPROVE

### **Color Selection Decision Tree:**
```
Need a color? 
├─ Background? → colorScheme.surface
├─ Text on background? → colorScheme.onSurface  
├─ Secondary text? → colorScheme.onSurfaceVariant
├─ Border? → colorScheme.outline
├─ Error state? → colorScheme.error
├─ Primary action? → colorScheme.primary
└─ Custom need? → Find closest semantic match or ask user
```

### **Typography Selection Decision Tree:**
```
Need text styling?
├─ Page title? → AppTextStyles.pageTitle(context)
├─ Section heading? → AppTextStyles.sectionTitle(context)  
├─ Card title? → AppTextStyles.cardTitle(context)
├─ Main content? → AppTextStyles.primaryText(context)
├─ Supporting text? → AppTextStyles.secondaryText(context)
├─ Button text? → AppTextStyles.buttonText(context)
├─ Form label? → AppTextStyles.formLabel(context)
├─ Error message? → AppTextStyles.errorText(context)
└─ Other? → Find closest semantic match or ask user
```

---

## 🎯 Migration Priority

### **High Priority (Fix Immediately)**
1. Replace all `Color(0x...)` with `colorScheme.*` 
2. Replace all `Colors.*` with `colorScheme.*`
3. Replace all `TextStyle(...)` with `AppTextStyles.*`

### **Medium Priority (Next Phase)**  
1. Ensure consistent semantic usage across all components
2. Add missing semantic styles for specialized use cases
3. Update component libraries to use theme system

### **Low Priority (Optimization)**
1. Performance optimization of theme calculations
2. Advanced theming features (dynamic colors, etc.)
3. Extended accessibility support

---

## 📝 Code Review Checklist

Before approving any Flutter code, verify:

- [ ] ❌ Zero instances of `Color(0x...)`
- [ ] ❌ Zero instances of `Colors.`
- [ ] ❌ Zero instances of `TextStyle(`
- [ ] ✅ All colors use `Theme.of(context).colorScheme.*`
- [ ] ✅ All text uses `AppTextStyles.*`
- [ ] ✅ Semantic meaning matches theme usage
- [ ] ✅ Code supports both light and dark themes
- [ ] ✅ Accessibility guidelines followed

---

## 🔧 Quick Fix Patterns

### **Color Fixes**
```dart
// Old → New
Color(0xFFFFFFFF) → Theme.of(context).colorScheme.surface
Color(0xFF1C252E) → Theme.of(context).colorScheme.onSurface
Color(0x0F919EAB) → Theme.of(context).colorScheme.outline
Colors.white → Theme.of(context).colorScheme.surface
Colors.black → Theme.of(context).colorScheme.onSurface
Colors.grey → Theme.of(context).colorScheme.onSurfaceVariant
Colors.red → Theme.of(context).colorScheme.error
```

### **Typography Fixes**
```dart
// Old → New
TextStyle(fontSize: 18, fontWeight: FontWeight.bold) → AppTextStyles.cardTitle(context)
TextStyle(fontSize: 14) → AppTextStyles.primaryText(context)
TextStyle(fontSize: 12) → AppTextStyles.captionText(context)
style: Theme.of(context).textTheme.bodyMedium → AppTextStyles.primaryText(context)
```

---

**⚠️ CRITICAL: This system MUST be used for ALL future Flutter development. No exceptions.**