import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mealtrack/features/scanner/service/image_compressor.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MockImageCompressor extends Mock implements ImageCompressor {}

class MockFirebaseRemoteConfig extends Mock
    implements FirebaseRemoteConfig {} // Mock class

class MockXFile extends Mock implements XFile {}

void main() {
  setUpAll(() {
    registerFallbackValue(CompressFormat.jpeg);
  });

  group('FirebaseAiService', () {
    late FirebaseAiService service;
    late MockImageCompressor mockImageCompressor;
    late MockFirebaseRemoteConfig mockRemoteConfig; // variable
    late MockXFile mockXFile;

    setUp(() {
      mockImageCompressor = MockImageCompressor();
      mockRemoteConfig = MockFirebaseRemoteConfig(); // init
      service = FirebaseAiService(
        imageCompressor: mockImageCompressor,
        remoteConfig: mockRemoteConfig, // inject
      );
      mockXFile = MockXFile();
      when(() => mockXFile.path).thenReturn('test/path/image.jpg');
    });

    // Note: We cannot easily mock FirebaseRemoteConfig.instance as it's static/singleton.
    // Ideally, we would wrap it too, but for this specific request "Error Handling" of image compression,
    // we can test the compression failure before RemoteConfig is even used in analyzeImageWithGemini.

    test(
      'analyzeImageWithGemini throws Exception when compression returns null',
      () async {
        // Arrange
        when(
          () => mockImageCompressor.compressWithFile(
            any(),
            minWidth: any(named: 'minWidth'),
            minHeight: any(named: 'minHeight'),
            quality: any(named: 'quality'),
            format: any(named: 'format'),
          ),
        ).thenAnswer((_) async => null);

        when(() => mockXFile.length()).thenAnswer((_) async => 1000);

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
  });
}
