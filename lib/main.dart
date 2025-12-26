import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final container = ProviderContainer();
  await container.read(firebaseAiServiceProvider).initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MealTrackApp(),
    ),
  );
}
