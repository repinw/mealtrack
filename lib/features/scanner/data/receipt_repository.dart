import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/scanner/data/receipt_parser.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'receipt_repository.g.dart';

// coverage:ignore-start
// Riverpod provider - tested via integration tests, mocked in unit tests
@riverpod
ReceiptRepository receiptRepository(Ref ref) {
  return ReceiptRepository(
    firebaseAiService: ref.watch(firebaseAiServiceProvider),
  );
}
// coverage:ignore-end

class ReceiptRepository {
  final FirebaseAiService _firebaseAiService;

  ReceiptRepository({required FirebaseAiService firebaseAiService})
    : _firebaseAiService = firebaseAiService;

  Future<List<FridgeItem>> analyzeReceipt(XFile imageFile) {
    return _analyzeContent(
      file: imageFile,
      sourceType: 'image',
      analysisFunction: _firebaseAiService.analyzeImageWithGemini,
    );
  }

  Future<List<FridgeItem>> analyzePdfReceipt(XFile pdfFile) {
    return _analyzeContent(
      file: pdfFile,
      sourceType: 'PDF',
      analysisFunction: _firebaseAiService.analyzePdfWithGemini,
    );
  }

  Future<List<FridgeItem>> _analyzeContent({
    required XFile file,
    required String sourceType,
    required Future<String> Function(XFile) analysisFunction,
  }) async {
    try {
      debugPrint('Repository: Starting receipt analysis from $sourceType');
      final jsonResponse = await analysisFunction(file);
      final items = parseScannedItemsFromJson(jsonResponse);
      debugPrint(
        'Repository: Successfully parsed ${items.length} items from $sourceType receipt',
      );
      return items;
    } catch (e) {
      debugPrint('Repository: Error analyzing receipt from $sourceType: $e');
      rethrow;
    }
  }
}
