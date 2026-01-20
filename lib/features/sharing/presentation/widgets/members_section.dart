import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/models/user_profile.dart';
import 'package:mealtrack/features/sharing/data/household_repository.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class MembersSection extends ConsumerWidget {
  const MembersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final membersAsync = ref.watch(householdMembersProvider);
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    final profile = ref.watch(userProfileProvider).value;
    final isHost =
        profile?.householdId == null && !(profile?.isAnonymous ?? true);

    return membersAsync.when(
      data: (members) {
        if (members.length <= 1) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.householdMembers,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final member = members[index];
                final isMe = member.uid == currentUser?.uid;

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        (member.displayName ?? '?')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        member.displayName ?? l10n.notAvailable,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (isMe)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.you,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ),
                    if (isHost && !isMe)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: () =>
                            _showRemoveDialog(context, ref, member, l10n),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile member,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeMember),
        content: Text(l10n.removeMemberConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(householdRepositoryProvider)
                    .removeMember(member.uid);
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
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }
}
