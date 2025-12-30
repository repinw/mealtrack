import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/scanner/data/receipt_parser.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'receipt_repository.g.dart';

@riverpod
ReceiptRepository receiptRepository(Ref ref) {
  return ReceiptRepository(
    firebaseAiService: ref.watch(firebaseAiServiceProvider),
  );
}

/// Repository for handling receipt scanning and analysis.
/// Coordinates between Firebase AI service and data parsing.
class ReceiptRepository {
  final FirebaseAiService _firebaseAiService;

  ReceiptRepository({required FirebaseAiService firebaseAiService})
    : _firebaseAiService = firebaseAiService;

  /// Analyzes an image receipt and returns parsed fridge items.
  Future<List<FridgeItem>> analyzeReceipt(XFile imageFile) async {
    try {
      debugPrint('Repository: Starting receipt analysis from image');
      final jsonResponse = await _firebaseAiService.analyzeImageWithGemini(
        imageFile,
      );
      final items = parseScannedItemsFromJson(jsonResponse);
      debugPrint(
        'Repository: Successfully parsed ${items.length} items from receipt',
      );
      return items;
    } catch (e) {
      debugPrint('Repository: Error analyzing receipt from image: $e');
      rethrow;
    }
  }

  /// Analyzes a PDF receipt and returns parsed fridge items.
  Future<List<FridgeItem>> analyzePdfReceipt(XFile pdfFile) async {
    try {
      debugPrint('Repository: Starting receipt analysis from PDF');
      final jsonResponse = await _firebaseAiService.analyzePdfWithGemini(
        pdfFile,
      );
      final items = parseScannedItemsFromJson(jsonResponse);
      debugPrint(
        'Repository: Successfully parsed ${items.length} items from PDF receipt',
      );
      return items;
    } catch (e) {
      debugPrint('Repository: Error analyzing receipt from PDF: $e');
      rethrow;
    }
  }
}
