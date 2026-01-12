import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/auth/presentation/auth_forgot_password_screen.dart';
import 'package:mealtrack/features/auth/presentation/guest_name_page.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/auth/presentation/auth_gate.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class MySignInScreen extends ConsumerWidget {
  const MySignInScreen({
    super.key,
    this.actions,
    this.showInventoryPageOnSuccess = true,
  });

  final List<FirebaseUIAction>? actions;
  final bool showInventoryPageOnSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SignInScreen(
        auth: auth,
        actions: [
          ForgotPasswordAction((context, email) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AuthForgotPasswordScreen(email: email),
              ),
            );
          }),
          AuthStateChangeAction<AuthFailed>((context, state) async {
            final l10n = AppLocalizations.of(context)!;
            final exception = state.exception;
            if (exception is FirebaseAuthException &&
                exception.code == 'credential-already-in-use') {
              final credential = exception.credential;
              if (credential != null && context.mounted) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.existingAccountFound),
                    content: Text(l10n.existingAccountFoundDescription),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.proceed),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  try {
                    await ref.read(firebaseAuthProvider).currentUser?.delete();
                    await ref
                        .read(firebaseAuthProvider)
                        .signInWithCredential(credential);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.signedInWithExistingAccount),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l10n.signInErrorPrefix}$e')),
                      );
                    }
                  }
                }
              }
            }
          }),
          if (showInventoryPageOnSuccess)
            AuthStateChangeAction((context, state) {
              final user = switch (state) {
                SignedIn(user: final user) => user,
                CredentialLinked(user: final user) => user,
                UserCreated(credential: final cred) => cred.user,
                _ => null,
              };

              if (user != null) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                  (route) => false,
                );
              }
            }),
          AuthStateChangeAction<UserCreated>((context, state) async {
            final user = state.credential.user;
            if (user != null && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GuestNamePage(user: user),
                ),
              );
            }
          }),
          ...?actions,
        ],
        styles: const {
          EmailFormStyle(signInButtonVariant: ButtonVariant.filled),
        },
        subtitleBuilder: (context, action) {
          final l10n = AppLocalizations.of(context)!;
          final actionText = switch (action) {
            AuthAction.signIn => l10n.signInSubtitle,
            AuthAction.signUp => l10n.signUpSubtitle,
            _ => throw Exception('Invalid action: $action'),
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(actionText),
          );
        },
        footerBuilder: (context, action) {
          final l10n = AppLocalizations.of(context)!;
          final actionText = switch (action) {
            AuthAction.signIn => l10n.signInAction,
            AuthAction.signUp => l10n.signUpAction,
            _ => throw Exception('Invalid action: $action'),
          };

          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                l10n.tosDisclaimer(actionText),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
