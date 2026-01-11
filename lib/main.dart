import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/core/config/firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupFirebase();

  runApp(const ProviderScope(child: MealTrackApp()));
}
