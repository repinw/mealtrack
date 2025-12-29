import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/data/receipt_repository.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAiService extends Mock implements FirebaseAiService {}

class MockXFile extends Mock implements XFile {}

void main() {
  late ReceiptRepository repository;
  late MockFirebaseAiService mockAiService;
  late MockXFile mockFile;

  setUp(() {
    mockAiService = MockFirebaseAiService();
    repository = ReceiptRepository(firebaseAiService: mockAiService);
    mockFile = MockXFile();
  });

  group('ReceiptRepository', () {
    const validJson = '''
      {
        "items": [
          {
            "n": "Test Item",
            "s": "Test Store",
            "p": 1.99,
            "q": 1
          }
        ]
      }
    ''';

    group('analyzeReceipt', () {
      test('analyzeReceipt returns parsed items on success', () async {
        when(
          () => mockAiService.analyzeImageWithGemini(mockFile),
        ).thenAnswer((_) async => validJson);

        final items = await repository.analyzeReceipt(mockFile);

        expect(items.length, 1);
        expect(items.first.name, 'Test Item');
        verify(() => mockAiService.analyzeImageWithGemini(mockFile)).called(1);
      });

      test(
        'analyzeReceipt rethrows ReceiptAnalysisException from service',
        () async {
          final exception = ReceiptAnalysisException('AI Error');
          when(
            () => mockAiService.analyzeImageWithGemini(mockFile),
          ).thenThrow(exception);

          expect(
            () => repository.analyzeReceipt(mockFile),
            throwsA(
              isA<ReceiptAnalysisException>().having(
                (e) => e.message,
                'message',
                'AI Error',
              ),
            ),
          );
        },
      );

      test(
        'analyzeReceipt throws ReceiptAnalysisException on invalid JSON',
        () async {
          when(
            () => mockAiService.analyzeImageWithGemini(mockFile),
          ).thenAnswer((_) async => "Invalid JSON Response");

          await expectLater(
            repository.analyzeReceipt(mockFile),
            throwsA(isA<ReceiptAnalysisException>()),
          );
        },
      );
    });

    group('analyzePdfReceipt', () {
      test('analyzePdfReceipt returns parsed items on success', () async {
        when(
          () => mockAiService.analyzePdfWithGemini(mockFile),
        ).thenAnswer((_) async => validJson);

        final items = await repository.analyzePdfReceipt(mockFile);

        expect(items.length, 1);
        expect(items.first.name, 'Test Item');
        verify(() => mockAiService.analyzePdfWithGemini(mockFile)).called(1);
      });

      test(
        'analyzePdfReceipt rethrows ReceiptAnalysisException from service',
        () async {
          final exception = ReceiptAnalysisException('AI PDF Error');
          when(
            () => mockAiService.analyzePdfWithGemini(mockFile),
          ).thenThrow(exception);

          expect(
            () => repository.analyzePdfReceipt(mockFile),
            throwsA(
              isA<ReceiptAnalysisException>().having(
                (e) => e.message,
                'message',
                'AI PDF Error',
              ),
            ),
          );
        },
      );

      test(
        'analyzePdfReceipt throws ReceiptAnalysisException on invalid JSON',
        () async {
          when(
            () => mockAiService.analyzePdfWithGemini(mockFile),
          ).thenAnswer((_) async => "Invalid JSON from PDF");

          await expectLater(
            repository.analyzePdfReceipt(mockFile),
            throwsA(isA<ReceiptAnalysisException>()),
          );
        },
      );
    });
  });
}
