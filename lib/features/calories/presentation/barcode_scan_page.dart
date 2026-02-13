import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/theme/calories_theme.dart';
import 'package:mealtrack/features/calories/data/open_food_facts_service.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum BarcodeNoResultAction { manualEntry, ocrFromCamera }

class BarcodeLookupResult {
  final String barcode;
  final List<OffProductCandidate> candidates;
  final BarcodeNoResultAction? noResultAction;

  const BarcodeLookupResult({
    required this.barcode,
    required this.candidates,
    this.noResultAction,
  });

  bool get hasSingleCandidate => candidates.length == 1;
  bool get hasMultipleCandidates => candidates.length > 1;
  bool get hasNoCandidates => candidates.isEmpty;

  OffProductCandidate? get singleCandidate {
    if (!hasSingleCandidate) return null;
    return candidates.first;
  }
}

class BarcodeScanPage extends ConsumerStatefulWidget {
  const BarcodeScanPage({super.key});

  static Future<BarcodeLookupResult?> open(BuildContext context) {
    return Navigator.of(context).push<BarcodeLookupResult>(
      MaterialPageRoute(builder: (_) => const BarcodeScanPage()),
    );
  }

  @override
  ConsumerState<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends ConsumerState<BarcodeScanPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: <BarcodeFormat>[
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.itf,
    ],
  );

  bool _isResolving = false;
  bool _isRestarting = false;
  String? _lastBarcode;
  String? _lookupError;
  String? _noResultBarcode;

  @override
  void dispose() {
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isResolving) return;

    final barcode = _extractBarcode(capture);
    if (barcode == null) return;
    final genericErrorMessage = AppLocalizations.of(context)!.errorOccurred;

    setState(() {
      _isResolving = true;
      _lookupError = null;
      _lastBarcode = barcode;
      _noResultBarcode = null;
    });

    unawaited(_scannerController.stop());

    try {
      final candidates = await ref
          .read(openFoodFactsService)
          .lookupByBarcode(barcode);
      if (!mounted) return;

      if (candidates.isEmpty) {
        setState(() {
          _isResolving = false;
          _noResultBarcode = barcode;
        });
        return;
      }

      Navigator.of(
        context,
      ).pop(BarcodeLookupResult(barcode: barcode, candidates: candidates));
    } on OpenFoodFactsException catch (e) {
      await _handleLookupFailure(e.message);
    } catch (_) {
      await _handleLookupFailure(genericErrorMessage);
    }
  }

  Future<void> _handleLookupFailure(String message) async {
    if (!mounted) return;

    setState(() {
      _isResolving = false;
      _isRestarting = true;
      _lookupError = message;
    });

    try {
      await _scannerController.start();
    } catch (_) {
      // Scanner errors are rendered by the scanner widget itself.
    }

    if (!mounted) return;

    setState(() {
      _isRestarting = false;
    });
  }

  Future<void> _retryAfterError() async {
    if (_isRestarting) return;

    setState(() {
      _lookupError = null;
      _lastBarcode = null;
      _isRestarting = true;
      _noResultBarcode = null;
    });

    try {
      await _scannerController.start();
    } catch (_) {
      // Scanner errors are rendered by the scanner widget itself.
    }

    if (!mounted) return;

    setState(() {
      _isRestarting = false;
    });
  }

  Future<void> _resumeScanningAfterNoResult() async {
    if (_isRestarting) return;

    setState(() {
      _isRestarting = true;
      _noResultBarcode = null;
      _lookupError = null;
    });

    try {
      await _scannerController.start();
    } catch (_) {
      // Scanner errors are rendered by the scanner widget itself.
    }

    if (!mounted) return;
    setState(() {
      _isRestarting = false;
    });
  }

  void _finishNoResultFlow(BarcodeNoResultAction action) {
    final barcode = _noResultBarcode;
    if (barcode == null) return;
    Navigator.of(context).pop(
      BarcodeLookupResult(
        barcode: barcode,
        candidates: const <OffProductCandidate>[],
        noResultAction: action,
      ),
    );
  }

  String? _extractBarcode(BarcodeCapture capture) {
    for (final code in capture.barcodes) {
      final raw = code.rawValue?.trim();
      if (raw != null && raw.isNotEmpty) {
        return raw;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final caloriesTheme = CaloriesTheme.of(context);
    final hasNoResultState = _noResultBarcode != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.caloriesBarcodeScan),
        actions: [
          BarcodeScanTorchButton(controller: _scannerController),
          BarcodeScanSwitchCameraButton(controller: _scannerController),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _scannerController, onDetect: _onDetect),
          if (!hasNoResultState) const BarcodeScanGuideOverlay(),
          if (!hasNoResultState)
            Positioned(
              left: caloriesTheme.pagePadding.left,
              right: caloriesTheme.pagePadding.right,
              bottom: caloriesTheme.pagePadding.bottom,
              child: BarcodeScanStatusCard(
                headline: l10n.caloriesBarcodeScan,
                detail: _lookupError ?? _lastBarcode,
                isError: _lookupError != null,
                retryLabel: l10n.retry,
                onRetry: _lookupError == null ? null : _retryAfterError,
              ),
            ),
          if (hasNoResultState)
            BarcodeNoResultOverlay(
              barcode: _noResultBarcode!,
              title: l10n.noAvailableProducts,
              manualLabel: l10n.caloriesManualEntry,
              ocrLabel: '${l10n.imageFromCamera} OCR',
              retryLabel: l10n.retry,
              onManualEntry: () =>
                  _finishNoResultFlow(BarcodeNoResultAction.manualEntry),
              onOcrEntry: () =>
                  _finishNoResultFlow(BarcodeNoResultAction.ocrFromCamera),
              onRetryScan: _resumeScanningAfterNoResult,
            ),
          if (_isResolving || _isRestarting)
            BarcodeScanBusyOverlay(label: l10n.loading),
        ],
      ),
    );
  }
}

