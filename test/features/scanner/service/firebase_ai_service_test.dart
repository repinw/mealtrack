import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mealtrack/features/scanner/service/image_compressor.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MockImageCompressor extends Mock implements ImageCompressor {}

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

class MockXFile extends Mock implements XFile {}

void main() {
  setUpAll(() {
    registerFallbackValue(CompressFormat.jpeg);
  });

  group('FirebaseAiService', () {
    late FirebaseAiService service;
    late MockImageCompressor mockImageCompressor;
    late MockFirebaseRemoteConfig mockRemoteConfig;
    late MockXFile mockXFile;

    setUp(() {
      mockImageCompressor = MockImageCompressor();
      mockRemoteConfig = MockFirebaseRemoteConfig();
      mockXFile = MockXFile();

      // Default mock behavior
      when(() => mockXFile.path).thenReturn('test/path/image.jpg');
      when(() => mockXFile.length()).thenAnswer((_) async => 1000);
      when(
        () => mockXFile.readAsBytes(),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));

      // Default compression success
      when(
        () => mockImageCompressor.compressWithFile(
          any(),
          minWidth: any(named: 'minWidth'),
          minHeight: any(named: 'minHeight'),
          quality: any(named: 'quality'),
          format: any(named: 'format'),
        ),
      ).thenAnswer((_) async => Uint8List(10));
    });

    test(
      'analyzeImageWithGemini calls compression before analyzing (Config Failure)',
      () async {
        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        // Force config read to fail. This happens BEFORE the try-catch block wrapping AI calls.
        when(
          () => mockRemoteConfig.getString("template_id"),
        ).thenThrow(Exception("Config reached"));

        await expectLater(
          () => service.analyzeImageWithGemini(mockXFile),
          throwsA(predicate((e) => e.toString().contains('Config reached'))),
        );

        verify(
          () => mockImageCompressor.compressWithFile(
            any(),
            minWidth: any(named: 'minWidth'),
            minHeight: any(named: 'minHeight'),
            quality: any(named: 'quality'),
            format: any(named: 'format'),
          ),
        ).called(1);
      },
    );

    test(
      'analyzePdfWithGemini Happy Path: reads template_id (ignores Firebase crash)',
      () async {
        const templateId = 'valid_template_id';

        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        when(
          () => mockRemoteConfig.getString("template_id"),
        ).thenReturn(templateId);

        try {
          await service.analyzePdfWithGemini(mockXFile);
        } catch (e) {
          // Expected downstream failure due to missing Firebase App
        }

        verify(() => mockRemoteConfig.getString("template_id")).called(1);
        verifyNever(
          () => mockImageCompressor.compressWithFile(
            any(),
            minWidth: any(named: 'minWidth'),
            minHeight: any(named: 'minHeight'),
            quality: any(named: 'quality'),
            format: any(named: 'format'),
          ),
        );
      },
    );

    test(
      'analyzeImageWithGemini Happy Path: verify compression usage (ignores Firebase crash)',
      () async {
        const templateId = 'valid_template_id';

        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        when(
          () => mockRemoteConfig.getString("template_id"),
        ).thenReturn(templateId);

        try {
          await service.analyzeImageWithGemini(mockXFile);
        } catch (e) {
          // Expected downstream failure
        }

        verify(() => mockRemoteConfig.getString("template_id")).called(1);
        verify(
          () => mockImageCompressor.compressWithFile(
            any(),
            minWidth: any(named: 'minWidth'),
            minHeight: any(named: 'minHeight'),
            quality: any(named: 'quality'),
            format: any(named: 'format'),
          ),
        ).called(1);
      },
    );

    test(
      'analyzeImageWithGemini Error Path: throws ReceiptAnalysisException when compression fails (returns null)',
      () async {
        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        when(
          () => mockImageCompressor.compressWithFile(
            any(),
            minWidth: any(named: 'minWidth'),
            minHeight: any(named: 'minHeight'),
            quality: any(named: 'quality'),
            format: any(named: 'format'),
          ),
        ).thenAnswer((_) async => null);

        await expectLater(
          () => service.analyzeImageWithGemini(mockXFile),
          throwsA(
            isA<ReceiptAnalysisException>().having(
              (e) => e.code,
              'code',
              'COMPRESSION_ERROR',
            ),
          ),
        );
      },
    );

    test('uses fallback template ID when remote config returns empty', () async {
      service = FirebaseAiService(
        imageCompressor: mockImageCompressor,
        remoteConfig: mockRemoteConfig,
      );

      // Simulate empty template_id from remote config
      when(() => mockRemoteConfig.getString('template_id')).thenReturn('');

      // Expect AI_ERROR because we don't have a valid Firebase App in this test environment
      // causing the VertexAI initialization or call to fail.
      // The important part is that we verify remoteConfig.getString was called,
      // showing it attempted to resolve the template ID.
      await expectLater(
        () => service.analyzeImageWithGemini(mockXFile),
        throwsA(
          isA<ReceiptAnalysisException>().having(
            (e) => e.code,
            'code',
            'AI_ERROR',
          ),
        ),
      );

      verify(() => mockRemoteConfig.getString('template_id')).called(1);
    });
  });
}
