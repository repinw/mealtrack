import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';

class UserAccountCard extends ConsumerWidget {
  const UserAccountCard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.userAccount,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person),
              title: const Text(AppLocalizations.name),
              subtitle: Text(user.displayName ?? AppLocalizations.notAvailable),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email),
              title: const Text(AppLocalizations.email),
              subtitle: Text(user.email ?? AppLocalizations.notAvailable),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.fingerprint),
              title: const Text(AppLocalizations.id),
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
                  label: const Text(AppLocalizations.logout),
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
                        title: const Text(
                          AppLocalizations.deleteAccountQuestion,
                        ),
                        content: const Text(
                          AppLocalizations.deleteAccountWarning,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text(AppLocalizations.cancel),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(AppLocalizations.delete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await _deleteAccount(context, user);
                    }
                  },
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text(AppLocalizations.deleteAccount),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, User user) async {
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login' && context.mounted) {
        final result = await showReauthenticateDialog(
          context: context,
          providers: [
            EmailAuthProvider(),
            GoogleProvider(
              clientId: googleClientId,
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
                SnackBar(
                  content: Text('${AppLocalizations.deleteAccountError}$e'),
                ),
              );
            }
          }
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.deleteAccountError}$e')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.deleteAccountError}$e')),
        );
      }
    }
  }
}
