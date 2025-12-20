import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/core/config/bootstrap.dart';
import 'package:mealtrack/core/data/hive_initializer.dart';
import 'package:mealtrack/firebase_options.dart';
import 'package:mealtrack/shared/widgets/initialization_error_app.dart';

Future<void> main() async {
  // Stellt sicher, dass die Flutter-Engine initialisiert ist, bevor
  // plattformspezifischer Code (z.B. für den Dateisystemzugriff via path_provider) ausgeführt wird.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final isInitialized = await bootstrap(AppHiveInitializer());

  runApp(
    isInitialized
        ? ProviderScope(child: const MealTrack())
        : const InitializationErrorApp(),
  );
}
