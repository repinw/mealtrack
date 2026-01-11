import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/auth_forgot_password_screen.dart';

void main() {
  testWidgets(
    'AuthForgotPasswordScreen renders ForgotPasswordScreen with correct email',
    (tester) async {
      const email = 'test@example.com';

      await tester.pumpWidget(
        const MaterialApp(home: AuthForgotPasswordScreen(email: email)),
      );

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      final widget = tester.widget<ForgotPasswordScreen>(
        find.byType(ForgotPasswordScreen),
      );
      expect(widget.email, email);
      expect(widget.headerMaxExtent, 200);
    },
  );
}
