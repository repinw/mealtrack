import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<String?> build() async {
    return null;
  }

  Future<void> analyzeImageFromGallery() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final imagePicker = ref.read(imagePickerProvider);
      final firebaseAiService = ref.read(firebaseAiServiceProvider);

      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1500,
        imageQuality: 80,
      );

      if (image == null) {
        return null;
      }

      return await firebaseAiService.analyzeImageWithGemini(image);
    });
  }
}
