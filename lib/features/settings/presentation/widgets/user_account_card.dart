import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/config/google_sign_in_config.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class UserAccountCard extends ConsumerWidget {
  const UserAccountCard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.userAccount,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person),
              title: Text(l10n.name),
              subtitle: Text(user.displayName ?? l10n.notAvailable),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email),
              title: Text(l10n.email),
              subtitle: Text(user.email ?? l10n.notAvailable),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.fingerprint),
              title: Text(l10n.id),
              subtitle: SelectableText(user.uid),
            ),
            const SizedBox(height: 16),
            if (!user.isAnonymous)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(firebaseAuthProvider).signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logout),
                ),
              ),
            if (!user.isAnonymous) const SizedBox(height: 8),
            if (!user.isAnonymous)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l10n.deleteAccountQuestion),
                        content: Text(l10n.deleteAccountWarning),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text(l10n.cancel),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(l10n.delete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await _deleteAccount(context, user, l10n);
                    }
                  },
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                  icon: const Icon(Icons.delete_forever),
                  label: Text(l10n.deleteAccount),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(
    BuildContext context,
    User user,
    AppLocalizations l10n,
  ) async {
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login' && context.mounted) {
        final result = await showReauthenticateDialog(
          context: context,
          providers: [
            EmailAuthProvider(),
            if (GoogleSignInConfig.clientId != null)
              GoogleProvider(
                clientId: GoogleSignInConfig.clientId!,
                scopes: ['email', 'profile'],
              ),
          ],
        );
        if (result && context.mounted) {
          try {
            await user.delete();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${l10n.deleteAccountError}$e')),
              );
            }
          }
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.deleteAccountError}$e')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.deleteAccountError}$e')));
      }
    }
  }
}
