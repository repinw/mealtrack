import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class AuthForgotPasswordScreen extends StatelessWidget {
  final String? email;

  const AuthForgotPasswordScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return ForgotPasswordScreen(email: email, headerMaxExtent: 200);
  }
}
