import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/auth/presentation/login_page.dart';
import 'package:mealtrack/features/auth/presentation/register_page.dart';
import 'package:mealtrack/features/auth/provider/auth_providers.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.restaurant_menu, size: 80, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'MealTrack',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Text(AppLocalizations.login),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: Text(AppLocalizations.register),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(authRepositoryProvider)
                        .signInAnonymously();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${AppLocalizations.errorOccurred} $e')),
                      );
                    }
                  }
                },
                child: Text(AppLocalizations.continueAsGuest),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
