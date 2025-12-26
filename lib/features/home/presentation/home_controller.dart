import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';

class HomeController extends ChangeNotifier {
  final ImagePicker imagePicker;
  final FirebaseAiService firebaseAiService;

  HomeController({required this.imagePicker, required this.firebaseAiService});

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  Future<String?> analyzeImageFromGallery() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1500,
        imageQuality: 80,
      );

      if (image == null) {
        return null;
      }

      _isBusy = true;
      notifyListeners();

      return await firebaseAiService.analyzeImageWithGemini(image);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
