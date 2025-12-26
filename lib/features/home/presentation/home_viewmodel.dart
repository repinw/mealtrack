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

  Future<void> analyzeImageFromGallery() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final imagePicker = ref.read(imagePickerProvider);
      final receiptRepository = ref.read(receiptRepositoryProvider);

      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
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
