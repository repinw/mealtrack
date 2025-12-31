import 'package:flutter/material.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';

class MealTrackApp extends StatelessWidget {
  const MealTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealTrack',
      theme: AppTheme.theme,
      home: const InventoryPage(title: AppLocalizations.digitalFridge),
    );
  }
}
