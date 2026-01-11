import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/auth/presentation/my_sign_in_screen.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';

class AuthSignInScreen extends ConsumerWidget {
  const AuthSignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mfaAction = AuthStateChangeAction<MFARequired>((
      context,
      state,
    ) async {
      final nav = Navigator.of(context);

      await startMFAVerification(resolver: state.resolver, context: context);

      nav.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const InventoryPage(title: 'MealTrack'),
        ),
        (route) => false,
      );
    });

    return MySignInScreen(mfaAction: mfaAction);
  }
}
