import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_providers.g.dart';

@riverpod
ImagePicker imagePicker(Ref ref) {
  return ImagePicker();
}

@riverpod
FilePicker filePicker(Ref ref) {
  return FilePicker.platform;
}

@riverpod
FirebaseAiService firebaseAiService(Ref ref) {
  return FirebaseAiService();
}
