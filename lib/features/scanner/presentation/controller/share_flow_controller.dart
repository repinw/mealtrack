import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/service/share_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_flow_controller.freezed.dart';
part 'share_flow_controller.g.dart';

@freezed
class ShareFlowState with _$ShareFlowState {
  const factory ShareFlowState.initial() = _Initial;
  const factory ShareFlowState.confirmationPending(XFile file) =
      _ConfirmationPending;
  const factory ShareFlowState.analyzing() = _Analyzing;
  const factory ShareFlowState.success() = _Success;
  const factory ShareFlowState.error(Object error) = _Error;
}

@riverpod
class ShareFlowController extends _$ShareFlowController {
  @override
  ShareFlowState build() {
    ref.listen(latestSharedFileProvider, (previous, next) {
      if (next != null) {
        state = ShareFlowState.confirmationPending(next);
      }
    });

    return const ShareFlowState.initial();
  }

  Future<void> confirmScan() async {
    final currentState = state;
    if (currentState is! _ConfirmationPending) return;

    final file = currentState.file;
    state = const ShareFlowState.analyzing();

    try {
      await ref.read(scannerViewModelProvider.notifier).analyzeSharedFile(file);
      ref.read(latestSharedFileProvider.notifier).consume();

      state = const ShareFlowState.success();
    } catch (e) {
      state = ShareFlowState.error(e);
      ref.read(latestSharedFileProvider.notifier).consume();
    }
  }

  void cancelScan() {
    ref.read(latestSharedFileProvider.notifier).consume();
    state = const ShareFlowState.initial();
  }

  void errorHandled() {
    state = const ShareFlowState.initial();
  }

  void successHandled() {
    state = const ShareFlowState.initial();
  }
}
