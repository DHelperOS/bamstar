// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bamstar/main.dart';

void main() {
  testWidgets('Onboarding renders and can navigate to Login via Skip', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Onboarding shows Skip button
    expect(find.text('건너뛰기'), findsOneWidget);

    // Tap Skip and navigate to LoginPage
    await tester.tap(find.text('건너뛰기'));
    await tester.pumpAndSettle();

    // Login page visible (check a reliable Korean copy on the screen)
    expect(find.text('카카오톡/구글로 간편하게 시작하세요.'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
  });
}
