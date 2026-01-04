import 'package:flutter/material.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/features/startup/presentation/startup_page.dart';

class MealTrackApp extends StatelessWidget {
  const MealTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealTrack',
      theme: AppTheme.theme,
      home: const StartupPage(),
    );
  }
}
