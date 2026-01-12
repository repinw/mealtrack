import 'package:flutter/material.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/sharing_card.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class SharingPage extends StatelessWidget {
  const SharingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sharing)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: const [SharingCard()],
      ),
    );
  }
}
