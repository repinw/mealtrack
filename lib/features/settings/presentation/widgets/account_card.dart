import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';

class AccountCard extends ConsumerWidget {
  final User? user;
  final bool isGuest;
  final String? currentUserId;

  const AccountCard({
    super.key,
    required this.user,
    required this.isGuest,
    required this.currentUserId,
  });

  static const double _cardRadius = 20.0;
  static const double _buttonRadius = 8.0;
  static const Color _cardShadowColor = Colors.black;
  static const Color _textMutedColor = Color(0xFF6B7280);
  static const Color _buttonTextColor = Color(0xFF374151);

  static const List<Color> _avatarGradient = [
    Color(0xFF4F46E5),
    Color(0xFF2563EB),
  ];

  Future<void> _migrateUserData(
    WidgetRef ref,
    String? oldUserId,
    String? newUserId,
  ) async {
    if (oldUserId != null && newUserId != null && oldUserId != newUserId) {
      try {
        await ref
            .read(firestoreServiceProvider)
            .migrateGuestData(oldUserId, newUserId);
      } catch (e) {
        debugPrint("Migration failed: $e");
      }
    }
  }

  void _navigateToSignIn(
    BuildContext context,
    WidgetRef ref,
    String? oldUserId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text(AppLocalizations.signIn)),
          body: SignInScreen(
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) async {
                await _migrateUserData(ref, oldUserId, state.user?.uid);
                if (context.mounted) Navigator.of(context).pop();
              }),
              AuthStateChangeAction<UserCreated>((context, state) async {
                await _migrateUserData(
                  ref,
                  oldUserId,
                  state.credential.user?.uid,
                );
                if (context.mounted) Navigator.of(context).pop();
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginOptionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppLocalizations.loginDialogTitle),
        content: const Text(AppLocalizations.loginDialogContent),
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();

              await ref.read(firebaseAuthProvider).currentUser?.delete();

              if (navigator.mounted) {
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text(AppLocalizations.signIn),
                      ),
                      body: SignInScreen(
                        actions: [
                          AuthStateChangeAction<SignedIn>((context, state) {
                            Navigator.of(context).pop();
                          }),
                          AuthStateChangeAction<UserCreated>((context, state) {
                            Navigator.of(context).pop();
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
            child: const Text(AppLocalizations.existingAccount),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSignIn(context, ref, currentUserId);
            },
            child: const Text(AppLocalizations.linkAccount),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.profile)),
          body: ProfileScreen(
            actions: [
              SignedOutAction((context) async {
                await ref.read(firebaseAuthProvider).signInAnonymously();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: _cardShadowColor.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 20),
            _buildUserInfo(),
            const Spacer(),
            _buildActionButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: _avatarGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final displayName = isGuest
        ? AppLocalizations.guest
        : (user?.displayName ?? AppLocalizations.loggedIn);
    final userId = user?.uid.substring(0, 8) ?? AppLocalizations.unknown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 14,
            color: _textMutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "ID: $userId...",
          style: const TextStyle(
            fontSize: 13,
            color: _textMutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () {
        if (!isGuest) {
          _navigateToProfile(context, ref);
        } else {
          _showLoginOptionDialog(context, ref);
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        foregroundColor: _buttonTextColor,
      ),
      child: Text(
        isGuest ? AppLocalizations.login : (AppLocalizations.profile),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
