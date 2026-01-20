import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/scanner/data/receipt_repository.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scanner_viewmodel.g.dart';

@riverpod
class ScannerViewModel extends _$ScannerViewModel {
  @override
  Future<List<FridgeItem>> build() async {
    return [];
  }

  Future<void> analyzeImageFromPDF() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final filePicker = ref.read(filePickerProvider);
      final receiptRepository = ref.read(receiptRepositoryProvider);

      final FilePickerResult? result = await filePicker.pickFiles(
        allowedExtensions: ['pdf'],
        type: FileType.custom,
      );

      if (result != null) {
        final path = result.files.first.path;
        if (path == null) {
          throw const FormatException('NO_PDF_SELECTED');
        }
        if (!path.toLowerCase().endsWith('.pdf')) {
          throw const FormatException('NO_PDF_SELECTED');
        }

        return await receiptRepository.analyzePdfReceipt(XFile(path));
      } else {
        return <FridgeItem>[];
      }
    });
  }

  Future<void> analyzeImageFromCamera() =>
      _pickAndAnalyzeImage(ImageSource.camera);

  Future<void> analyzeImageFromGallery() =>
      _pickAndAnalyzeImage(ImageSource.gallery);

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
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
        return <FridgeItem>[];
      }

      return await receiptRepository.analyzeReceipt(image);
    });
  }

  Future<void> analyzeSharedFile(XFile file) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final receiptRepository = ref.read(receiptRepositoryProvider);

      final mimeType = lookupMimeType(file.path);
      final isPdf =
          mimeType == 'application/pdf' ||
          (mimeType == null && file.path.toLowerCase().endsWith('.pdf'));

      if (isPdf) {
        return await receiptRepository.analyzePdfReceipt(file);
      } else {
        return await receiptRepository.analyzeReceipt(file);
      }
    });
  }
}
