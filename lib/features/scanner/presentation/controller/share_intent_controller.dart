import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_intent_controller.g.dart';

@riverpod
class ShareIntentController extends _$ShareIntentController {
  @override
  FutureOr<void> build() {}

  Future<void> analyzeFile(XFile file) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(scannerViewModelProvider.notifier).analyzeSharedFile(file);
    });
  }
}
