import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

import 'package:mealtrack/features/sharing/presentation/widgets/invite_section.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/join_section.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/members_section.dart';

class SharingCard extends ConsumerWidget {
  const SharingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(authStateChangesProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final members = ref.watch(householdMembersProvider).value ?? [];

    final isAnonymous = user?.isAnonymous ?? true;
    final isInHousehold = profile?.householdId != null;
    final isHost = !isInHousehold && !isAnonymous;
    final hasMembers = members.length > 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.sharing.toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            if (!isInHousehold && !hasMembers) ...[const JoinSection()],

            if (hasMembers) const MembersSection(),

            if (isHost) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              const InviteSection(),
            ] else if (isAnonymous && !isInHousehold) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.convertAccountToShare,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isInHousehold) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLeaveDialog(context, ref, l10n),
                  icon: const Icon(Icons.exit_to_app),
                  label: Text(l10n.leaveHousehold),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLeaveDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveHousehold),
        content: Text(l10n.leaveHouseholdConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(firestoreServiceProvider).leaveHousehold();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.errorLabel}$e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );
  }
}
