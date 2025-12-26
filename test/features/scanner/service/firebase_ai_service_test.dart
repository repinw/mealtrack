import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
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
      'analyzeImageWithGemini throws Exception when compression returns null',
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
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Image compression failed'),
            ),
          ),
        );
      },
    );

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
      'analyzeImageWithGemini Error Path: throws ReceiptAnalysisException when template_id is empty',
      () async {
        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        when(() => mockRemoteConfig.getString("template_id")).thenReturn("");

        await expectLater(
          () => service.analyzeImageWithGemini(mockXFile),
          throwsA(
            isA<ReceiptAnalysisException>().having(
              (e) => e.message,
              'message',
              contains("empty"),
            ),
          ),
        );

        verify(() => mockRemoteConfig.getString("template_id")).called(1);
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
  });
}
