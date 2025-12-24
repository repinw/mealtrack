import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/home/presentation/home_page.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';

class MealTrackApp extends StatelessWidget {
  final ImagePicker imagePicker;
  final FirebaseAiService firebaseAiService;

  const MealTrackApp({
    super.key,
    required this.imagePicker,
    required this.firebaseAiService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(
        imagePicker: imagePicker,
        firebaseAiService: firebaseAiService,
      ),
    );
  }
}
