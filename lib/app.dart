import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/home/presentation/home_page.dart';
import 'package:mealtrack/features/scanner/service/text_recognition_service.dart';

class MealTrackApp extends StatelessWidget {
  final ImagePicker? imagePicker;
  final TextRecognitionService? textRecognitionService;

  const MealTrackApp({
    super.key,
    this.imagePicker,
    this.textRecognitionService,
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
        imagePicker: imagePicker ?? ImagePicker(),
        textRecognitionService:
            textRecognitionService ?? TextRecognitionService(),
      ),
    );
  }
}
