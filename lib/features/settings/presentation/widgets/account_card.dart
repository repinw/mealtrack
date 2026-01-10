import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/auth/presentation/my_sign_in_screen.dart';
import 'package:mealtrack/features/settings/presentation/widgets/guest_mode_card.dart';
import 'package:mealtrack/features/settings/presentation/widgets/user_account_card.dart';
import 'package:mealtrack/features/settings/presentation/widgets/link_account_bottom_sheet.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/extensions/user_extension.dart';

class AccountCard extends ConsumerWidget {
  const AccountCard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (user.isAnonymous)
          GuestModeCard(
            onLinkAccount: () => _showLinkAccountOptions(context, ref, user),
          ),
        if (user.isAnonymous) const SizedBox(height: 16),
        UserAccountCard(user: user),
      ],
    );
  }

  void _showLinkAccountOptions(
    BuildContext context,
    WidgetRef ref,
    User currentUser,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => LinkAccountBottomSheet(
        onNewAccount: () {
          _navigateToSignInScreen(context, ref, currentUser);
        },
        onUseExistingAccount: () =>
            _handleUseExistingAccount(context, currentUser),
      ),
    );
  }

  void _navigateToSignInScreen(
    BuildContext context,
    WidgetRef ref,
    User currentUser,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MySignInScreen(
          showInventoryPageOnSuccess: false,
          mfaAction: AuthStateChangeAction<MFARequired>(
            (context, state) async {},
          ),
          actions: [
            AuthStateChangeAction<CredentialLinked>((context, state) async {
              await _handleAuthSuccess(context, state.user);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppLocalizations.linkAccountSuccess),
                  ),
                );
              }
            }),
            AuthStateChangeAction<SignedIn>((context, state) async {
              if (state.user != null) {
                await _handleAuthSuccess(context, state.user!);
              }
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUseExistingAccount(
    BuildContext context,
    User currentUser,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppLocalizations.warning),
        content: const Text(AppLocalizations.linkAccountExistingWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppLocalizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppLocalizations.proceed),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await currentUser.delete();
    }
  }

  Future<void> _handleAuthSuccess(BuildContext context, User user) async {
    await user.updateDisplayNameFromProvider();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
