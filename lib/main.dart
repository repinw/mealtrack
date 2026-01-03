import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    providerAndroid: AndroidDebugProvider(),
    providerApple: AppleDebugProvider(),
  );

  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MealTrackApp(),
    ),
  );
}
