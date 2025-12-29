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
