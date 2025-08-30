# BamStar Code Style & Conventions

## MANDATORY Theme & Typography System

### ❌ NEVER USE:
- `Color(0xFF...)` - Hardcoded hex colors
- `Colors.*` - Direct Flutter color constants
- `TextStyle(fontSize: ..., fontWeight: ...)` - Hardcoded text styles
- Direct theme access: `Theme.of(context).textTheme.*`

### ✅ ALWAYS USE:

#### Colors
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
```

#### Typography
```dart
// Import required
import '../theme/app_text_styles.dart';

// Semantic Text Styles
AppTextStyles.pageTitle(context)      // Page headers
AppTextStyles.sectionTitle(context)   // Section headings
AppTextStyles.cardTitle(context)      // Card titles
AppTextStyles.primaryText(context)    // Main body text
AppTextStyles.secondaryText(context)  // Secondary text
AppTextStyles.buttonText(context)     // Button labels
```

## MANDATORY Toast Notification System

### ❌ NEVER USE:
- `ScaffoldMessenger.of(context).showSnackBar()`
- `SnackBar()` widget
- Direct delightful_toast calls

### ✅ ALWAYS USE:
```dart
// Import required
import '../utils/toast_helper.dart';

// Toast categories
ToastHelper.success(context, '프로필이 저장되었습니다');
ToastHelper.error(context, '저장 중 오류가 발생했습니다');
ToastHelper.warning(context, '로그인이 필요합니다');
ToastHelper.info(context, '검색을 실행합니다');
```

## File & Directory Structure

### Project Organization
```
lib/
├── scenes/           # UI pages/screens (by feature)
│   ├── community/    # Community feature pages
│   ├── member_profile/ # Profile management pages
│   └── auth/         # Authentication pages
├── providers/        # Riverpod providers (by domain)
│   ├── auth/         # Auth state management
│   ├── user/         # User data providers
│   └── community/    # Community providers
├── services/         # Business logic & API calls
├── models/           # Data models
├── widgets/          # Reusable UI components
├── utils/            # Helper functions
├── theme/            # Design system
└── main.dart         # App entry point
```

### Naming Conventions

#### Files & Directories
- **Files**: `snake_case.dart` (e.g., `user_profile_page.dart`)
- **Directories**: `snake_case` (e.g., `member_profile/`)
- **Classes**: `PascalCase` (e.g., `UserProfilePage`)
- **Variables/Functions**: `camelCase` (e.g., `getUserData`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `API_BASE_URL`)

#### Widget Naming
```dart
// Page/Screen widgets
class UserProfilePage extends StatefulWidget
class CommunityHomePage extends StatelessWidget

// Component widgets  
class ProfileImageWidget extends StatelessWidget
class PostCardWidget extends StatefulWidget

// Service classes
class UserService
class CommunityRepository
```

## State Management Patterns

### Riverpod Usage
```dart
// Provider definition
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

// Consumer usage
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Text(user?.name ?? 'Loading...');
  }
}
```

### BLoC Usage
```dart
// BLoC definition
class UserBloc extends Bloc<UserEvent, UserState> {
  // Implementation
}

// BlocBuilder usage
BlocBuilder<UserBloc, UserState>(
  builder: (context, state) {
    if (state is UserLoading) return CircularProgressIndicator();
    if (state is UserLoaded) return Text(state.user.name);
    return Container();
  },
)
```

## Import Organization

### Import Order
```dart
// 1. Flutter/Dart imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 2. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 3. Internal imports (relative)
import '../theme/app_text_styles.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
```

### Required Imports for Theme System
```dart
import '../theme/app_text_styles.dart';  // For typography
// ColorScheme accessed via Theme.of(context).colorScheme
```

## Code Quality Standards

### MANDATORY Quality Checks
```dart
// ❌ Code will be REJECTED if it contains:
Color(0xFFFFFFFF)                    // Use colorScheme.surface
Colors.white                         // Use colorScheme.surface
TextStyle(fontSize: 14)              // Use AppTextStyles.primaryText(context)
ScaffoldMessenger.showSnackBar()     // Use ToastHelper methods
```

### Flutter Analyze Requirements
- **CRITICAL**: All ERROR-level issues must be fixed
- **RECOMMENDED**: WARNING-level issues should be addressed
- **OPTIONAL**: INFO-level issues (style suggestions)

### Git Commit Standards
```bash
# Commit message format
type: brief description

# Types:
feat:     # New feature
fix:      # Bug fix
style:    # Code style changes
refactor: # Code refactoring
test:     # Adding tests
docs:     # Documentation changes
```

## UI/UX Guidelines

### Mobile-First Design
- Touch targets ≥44px
- Responsive layouts using MediaQuery
- Consider thumb-reach zones
- Optimize for single-handed use

### Accessibility
- Semantic text styles for screen readers
- Sufficient color contrast
- Touch target sizes
- Alternative text for images

### Material 3 Compliance
```dart
// Use Material 3 theme
ThemeData(useMaterial3: true)

// Consistent elevation and shadows
Material(
  elevation: 2,
  shadowColor: Theme.of(context).colorScheme.shadow,
)
```

## Error Handling Patterns

### Service Layer Error Handling
```dart
class UserService {
  Future<Result<User>> getUser(String id) async {
    try {
      final user = await apiCall(id);
      return Success(user);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
```

### UI Error Display
```dart
// Use Toast for user-facing errors
ToastHelper.error(context, '사용자 정보를 불러올 수 없습니다');

// Use proper error states
if (state is UserError) {
  return Column(
    children: [
      Icon(Icons.error, color: Theme.of(context).colorScheme.error),
      Text('오류가 발생했습니다', style: AppTextStyles.errorText(context)),
    ],
  );
}
```