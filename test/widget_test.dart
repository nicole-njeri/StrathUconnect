// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:strathapp/main.dart';
import 'package:strathapp/screens/login_screen.dart';

void main() {
  testWidgets('App starts and shows LoginScreen or loading state', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StrathUConnectApp());

    // Since the app uses a StreamBuilder for auth state, it might show a loading indicator first.
    // We'll pump and settle to allow the stream to emit a value.
    await tester.pumpAndSettle();

    // After settling, since there's no logged-in user in a test environment,
    // we expect to see the LoginScreen. A simple check for a widget known
    // to be on the LoginScreen is sufficient. For example, a text field or button.
    // Let's assume LoginScreen has a text 'Login'.
    // If your LoginScreen has different widgets, adjust the finder accordingly.
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
