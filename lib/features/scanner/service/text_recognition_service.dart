import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:mealtrack/features/scanner/data/receipt_parser.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';

class TextRecognitionService {
  final FirebaseAiService _firebaseAiService;
  final ImagePicker _picker;
  final List<ScannedItem> Function(String) _parser;

  TextRecognitionService({
    FirebaseAiService? firebaseAiService,
    ImagePicker? picker,
    List<ScannedItem> Function(String)? parser,
  }) : _firebaseAiService = firebaseAiService ?? FirebaseAiService(),
       _picker = picker ?? ImagePicker(),
       _parser = parser ?? parseScannedItemsFromJson;

  Future<List<ScannedItem>> processImage(XFile? image) async {
    if (image == null) return List.empty();

    final responseJson = await _firebaseAiService.analyzeImageWithGemini(image);

    return _parser(responseJson);
  }
}
