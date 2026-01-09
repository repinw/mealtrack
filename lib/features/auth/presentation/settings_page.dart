import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/auth/provider/auth_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthError(dynamic error,
      Future<void> Function() retryMethod, String providerId) async {
    if (error is FirebaseAuthException &&
        error.code == 'credential-already-in-use') {
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.accountConflict),
          content: Text(AppLocalizations.accountConflictMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.switchAccount),
            ),
          ],
        ),
      );

      if (shouldSwitch == true && mounted) {
        setState(() => _isLoading = true);
        try {
          await ref.read(authRepositoryProvider).signOut();
          // After sign out, sign in with the target provider logic
          // Since we can't easily capture the credential here without more complex logic,
          // the simplest approach is to ask user to sign in again.
          // Or we could try to implement 'signInWithCredential' if we had the credential.
          // But for now, let's just sign out and let the user log in from Welcome page.
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } catch (e) {
            // handle error
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.errorOccurred} $error')),
        );
      }
    }
  }

  Future<void> _upgradeToEmail() async {
    setState(() => _isLoading = true);
    try {
        // Show dialog to get email/pass
      final result = await showDialog<List<String>>(
        context: context,
        builder: (context) {
          final emailController = TextEditingController();
          final passwordController = TextEditingController();
          return AlertDialog(
            title: Text(AppLocalizations.createAccount),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: AppLocalizations.email),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: AppLocalizations.password),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pop([emailController.text, passwordController.text]),
                child: Text(AppLocalizations.save),
              ),
            ],
          );
        },
      );

      if (result != null && result.length == 2) {
        await ref
            .read(authRepositoryProvider)
            .upgradeAnonymousToEmail(result[0], result[1]);
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account upgraded successfully')),
            );
        }
      }
    } catch (e) {
      await _handleAuthError(e, _upgradeToEmail, 'password');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _upgradeToGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).upgradeAnonymousToGoogle();
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account linked with Google')),
          );
      }
    } catch (e) {
      await _handleAuthError(e, _upgradeToGoogle, 'google.com');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.errorOccurred} $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(AppLocalizations.accountStatus),
              subtitle: Text(isAnonymous
                  ? AppLocalizations.guestAccount
                  : AppLocalizations.registeredAccount),
              trailing: Icon(isAnonymous ? Icons.person_outline : Icons.person),
            ),
            if (isAnonymous) ...[
              const SizedBox(height: 24),
              Text(
                AppLocalizations.upgradeAccount,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _upgradeToEmail,
                child: Text(AppLocalizations.createAccount),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _upgradeToGoogle,
                icon: const Icon(Icons.link),
                label: Text(AppLocalizations.linkWithGoogle),
              ),
            ],
            const Spacer(),
            OutlinedButton(
              onPressed: _isLoading ? null : _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: Text(AppLocalizations.logout),
            ),
          ],
        ),
      ),
    );
  }
}
