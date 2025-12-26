import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
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
        // Arrange
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

        // Act & Assert
        expect(
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

    test('analyzeImageWithGemini calls compression before analyzing', () async {
      // Arrange
      service = FirebaseAiService(
        imageCompressor: mockImageCompressor,
        remoteConfig: mockRemoteConfig,
      );

      // Force config read to fail to stop BEFORE model call
      when(
        () => mockRemoteConfig.getString("template_id"),
      ).thenThrow(Exception("Config reached"));

      // Act & Assert
      expect(
        () => service.analyzeImageWithGemini(mockXFile),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Config reached'),
          ),
        ),
      );

      // Verify compression was called
      verify(
        () => mockImageCompressor.compressWithFile(
          any(),
          minWidth: any(named: 'minWidth'),
          minHeight: any(named: 'minHeight'),
          quality: any(named: 'quality'),
          format: any(named: 'format'),
        ),
      ).called(1);
    });

    test(
      'analyzeImageWithGemini Error Path: throws Exception when template_id is empty',
      () async {
        // Arrange
        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        // Mock Remote Config to return empty string
        when(() => mockRemoteConfig.getString("template_id")).thenReturn("");

        // Act & Assert
        expect(
          () => service.analyzeImageWithGemini(mockXFile),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains("Remote Config 'template_id' is empty"),
            ),
          ),
        );

        // Verify we checked the ID
        verify(() => mockRemoteConfig.getString("template_id")).called(1);
      },
    );

    test(
      'analyzeImageWithGemini Happy Path: reads template_id (but fails on model execution in test)',
      () async {
        // Arrange
        const templateId = 'valid_template_id';

        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        // Mock Remote Config
        when(
          () => mockRemoteConfig.getString("template_id"),
        ).thenReturn(templateId);

        // Since we can't mock FirebaseAI.vertexAI() static call easily without wrapper,
        // and we don't have a initialized FirebaseApp in test,
        // we expect it to fail with a core error (e.g. [core/no-app] or similar)
        // or a network error if it tries to connect.
        // We essentially just verify that it PASSED the "empty check".

        try {
          await service.analyzeImageWithGemini(mockXFile);
        } catch (e) {
          // We expect an error here, but NOT "Remote Config 'template_id' is empty".
          expect(
            e.toString(),
            isNot(contains("Remote Config 'template_id' is empty")),
          );
          // It might be "No Firebase App" or "MethodChannel" error.
        }

        // Assert
        verify(() => mockRemoteConfig.getString("template_id")).called(1);
      },
    );
  });
}
