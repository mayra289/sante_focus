// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:santefocus/main.dart';

void main() {
  testWidgets('Login page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login page elements are present.
    expect(find.text('Portail Patient'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
    expect(find.text('Email / Identifiant Santé'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);

    // Verify that the counter-specific elements are NOT present.
    expect(find.text('0'), findsNothing);
  });
}
