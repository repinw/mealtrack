import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/scanner/data/receipt_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  Future<List<FridgeItem>> build() async {
    return [];
  }

  Future<void> analyzeImageFromCamera() async {
    return _analyzeImageFromImage(ImageSource.camera);
  }

  Future<void> analyzeImageFromGallery() async {
    return _analyzeImageFromImage(ImageSource.gallery);
  }

  Future<void> _analyzeImageFromImage(ImageSource source) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final imagePicker = ref.read(imagePickerProvider);
      final receiptRepository = ref.read(receiptRepositoryProvider);

      final XFile? image = await imagePicker.pickImage(
        source: source,
        maxWidth: 1500,
        imageQuality: 80,
      );

      if (image == null) {
        return [];
      }

      return await receiptRepository.analyzeReceipt(image);
    });
  }
}
