# Color Refactoring Plan - BamStar Flutter App

## Overview
Systematically replace all hardcoded colors with theme references using the new centralized color system.

## New Color System Components
- **AppColorPalette**: Base color definitions
- **AppColorSchemeExtension**: Extensions on ColorScheme for semantic colors  
- **AppColorScheme**: Material 3 compatible color schemes
- **AppTheme**: Uses new color system

## Refactoring Guidelines

### Theme Color Mapping
- **Primary colors**: `Theme.of(context).colorScheme.primary`
- **Surface colors**: `Theme.of(context).colorScheme.surface`
- **Text colors**: `Theme.of(context).colorScheme.onSurface`
- **Success colors**: `Theme.of(context).colorScheme.success` (via extension)
- **Error colors**: `Theme.of(context).colorScheme.error`
- **Grey colors**: `Theme.of(context).colorScheme.grey500` (via extension)
- **Warning colors**: `Theme.of(context).colorScheme.warning` (via extension)

### Pattern Replacements
- `Color(0x...)` → appropriate theme color
- `Colors.white` → `Theme.of(context).colorScheme.surface` (context-dependent)
- `Colors.black` → `Theme.of(context).colorScheme.onSurface`
- `Colors.grey.shade300` → `Theme.of(context).colorScheme.grey300`
- `withOpacity()` → `withValues(alpha: ...)`
- `withAlpha()` → `withValues(alpha: ...)`

## Files Analysis Summary

### High Priority (Core UI Components)
1. **widgets/primary_text_button.dart** - Uses `Colors.white`, needs theme colors
2. **widgets/social_auth_button.dart** - Brand-specific colors (keep some), others to theme
3. **widgets/auth_fields.dart** - Multiple hardcoded colors, grey shades
4. **utils/global_toast.dart** - Uses hardcoded colors for backgrounds
5. **widgets/pull_refresh_indicator.dart** - Uses some hardcoded colors

### Medium Priority (Community Features)
6. **scenes/community/widgets/post_card.dart** - Uses `Colors.grey[300]`
7. **scenes/community/widgets/post_actions_menu.dart** - Uses `Colors.orange`, `Colors.red`

### Community-Specific Colors
- Most community widgets already use theme colors well
- PostCard uses `Colors.grey[300]` for placeholder
- PostActionsMenu uses hardcoded `Colors.orange` and `Colors.red` for toasts

### Low Priority
- Brand-specific social auth colors (Apple black, Google white, Facebook blue) should remain
- Some transparency/shadow effects can be kept as-is

## Implementation Strategy
1. Start with high-priority UI components
2. Replace simple hardcoded colors first
3. Update deprecated `withAlpha()` to `withValues(alpha: ...)`
4. Test theme switching after each file
5. Validate accessibility in both light/dark themes