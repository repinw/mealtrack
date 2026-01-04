import 'package:flutter/material.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';

class AccountSectionHeader extends StatelessWidget {
  const AccountSectionHeader({super.key});

  static const Color _headingColor = Color(0xFF1F2937);

  static const Color _descriptionColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.account,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _headingColor,
          ),
        ),
        SizedBox(height: 6),
        Text(
          AppLocalizations.accountDescription,
          style: TextStyle(fontSize: 14, color: _descriptionColor),
        ),
      ],
    );
  }
}