class BarcodeScanGuideOverlay extends StatelessWidget {
  const BarcodeScanGuideOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final frameWidth = constraints.maxWidth * 0.72;
          final frameHeight = frameWidth * 0.56;

          return Center(
            child: Container(
              width: frameWidth,
              height: frameHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BarcodeScanStatusCard extends StatelessWidget {
  final String headline;
  final String? detail;
  final bool isError;
  final String retryLabel;
  final VoidCallback? onRetry;

  const BarcodeScanStatusCard({
    super.key,
    required this.headline,
    required this.detail,
    required this.isError,
    required this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface.withValues(alpha: 0.92);

    return Card(
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(headline, style: Theme.of(context).textTheme.titleSmall),
            if (detail != null) ...[
              const SizedBox(height: 6),
              Text(
                detail!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isError
                      ? colorScheme.error
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: onRetry, child: Text(retryLabel)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BarcodeScanBusyOverlay extends StatelessWidget {
  final String label;

  const BarcodeScanBusyOverlay({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BarcodeNoResultOverlay extends StatelessWidget {
  final String barcode;
  final String title;
  final String manualLabel;
  final String ocrLabel;
  final String retryLabel;
  final VoidCallback onManualEntry;
  final VoidCallback onOcrEntry;
  final VoidCallback onRetryScan;

  const BarcodeNoResultOverlay({
    super.key,
    required this.barcode,
    required this.title,
    required this.manualLabel,
    required this.ocrLabel,
    required this.retryLabel,
    required this.onManualEntry,
    required this.onOcrEntry,
    required this.onRetryScan,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    barcode,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onOcrEntry,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(ocrLabel),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onManualEntry,
                    icon: const Icon(Icons.edit_note_outlined),
                    label: Text(manualLabel),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: onRetryScan, child: Text(retryLabel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BarcodeScanTorchButton extends StatelessWidget {
  final MobileScannerController controller;

  const BarcodeScanTorchButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, child) {
        final isOn = state.torchState == TorchState.on;
        return IconButton(
          onPressed: state.torchState == TorchState.unavailable
              ? null
              : () => controller.toggleTorch(),
          icon: Icon(isOn ? Icons.flash_on : Icons.flash_off),
        );
      },
    );
  }
}

class BarcodeScanSwitchCameraButton extends StatelessWidget {
  final MobileScannerController controller;

  const BarcodeScanSwitchCameraButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => controller.switchCamera(),
      icon: const Icon(Icons.cameraswitch_outlined),
    );
  }
}
