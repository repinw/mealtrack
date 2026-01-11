import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/auth/presentation/welcome_page.dart';
import 'package:mealtrack/features/settings/presentation/widgets/account_card.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: authState.when(
        data: (_) {
          final user = ref.read(firebaseAuthProvider).currentUser;
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false,
                );
              }
            });
            return const Center(child: CircularProgressIndicator());
          }
          return AccountCard(user: user);
        },
        error: (error, stackTrace) =>
            Center(child: Text('${l10n.errorLabel}$error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
