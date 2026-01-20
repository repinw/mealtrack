import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_service.g.dart';

@Riverpod(keepAlive: true)
class ShareService extends _$ShareService {
  StreamSubscription? _intentSub;

  @override
  Future<void> build() async {
    // 1. Listen to media shared while the app is in memory
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          _handleSharedFiles(value);
        }
      },
      onError: (err) {
        debugPrint("getIntentDataStream error: $err");
      },
    );

    // 2. Handle media shared when the app is closed (cold start)
    final initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initialMedia.isNotEmpty) {
      _handleSharedFiles(initialMedia);
    }

    ref.onDispose(() {
      _intentSub?.cancel();
    });
  }

  Future<void> _handleSharedFiles(List<SharedMediaFile> files) async {
    // Take the first file for now
    final file = files.first;
    debugPrint("Shared file received: ${file.path} (${file.type})");

    ref.read(latestSharedFileProvider.notifier).state = XFile(file.path);
  }
}

// A simple provider to expose the latest shared file to the UI
@riverpod
class LatestSharedFile extends _$LatestSharedFile {
  @override
  XFile? build() => null;

  @override
  set state(XFile? newState) => super.state = newState;

  void consume() {
    state = null;
  }
}
