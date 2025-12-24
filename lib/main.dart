import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mealtrack/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final imagePicker = ImagePicker();
  final firebaseAiService = FirebaseAiService();

  runApp(
    ProviderScope(
      child: MealTrackApp(
        imagePicker: imagePicker,
        firebaseAiService: firebaseAiService,
      ),
    ),
  );
}
