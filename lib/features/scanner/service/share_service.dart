import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService(ref);
});

class ShareService {
  final Ref _ref;
  StreamSubscription? _intentSub;

  ShareService(this._ref);

  void init(BuildContext context) {
    // 1. Listen to media shared while the app is in memory
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        _handleSharedFiles(context, value);
      },
      onError: (err) {
        debugPrint("getIntentDataStream error: $err");
      },
    );

    // 2. Get the media that opened the app (Cold start)
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> value,
    ) {
      _handleSharedFiles(context, value);
      ReceiveSharingIntent.instance.reset(); // Clear after handling
    });
  }

  void dispose() {
    _intentSub?.cancel();
  }

  Future<void> _handleSharedFiles(
    BuildContext context,
    List<SharedMediaFile> files,
  ) async {
    if (files.isEmpty) return;

    final file = files.first;
    final path = file.path;

    // Check if it's a valid file path
    if (path.isEmpty || !File(path).existsSync()) return;

    final scannerViewModel = _ref.read(scannerViewModelProvider.notifier);

    // Analyze the file (Image or PDF)
    final success = await scannerViewModel.analyzeFile(path);

    if (success && context.mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const ReceiptEditPage()));
    }
  }
}
