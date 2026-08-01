import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rezky_mobile_010826/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture screenshots', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Capture Login Screen
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('login_screen');

    // Perform Login
    final emailField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'Email',
    );
    final passwordField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'Password',
    );
    final loginButton = find.widgetWithText(ElevatedButton, 'Get Started');

    await tester.enterText(emailField, 'admin@test.com');
    await tester.enterText(passwordField, 'admin123');
    await tester.pumpAndSettle();

    await tester.tap(loginButton);
    
    // Wait for dashboard to load
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Capture Dashboard Screen
    await tester.pumpAndSettle();
    await binding.takeScreenshot('dashboard_screen');
  });
}
