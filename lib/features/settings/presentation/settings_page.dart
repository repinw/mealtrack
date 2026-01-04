import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/features/settings/presentation/widgets/account_card.dart';
import 'package:mealtrack/features/settings/presentation/widgets/account_section_header.dart';
import 'package:mealtrack/features/settings/presentation/widgets/settings_header.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);
    final user = userAsync.asData?.value;
    final isGuest = user?.isAnonymous ?? true;
    final currentUserId = user?.uid;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const SettingsHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AccountSectionHeader(),
                  const SizedBox(height: 20),
                  AccountCard(
                    user: user,
                    isGuest: isGuest,
                    currentUserId: currentUserId,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
