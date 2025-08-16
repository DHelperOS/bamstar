# State management guidelines

Project policy (single source of truth)
-------------------------------------
- The canonical package versions for state management are declared in the project's `pubspec.yaml`.
- Use the versions listed there (for example, `flutter_riverpod` and `flutter_bloc`) instead of hardcoding versions inside docs.

Why this matters
-----------------
- `pubspec.yaml` is used by `flutter pub get` and CI to resolve dependencies. Keeping the guideline tied to it avoids drift between docs and actual builds.

Basic rules
-----------
- Wrap the app in `ProviderScope` in `main.dart`.
- Keep providers close to where state is needed; prefer `StateProvider` for simple primitives and `StateNotifierProvider`/`NotifierProvider` for complex state.
- Use `ConsumerWidget`/`ConsumerStatefulWidget` to read/watch providers inside widgets.
- For Bloc integration, keep BlocProviders at appropriate subtree levels and prefer Bloc for complex event-driven flows.

How to check the canonical versions
-----------------------------------
Open `pubspec.yaml` and look for the package entries. Example lines in this repo:

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  flutter_bloc: ^9.1.1
```

Use those versions when writing code, tests, or publishing examples in the repo.

Examples (use packages from `pubspec.yaml`)
-----------------------------------------

- Simple page index (Riverpod):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);
```

- Complex notifier (Riverpod):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExampleNotifier extends StateNotifier<ExampleState> {
  ExampleNotifier(): super(ExampleState.initial());
}
final exampleProvider = StateNotifierProvider<ExampleNotifier, ExampleState>((ref) => ExampleNotifier());
```

- Bloc usage example (use `flutter_bloc` declared in `pubspec.yaml`):

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class ExampleEvent {}
class ExampleState {}

class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  ExampleBloc(): super(ExampleState()) {
    on<ExampleEvent>((event, emit) {
      // event -> state
    });
  }
}
```

Automation and CI
-----------------
- CI should run `flutter pub get` and `flutter analyze` to ensure examples and code compile with declared package versions.

Notes
-----
- If you need to bump package versions, update `pubspec.yaml` first, run `flutter pub get`, then update examples/docs to match.
- Keep `dev/state_management_guidelines.md` as documentation; treat `pubspec.yaml` as the single source of truth for package versions.
