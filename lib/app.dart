import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mealtrack/core/router/app_router.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/features/auth/presentation/auth_gate.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/share_intent_listener.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class MealTrackApp extends ConsumerWidget {
  const MealTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: ref.watch(navigatorKeyProvider),
      title: 'MealTrack',
      theme: AppTheme.theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FirebaseUILocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthGate(),
      builder: (context, child) => ShareIntentListener(child: child!),
    );
  }
}
